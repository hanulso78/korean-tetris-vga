/* ============================================================================
 *  game.c  -  게임 상태 처리  (원래 KOR-INT.C)
 * ----------------------------------------------------------------------------
 *  main 의 루프가 game_state 에 맞는 함수를 프레임마다 한 번씩 부른다.
 *
 *      MENU           -> NEW_GAME (메뉴 1) / EDITOR (메뉴 2)
 *      NEW_GAME       -> START_STAGE
 *      START_STAGE    -> SPAWN_PIECE
 *      SPAWN_PIECE    -> MOVE_PIECE (보통 블록) / MOVE_ITEM (아이템)
 *                        / LOSE_LIFE (나오자마자 막힘)
 *      MOVE_PIECE     -> LOCK_PIECE -> CHECK_LINES
 *      MOVE_ITEM      -> CHECK_LINES (효과가 끝나거나 굳으면)
 *      CHECK_LINES    -> FLASH_LINES -> COLLAPSE_LINES -> CHECK_TARGETS
 *                        / GIMMICK (지울 줄이 없으면)
 *      CHECK_TARGETS  -> STAGE_CLEAR (사람을 다 구함) / GIMMICK
 *      GIMMICK        -> SPAWN_PIECE / CHECK_LINES (기믹이 일어났으면)
 *      STAGE_CLEAR    -> CLEAR_ANIM -> START_STAGE (다음 스테이지)
 *      LOSE_LIFE      -> START_STAGE (목숨이 남음) / GAME_OVER -> MENU
 * ========================================================================== */
#include <stdlib.h>
#include <time.h>

#include "korea.h"

#define NEXT_BOX_X          1       /* NEXT 창 안쪽 */
#define LOCK_LAMP_X         38      /* 블록이 닿았는지 보여 주는 표시 */
#define LOCK_LAMP_Y         20
#define GLYPH_LOCK_LAMP     0x8B    /* 0x8B 꺼짐, 0x8C 켜짐 */
#define LOCK_TICKS          10      /* 닿은 채로 이만큼 지나면 굳는다 */

/* F1..F4 는 option_bits 의 비트를 하나씩 뒤집는다 (0비트 배경음악만 쓰인다) */
static void toggle_option(int key)
{
    switch (key) {
    case SC_F1: option_bits ^= 0x01; break;
    case SC_F2: option_bits ^= 0x02; break;
    case SC_F3: option_bits ^= 0x04; break;
    case SC_F4: option_bits ^= 0x08; break;
    }
}

/* ---------------------------------------------------------------------------
 *  원래: game_start_init  (KOR-INT.C:63, 168C)
 * ------------------------------------------------------------------------- */
void state_new_game(void)
{
    cur_x = cur_y = 0;
    draw_play_screen();

    flush_keys();
    srand16((unsigned)time(NULL));

    piece_queue[0] = rand16() % 7;
    piece_queue[1] = rand16() % 7;
    stage_no = 0;
    score = 0;
    lives = 1;
    item_blink = 0;
    anim_tick = 0;

    game_state = ST_START_STAGE;

    bgm_song = bgm_pos = bgm_freq = bgm_wait = 0;
}

/* ---------------------------------------------------------------------------
 *  원래: stage_init  (KOR-INT.C:90, 16FE)
 *  판 둘레에 벽을 두르고 스테이지 지도와 설정값을 불러온다.
 *      행 0..2   : 열 3..12 만 비고 나머지는 벽 (안 보이는 출발 자리)
 *      행 23..25 : 모두 벽 (바닥)
 *      열 0..2, 13..15 : 벽
 * ------------------------------------------------------------------------- */
void state_start_stage(void)
{
    int i, j;

    for (i = 0; i < 3; i++) {
        for (j = 0; j < BOARD_COLS; j++)
            board[i][j] = board[i + 23][j] = CELL_WALL;
        for (j = FIELD_LEFT; j <= FIELD_RIGHT; j++)
            board[i][j] = CELL_EMPTY;
    }
    for (i = 0; i <= FIELD_BOTTOM; i++)
        for (j = 0; j < 3; j++) {
            board[i][j]      = CELL_WALL;
            board[i][j + 13] = CELL_WALL;
        }

    map_to_board();

    gimmick_timer = stage_gimmick_time[STAGE_IX(stage_no)];
    fall_delay    = stage_fall_delay[STAGE_IX(stage_no)];
    bonus_left    = stage_bonus[STAGE_IX(stage_no)] * 5;

    speed_seconds = frame_ms = bgm_pos = stack_height = item_help = 0;

    draw_status();
    music_play(SONG_GAME);                  /* (새로 넣음) */
    draw_next_stage_preview();

    game_state = ST_SPAWN_PIECE;
}

