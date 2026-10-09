/* ============================================================================
 *  korea.h  -  KOREA (1990, PARK S.G.) 공용 선언
 * ----------------------------------------------------------------------------
 *  KOREA.EXE 는 터보 C 2.0 (small 모델) 로 만든 16비트 DOS 게임이다.
 *  실행 파일 뒤에 터보 디버거 심볼 정보가 붙어 있어서 원래 소스 파일 이름
 *  (KOREA.C, KOR-BGM.C, KOR-TIT.C, KOR-STG.C, KOR-GRP.C, KOR-INT.C, KOR-SUB.C),
 *  함수/전역변수/지역변수 이름, 소스 줄 번호까지 알 수 있었다.
 *
 *  이 C 소스에서는 이름을 하는 일에 맞게 새로 붙였다.  원래 이름은 아래
 *  선언마다 주석으로 남겼고, 각 함수 위에도 "원래: 이름 (파일:줄, 코드 오프셋)"
 *  으로 적어 두었다.
 *
 *  게임 개요 - 테트리스 형식.
 *      판은 가로 10칸(열 3..12) x 세로 23칸(행 0..22), 위 3줄(0..2)은 안 보인다.
 *      판 곳곳에 "사람"(칸 값 0x6F)이 갇혀 있고, 줄을 지워서 사람을 모두
 *      구하면(판에서 0x6F 가 사라지면) 스테이지를 깬다.
 *      가끔 블록 대신 아이템(로켓 두 가지, 폭탄, 레이저, 터보)이 떨어진다.
 *      스테이지마다 정해진 시간이 되면 판이 옆으로 밀리거나 벽돌이 생기는 등의
 *      "기믹"(원래 이름 option)이 일어난다.  스테이지 100개는 KOREA.STG 에 있고
 *      편집기로 고칠 수 있다.
 *
 *  화면 - 원본은 허큘리스(640x400 흑백, 16x16 글자 40x25)와
 *         CGA(320x200 4색, 8x8 글자) 둘을 지원했고, 게임 코드 곳곳에서
 *         화면 메모리를 직접 만졌다.  이 판에서는 그런 곳을 모두 아래
 *         "화면 백엔드" 함수로 바꿔서 백엔드 두 가지 중 하나를 링크한다.
 *             vidmono.c  허큘리스 화면 그대로 (VGA 640x480 흑백)  -> KOREA.EXE
 *             vid256.c   VESA 256색, 색칠한 스프라이트        -> KOREAVGA.EXE
 * ========================================================================== */
#ifndef KOREA_H
#define KOREA_H

/* ---- 크기 ------------------------------------------------------------------ */
#define SCREEN_COLS     40          /* 글자 단위 화면 크기 */
#define SCREEN_ROWS     25
#define SCREEN_W        640         /* 허큘리스 화면 픽셀 */
#define SCREEN_H        400
#define BYTES_PER_LINE  80          /* 1bpp, 한 줄 80바이트 */

#define BOARD_ROWS      26          /* board[행][열] */
#define BOARD_COLS      16
#define FIELD_TOP       3           /* 화면에 보이는 첫 행 */
#define FIELD_BOTTOM    22          /* 마지막 행 */
#define FIELD_LEFT      3           /* 첫 열 */
#define FIELD_RIGHT     12          /* 마지막 열 */
#define FIELD_X         8           /* 게임 화면에서 판 열 -> 화면 x 차이 (열3 = x11) */

#define STAGE_COUNT     100         /* KOREA.STG 안의 스테이지 수 */
#define MAP_ROWS        20          /* 스테이지 지도 = 보이는 판 20x10 */
#define MAP_COLS        10

#define PIECE_KINDS     12          /* 보통 블록 7 + 아이템 5 */
#define ITEM_FIRST      7           /* 7 이상이면 아이템 */

/* ---- 판 칸 값 --------------------------------------------------------------- */
#define CELL_EMPTY      0x00
/*      0x01..0x10  떨어지는 중인 블록 (piece_shape 값)                         */
#define CELL_SOLID_MIN  0x11        /* 이 값 이상이면 부딪힌다                  */
#define CELL_FLASH      0x12        /* 지워지는 줄 반짝임 시작 (0x12..0x19)      */
#define CELL_FLASH_END  0x19
#define CELL_LOCKED     0x60        /* 굳은 블록 = 블록 글자 + 0x60             */
#define CELL_ITEM_BLOCK 0x6E        /* 아이템이 남긴 벽돌                        */
#define CELL_TARGET     0x6F        /* 구해야 할 사람                            */
#define CELL_WALL       0x7F
#define CELL_LOSE_EMPTY 0x8B        /* 목숨을 잃을 때 판을 덮는 무늬             */
#define CELL_LOSE_FULL  0x8C
#define CELL_CLEAR_ANIM 0xF5        /* 스테이지를 깼을 때 사라지는 무늬 (0xF5..)  */

