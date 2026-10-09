/* ============================================================================
 *  menu.c  -  첫 화면 메뉴  (원래 KOR-TIT.C)
 * ========================================================================== */
#include <stdlib.h>
#include <string.h>

#include "korea.h"

#define MENU_X        2         /* 화살표 위치 */
#define MENU_Y0       17        /* 첫 항목 행, 항목마다 2행씩 */
#define GLYPH_ARROW   0xFD      /* 0xFD..0xFF 움직이는 화살표 */

/* ---------------------------------------------------------------------------
 *  (새로 넣음) 256색판: 로고("KOREAN" / "TETRIS")를 글자마다 다른 색으로.
 *  로고는 'e' 벽돌로 그려져 있다.  'e' 가 있는 줄 묶음마다, 'e' 가 하나도 없는
 *  열을 경계로 글자를 나눠 무지개 색 벽돌로 다시 찍는다.
 * ------------------------------------------------------------------------- */
#define LOGO_BRICK   'e'

static void color_logo(void)
{
    int row, top, bottom, col, used, prev_used, letter = 0;

    for (row = 0; row < 25; row++) {
        if (!strchr(menu_screen[row], LOGO_BRICK))
            continue;
        top = row;                                  /* 한 묶음 = 'e' 가 있는 이어진 줄들 */
        while (row + 1 < 25 && strchr(menu_screen[row + 1], LOGO_BRICK))
            row++;
        bottom = row;

        prev_used = 0;
        for (col = 0; col < SCREEN_COLS; col++) {
            int r;
            used = 0;
            for (r = top; r <= bottom; r++)
                if (menu_screen[r][col] == LOGO_BRICK)
                    used = 1;
            if (used && !prev_used)
                letter++;                           /* 새 글자가 시작됐다 */
            if (used)
                for (r = top; r <= bottom; r++)
                    if (menu_screen[r][col] == LOGO_BRICK)
                        put_glyph(col, r, LOGO_GLYPH + (letter - 1) % LOGO_COLORS);
            prev_used = used;
        }
    }
}

/* ---------------------------------------------------------------------------
 *  원래: select_subrutine  (KOR-TIT.C:12, 023D)
 *  메뉴 항목 번호(1부터) -> 게임 상태.
 *  3 "EDIT GAME START" 와 4 "INPUT PASSWORD" 는 만들다 만 것이라 아무 일도 없다.
 *  KOREAVGA.EXE 는 그 자리에 3 "QUIT" 을 넣었다.
 * ------------------------------------------------------------------------- */
void menu_select(int item)
{
    switch (item) {
    case 1: game_state = ST_NEW_GAME; break;
    case 2: game_state = ST_EDITOR;   break;
    case 3:                                     /* (새로 넣음) KOREAVGA.EXE 의 QUIT */
        if (enhanced_rules) {
            video_shutdown();
            exit(0);
        }
        break;
    }
}

/* ---------------------------------------------------------------------------
 *  원래: game_title  (KOR-TIT.C:21, 0261)
 *  KOREA 로고와 메뉴 네 줄을 찍고 화살표를 움직이며 고를 때까지 기다린다.
 *      지역변수  key, ry(이전 줄), j/i(화살표 애니메이션), y(현재 줄), ss(고른 항목)
 * ------------------------------------------------------------------------- */
void main_menu(void)
{
    int key, prev_sel, sub_tick, frame;
    int sel, chosen;
    int items = enhanced_rules ? 3 : 4;         /* 메뉴 줄 수 (KOREAVGA.EXE 는 QUIT 까지 3) */
    int r;

    sel = 0;
    cur_x = cur_y = 0;
    sub_tick = frame = 0;
    sound_off();
    music_play(SONG_TITLE);                 /* (새로 넣음) */
    for (r = 0; r < 25; r++)
        print_text(menu_screen[r]);
    if (video_has_color())
        color_logo();

    flush_keys();
    for (;;) {
        key = poll_key();
        chosen = 0;
        prev_sel = sel;
        switch (key) {
        case SC_1:      sel = 0;               break;
        case SC_2:      sel = 1;               break;
        case SC_UP:     sel = (sel + items - 1) % items; break;
        case SC_DOWN:   sel = (sel + 1) % items;         break;
        case SC_ENTER:
        case SC_SPACE:  chosen = sel + 1;      break;
        case SC_ESC:    video_shutdown(); exit(1);
        }

        sub_tick = (sub_tick + 1) % 3;          /* 3틱마다 화살표 한 장 */
        if (sub_tick == 0)
            frame = (frame + 1) % 3;
        wait_tick();
        put_glyph(MENU_X, sel * 2 + MENU_Y0, GLYPH_ARROW + frame);
        if (prev_sel != sel)
            put_glyph(MENU_X, prev_sel * 2 + MENU_Y0, ' ');

        if (chosen) {
            menu_select(chosen);
            wait_ticks(3);
            return;
        }
    }
}
