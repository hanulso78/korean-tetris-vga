/* ============================================================================
 *  board.c  -  판, 블록, 점수판, 아이템  (원래 KOR-SUB.C 나머지)
 * ========================================================================== */
#include "korea.h"

#define GLYPH_TARGET_ANIM  0xB0    /* 사람 애니메이션 0xB0..0xCF */
#define GLYPH_LIFE         0x8D
#define GLYPH_NO_LIFE      0x40

#define ITEM_ROCKET_FILL   7       /* MAKE  ROCKET */
#define ITEM_ROCKET_DIG    8       /* ERASE ROCKET */
#define ITEM_BOMB          9
#define ITEM_LASER         10
#define ITEM_TURBO         11
#define ITEM_READY         99      /* state_step: 아이템을 아직 안 쐈다 */

/* ---------------------------------------------------------------------------
 *  원래: title  (KOR-SUB.C:110, 25CD)   게임 화면 틀
 * ------------------------------------------------------------------------- */
void draw_play_screen(void)
{
    int r;

    cur_x = cur_y = 0;
    for (r = 0; r < 25; r++)
        print_text(play_screen[r]);
}

/* ---------------------------------------------------------------------------
 *  원래: put_stage  (KOR-SUB.C:192, 27F8)
 *  보이는 판(행 3..22, 열 3..12)을 화면 x 11..20 에 그린다.
 *  drawn_board 와 달라진 칸만 다시 찍고, 사람 칸은 늘 애니메이션을 찍는다.
 *
 *  (새로 넣음) 화면 백엔드가 부드러운 이동을 하면(256색판) 떨어지는 블록/아이템
 *  칸은 판에 빈칸으로 찍고 따로 넘겨준다 (video_set_piece).  흑백판은 원본 그대로.
 * ------------------------------------------------------------------------- */
static int is_moving_cell(int col, int row, unsigned char v)
{
    if (game_state == ST_MOVE_PIECE)
        return v != CELL_EMPTY && v < CELL_SOLID_MIN;
    if (game_state == ST_MOVE_ITEM)
        return v != CELL_EMPTY && col == piece_x && row == piece_y;
    return 0;
}

void draw_board(void)
{
    unsigned char *drawn = drawn_board;
    const unsigned char *cell;
    signed char dx[16], dy[16];
    unsigned char code[16];
    int smooth = video_smooth_piece();
    int n = 0;
    int x, y, v;

    for (y = FIELD_TOP; y <= FIELD_BOTTOM; y++) {
        cell = board[y] + FIELD_LEFT;
        for (x = FIELD_LEFT + FIELD_X; x <= FIELD_RIGHT + FIELD_X; x++, cell++, drawn++) {
            v = *cell;
            if (smooth && n < 16 && is_moving_cell(x - FIELD_X, y, v)) {
                dx[n] = (signed char)(x - FIELD_X - piece_x);
                dy[n] = (signed char)(y - piece_y);
                code[n++] = (unsigned char)v;
                v = CELL_EMPTY;                 /* 밑에는 빈칸 */
            }
            if (v != *drawn) {
                *drawn = (unsigned char)v;
                put_glyph(x, y, v);
            }
            if (v == CELL_TARGET)
                put_glyph(x, y, GLYPH_TARGET_ANIM + (anim_tick >> 2));
        }
    }
    if (smooth)
        video_set_piece(game_state == ST_MOVE_PIECE || game_state == ST_MOVE_ITEM
                            ? PIECE_NOW * 4 + piece_rot : -1,
                        piece_x + FIELD_X, piece_y, n, dx, dy, code, hard_dropped);
    hard_dropped = 0;
}

/* ---------------------------------------------------------------------------
 *  원래: put_stage2  (KOR-SUB.C:213, 28B4)
 *  편집기용.  판 행 y 를 화면 행 y+1, 열 3 을 화면 x 15 에 그린다.
 *  원본은 한 행의 글자 10개를 화면 16줄에 바로 복사했다 (put_glyph 와 같은 일).
 * ------------------------------------------------------------------------- */
void editor_draw_board(void)
{
    int row, c;

    for (row = FIELD_TOP; row <= FIELD_BOTTOM; row++)
        for (c = 0; c < MAP_COLS; c++)
            put_glyph(15 + c, row + 1, board[row][FIELD_LEFT + c]);
}