/* ---- 게임 상태 (원래 flag) ---------------------------------------------------- */
enum {
    ST_NEW_GAME       = 2,          /* game_start_init   */
    ST_START_STAGE    = 3,          /* stage_init        */
    ST_SPAWN_PIECE    = 6,          /* get_stick         */
    ST_MOVE_PIECE     = 20,         /* run_stick         */
    ST_MOVE_ITEM      = 23,         /* run_power         */
    ST_LOCK_PIECE     = 26,         /* stage_stick_set   */
    ST_CHECK_LINES    = 30,         /* stick_clear_check */
    ST_FLASH_LINES    = 31,         /* stick_clear_sub1  */
    ST_COLLAPSE_LINES = 33,         /* stick_clear_sub2  */
    ST_CHECK_TARGETS  = 40,         /* screen_up_check   */
    ST_GIMMICK        = 50,         /* run_option        */
    ST_LOSE_LIFE      = 60,         /* subtract_stick    */
    ST_GAME_OVER      = 66,         /* game_over         */
    ST_STAGE_CLEAR    = 80,         /* screen_clear_up   */
    ST_CLEAR_ANIM     = 83,         /* screen_up_sub     */
    ST_MENU           = 100,        /* game_title        */
    ST_EDITOR         = 200         /* user_stage        */
};

/* option_bits (원래 information) - F1..F4 로 켜고 끈다.  0비트만 쓰인다 */
#define OPT_MUSIC       0x01

/* 스캔 코드 */
#define SC_ESC   0x01
#define SC_1     0x02
#define SC_2     0x03
#define SC_ENTER 0x1C
#define SC_SPACE 0x39
#define SC_F1    0x3B
#define SC_F2    0x3C
#define SC_F3    0x3D
#define SC_F4    0x3E
#define SC_UP    0x48
#define SC_LEFT  0x4B
#define SC_PAD5  0x4C
#define SC_RIGHT 0x4D
#define SC_DOWN  0x50

/* ============================ 전역 변수 (korea.c) =========================== */
/*                                                   원래 이름      DS 오프셋  */
extern int            game_state;                 /* flag           0FFC */
extern int            state_step;                 /* sub_flag       9229 */
extern int            option_bits;                /* information    027C */

extern int            cur_x, cur_y;               /* locx, locy     0FFE,1000 */
extern int            win_left, win_top;          /* windowx1,y1    1A64,1A66 */
extern int            win_right, win_bottom;      /* windowx2,y2    1A68,1A6A */

extern unsigned char  board[BOARD_ROWS][BOARD_COLS]; /* STAGE       18BA */
extern unsigned char  drawn_board[MAP_ROWS * MAP_COLS]; /* chk_stage 922B 화면에 그려 둔 칸 */
extern unsigned char  edit_clipboard[MAP_ROWS][MAP_COLS]; /* STORE_STAGE 17EE */

extern unsigned char  stage_map[STAGE_COUNT][MAP_ROWS][MAP_COLS]; /* screen 43DD */
extern int            stage_fall_delay[STAGE_COUNT];   /* speed      40AE */
extern int            stage_item[STAGE_COUNT];         /* power      424C */
extern int            stage_gimmick[STAGE_COUNT];      /* option     4315 */
extern int            stage_bonus[STAGE_COUNT];        /* bonus      417E */
extern int            stage_gimmick_time[STAGE_COUNT]; /* timer_chk  9301 */

extern int            piece_queue[3];             /* STICK          1A5E [2]=지금 블록 */
#define PIECE_NOW     piece_queue[2]
extern int            piece_x, piece_y;           /* korx, kory     417C,4246 */
extern int            prev_piece_x, prev_piece_y; /* korxr, koryr   4248,424A */
extern int            piece_rot;                  /* stick_img      92F7 */
extern int            prev_piece_rot;             /* stick_rimg     93CD */

extern signed char    stage_no;                   /* point          4314 (0부터) */
extern long           score;                      /* score          4176 */
extern long           hi_score[10];               /* hi_score       9201 (쓰이지 않아 늘 0) */
extern int            lives;                      /* life           20AC */
extern int            anim_tick;                  /* simul          417A 1..127 반복 */

