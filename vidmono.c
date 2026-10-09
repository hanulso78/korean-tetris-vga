/* ============================================================================
 *  vidmono.c  -  흑백 화면 백엔드 (원판 그대로)  ->  KOREA.EXE
 *                (원래 KOR-GRP.C 의 허큘리스 부분)
 * ----------------------------------------------------------------------------
 *  원본이 한 일
 *      get_graph_driver  int 11h 장비 목록의 흑백 비트로 허큘리스/CGA 를 가렸다.
 *      mode_set          허큘리스 6845 CRTC 에 표(gtable/ttable)를 써서
 *                        640x400 그래픽(한 줄 80바이트, 4 뱅크 인터레이스)
 *                        또는 텍스트 모드로 바꿨다.
 *                            gtable = 31 28 29 08 68 02 64 65 02 03 02 01
 *                            ttable = 61 50 52 0F 19 06 19 19 02 0D 0B 0C
 *      grset             yad[i] = B000:0 + (i>>2)*80 + ((i&3)<<13)  (i = 화면 줄)
 *                        허큘리스면 mode_set(1), 아니면 BIOS 모드 5 (CGA 320x200)
 *      putptn_herc       16x16 글자를 16줄 그대로 찍었다.
 *      putptn_cga        같은 글자의 홀수 줄 8개만, 16비트를 2비트x8 픽셀로 찍었다.
 *                        (글꼴은 허큘리스용으로 그린 것이라 CGA 에서는 색이 뒤섞인다)
 *
 *  이 판
 *      허큘리스 화면 메모리와 같은 모양의 버퍼(640x400, 1bpp, 한 줄 80바이트)에
 *      원본처럼 그리고, video_present 가 VGA 모드 12h(640x480 16색) 가운데로
 *      옮긴다.  모드 12h 기본 상태(쓰기 모드 0, 맵 마스크 0Fh)에서는 바이트를
 *      그대로 쓰면 1 비트가 흰색(15), 0 비트가 검정이 된다.
 * ========================================================================== */
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <dpmi.h>                /* __dpmi_int */
#include <go32.h>                /* _dos_ds, _my_ds */
#include <sys/movedata.h>        /* movedata */

#include "korea.h"

#define VGA_ADDR      0xA0000
#define VGA_TOP       40         /* 480 줄 가운데에 400 줄 */

const char font_file_name[] = "KOREA.PTN";

static unsigned char   vram[SCREEN_H * BYTES_PER_LINE];   /* 원래 HVRAM (B000:0000) */
static unsigned char  *scanline[SCREEN_H];                /* 원래 yad */
static unsigned short  font[256][16];                     /* 원래 chr */

static void bios_set_mode(int mode)
{
    __dpmi_regs r;

    memset(&r, 0, sizeof r);
    r.x.ax = mode;
    __dpmi_int(0x10, &r);
}

/* ---------------------------------------------------------------------------
 *  원래: chrinit  (KOR-GRP.C:327, 15C5)
 *  KOREA.PTN (8192바이트) = 16x16 글자 256개, 글자마다 16줄 x 2바이트.
 *  512바이트(글자 16개)씩 16번 읽는다.  파일이 없으면 -1.
 * ------------------------------------------------------------------------- */
int load_font(void)
{
    unsigned char buf[512];
    int fd, block, ch, row;

    fd = open("korea.PTN", O_RDONLY | O_BINARY);
    if (fd == -1)
        return -1;

    for (block = 0; block < 16; block++) {
        read(fd, buf, sizeof buf);
        for (ch = 0; ch < 16; ch++)
            for (row = 0; row < 16; row++) {
                unsigned char *p = buf + (ch * 16 + row) * 2;
                font[block * 16 + ch][row] = (unsigned short)(p[0] | p[1] << 8);
            }
    }
    close(fd);
    return 0;
}

/* ---------------------------------------------------------------------------
 *  원래: grset  (KOR-GRP.C:70, 0F1A)
 * ------------------------------------------------------------------------- */
void video_init(void)
{
    int i;

    for (i = 0; i < SCREEN_H; i++)
        scanline[i] = vram + i * BYTES_PER_LINE;
    memset(vram, 0, sizeof vram);

    bios_set_mode(0x12);
}

/* ---------------------------------------------------------------------------
 *  원래: textset  (KOR-GRP.C:88, 0F9F)
 *  원본은 허큘리스면 모드 7, 아니면 모드 3 으로 돌아갔다.
 * ------------------------------------------------------------------------- */