/* ---------------------------------------------------------------------------
 *  원래: stage_check  (KOR-SUB.C:249, 2B59)
 *  떨어지는 블록이 굳은 칸(> 0x10)과 겹치면 직전 위치/회전으로 되돌리고 1.
 * ------------------------------------------------------------------------- */
int piece_collides(void)
{
    const unsigned char *shape = piece_shape[PIECE_NOW][piece_rot];
    int row, col;

    for (row = piece_y; row < piece_y + 4; row++)
        for (col = piece_x; col < piece_x + 4; col++)
            if (*shape++ && board[row][col] >= CELL_SOLID_MIN) {
                piece_x   = prev_piece_x;
                piece_y   = prev_piece_y;
                piece_rot = prev_piece_rot;
                return 1;
            }
    return 0;
}

/* ---------------------------------------------------------------------------
 *  원래: stage_down_check  (KOR-SUB.C:266, 2BFB)
 *  블록 바로 아래에 굳은 칸이 있으면 1 (땅에 닿았다).
 * ------------------------------------------------------------------------- */
int piece_landed(void)
{
    const unsigned char *shape = piece_shape[PIECE_NOW][piece_rot];
    int row, col;

    for (row = piece_y; row < piece_y + 4; row++)
        for (col = piece_x; col < piece_x + 4; col++)
            if (*shape++ && board[row + 1][col] >= CELL_SOLID_MIN)
                return 1;
    return 0;
}

/* ---------------------------------------------------------------------------
 *  원래: stage_store  (KOR-SUB.C:280, 2C74)   블록 모양을 판에 더한다
 * ------------------------------------------------------------------------- */
void board_add_piece(void)
{
    const unsigned char *shape = piece_shape[PIECE_NOW][piece_rot];
    int row, col;

    for (row = piece_y; row < piece_y + 4; row++)
        for (col = piece_x; col < piece_x + 4; col++)
            board[row][col] += *shape++;
}

/* ---------------------------------------------------------------------------
 *  원래: stage_stick_clear  (KOR-SUB.C:292, 2CDF)
 *  판에서 떨어지는 중인 블록(0x01..0x10)을 모두 지운다.
 * ------------------------------------------------------------------------- */
void board_remove_piece(void)
{
    int row, col;

    for (row = 0; row <= FIELD_BOTTOM; row++)
        for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++)
            if (board[row][col] < CELL_SOLID_MIN)
                board[row][col] = CELL_EMPTY;
}

/* ---------------------------------------------------------------------------
 *  원래: left_rotate / right_rotate  (KOR-SUB.C:302/319, 2D23/2DB7)
 *  기믹 1, 2: 판 전체를 왼쪽/오른쪽으로 한 칸 돌려 밀고 소리를 낸다.
 * ------------------------------------------------------------------------- */
void gimmick_shift_left(void)
{
    int row, col, first, hz;

    for (row = FIELD_TOP; row <= FIELD_BOTTOM; row++) {
        first = board[row][FIELD_LEFT];
        for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++)
            board[row][col] = board[row][col + 1];
        board[row][FIELD_RIGHT] = first;
    }
    for (hz = 1000; hz < 2000; hz += 200) {
        sound_on(hz);
        wait_tick();
    }
    sound_off();
}

void gimmick_shift_right(void)
{
    int row, col, last, hz;

    for (row = FIELD_TOP; row <= FIELD_BOTTOM; row++) {
        last = board[row][FIELD_RIGHT];
        for (col = FIELD_RIGHT; col > FIELD_LEFT; col--)
            board[row][col] = board[row][col - 1];
        board[row][FIELD_LEFT] = last;
    }
    for (hz = 2000; hz > 1000; hz -= 200) {
        sound_on(hz);
        wait_tick();
    }
    sound_off();
}

/* ---------------------------------------------------------------------------
 *  원래: make_point  (KOR-SUB.C:336, 2E4B)
 *  기믹 3: 아래가 막힌 빈칸을 무작위로 골라 벽돌을 하나 만든다.
 *  (글자 0x27..0x22 로 나타나는 애니메이션)
 * ------------------------------------------------------------------------- */
