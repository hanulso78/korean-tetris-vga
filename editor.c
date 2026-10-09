/* ============================================================================
 *  editor.c  -  스테이지 편집기  (원래 KOR-STG.C, "STAGE EDIT VERSION 1.5")
 * ----------------------------------------------------------------------------
 *  편집기 화면에서는 판을 게임 화면과 다른 자리(x+12, y+1)에 그린다.
 *  커서 위치로 piece_x / piece_y 를 빌려 쓴다(판 좌표, 열 3..12 / 행 3..22).
 *
 *  키 (get_key 값: 글자키는 ASCII, 확장키는 0x100 + 스캔 코드)
 *      화살표            커서 이동 (줄 끝에서 다음 줄로 넘어간다)
 *      a..z / A..Z       칸에 블록 글자를 넣는다 (소문자로), Space 는 지운다
 *      PgUp / PgDn       다음 / 이전 스테이지
 *      8 2 4 6           판 전체를 위/아래/왼쪽/오른쪽으로 한 칸 돌려 민다
 *      Enter             판을 복사,  BackSpace 붙여넣기,  Del 판 비우기
 *      Ctrl+S / Alt+S    SPEED +/-      Alt+P / Ctrl+P   POWER +/-
 *      Alt+O,Tab / Ctrl+O OPTION +/-    Alt+B / Ctrl+B   BONUS +/-
 *      Alt+T / Ctrl+T    TIMER +/-
 *      Ctrl+Enter(LF)    KOREA.STG 에 저장
 *      ESC               메뉴로
 * ========================================================================== */
#include <ctype.h>

#include "korea.h"

#define KEY_CTRL_B    0x02
#define KEY_BS        0x08
#define KEY_TAB       0x09
#define KEY_LF        0x0A
#define KEY_CR        0x0D
#define KEY_CTRL_O    0x0F
#define KEY_CTRL_P    0x10
#define KEY_CTRL_S    0x13
#define KEY_CTRL_T    0x14
#define KEY_ESC       0x1B
#define KEY_ALT_T     0x114
#define KEY_ALT_O     0x118
#define KEY_ALT_P     0x119
#define KEY_ALT_S     0x11F
#define KEY_ALT_B     0x130
#define KEY_UP        0x148
#define KEY_PGUP      0x149
#define KEY_LEFT      0x14B
#define KEY_RIGHT     0x14D
#define KEY_DOWN      0x150
#define KEY_PGDN      0x151
#define KEY_DEL       0x153

#define EDIT_BOARD_X  12        /* 편집기 화면: 판 열 + 12 = 화면 x */

/* ---------------------------------------------------------------------------
 *  원래: user_stage_title  (KOR-STG.C:57, 047B)
 * ------------------------------------------------------------------------- */
static void editor_draw_screen(void)
{
    int r;

    cur_x = cur_y = 0;
    for (r = 0; r < 25; r++)
        print_text(editor_screen[r]);
}

/* ---------------------------------------------------------------------------
 *  원래: put_cursor  (KOR-STG.C:89, 059B)
 *  커서 칸 16x16 을 화면 메모리에서 바로 뒤집었다(XOR).
 * ------------------------------------------------------------------------- */
static void editor_toggle_cursor(void)
{
    invert_cells(piece_x + EDIT_BOARD_X, piece_y + 1, 1, 1);
}

/* ---------------------------------------------------------------------------
 *  원래: screen_left / screen_right / screen_up / screen_down
 *        (KOR-STG.C:100/112/124/137, 05E9/0662/06DB/0734)
 *  판을 한 칸 밀고, 밀려 나간 줄은 반대편으로 돌아온다.
 * ------------------------------------------------------------------------- */
static void editor_roll_left(void)
{
    int row, col, first;

    for (row = FIELD_TOP; row <= FIELD_BOTTOM; row++) {
        first = board[row][FIELD_LEFT];
        for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++)
            board[row][col] = board[row][col + 1];
        board[row][FIELD_RIGHT] = first;
    }
}

static void editor_roll_right(void)
{
    int row, col, last;

    for (row = FIELD_TOP; row <= FIELD_BOTTOM; row++) {
        last = board[row][FIELD_RIGHT];
        for (col = FIELD_RIGHT; col > FIELD_LEFT; col--)
            board[row][col] = board[row][col - 1];
        board[row][FIELD_LEFT] = last;
    }
}

static void editor_roll_up(void)
{
    int col, row, top;

    for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++) {
        top = board[FIELD_TOP][col];
        for (row = FIELD_TOP; row < FIELD_BOTTOM; row++)
            board[row][col] = board[row + 1][col];
        board[FIELD_BOTTOM][col] = top;
    }
}

static void editor_roll_down(void)
{
    int col, row, bottom;

    for (col = FIELD_LEFT; col <= FIELD_RIGHT; col++) {
        bottom = board[FIELD_BOTTOM][col];
        for (row = FIELD_BOTTOM; row > FIELD_TOP; row--)
            board[row][col] = board[row - 1][col];
        board[FIELD_TOP][col] = bottom;
    }
}

