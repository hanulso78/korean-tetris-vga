/* ============================================================================
 *  KOREA  -  (C) 1990 PARK S.G.
 * ----------------------------------------------------------------------------
 *  KOREA.EXE (83,332 바이트, 1990-03-22) 를 역어셈블해서 C 로 옮긴 것.
 *
 *  원본은 볼랜드 터보 C 2.0 small 모델 16비트 DOS 프로그램이다.
 *  실행 파일 구조 (MZ 헤더 0x200 바이트 뒤 이미지 기준)
 *      0000..01BB   C0.OBJ 시작 코드
 *      01BC..3BA4   게임 코드 (소스 7개)                        <- 이 소스들
 *                     01BC KOR-BGM.C   023D KOR-TIT.C   047B KOR-STG.C
 *                     0E83 KOR-GRP.C   168C KOR-INT.C   239A KOR-SUB.C
 *                     3A58 KOREA.C
 *      3BA5..       터보 C 런타임 (printf, open, rand, sound ...)
 *      6240         데이터 세그먼트 DGROUP (seg 0624)
 *      파일 0xF946  터보 디버거 심볼 정보 (이름/형/줄 번호)
 *
 *  원본 소스 파일            ->  이 판
 *      KOREA.C    main          korea.c   (전역 변수도 여기)
 *      KOR-BGM.C  배경음악       music.c   (KOREA.EXE,    PC 스피커)
 *                                musvgm.c  (KOREAVGA.EXE, 애드립 VGM - 새로 씀)
 *      KOR-TIT.C  첫 메뉴        menu.c
 *      KOR-STG.C  스테이지 편집기 editor.c
 *      KOR-GRP.C  화면/글자 출력  text.c    (글자 출력, 창 스크롤)
 *                                vidmono.c (KOREA.EXE,    허큘리스 흉내 -> VGA)
 *                                vid256.c  (KOREAVGA.EXE, VESA 256색 - 새로 씀)
 *      KOR-INT.C  게임 상태 처리  game.c
 *      KOR-SUB.C  보조 함수들     system.c (파일/키보드/시계)
 *                                 board.c  (판/점수판/아이템)
 *      (DGROUP 초기값)            data.c
 *
 *  djgpp(32비트 보호모드)로 옮기면서 바뀐 것
 *      - 화면: 원본이 화면 메모리를 직접 만지던 곳을 화면 백엔드 함수로 모았다
 *        (korea.h).  KOREA.EXE 는 허큘리스 640x400 화면 메모리를 흉내 낸
 *        버퍼에 원본과 똑같이 그려 VGA 640x480 에 옮기고, KOREAVGA.EXE 는
 *        색칠한 스프라이트로 VESA 256색 화면에 그린다.
 *      - 키보드/시계: 원본처럼 BIOS 데이터 영역(0040:001A, 0040:006C)을
 *        _farpeek/_farpoke 로 직접 읽고 쓴다.
 *      - rand / sound: 터보 C 런타임과 똑같이 동작하도록 따로 만들었다.
 *      - 스테이지 번호가 100을 넘으면 원본은 표 밖을 읽었다 -> 100으로 나눈다.
 *      - KOREAVGA.EXE 만: 메뉴/게임/스테이지 깸/게임 끝에서 곡을 바꾼다
 *        (music_play).  KOREA.EXE 에서는 아무 일도 하지 않는다.
 *
 *  조작 (원본 그대로)
 *      메뉴     : 위/아래 또는 1/2, Enter/Space 선택, ESC 끝
 *      게임     : 왼쪽/오른쪽 이동, 아래 한 칸 내리기,
 *                 숫자판 5 회전 (위 화살표로도 - 원본에 없던 것),
 *                 Space 바닥까지 떨어뜨리기(아이템이면 발사),
 *                 F1 배경음악 켜기/끄기, ESC 끝
 * ========================================================================== */

#include <stdio.h>
#include <stdlib.h>

#include "korea.h"

/* ============================ 전역 변수 =====================================
   원래 이름과 DS 오프셋은 korea.h 선언 옆에 적어 두었다. */

int            game_state;
int            state_step;
int            option_bits;

int            cur_x, cur_y;
int            win_left, win_top, win_right, win_bottom;

unsigned char  board[BOARD_ROWS][BOARD_COLS];
unsigned char  drawn_board[MAP_ROWS * MAP_COLS];
unsigned char  edit_clipboard[MAP_ROWS][MAP_COLS];

unsigned char  stage_map[STAGE_COUNT][MAP_ROWS][MAP_COLS];
int            stage_fall_delay[STAGE_COUNT];
int            stage_item[STAGE_COUNT];
int            stage_gimmick[STAGE_COUNT];
int            stage_bonus[STAGE_COUNT];
int            stage_gimmick_time[STAGE_COUNT];

int            piece_queue[3];
int            piece_x, piece_y;
int            prev_piece_x, prev_piece_y;
int            piece_rot, prev_piece_rot;

signed char    stage_no;
long           score;
long           hi_score[10];
int            lives;
int            anim_tick;

int            fall_count;
int            fall_delay;
int            speed_seconds;
int            frame_ms;
int            bonus_left;
int            gimmick_timer;
int            lock_count;
int            hard_dropped;
int            item_x, item_y;
int            item_help;
unsigned char  item_blink;
int            stack_height;

int            bgm_freq, bgm_wait, bgm_pos, bgm_song;

/* ---------------------------------------------------------------------------
 *  원래: main  (KOREA.C:121, 3A58)
 *  상태 번호(game_state)에 따라 할 일을 한 번씩 부르는 무한 루프.
 *  메뉴와 편집기가 아니면 매번 판/점수판을 다시 그리고 시계 한 틱을 기다린다.
 * ------------------------------------------------------------------------- */
int main(void)
{
    if (load_font()) {
        printf("Not found \"%s\" image data file.\n", font_file_name);
        exit(1);
    }
    if (load_stages()) {
        printf("Not found \"KOREA.STG\" stage data file.\n");
        exit(1);
    }
    video_init();
    music_init();                           /* (새로 넣음) */

    game_state = ST_MENU;
    win_left = win_top = 0;
    win_right  = SCREEN_COLS;
    win_bottom = SCREEN_ROWS + 1;

    for (;;) {
        switch (game_state) {
        case ST_NEW_GAME:       state_new_game();       break;
        case ST_START_STAGE:    state_start_stage();    break;
        case ST_SPAWN_PIECE:    state_spawn_piece();    break;
        case ST_MOVE_PIECE:     state_move_piece();     break;
        case ST_MOVE_ITEM:      state_move_item();      break;
        case ST_LOCK_PIECE:     state_lock_piece();     break;
        case ST_CHECK_LINES:    state_check_lines();    break;
        case ST_FLASH_LINES:    state_flash_lines();    break;
        case ST_COLLAPSE_LINES: state_collapse_lines(); break;
        case ST_CHECK_TARGETS:  state_check_targets();  break;
        case ST_GIMMICK:        state_gimmick();        break;
        case ST_LOSE_LIFE:      state_lose_life();      break;
        case ST_GAME_OVER:      state_game_over();      break;
        case ST_STAGE_CLEAR:    state_stage_clear();    break;
        case ST_CLEAR_ANIM:     state_clear_anim();     break;

        case ST_MENU:   main_menu();    continue;
        case ST_EDITOR: stage_editor(); continue;
        }
        draw_board();
        update_status();
        wait_tick();
    }
}