/* ---------------------------------------------------------------------------
 *  원래: get_stick  (KOR-INT.C:129, 17F0)
 *  대기열을 한 칸 밀어 새 블록을 꺼낸다.
 *      새로 뽑는 블록: 50번에 49번은 보통 블록 0..4
 *                      (5, 6 번 블록은 게임을 시작할 때 말고는 안 나온다)
 *                      나머지는 아이템 - 스테이지 설정이 있으면 그것, 없으면 무작위
 *      도움 아이템   : 블록이 16개 넘게 나오는 동안 쌓인 높이가 10 을 넘으면
 *                      3번에 1번꼴로 무작위 아이템을 준다.
 *  NEXT 창에 다음 블록 두 개를 그리고, 나오자마자 부딪히면 목숨을 잃는다.
 * ------------------------------------------------------------------------- */
void state_spawn_piece(void)
{
    const unsigned char *shape;
    const char *caption;
    int top, n, row, col, kind;

    sound_on(2093);

    piece_queue[2] = piece_queue[1];
    piece_queue[1] = piece_queue[0];
    if (rand16() % 50)
        piece_queue[0] = rand16() % 5;
    else if (stage_item[STAGE_IX(stage_no)])
        piece_queue[0] = stage_item[STAGE_IX(stage_no)] + 6;
    else
        piece_queue[0] = rand16() % 5 + ITEM_FIRST;

    item_help++;
    if (item_help > 15 && stack_height > 10 && rand16() % 3 == 0) {
        kind = rand16() % 5;
        piece_queue[0] = kind + ITEM_FIRST;
        item_help = item_help > 5 ? item_help - 5 : 0;
    }

    /* NEXT 창: piece_queue[0] 은 행 9, [1] 은 행 6 부터 2행 x 4열 */
    for (top = 9, n = 0; top > 5; top -= 3, n++) {
        shape = piece_shape[piece_queue[n]][0];
        for (row = top; row < top + 2; row++)
            for (col = NEXT_BOX_X; col < NEXT_BOX_X + 4; col++)
                put_glyph(col, row, *shape++ + CELL_LOCKED);
    }

    fall_count = lock_count = 0;
    item_y = item_x = 0;
    piece_rot = 0;
    state_step = 99;                        /* 아이템: 아직 안 쐈다 */
    piece_x = 6;
    piece_y = 1;

    if (PIECE_NOW >= ITEM_FIRST) {
        caption    = piece_caption[PIECE_NOW - 6];
        game_state = ST_MOVE_ITEM;
        piece_x    = 8;
        piece_y    = 2;
        piece_rot  = 1;                     /* 회전1 첫 칸 = 판 위 글자 */
    } else {
        caption    = piece_caption[0];      /* 만든 사람 (data.c CREDIT_CAPTION) */
        game_state = ST_MOVE_PIECE;
    }
    cur_x = 26;
    cur_y = 22;
    print_text(caption);

    if (piece_collides() || piece_landed()) {
        game_state = ST_LOSE_LIFE;
        state_step = FIELD_TOP;             /* 덮을 첫 행 */
    }
}

/* ---------------------------------------------------------------------------
 *  원래: run_stick  (KOR-INT.C:186, 19AF)
 *  보통 블록을 한 프레임 움직인다.
 *      moved   (원래 f)          1 = 옮김/내림, 2 = 회전
 *      blocked (원래 check_flag) 옮기려다 부딪혔다
 *      landed  (원래 stop_flag)  아래가 막혔다
 *  아래가 막힌 채로 lock_count 가 10 을 넘으면 굳는다.
 * ------------------------------------------------------------------------- */
