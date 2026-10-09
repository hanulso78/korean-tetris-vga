/* ============================================================================
 *  text.c  -  글자 출력, 창 스크롤, 한 줄 입력  (원래 KOR-GRP.C 뒷부분)
 * ----------------------------------------------------------------------------
 *  커서(cur_x, cur_y)와 창(win_left..win_right, win_top..win_bottom)은
 *  글자 칸 단위다.  실제로 찍는 일은 화면 백엔드(vidmono.c / vid256.c)가 한다.
 * ========================================================================== */
#include <string.h>
#include <ctype.h>

#include "korea.h"

/* ---------------------------------------------------------------------------
 *  원래: up_scroll  (KOR-GRP.C:192, 1250)   창을 한 글자 줄 위로 올린다
 *  (원본은 화면 줄 16개를 줄마다 memcpy 했다)
 * ------------------------------------------------------------------------- */
void scroll_window_up(void)
{
    int width = win_right - win_left;
    int row;

    for (row = win_top; row < win_bottom - 1; row++)
        copy_cell_row(row, row + 1, win_left, width);
    clear_cell_row(win_bottom - 1, win_left, width);
}

/* ---------------------------------------------------------------------------
 *  원래: down_scroll  (KOR-GRP.C:210, 1315)   (쓰이지 않는다)
 *  원본 그대로 win_top+1 줄은 옮기지 않는다.
 * ------------------------------------------------------------------------- */
void scroll_window_down(void)
{
    int width = win_right - win_left;
    int row;

    for (row = win_bottom - 1; win_top + 1 < row; row--)
        copy_cell_row(row, row - 1, win_left, width);
    clear_cell_row(win_top, win_left, width);
}

/* ---------------------------------------------------------------------------
 *  원래: window_cls  (KOR-GRP.C:228, 13D8)   (쓰이지 않는다)
 * ------------------------------------------------------------------------- */
void clear_window(void)
{
    int row;

    for (row = win_top; row < win_bottom; row++)
        clear_cell_row(row, win_left, win_right - win_left);
}

/* ---------------------------------------------------------------------------
 *  원래: lprint / cprint / crlf  (KOR-GRP.C:240/255/268, 142A/1484/14CD)
 *  커서에 글자를 찍고 창 끝에서 다음 줄로, 창 아래 끝에서는 창을 올린다.
 * ------------------------------------------------------------------------- */
static void advance_cursor(void)
{
    if (++cur_x == win_right) {
        cur_x = win_left;
        if (++cur_y == win_bottom) {
            cur_y--;
            scroll_window_up();
        }
    }
}

void print_text(const char *s)
{
    while (*s) {
        put_glyph(cur_x, cur_y, (unsigned char)*s++);
        advance_cursor();
    }
}

void print_char(int c)
{
    put_glyph(cur_x, cur_y, (unsigned char)c);
    advance_cursor();
}

void new_line(void)
{
    cur_x = win_left;
    if (++cur_y == win_bottom) {
        cur_y--;
        scroll_window_up();
    }
}

/* ---------------------------------------------------------------------------
 *  원래: cinkey  (KOR-GRP.C:278, 14EC)   (read_line 만 부르고, 그건 안 쓰인다)
 *  소문자는 대문자로.  글자/숫자/".- \:" 는 그대로,
 *  BackSpace 나 왼쪽 화살표는 0, Enter 는 1 을 돌려준다.
 * ------------------------------------------------------------------------- */
int read_line_key(void)
{
    int k;

    for (;;) {
        k = get_key(0);
        if (k < 0x100 && islower(k))
            k -= 0x20;
        if (k < 0x100 && (isdigit(k) || isupper(k) || (k && strchr(".- \\:", k))))
            return k;
        if (k == 0x14B || k == '\b')
            return 0;
        if (k == '\r')
            return 1;
    }
}

/* ---------------------------------------------------------------------------
 *  원래: linkey  (KOR-GRP.C:292, 1546)   한 줄 입력 (최대 32자).  안 쓰인다
 *  ("INPUT PASSWORD" 메뉴를 위해 만들어 둔 것 같다)
 * ------------------------------------------------------------------------- */
void read_line(char *buf)
{
    int len = 0;
    int k;

    for (;;) {
        print_char('>');
        cur_x--;
        k = read_line_key();
        if (k > 1) {
            if (++len < 33) {
                print_char(k);
                *buf++ = (char)k;
            } else
                len--;
        } else if (k != 0) {
            *buf = '\0';
            print_char(' ');
            new_line();
            return;
        } else if (len != 0) {
            print_char(' ');
            cur_x--;
            cur_x--;
            len--;
            buf--;
        }
    }
}