void gimmick_add_block(void)
{
    int row, col, n;

    for (;;) {
        row = rand16() % MAP_ROWS + FIELD_TOP;
        col = rand16() % MAP_COLS + FIELD_LEFT;
        if (board[row + 1][col] != CELL_EMPTY && board[row][col] == CELL_EMPTY) {
            sound_off();
            for (n = 0x27; n > 0x21; n--) {
                put_glyph(col + FIELD_X, row, n);
                sound_on((n - 0x22) * 300 + 500);
                wait_tick();
            }
            board[row][col] = (unsigned char)(rand16() % 7 + CELL_LOCKED + 1);
            return;
        }
    }
}

/* ---------------------------------------------------------------------------
 *  원래: erase_point  (KOR-SUB.C:357, 2F0A)
 *  기믹 4: 차 있는 칸 하나를 무작위로 지운다 (사람도 지워진다).
 * ------------------------------------------------------------------------- */
void gimmick_remove_block(void)
{
    int row, col, n;

    for (;;) {
        row = rand16() % MAP_ROWS + FIELD_TOP;
        col = rand16() % MAP_COLS + FIELD_LEFT;
        if (board[row][col] != CELL_EMPTY) {
            sound_off();
            for (n = 0x22; n < 0x28; n++) {
                put_glyph(col + FIELD_X, row, n);
                sound_on((n - 0x22) * 300 + 500);
                wait_tick();
            }
            board[row][col] = CELL_EMPTY;
            return;
        }
    }
}

/* ---------------------------------------------------------------------------
 *  원래: up_stage  (KOR-SUB.C:378, 2FA6)
 *  기믹 5: 판을 한 줄 올리고 맨 아래에 무작위 벽돌 줄(적어도 한 칸)을 넣는다.
 * ------------------------------------------------------------------------- */
void gimmick_raise_floor(void)
{
    int row, col, empty = 1;

    sound_on(2000);
    for (row = 0; row < FIELD_BOTTOM; row++)
        for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++)
            board[row][col] = board[row + 1][col];

    do {
        for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++) {
            if (rand16() % 3) {
                board[FIELD_BOTTOM][col] = (unsigned char)(rand16() % 7 + CELL_LOCKED + 1);
                empty = 0;
            } else
                board[FIELD_BOTTOM][col] = CELL_EMPTY;
        }
    } while (empty);

    wait_tick();
    sound_on(500);
    wait_tick();
    sound_off();
}

/* ---------------------------------------------------------------------------
 *  원래: screen_to_stage / stage_to_screen  (KOR-SUB.C:400/413, 3048/30B4)
 *  스테이지 지도 20x10 <-> 판.  판에 옮길 때는 화면 캐시를 모두 무효로 한다.
 * ------------------------------------------------------------------------- */
void map_to_board(void)
{
    unsigned char *drawn = drawn_board;
    int i, j;

    for (i = 0; i < MAP_ROWS; i++)
        for (j = 0; j < MAP_COLS; j++) {
            board[i + FIELD_TOP][j + FIELD_LEFT] = stage_map[STAGE_IX(stage_no)][i][j];
            *drawn++ = 0xFF;
        }
}

void board_to_map(void)
{
    int i, j;

    for (i = 0; i < MAP_ROWS; i++)
        for (j = 0; j < MAP_COLS; j++)
            stage_map[STAGE_IX(stage_no)][i][j] = board[i + FIELD_TOP][j + FIELD_LEFT];
}

/* ---------------------------------------------------------------------------
 *  원래: grp_put_init .. put_life  (KOR-SUB.C:422..486, 3109..3224)
 *  오른쪽 점수판.  숫자는 x=38 에서 왼쪽으로 찍는다.
 * ------------------------------------------------------------------------- */
void draw_status(void)
{
    show_hi_score();
    show_score();
    show_stage_no();
    show_gimmick();
    show_speed();
    show_bonus();
    show_gimmick_timer();
    show_lives();
}

void show_hi_score(void)      { put_long_number(38, 4, hi_score[0]); }
void show_score(void)         { put_long_number(38, 6, score); }
void show_stage_no(void)      { put_number(38, 8, stage_no + 1); }
void show_speed(void)         { put_number(38, 12, 9 - fall_delay); }
void show_bonus(void)         { put_number(38, 14, bonus_left); }
void show_gimmick_timer(void) { put_number(38, 16, gimmick_timer); }