void state_move_piece(void)
{
    int moved = 0, blocked = 0, landed = 0;
    int key;

    prev_piece_x   = piece_x;
    prev_piece_y   = piece_y;
    prev_piece_rot = piece_rot;

    key = poll_key();
    switch (key) {
    case SC_LEFT:  piece_x--;                          moved = 1; break;
    case SC_UP:                                 /* 원본에 없던 것: 위 화살표로도 회전 */
    case SC_PAD5:  piece_rot = (piece_rot + 1) & 3;    moved = 2; break;
    case SC_RIGHT: piece_x++;                          moved = 1; break;
    case SC_DOWN:  piece_y++; fall_count = 0;          moved = 1; break;
    case SC_SPACE:
        hard_drop();
        hard_dropped = 1;                       /* (새로 넣음) 화면에서 떨어지는 모습 */
        board_remove_piece();
        board_add_piece();
        break;
    case SC_F1: case SC_F2: case SC_F3: case SC_F4:
        toggle_option(key);
        break;
    case SC_ESC:
        video_shutdown();
        sound_off();
        exit(1);
    }

    if (moved) {
        blocked = piece_collides();
        board_remove_piece();
        board_add_piece();
        if (moved == 1)
            landed = piece_landed();
        moved = (blocked && landed) ? 1 : 0;
    }

    landed = piece_landed();
    if (++fall_count > fall_delay) {
        fall_count = 0;
        if (landed)
            moved = 1;
        else {
            piece_y++;
            board_remove_piece();
            board_add_piece();
        }
    } else if (landed)
        moved = 1;
    else
        lock_count++;

    put_glyph(LOCK_LAMP_X, LOCK_LAMP_Y, GLYPH_LOCK_LAMP + (moved || blocked));

    lock_count = moved ? lock_count + 1 : (lock_count ? lock_count - 1 : 0);
    if (lock_count > LOCK_TICKS)
        game_state = ST_LOCK_PIECE;
}

/* ---------------------------------------------------------------------------
 *  원래: run_power  (KOR-INT.C:237, 1B58)
 *  아이템 한 칸을 움직인다.  Space 로 쏘면 item_step 이 효과를 진행하고,
 *  효과가 끝나면(1) 줄 검사로 간다.  쏘지 않고 굳으면 벽돌(0x6E)이 된다.
 * ------------------------------------------------------------------------- */
void state_move_item(void)
{
    int moved = 0, blocked = 0, landed = 0;
    int key;

    prev_piece_x   = piece_x;
    prev_piece_y   = piece_y;
    prev_piece_rot = piece_rot;

    board[piece_y][piece_x] = CELL_EMPTY;
    item_blink ^= 5;                        /* 글자 +0 / +5 로 깜빡인다 */

    key = poll_key();
    switch (key) {
    case SC_LEFT:  piece_x--;                 moved = 1; break;
    case SC_RIGHT: piece_x++;                 moved = 1; break;
    case SC_DOWN:  piece_y++; fall_count = 0; moved = 1; break;
    case SC_SPACE: item_fire();                          break;
    case SC_F1: case SC_F2: case SC_F3: case SC_F4:
        toggle_option(key);
        break;
    case SC_ESC:
        video_shutdown();
        exit(1);
    }

    if (item_step()) {
        game_state = ST_CHECK_LINES;
        return;
    }

    if (moved) {
        if (board[piece_y][piece_x] != CELL_EMPTY) {
            blocked = 1;
            piece_x = prev_piece_x;
            piece_y = prev_piece_y;
        }
        if (board[piece_y + 1][piece_x] > CELL_LOCKED)
            landed = 1;
        moved = (blocked && landed) ? 1 : 0;
    }

    if (board[piece_y + 1][piece_x] > CELL_LOCKED)
        landed = 1;
    if (++fall_count > fall_delay) {
        fall_count = 0;
        if (landed)
            moved = 1;
        else
            piece_y++;
    } else if (landed)
        moved = 1;
    else
        lock_count++;

    board[piece_y][piece_x] =
        (unsigned char)(piece_shape[PIECE_NOW][1][0] + item_blink);

    put_glyph(LOCK_LAMP_X, LOCK_LAMP_Y, GLYPH_LOCK_LAMP + (moved || blocked));

    lock_count = moved ? lock_count + 1 : (lock_count ? lock_count - 1 : 0);
    if (lock_count > LOCK_TICKS) {
        game_state = ST_CHECK_LINES;
        board[piece_y][piece_x] = CELL_ITEM_BLOCK;
    }
}

/* ---------------------------------------------------------------------------
 *  원래: stage_stick_set  (KOR-INT.C:300, 1D9E)
 *  떨어지던 블록 칸에 0x60 을 더해 굳히고, 쌓인 높이를 기억한다.
 *  블록 하나마다 점수 (스테이지 번호 + 1).
 * ------------------------------------------------------------------------- */
void state_lock_piece(void)
{
    int row, col;

    for (row = FIELD_BOTTOM; row != 0; row--)
        for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++)
            if (board[row][col] < CELL_SOLID_MIN && board[row][col] != CELL_EMPTY) {
                board[row][col] += CELL_LOCKED;
                stack_height = FIELD_BOTTOM + 1 - row;
            }

    score += stage_no + 1;
    game_state = ST_CHECK_LINES;
}