extern int            fall_count;                 /* d_wait         91FD */
extern int            fall_delay;                 /* speed_w        92F9 */
extern int            speed_seconds;              /* speed_sec      92F5 */
extern int            frame_ms;                   /* mili_sec       91FF 틱마다 +5 */
extern int            bonus_left;                 /* bonus_w        92F3 */
extern int            gimmick_timer;              /* timer_w        92FB */
extern int            lock_count;                 /* set_wait       93C9 */
extern int            hard_dropped;               /* (새로 넣음) 이번 프레임에 Space 로 떨어뜨렸다 */
extern int            item_x, item_y;             /* power_x/y      92FD,92FF */
extern int            item_help;                  /* help_power     93D1 */
extern unsigned char  item_blink;                 /* power_simul    93D3 */
extern int            stack_height;               /* stick_power    93D4 */

extern int            bgm_freq;                   /* play_data      17E6 */
extern int            bgm_wait;                   /* play_wait      17E8 */
extern int            bgm_pos;                    /* play_point     17EA */
extern int            bgm_song;                   /* music_select   17EC */

/* ============================ 데이터 표 (data.c) ============================ */
extern const int            note_freq[44];                        /* oct_data  */
extern const signed char    bgm_score[2][200];                    /* play      */
extern const unsigned char  piece_shape[PIECE_KINDS][4][16];      /* PTN       */
extern const char           piece_caption[6][14];                 /* power_msg */
extern const char           gimmick_icon[6][7];                   /* op_msg    */
extern const char           editor_digit3[6][5];                  /* msg       */
extern const unsigned char  preview_pattern[3][8];                /* next_img  */
extern const char           menu_screen[25][41];
extern const char           editor_screen[25][41];
extern const char           play_screen[25][41];
extern const int            enhanced_rules;       /* (새로 넣음) KOREAVGA.EXE 만 1 */

/* 스테이지 번호 -> 표 첨자.  원본은 그대로 썼지만(100판 이후 표 밖을 읽음)
   여기서는 100으로 나눈 나머지를 쓴다. */
#define STAGE_IX(n)   ((unsigned char)(n) % STAGE_COUNT)

/* ============================ 음악 백엔드 (KOR-BGM.C) ======================
   music.c  원판 그대로 PC 스피커 (F1 로 켠다)       -> KOREA.EXE
   musvgm.c 애드립(OPL2) VGM 곡 (처음부터 켜져 있다) -> KOREAVGA.EXE */
enum { SONG_NONE, SONG_TITLE, SONG_GAME, SONG_CLEAR, SONG_OVER };
void music_init(void);                            /* (새로 넣음) */
void music_play(int song);                        /* (새로 넣음) 원판에서는 아무 일 없음 */
void music_poll(void);                            /* (새로 넣음) 기다리는 동안 자주 부른다 */
enum { EFFECT_BONUS_COUNT };
void music_effect(int effect);                    /* (새로 넣음) 효과음 - 원판은 PC 스피커 */
void bgm_tick(void);                              /* music_play - 시계 한 틱마다 */

/* ============================ menu.c   (KOR-TIT.C) ========================= */
void menu_select(int item);                       /* select_subrutine */
void main_menu(void);                             /* game_title */

/* ============================ editor.c (KOR-STG.C) ========================= */
void stage_editor(void);                          /* user_stage */

/* ============================ 화면 백엔드 (KOR-GRP.C) =======================
   vidmono.c 또는 vid256.c 가 만든다.  좌표 x, y 는 글자 칸(40x25). */
extern const char font_file_name[];               /* 글꼴 파일 이름 (오류 메시지용) */
int  load_font(void);                             /* chrinit */
void video_init(void);                            /* grset */
void video_shutdown(void);                        /* textset */
void video_present(void);                         /* (새로 넣음) 화면 내보내기 */
void put_glyph(int x, int y, int code);           /* putptn  (원본은 글자 주소를 받았다) */
void invert_cells(int x, int y, int w, int h);    /* (새로 넣음) 화면 바이트 XOR 0xFF */
void put_preview_cell(int col, int row, unsigned char cell); /* (새로 넣음) 미리보기 8x8 */
void copy_cell_row(int dst_row, int src_row, int x, int w);  /* (새로 넣음) 창 스크롤 */
void clear_cell_row(int row, int x, int w);
/* (새로 넣음) 떨어지는 블록을 판과 따로 그려 칸 사이를 부드럽게 옮기기.
   video_smooth_piece 가 0 이면(흑백판) 원본처럼 판에 그대로 찍는다.
   video_set_piece: key 가 같고 1~2칸만 옮겼으면 미끄러지고, 아니면 바로 옮긴다.
   key 가 -1 이면 움직이는 블록이 없다 (n 도 0).
   (col, row) 는 기준 칸(글자 좌표), 칸마다 기준에서의 거리 dx/dy 와 글자 code.
   dropped 가 참이면 Space 로 바닥까지 떨어뜨린 것 - 화면에서 떨어지는 모습을 보인다. */