/* ---------------------------------------------------------------------------
 *  원래: screen_store / screen_restore / screen_delete
 *        (KOR-STG.C:150/159/168, 078D/07D7/0821)
 * ------------------------------------------------------------------------- */
static void editor_copy(void)
{
    int i, j;

    for (i = 0; i < MAP_ROWS; i++)
        for (j = 0; j < MAP_COLS; j++)
            edit_clipboard[i][j] = board[i + FIELD_TOP][j + FIELD_LEFT];
}

static void editor_paste(void)
{
    int i, j;

    for (i = 0; i < MAP_ROWS; i++)
        for (j = 0; j < MAP_COLS; j++)
            board[i + FIELD_TOP][j + FIELD_LEFT] = edit_clipboard[i][j];
}

static void editor_clear(void)
{
    int i, j;

    for (i = 0; i < MAP_ROWS; i++)
        for (j = 0; j < MAP_COLS; j++)
            board[i + FIELD_TOP][j + FIELD_LEFT] = CELL_EMPTY;
}

/* ---------------------------------------------------------------------------
 *  원래: locprt / locprtl  (KOR-STG.C:177/183, 0856/0875)
 * ------------------------------------------------------------------------- */
static void put_digit(int x, int y, int n)
{
    put_glyph(x, y, '0' + n);
}

static void put_2digits(int x, int y, int n)
{
    int tens = n / 10;
    int ones = n % 10;

    put_glyph(x++, y, '0' + tens);
    put_glyph(x,   y, '0' + ones);
}

/* ---------------------------------------------------------------------------
 *  원래: cursor_right / cursor_left / cursor_down / cursor_up
 *        (KOR-STG.C:203/212/221/230, 0917/093C/0961/0986)
 *  wrap 이 참이면 끝에서 넘어갈 때 이웃 줄(칸)로도 옮긴다.
 * ------------------------------------------------------------------------- */
static void editor_cursor_up(int wrap);
static void editor_cursor_left(int wrap);
static void editor_cursor_down(int wrap);

static void editor_cursor_right(int wrap)
{
    if (++piece_x == FIELD_RIGHT + 1) {
        piece_x = FIELD_LEFT;
        if (wrap)
            editor_cursor_down(0);
    }
}

static void editor_cursor_left(int wrap)
{
    if (--piece_x == FIELD_LEFT - 1) {
        piece_x = FIELD_RIGHT;
        if (wrap)
            editor_cursor_up(0);
    }
}

static void editor_cursor_down(int wrap)
{
    if (++piece_y == FIELD_BOTTOM + 1) {
        piece_y = FIELD_TOP;
        if (wrap)
            editor_cursor_right(0);
    }
}

static void editor_cursor_up(int wrap)
{
    if (--piece_y == FIELD_TOP - 1) {
        piece_y = FIELD_BOTTOM;
        if (wrap)
            editor_cursor_left(0);
    }
}

/* ---------------------------------------------------------------------------
 *  원래: cursor_move  (KOR-STG.C:192, 08CC)   1 위, 2 아래, 3 왼쪽, 4 오른쪽
 * ------------------------------------------------------------------------- */
static void editor_move_cursor(int dir)
{
    switch (dir) {
    case 1: editor_cursor_up(1);    break;
    case 2: editor_cursor_down(1);  break;
    case 3: editor_cursor_left(1);  break;
    case 4: editor_cursor_right(1); break;
    }
}

/* ---------------------------------------------------------------------------
 *  원래: stage_up / stage_down  (KOR-STG.C:239/247, 09AB/09C5)
 *  고친 판을 지도에 되돌려 놓고 옆 스테이지를 불러온다(파일에는 안 쓴다).
 * ------------------------------------------------------------------------- */
static void editor_next_stage(void)
{
    board_to_map();
    stage_no = (stage_no + 1) % STAGE_COUNT;
    map_to_board();
}

static void editor_prev_stage(void)
{
    board_to_map();
    stage_no = (stage_no == 0) ? STAGE_COUNT - 1 : stage_no - 1;
    map_to_board();
}

/* ---------------------------------------------------------------------------
 *  원래: cursor_set  (KOR-STG.C:255, 09E3)
 *  영문자는 소문자로 바꿔 칸에 넣는다 ('a'=0x61 은 굳은 블록 1번 글자,
 *  'o'=0x6F 는 사람).  Space 는 칸을 비운다.
 * ------------------------------------------------------------------------- */
static void editor_put_cell(int key)
{
    if (key < 0x100 && isalpha(key))
        board[piece_y][piece_x] = (unsigned char)tolower(key);
    if (key == ' ')
        board[piece_y][piece_x] = CELL_EMPTY;
}

/* ---------------------------------------------------------------------------
 *  원래: stage_put_option / stage_put_power  (KOR-STG.C:262/272, 0A30/0A53)
 * ------------------------------------------------------------------------- */
static void editor_show_gimmick(int n)
{
    cur_x = 36;
    cur_y = 11;
    print_text(editor_digit3[n]);
}