/* ---------------------------------------------------------------------------
 *  원래: stick_clear_check  (KOR-INT.C:319, 1E12)
 *  꽉 찬 줄을 반짝임 시작 값(0x12)으로 바꾼다.
 *  점수: 1줄 100, 2줄 200, 3줄 400, 4줄 800, 5줄 1600, 6줄 이상 2000.
 * ------------------------------------------------------------------------- */
void state_check_lines(void)
{
    int lines = 0;
    int row, col, full;

    game_state = ST_GIMMICK;
    for (row = 0; row <= FIELD_BOTTOM; row++) {
        full = 1;
        for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++)
            if (board[row][col] == CELL_EMPTY)
                full = 0;
        if (full) {
            lines++;
            game_state = ST_FLASH_LINES;
            state_step = CELL_FLASH;
            item_help = item_help > 3 ? item_help - 3 : 0;
            for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++)
                board[row][col] = CELL_FLASH;
        }
    }

    if (lines > 5)
        score += 2000;
    else if (lines != 0)
        score += (1 << (lines - 1)) * 100;
}

/* ---------------------------------------------------------------------------
 *  원래: stick_clear_sub1  (KOR-INT.C:344, 1ED6)
 *  지울 줄 글자를 0x12 -> 0x19 로 한 단계씩 바꾸며 잡음 소리를 낸다.
 * ------------------------------------------------------------------------- */
void state_flash_lines(void)
{
    int row, col;

    for (row = 0; row <= FIELD_BOTTOM; row++)
        if (board[row][FIELD_LEFT] == state_step)
            for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++)
                board[row][col]++;

    sound_on(rand16() % 10000 + 100);
    if (++state_step == CELL_FLASH_END) {
        game_state = ST_COLLAPSE_LINES;
        sound_off();
    }
}

/* ---------------------------------------------------------------------------
 *  원래: stick_clear_sub2  (KOR-INT.C:366, 1F46)
 *  열마다 0x19 칸을 빼고 아래로 당긴다 (벽 열 0..2 도 같이 돈다).
 * ------------------------------------------------------------------------- */
void state_collapse_lines(void)
{
    int col, src, dst;

    for (col = 0; col <= FIELD_RIGHT; col++) {
        dst = FIELD_BOTTOM;
        for (src = FIELD_BOTTOM; src >= 0; src--)
            if (board[src][col] != CELL_FLASH_END)
                board[dst--][col] = board[src][col];
        for (; dst > FIELD_TOP - 1; dst--)
            board[dst][col] = CELL_EMPTY;
    }
    game_state = ST_CHECK_TARGETS;
}

/* ---------------------------------------------------------------------------
 *  원래: stick_clear_sub3  (KOR-INT.C:385, 1FCC)   어디서도 부르지 않는다
 *  열마다 굳은 칸만 아래로 모은다 (turbo 아이템과 거의 같다).
 * ------------------------------------------------------------------------- */
void collapse_blocks(void)
{
    int col, src, dst;

    for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++) {
        dst = FIELD_BOTTOM;
        for (src = FIELD_BOTTOM; src != 0; src--)
            if (board[src][col] > CELL_LOCKED)
                board[dst--][col] = board[src][col];
        for (; dst > FIELD_TOP - 1; dst--)
            board[dst][col] = CELL_EMPTY;
    }
    game_state = ST_SPAWN_PIECE;
}

/* ---------------------------------------------------------------------------
 *  원래: screen_up_check  (KOR-INT.C:404, 2053)
 *  판에 사람이 하나도 없으면 스테이지를 깼다.
 * ------------------------------------------------------------------------- */
void state_check_targets(void)
{
    int row, col;

    game_state = ST_STAGE_CLEAR;
    for (row = FIELD_BOTTOM; row > FIELD_TOP - 1; row--)
        for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++)
            if (board[row][col] == CELL_TARGET) {
                game_state = ST_GIMMICK;
                return;
            }
}

/* ---------------------------------------------------------------------------
 *  원래: run_option  (KOR-INT.C:422, 2094)
 *  기믹 타이머가 0 이 되면 스테이지의 기믹을 한 번 일으키고 타이머를 되돌린다.
 *      1 판을 왼쪽으로  2 오른쪽으로  3 벽돌 생김  4 칸 하나 지움  5 바닥이 올라옴
 * ------------------------------------------------------------------------- */