void video_shutdown(void)
{
    memset(vram, 0, sizeof vram);
    sound_off();                        /* 원본에 없던 것: 삑 소리가 남지 않게 */
    bios_set_mode(0x03);
}

/* ---------------------------------------------------------------------------
 *  원본에 없던 것.  원본은 화면 메모리에 바로 썼으므로 따로 할 일이 없었다.
 *  wait_tick 과 get_key 가 기다리기 전에 부른다.
 * ------------------------------------------------------------------------- */
void video_present(void)
{
    movedata(_my_ds(), (unsigned)vram,
             _dos_ds, VGA_ADDR + VGA_TOP * BYTES_PER_LINE, sizeof vram);
}

/* ---------------------------------------------------------------------------
 *  원래: putptn  (KOR-GRP.C:185, 1220)  ->  putptn_herc  (KOR-GRP.C:102, 0FD2)
 *  글자 칸 (x, y) 에 16x16 글자를 찍는다.  한 줄 16비트 = 화면 2바이트.
 * ------------------------------------------------------------------------- */
void put_glyph(int x, int y, int code)
{
    const unsigned short *glyph = font[code & 0xFF];
    int i;

    for (i = 0; i < 16; i++) {
        unsigned char *p = scanline[y * 16 + i] + x * 2;
        p[0] = (unsigned char)(glyph[i]);
        p[1] = (unsigned char)(glyph[i] >> 8);
    }
}

/* ---------------------------------------------------------------------------
 *  원본에서 화면 메모리를 직접 XOR 하던 곳 (편집기 커서 put_cursor,
 *  TURBO 아이템 power_turbo_proc) 을 모은 것.
 * ------------------------------------------------------------------------- */
void invert_cells(int x, int y, int w, int h)
{
    int line, i;

    for (line = y * 16; line < (y + h) * 16; line++) {
        unsigned char *p = scanline[line] + x * 2;
        for (i = 0; i < w * 2; i++)
            *p++ ^= 0xFF;
    }
}

/* ---------------------------------------------------------------------------
 *  원본 next_stage_put 이 화면 메모리에 직접 쓰던 부분.
 *  미리보기 창 안 (col, row) 칸 = 픽셀 (16 + col*8, 224 + row*8) 에
 *  8x8 무늬 한 바이트씩 8줄을 쓴다.
 * ------------------------------------------------------------------------- */
void put_preview_cell(int col, int row, unsigned char cell)
{
    const unsigned char *pat;
    int top = (row + 28) * 8;
    int line;

    pat = preview_pattern[cell ? (cell == CELL_TARGET ? 1 : 0) : 2];
    for (line = top; line < top + 8; line++)
        scanline[line][col + 2] = *pat++;
}

/* ---------------------------------------------------------------------------
 *  창 스크롤용 (text.c).  글자 한 줄 = 화면 16줄.
 *  (원본은 창 아래 끝이 26 이라 yad[] 밖을 읽을 수 있었다 -> 화면 밖은 건너뛴다)
 * ------------------------------------------------------------------------- */
void copy_cell_row(int dst_row, int src_row, int x, int w)
{
    int i;

    if (dst_row < 0 || dst_row >= SCREEN_ROWS || src_row < 0 || src_row >= SCREEN_ROWS)
        return;
    for (i = 0; i < 16; i++)
        memcpy(scanline[dst_row * 16 + i] + x * 2, scanline[src_row * 16 + i] + x * 2, w * 2);
}

void clear_cell_row(int row, int x, int w)
{
    int i;

    if (row < 0 || row >= SCREEN_ROWS)
        return;
    for (i = 0; i < 16; i++)
        memset(scanline[row * 16 + i] + x * 2, 0, w * 2);
}

/* ---------------------------------------------------------------------------
 *  부드러운 블록 이동은 256색판에만 있다.  흑백판은 원본처럼 판에 그대로 찍는다.
 * ------------------------------------------------------------------------- */
int  video_smooth_piece(void) { return 0; }
int  video_has_color(void)    { return 0; }
void video_idle(void)         { }

void video_set_piece(int key, int col, int row, int n,
                     const signed char *dx, const signed char *dy, const unsigned char *code,
                     int dropped)
{
    (void)key; (void)col; (void)row; (void)n; (void)dx; (void)dy; (void)code; (void)dropped;
}