int  video_smooth_piece(void);
/* (새로 넣음) 색이 있는 화면이면 1 - 첫 화면 로고를 글자마다 다른 색으로 찍는다.
   색 벽돌은 LOGO_GLYPH 부터 LOGO_COLORS 가지 (KOREA256.SPR 에만 있다) */
int  video_has_color(void);
#define LOGO_GLYPH      0x97
#define LOGO_COLORS     8
void video_set_piece(int key, int col, int row, int n,
                     const signed char *dx, const signed char *dy, const unsigned char *code,
                     int dropped);
void video_idle(void);                            /* 기다리는 동안 자주 부른다 */

/* ============================ text.c   (KOR-GRP.C) ========================= */
void scroll_window_up(void);                      /* up_scroll */
void scroll_window_down(void);                    /* down_scroll */
void clear_window(void);                          /* window_cls */
void print_text(const char *s);                   /* lprint */
void print_char(int c);                           /* cprint */
void new_line(void);                              /* crlf */
int  read_line_key(void);                         /* cinkey */
void read_line(char *buf);                        /* linkey */

/* ============================ game.c   (KOR-INT.C) ========================= */
void state_new_game(void);                        /* game_start_init */
void state_start_stage(void);                     /* stage_init */
void state_spawn_piece(void);                     /* get_stick */
void state_move_piece(void);                      /* run_stick */
void state_move_item(void);                       /* run_power */
void state_lock_piece(void);                      /* stage_stick_set */
void state_check_lines(void);                     /* stick_clear_check */
void state_flash_lines(void);                     /* stick_clear_sub1 */
void state_collapse_lines(void);                  /* stick_clear_sub2 */
void collapse_blocks(void);                       /* stick_clear_sub3 (안 쓰임) */
void state_check_targets(void);                   /* screen_up_check */
void state_gimmick(void);                         /* run_option */
void state_lose_life(void);                       /* subtract_stick */
void state_game_over(void);                       /* game_over */
void state_stage_clear(void);                     /* screen_clear_up */
void state_clear_anim(void);                      /* screen_up_sub */

/* ============================ system.c (KOR-SUB.C 앞부분) =================== */
int  load_stages(void);                           /* stage_load */
int  save_stages(void);                           /* user_stage_save */
int  get_key(int cmd);                            /* inkey */
void flush_keys(void);                            /* key_scan_init */
int  poll_key(void);                              /* key_scan */
void wait_tick(void);                             /* clock_wait */
void wait_ticks(int n);                           /* sec_wait */
void srand16(unsigned seed);                      /* 터보 C srand */
int  rand16(void);                                /* 터보 C rand (0..32767) */
void sound_on(int hz);                            /* 터보 C sound */
void sound_off(void);                             /* 터보 C nosound */

/* ============================ board.c  (KOR-SUB.C 나머지) ==================== */
void draw_play_screen(void);                      /* title */
void draw_board(void);                            /* put_stage */
void editor_draw_board(void);                     /* put_stage2 */
int  piece_collides(void);                        /* stage_check */
int  piece_landed(void);                          /* stage_down_check */
void board_add_piece(void);                       /* stage_store */
void board_remove_piece(void);                    /* stage_stick_clear */
void gimmick_shift_left(void);                    /* left_rotate */
void gimmick_shift_right(void);                   /* right_rotate */
void gimmick_add_block(void);                     /* make_point */
void gimmick_remove_block(void);                  /* erase_point */
void gimmick_raise_floor(void);                   /* up_stage */
void map_to_board(void);                          /* screen_to_stage */
void board_to_map(void);                          /* stage_to_screen */
void draw_status(void);                           /* grp_put_init */
void show_hi_score(void);                         /* put_hi_score */
void show_score(void);                            /* put_score */
void show_stage_no(void);                         /* put_stage_count */
void show_gimmick(void);                          /* put_option */
void show_speed(void);                            /* put_speed */
void show_bonus(void);                            /* put_bonus */
void show_gimmick_timer(void);                    /* put_timer */
void show_lives(void);                            /* put_life */
void put_number(int x, int y, int n);             /* grp_put1 */
void put_long_number(int x, int y, long n);       /* grp_put2 */
void update_status(void);                         /* put_data */
void draw_next_stage_preview(void);               /* next_stage_put */
void hard_drop(void);                             /* kor_y_end */
void item_fire(void);                             /* power_proc_set */
int  item_step(void);                             /* power_process */

#endif