void show_gimmick(void)
{
    cur_x = 34;
    cur_y = 10;
    print_text(gimmick_icon[stage_gimmick[STAGE_IX(stage_no)]]);
}

void show_lives(void)
{
    int i;

    for (i = 0; i < 8; i++)
        put_glyph(38 - i, 18, lives > i ? GLYPH_LIFE : GLYPH_NO_LIFE);
}

/* ---------------------------------------------------------------------------
 *  원래: grp_put1  (KOR-SUB.C:489, 3224)
 *  x 에서 왼쪽으로 숫자를 찍고, 그 왼쪽에 '0' 을 하나 더 찍는다
 *  (자릿수가 줄었을 때 남은 숫자를 덮는다).
 * ------------------------------------------------------------------------- */
void put_number(int x, int y, int n)
{
    do {
        put_glyph(x--, y, '0' + n % 10);
        n /= 10;
    } while (n);
    put_glyph(x, y, '0');
}

/* ---------------------------------------------------------------------------
 *  원래: grp_put2  (KOR-SUB.C:498, 3272)   long 숫자
 * ------------------------------------------------------------------------- */
void put_long_number(int x, int y, long n)
{
    do {
        put_glyph(x--, y, '0' + (int)(n % 10));
        n /= 10;
    } while (n);
}

/* ---------------------------------------------------------------------------
 *  원래: put_data  (KOR-SUB.C:507, 32C6)
 *  프레임마다 부른다.  frame_ms 를 5씩 올려 90(=18틱, 약 1초)마다
 *      보너스 -1 (45 에서도 -1 이라 초당 2),  기믹 타이머 -1,
 *      60초마다 떨어지는 간격 -1 (0 다음은 3)
 *  그리고 숫자들을 다시 찍는다.
 * ------------------------------------------------------------------------- */
void update_status(void)
{
    frame_ms += 5;
    if (frame_ms == 45 && bonus_left)
        bonus_left--;
    else if (frame_ms == 90) {
        if (bonus_left)
            bonus_left--;
        if (gimmick_timer)
            gimmick_timer--;
        if (++speed_seconds == 60) {
            fall_delay = fall_delay ? fall_delay - 1 : 3;
            speed_seconds = 0;
        }
        frame_ms = 0;
    }
    show_bonus();
    show_gimmick_timer();
    show_speed();
    show_score();
}

/* ---------------------------------------------------------------------------
 *  원래: next_stage_put  (KOR-SUB.C:529, 3338)
 *  왼쪽 아래 창에 다음 스테이지 지도를 8x8 픽셀 칸으로 작게 그린다.
 *  (원본은 여기서 화면 메모리에 직접 썼다 -> put_preview_cell)
 *  원본은 99판에서 표 밖(screen[100])을 읽었다 -> STAGE_IX 로 1판을 보여 준다.
 * ------------------------------------------------------------------------- */
void draw_next_stage_preview(void)
{
    int next = STAGE_IX(stage_no % STAGE_COUNT + 1);
    int i, j;

    for (i = 0; i < MAP_ROWS; i++)
        for (j = 0; j < MAP_COLS; j++)
            put_preview_cell(j, i, stage_map[next][i][j]);
}

/* ---------------------------------------------------------------------------
 *  원래: kor_y_end  (KOR-SUB.C:551, 342F)   Space: 바닥까지 떨어뜨린다
 *  원본은 블록이 맨 위 두 줄(행 0..1)에 있으면 아무 일도 하지 않았다.
 *  KOREAVGA.EXE 는 나오자마자 눌러도 떨어진다 (enhanced_rules).
 * ------------------------------------------------------------------------- */
void hard_drop(void)
{
    if (piece_y < 2 && !enhanced_rules)
        return;
    while (!piece_landed()) {
        piece_y++;
        fall_count = 0;
    }
}

/* ============================ 아이템 =========================================
 *  아이템은 판에 한 칸짜리 글자로 떨어진다 (game.c state_move_item).
 *  Space 로 쏘면 item_x/item_y 에 자리를 기억하고, 매 프레임 item_step 이
 *  효과를 진행한다.  item_step 이 1 을 돌려주면 줄 검사 상태로 넘어간다.
 * ========================================================================== */