void state_gimmick(void)
{
    game_state = ST_SPAWN_PIECE;
    if (gimmick_timer == 0) {
        switch (stage_gimmick[STAGE_IX(stage_no)]) {
        case 1: gimmick_shift_left();   break;
        case 2: gimmick_shift_right();  break;
        case 3: gimmick_add_block();    break;
        case 4: gimmick_remove_block(); break;
        case 5: gimmick_raise_floor();  break;
        }
        gimmick_timer = stage_gimmick_time[STAGE_IX(stage_no)];
        game_state = ST_CHECK_LINES;
    }
}

/* ---------------------------------------------------------------------------
 *  원래: subtract_stick  (KOR-INT.C:446, 20F9)
 *  판을 위에서부터 한 줄씩 덮은 뒤, 목숨이 남았으면 그 스테이지를 처음부터,
 *  없으면 게임 끝.
 * ------------------------------------------------------------------------- */
void state_lose_life(void)
{
    int col;

    for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++)
        board[state_step][col] =
            board[state_step][col] ? CELL_LOSE_FULL : CELL_LOSE_EMPTY;

    if (++state_step == FIELD_BOTTOM + 2) {
        wait_ticks(18);
        game_state = ST_START_STAGE;
        if (lives)
            lives--;
        else
            game_state = ST_GAME_OVER;
    }
}

/* ---------------------------------------------------------------------------
 *  원래: game_over  (KOR-INT.C:465, 216A)
 *  "GAME  OVER" 글자를 판 아래에서 위로(행 22 -> 9) 올린다.
 * ------------------------------------------------------------------------- */
void state_game_over(void)
{
    int row, col;

    sound_off();
    music_play(SONG_OVER);                  /* (새로 넣음) */
    for (row = FIELD_BOTTOM; row > 8; row--) {
        cur_x = 11;
        cur_y = row;
        draw_board();
        print_text("GAME  OVER");
        for (col = 0; col < MAP_COLS; col++)            /* 다음번에 이 줄을 다시 그리게 */
            drawn_board[(row - FIELD_TOP) * MAP_COLS + col] = 0xFF;
        wait_ticks(2);
    }
    wait_ticks(36);
    game_state = ST_MENU;
}

/* ---------------------------------------------------------------------------
 *  원래: screen_clear_up  (KOR-INT.C:488, 21CB)
 *  스테이지를 깼다.  남은 보너스에 따라 한마디를 보여 주고,
 *  보너스를 10 씩 점수로 바꾼다 (10 마다 스테이지 번호 x 10 점).
 * ------------------------------------------------------------------------- */
void state_stage_clear(void)
{
    int wait, row, col;

    stage_no++;
    sound_off();
    music_play(SONG_CLEAR);                 /* (새로 넣음) */
    wait_tick();

    cur_x = 11;
    cur_y = 7;
    print_text("  CLEAR.  ");
    cur_x = 11;
    cur_y = 9;

    wait = 10;
    if (bonus_left > 300)
        print_text("VERY GOOD.");
    else if (bonus_left > 200) {
        print_text("   GOOD.  ");
        wait = 20;
    } else if (bonus_left > 100) {
        print_text("   NICE.  ");
        wait = 30;
    } else if (bonus_left != 0) {
        print_text("   FINE.  ");
        wait = 40;
    } else {
        print_text(" NO BONUS.");
        wait = 50;
    }
    wait_ticks(wait);

    score      += bonus_left % 10;
    bonus_left -= bonus_left % 10;
    while (bonus_left != 0) {
        show_bonus();
        show_score();
        music_effect(EFFECT_BONUS_COUNT);   /* 원래 sound(200) */
        wait_tick();
        score += stage_no * 10;
        bonus_left -= 10;
        sound_off();
    }

    game_state = ST_CLEAR_ANIM;
    state_step = 24;
    for (row = FIELD_TOP; row <= FIELD_BOTTOM; row++)
        for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++)
            if (board[row][col])
                board[row][col] = CELL_CLEAR_ANIM;
}

/* ---------------------------------------------------------------------------
 *  원래: screen_up_sub  (KOR-INT.C:537, 2322)
 *  남은 칸들을 글자 0xF5..0xFC 로 바꿔 가며 사라지게 하고 다음 스테이지로.
 * ------------------------------------------------------------------------- */
void state_clear_anim(void)
{
    int row, col;

    for (row = FIELD_TOP; row <= FIELD_BOTTOM; row++)
        for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++)
            if (board[row][col])
                board[row][col] = (unsigned char)(state_step + 0xDD);

    sound_on(6000 - ((state_step - 24) << 9));
    if (++state_step == 32) {
        game_state = ST_START_STAGE;
        sound_off();
        draw_next_stage_preview();
    }
}