static void editor_show_item(int n)
{
    cur_x = 36;
    cur_y = 9;
    print_text(editor_digit3[n]);
}

/* ---------------------------------------------------------------------------
 *  원래: put_env  (KOR-STG.C:282, 0A76)  오른쪽 설정값 표시
 * ------------------------------------------------------------------------- */
static void editor_show_settings(void)
{
    put_2digits(37, 5, stage_no + 1);
    put_digit(38, 7, 9 - stage_fall_delay[stage_no]);
    editor_show_item(stage_item[stage_no]);
    editor_show_gimmick(stage_gimmick[stage_no]);
    put_2digits(37, 13, stage_bonus[stage_no]);
    put_2digits(37, 15, stage_gimmick_time[stage_no]);
}

/* ---------------------------------------------------------------------------
 *  원래: add_speed ... sub_optime  (KOR-STG.C:293..350, 0B05..0CBD)
 *  값 하나씩 올리고 내린다.  끝에 닿으면 반대쪽 끝으로 돈다.
 *      SPEED  = 떨어지는 간격 0..9 (화면에는 9-값)
 *      POWER  = 나오는 아이템 0..5  (0 이면 무작위)
 *      OPTION = 기믹 0..5
 *      BONUS  = 보너스(x5) 0..99,  TIMER = 기믹 간격(초) 0..99
 * ------------------------------------------------------------------------- */
static void editor_inc_speed(void)   { stage_fall_delay[stage_no] = (stage_fall_delay[stage_no] + 1) % 10; }
static void editor_dec_speed(void)   { int *v = &stage_fall_delay[stage_no];   *v = *v ? *v - 1 : 9;  }
static void editor_inc_item(void)    { stage_item[stage_no] = (stage_item[stage_no] + 1) % 6; }
static void editor_dec_item(void)    { int *v = &stage_item[stage_no];         *v = *v ? *v - 1 : 5;  }
static void editor_inc_gimmick(void) { stage_gimmick[stage_no] = (stage_gimmick[stage_no] + 1) % 6; }
static void editor_dec_gimmick(void) { int *v = &stage_gimmick[stage_no];      *v = *v ? *v - 1 : 5;  }
static void editor_inc_bonus(void)   { stage_bonus[stage_no] = (stage_bonus[stage_no] + 1) % 100; }
static void editor_dec_bonus(void)   { int *v = &stage_bonus[stage_no];        *v = *v ? *v - 1 : 99; }
static void editor_inc_timer(void)   { stage_gimmick_time[stage_no] = (stage_gimmick_time[stage_no] + 1) % 100; }
static void editor_dec_timer(void)   { int *v = &stage_gimmick_time[stage_no]; *v = *v ? *v - 1 : 99; }

/* ---------------------------------------------------------------------------
 *  원래: user_stage  (KOR-STG.C:354, 0CBD)
 * ------------------------------------------------------------------------- */
void stage_editor(void)
{
    int key;

    music_play(SONG_NONE);                  /* (새로 넣음) */
    load_stages();
    cur_x = cur_y = 0;
    piece_x = 8;
    piece_y = 13;
    editor_draw_screen();
    stage_no = 0;
    map_to_board();
    editor_show_settings();

    do {
        editor_draw_board();
        editor_toggle_cursor();
        editor_show_settings();

        key = get_key(0);
        switch (key) {
        case KEY_UP:     editor_move_cursor(1);  break;
        case KEY_DOWN:   editor_move_cursor(2);  break;
        case KEY_LEFT:   editor_move_cursor(3);  break;
        case KEY_RIGHT:  editor_move_cursor(4);  break;
        case KEY_PGUP:   editor_next_stage();    break;
        case KEY_PGDN:   editor_prev_stage();    break;
        case KEY_TAB:    editor_inc_gimmick();   break;
        case KEY_LF:     save_stages();          break;
        case '8':        editor_roll_up();       break;
        case '2':        editor_roll_down();     break;
        case '4':        editor_roll_left();     break;
        case '6':        editor_roll_right();    break;
        case KEY_CR:     editor_copy();          break;
        case KEY_BS:     editor_paste();         break;
        case KEY_DEL:    editor_clear();         break;
        case KEY_CTRL_S: editor_inc_speed();     break;
        case KEY_ALT_S:  editor_dec_speed();     break;
        case KEY_ALT_P:  editor_inc_item();      break;
        case KEY_CTRL_P: editor_dec_item();      break;
        case KEY_ALT_O:  editor_inc_gimmick();   break;
        case KEY_CTRL_O: editor_dec_gimmick();   break;
        case KEY_ALT_B:  editor_inc_bonus();     break;
        case KEY_CTRL_B: editor_dec_bonus();     break;
        case KEY_ALT_T:  editor_inc_timer();     break;
        case KEY_CTRL_T: editor_dec_timer();     break;
        default:         editor_put_cell(key);   break;
        }
    } while (key != KEY_ESC);

    game_state = ST_MENU;
}