/* (새로 넣음) 256색판은 아이템을 판과 따로 그리므로, 폭발/레이저/터보가
   시작되면 따로 그리던 아이템을 치운다 (원본은 판 위 글자가 덮여 사라졌다) */
static void hide_moving_item(void)
{
    video_set_piece(-1, 0, 0, 0, 0, 0, 0, 0);
}

/* 원래: power_rocket_make_set  (KOR-SUB.C:563, 3454) */
static void rocket_fill_start(void)
{
    if (item_y == 0 && board[piece_y + 1][piece_x] == CELL_EMPTY) {
        item_y = piece_y;
        item_x = piece_x;
        state_step = 0;
    }
}

/* 원래: power_rocket_erase_set  (KOR-SUB.C:573, 348D) */
static void rocket_dig_start(void)
{
    if (item_y == 0) {
        item_y = piece_y;
        item_x = piece_x;
    }
}

/* 원래: power_bomb_laser_turbo_set  (KOR-SUB.C:582, 34A5) */
static void blast_start(void)
{
    if (state_step == ITEM_READY) {
        item_y = piece_y;
        item_x = piece_x;
        state_step = 0;
    }
}

/* ---------------------------------------------------------------------------
 *  원래: power_proc_set  (KOR-SUB.C:592, 34C3)   Space 로 아이템 발사
 * ------------------------------------------------------------------------- */
void item_fire(void)
{
    switch (PIECE_NOW) {
    case ITEM_ROCKET_FILL: rocket_fill_start(); break;
    case ITEM_ROCKET_DIG:  rocket_dig_start();  break;
    default:               blast_start();       break;
    }
}

/* ---------------------------------------------------------------------------
 *  원래: put_bomb_pattern_and_store  (KOR-SUB.C:603, 34E4)
 *  판 안쪽 칸이면 폭발 글자를 찍고, 사람/벽이 아니면 그 칸을 벽돌(0x6E)로
 *  채운다.  채워진 줄은 곧이어 줄 검사에서 지워진다.
 * ------------------------------------------------------------------------- */
static void blast_cell(int x, int y, int glyph)
{
    if (x < FIELD_LEFT || x > FIELD_RIGHT || y < FIELD_TOP || y > FIELD_BOTTOM)
        return;
    put_glyph(x + FIELD_X, y, glyph);
    drawn_board[(y - FIELD_TOP) * MAP_COLS + x - FIELD_LEFT] = 0xFF;
    if (board[y][x] < CELL_TARGET)
        board[y][x] = CELL_ITEM_BLOCK;
}

/* ---------------------------------------------------------------------------
 *  원래: power_rocket_make_proc  (KOR-SUB.C:614, 3555)
 *  MAKE ROCKET: 쏜 자리에서 아래로 내려가다 굳은 칸 위에서 벽돌이 된다.
 *  (쏘기 전에는 item_y 가 0 이라 board[0][item_x] 만 지운다 - 원본대로)
 * ------------------------------------------------------------------------- */
static int rocket_fill_step(void)
{
    board[item_y][item_x] = CELL_EMPTY;
    if (item_y != 0) {
        if (board[item_y + 1][item_x] > CELL_LOCKED) {
            board[item_y][item_x] = CELL_ITEM_BLOCK;
            item_y = 0;
        } else {
            item_y++;
            if (state_step < 6)
                state_step++;
            board[item_y][item_x] = (unsigned char)(state_step + 0x26);
        }
    }
    return 0;
}

/* ---------------------------------------------------------------------------
 *  원래: power_rocket_erase_proc  (KOR-SUB.C:632, 35E5)
 *  ERASE ROCKET: 아래로 내려가다 처음 만난 굳은 칸을 지운다 (사람/벽이면 멈춤).
 * ------------------------------------------------------------------------- */
static int rocket_dig_step(void)
{
    board[item_y][item_x] = CELL_EMPTY;
    if (item_y != 0) {
        item_y++;
        if (board[item_y][item_x] > CELL_LOCKED) {
            if (board[item_y][item_x] < CELL_TARGET) {
                board[item_y][item_x] = CELL_EMPTY;
                item_y = 0;
            } else
                item_y = 0;
        } else
            board[item_y][item_x] = 0x0C;
    }
    return 0;
}

/* ---------------------------------------------------------------------------
 *  원래: power_bomb_proc  (KOR-SUB.C:654, 3688)
 *  BOMB: 쏜 자리를 중심으로 점점 넓어지는 모양으로 폭발 글자 0x1B..0x1F 를
 *  찍으며 그 칸들을 벽돌로 채운다.
 * ------------------------------------------------------------------------- */
static int bomb_explode(void)
{
    int g;
    int n, x, y;

    if (state_step != 0)
        return 0;
    state_step = 1;
    hide_moving_item();

    sound_off();
    for (n = 0x1B; n < 0x20; n++) {
        g = n;

        blast_cell(item_x, item_y, g);
        wait_tick();

        blast_cell(item_x - 1, item_y, g);
        blast_cell(item_x + 1, item_y, g);
        blast_cell(item_x, item_y - 1, g);
        blast_cell(item_x, item_y + 1, g);
        wait_tick();

        for (x = item_x - 1; x < item_x + 2; x++)
            for (y = item_y - 2; y < item_y + 3; y++)
                blast_cell(x, y, g);
        for (x = item_x - 2; x < item_x + 3; x += 4)
            for (y = item_y - 1; y < item_y + 2; y++)
                blast_cell(x, y, g);
        wait_tick();

        for (x = item_x - 2; x < item_x + 3; x++)
            for (y = item_y - 3; y < item_y + 4; y++)
                blast_cell(x, y, g);
        for (x = item_x - 3; x < item_x + 4; x += 6)
            for (y = item_y - 2; y < item_y + 3; y++)
                blast_cell(x, y, g);
        blast_cell(item_x - 2, item_y - 2, g);
        blast_cell(item_x - 2, item_y + 2, g);
        blast_cell(item_x + 2, item_y - 2, g);
        blast_cell(item_x + 2, item_y + 2, g);
        wait_tick();
    }
    draw_board();
    return 1;
}

/* ---------------------------------------------------------------------------
 *  원래: power_laser_proc  (KOR-SUB.C:698, 38C3)
 *  LASER: 쏜 줄을 가운데서 양옆으로 채운다 -> 그 줄이 지워진다.
 * ------------------------------------------------------------------------- */
static int laser_fire(void)
{
    int i;

    if (state_step != 0)
        return 0;
    state_step = 1;
    hide_moving_item();

    sound_off();
    blast_cell(item_x, item_y, 0x0B);
    wait_tick();
    for (i = 0; i < 10; i++) {
        blast_cell(item_x - i, item_y, 0x1A);
        blast_cell(item_x + i, item_y, 0x1A);
        wait_tick();
    }
    return 1;
}

/* ---------------------------------------------------------------------------
 *  원래: power_turbo_proc  (KOR-SUB.C:717, 3930)
 *  TURBO: 판 화면을 두 번 뒤집어 번쩍이고, 열마다 굳은 칸을 아래로 모은다.
 * ------------------------------------------------------------------------- */
static int turbo_compact(void)
{
    int flash, col, src, dst;

    if (state_step != 0)
        return 0;
    state_step = 1;
    hide_moving_item();

    for (flash = 0; flash < 2; flash++) {       /* 원본은 화면 메모리를 직접 XOR */
        invert_cells(FIELD_LEFT + FIELD_X, FIELD_TOP, MAP_COLS, MAP_ROWS);
        wait_tick();
    }

    for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++) {
        dst = FIELD_BOTTOM;
        for (src = FIELD_BOTTOM; src >= 0; src--)
            if (board[src][col] > CELL_LOCKED)
                board[dst--][col] = board[src][col];
        for (; dst > FIELD_TOP - 1; dst--)
            board[dst][col] = CELL_EMPTY;
    }
    return 1;
}

/* ---------------------------------------------------------------------------
 *  원래: power_process  (KOR-SUB.C:746, 3A1C)
 * ------------------------------------------------------------------------- */
int item_step(void)
{
    switch (PIECE_NOW) {
    case ITEM_ROCKET_FILL: return rocket_fill_step();
    case ITEM_ROCKET_DIG:  return rocket_dig_step();
    case ITEM_BOMB:        return bomb_explode();
    case ITEM_LASER:       return laser_fire();
    case ITEM_TURBO:       return turbo_compact();
    }
    return 0;
}
