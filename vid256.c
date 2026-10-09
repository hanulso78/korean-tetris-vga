/* ============================================================================
 *  vid256.c  -  256색 화면 백엔드  ->  KOREAVGA.EXE
 * ----------------------------------------------------------------------------
 *  원판의 흑백 16x16 글자 256개를 색칠한 스프라이트(KOREA256.SPR)로 그린다.
 *  KOREA256.SPR 은 tools/mkspr256.py 가 KOREA.PTN 에서 만든다.
 *      0..7     "KOR256S" + 0
 *      8..775   팔레트 256색 (VGA DAC 값 0..63)
 *      776..    16x16 스프라이트 256개, 한 픽셀 = 팔레트 번호
 *
 *  화면 모드 (차례로 시도)
 *      VESA 0x100  640x400 256색  - 게임 화면과 크기가 똑같다
 *      VESA 0x101  640x480 256색  - 위아래 40줄씩 비우고 가운데에
 *      모드 13h    320x200 256색  - VESA 가 없을 때, 가로세로 반으로 줄여서
 *  VESA 는 선형 프레임 버퍼(LFB)가 있으면 그것을, 없으면 뱅크 창을 쓴다.
 *
 *  게임은 640x400 8비트 버퍼(fb)에 그리고, video_present 가 바뀐 글자 줄만
 *  화면으로 옮긴다.
 *
 *  원본은 커서/TURBO 번쩍임을 화면 바이트 XOR 0xFF 로 했다.  팔레트를
 *  "팔레트[255-i] = 반대색(팔레트[i])" 로 만들어 두었으므로 여기서도 똑같이
 *  XOR 하면 색이 반전되고, 한 번 더 하면 돌아온다.
 * ========================================================================== */
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <dpmi.h>                /* __dpmi_int, __dpmi_physical_address_mapping */
#include <go32.h>                /* _dos_ds, _my_ds, __tb */
#include <pc.h>                  /* outportb */
#include <sys/movedata.h>        /* movedata, dosmemget */
#include <time.h>                /* uclock */

#include "korea.h"

const char font_file_name[] = "KOREA256.SPR";

#define SPR_MAGIC       "KOR256S"
#define PREVIEW_X       16          /* 다음 스테이지 미리보기 창 안쪽 (픽셀) */
#define PREVIEW_Y       208         /* 원판 224 에서 한 줄(16) 위로 (data.c PREVIEW_13) */

static unsigned char fb[SCREEN_W * SCREEN_H];
static unsigned char sprite[256][256];
static unsigned char palette[768];
static unsigned char row_dirty[SCREEN_ROWS];

/* ---- VESA ----------------------------------------------------------------- */
typedef struct {
    unsigned short attributes;
    unsigned char  win_a_attr, win_b_attr;
    unsigned short granularity, win_size, seg_a, seg_b;
    unsigned long  func_ptr;
    unsigned short bytes_per_line, width, height;
    unsigned char  char_w, char_h, planes, bpp, banks, memory_model;
    unsigned char  bank_size, pages, reserved0;
    unsigned char  red_mask, red_pos, green_mask, green_pos;
    unsigned char  blue_mask, blue_pos, rsvd_mask, rsvd_pos, direct_color;
    unsigned long  phys_base;
    unsigned char  reserved[212];
} __attribute__((packed)) vbe_mode_info;

static int             video_mode;      /* 0x100, 0x101, 0x13 */
static int             top_margin;      /* 화면 위 빈 줄 수 */
static int             line_bytes;      /* 화면 한 줄 바이트 수 */

static int             lfb_sel;         /* 0 이 아니면 선형 프레임 버퍼 */
static __dpmi_meminfo  lfb_map;

static int             bank_window;     /* 0 = 창 A, 1 = 창 B */
static unsigned long   bank_addr;       /* 창 선형 주소 (A0000) */
static unsigned long   bank_size;       /* 창 크기 */
static unsigned long   bank_step;       /* 뱅크 한 칸 크기 */
static long            bank_now = -1;

static void bios_set_mode(int mode)
{
    __dpmi_regs r;

    memset(&r, 0, sizeof r);
    r.x.ax = mode;
    __dpmi_int(0x10, &r);
}

static int vbe_get_mode_info(int mode, vbe_mode_info *mi)
{
    __dpmi_regs r;

    memset(&r, 0, sizeof r);
    r.x.ax = 0x4F01;
    r.x.cx = mode;
    r.x.es = (__tb >> 4) & 0xFFFF;
    r.x.di = __tb & 0x0F;
    __dpmi_int(0x10, &r);
    if (r.x.ax != 0x004F)
        return 0;
    dosmemget(__tb, sizeof *mi, mi);
    return (mi->attributes & 0x01) && mi->bpp == 8 &&
           mi->width >= SCREEN_W && mi->height >= SCREEN_H;
}

static void lfb_release(void)
{
    if (lfb_sel) {
        __dpmi_free_ldt_descriptor(lfb_sel);
        __dpmi_free_physical_address_mapping(&lfb_map);
        lfb_sel = 0;
    }
}

static int lfb_setup(const vbe_mode_info *mi)
{
    int sel;

    if (!(mi->attributes & 0x80) || mi->phys_base == 0)
        return 0;
    lfb_map.address = mi->phys_base;
    lfb_map.size    = (unsigned long)mi->bytes_per_line * mi->height;
    if (__dpmi_physical_address_mapping(&lfb_map) != 0)
        return 0;
    sel = __dpmi_allocate_ldt_descriptors(1);
    if (sel <= 0) {
        __dpmi_free_physical_address_mapping(&lfb_map);
        return 0;
    }
    __dpmi_set_segment_base_address(sel, lfb_map.address);
    __dpmi_set_segment_limit(sel, (lfb_map.size - 1) | 0xFFF);
    lfb_sel = sel;
    return 1;
}

static int try_vesa(int mode)
{
    vbe_mode_info mi;
    __dpmi_regs r;

    if (!vbe_get_mode_info(mode, &mi))
        return 0;

    if (!lfb_setup(&mi)) {                      /* 뱅크 창 방식 */
        if ((mi.win_a_attr & 0x05) == 0x05) {
            bank_window = 0;
            bank_addr   = (unsigned long)mi.seg_a << 4;
        } else if ((mi.win_b_attr & 0x05) == 0x05) {
            bank_window = 1;
            bank_addr   = (unsigned long)mi.seg_b << 4;
        } else
            return 0;
        bank_size = (unsigned long)mi.win_size * 1024;
        bank_step = (unsigned long)mi.granularity * 1024;
        if (bank_size == 0 || bank_step == 0)
            return 0;
    }

    memset(&r, 0, sizeof r);
    r.x.ax = 0x4F02;
    r.x.bx = mode | (lfb_sel ? 0x4000 : 0);
    __dpmi_int(0x10, &r);
    if (r.x.ax != 0x004F) {
        lfb_release();
        return 0;
    }

    video_mode = mode;
    line_bytes = mi.bytes_per_line;
    top_margin = (mi.height - SCREEN_H) / 2;
    bank_now   = -1;
    return 1;
}

/* 화면 메모리 offset 에 len 바이트를 쓴다 (LFB 또는 뱅크를 넘기며) */
static void vram_write(unsigned long offset, const unsigned char *src, unsigned long len)
{
    __dpmi_regs r;
    unsigned long bank, off, n;

    if (lfb_sel) {
        movedata(_my_ds(), (unsigned)src, lfb_sel, offset, len);
        return;
    }
    while (len > 0) {
        bank = offset / bank_step;
        off  = offset - bank * bank_step;
        n    = bank_size - off;
        if (n > len)
            n = len;
        if ((long)bank != bank_now) {
            memset(&r, 0, sizeof r);
            r.x.ax = 0x4F05;
            r.x.bx = bank_window;
            r.x.dx = bank;
            __dpmi_int(0x10, &r);
            bank_now = bank;
        }
        movedata(_my_ds(), (unsigned)src, _dos_ds, bank_addr + off, n);
        src += n;
        offset += n;
        len -= n;
    }
}

static void set_palette(void)
{
    int i;

    outportb(0x3C8, 0);
    for (i = 0; i < 768; i++)
        outportb(0x3C9, palette[i]);
}

static void mark_rows(int first_line, int last_line)
{
    int r;

    for (r = first_line / 16; r <= last_line / 16 && r < SCREEN_ROWS; r++)
        if (r >= 0)
            row_dirty[r] = 1;
}

/* ---------------------------------------------------------------------------
 *  원래 chrinit 자리.  KOREA256.SPR 을 읽는다.  없거나 틀리면 -1.
 * ------------------------------------------------------------------------- */
int load_font(void)
{
    char magic[8];
    int fd, c, ok;

    fd = open("korea256.spr", O_RDONLY | O_BINARY);
    if (fd == -1)
        return -1;

    ok = read(fd, magic, 8) == 8 && memcmp(magic, SPR_MAGIC, 8) == 0 &&
         read(fd, palette, sizeof palette) == sizeof palette;
    for (c = 0; ok && c < 256; c++)
        ok = read(fd, sprite[c], 256) == 256;
    close(fd);
    return ok ? 0 : -1;
}

/* ---------------------------------------------------------------------------
 *  원래 grset 자리.
 * ------------------------------------------------------------------------- */
void video_init(void)
{
    memset(fb, 0, sizeof fb);
    if (!try_vesa(0x100) && !try_vesa(0x101)) {
        bios_set_mode(0x13);
        video_mode = 0x13;
    }
    set_palette();
    memset(row_dirty, 1, sizeof row_dirty);
}

/* ---------------------------------------------------------------------------
 *  원래 textset 자리.
 * ------------------------------------------------------------------------- */
void video_shutdown(void)
{
    memset(fb, 0, sizeof fb);
    sound_off();
    lfb_release();
    bios_set_mode(0x03);
}

/* ---------------------------------------------------------------------------
 *  바뀐 글자 줄(16 화면 줄)만 화면으로 옮긴다.
 * ------------------------------------------------------------------------- */
/* ============================ 부드러운 블록 이동 ==============================
 *  떨어지는 블록/아이템은 draw_board 가 판(fb)에 빈칸으로 찍고 여기로 넘겨준다.
 *  화면으로 내보낼 때 fb 위에 겹쳐 그리는데, 칸 위치가 바뀌면 이전 자리에서
 *  새 자리까지 픽셀 단위로 미끄러진다.  가로와 세로는 따로 움직인다.
 *      옆으로 옮김 : 한 틱(SLIDE_TIME) 동안 일정한 속도로 - 키를 누르고 있으면
 *                    틱마다 이어져서 멈칫거리지 않고 쭉 미끄러진다
 *      Space 로 바닥까지 떨어뜨림 : 중력가속도 DROP_GRAVITY 로 점점 빨라지며 떨어진다
 *  화면은 VGA 수직 귀선에 맞춰 내보낸다 - 줄을 나눠 쓰는 도중에 화면이 그려져
 *  블록이 어긋나 보이며 깜빡이는 것(찢김)을 막는다.
 *      저절로 떨어짐 / 아래 화살표 : 원본처럼 칸 단위로 바로 옮긴다
 *  게임 규칙(칸 단위 이동, 부딪힘)은 그대로다.
 * ========================================================================== */
#define SLIDE_TIME   (UCLOCKS_PER_SEC * 10 / 182)  /* 게임 한 틱 (약 55ms) */
#define DROP_GRAVITY 3500.0                       /* 바닥까지 떨어질 때 가속도 (픽셀/초^2) */
#define EASE_OUT     0                             /* 움직임 모양 */
#define EASE_FALL    1                             /* 점점 빨라진다 */
#define EASE_LINEAR  2                             /* 일정한 속도 */
#define SLIDE_MAX    32                            /* 이보다 멀면 바로 옮긴다 */
#define CLIP_X0      ((FIELD_LEFT + FIELD_X) * 16)
#define CLIP_X1      ((FIELD_RIGHT + FIELD_X + 1) * 16)
#define CLIP_Y0      (FIELD_TOP * 16)
#define CLIP_Y1      ((FIELD_BOTTOM + 1) * 16)

/* 한 축(가로 또는 세로)의 움직임 */
typedef struct {
    int      pos;                                  /* 지금 그리는 픽셀 */
    int      from, to;
    uclock_t start, time;
    int      ease;                                 /* EASE_OUT / EASE_FALL / EASE_LINEAR */
    int      moving;
} slide_axis;

static struct {
    int           n, key;
    signed char   dx[16], dy[16];
    unsigned char code[16];
    slide_axis    x, y;
} piece;

int video_smooth_piece(void)
{
    return 1;
}

int video_has_color(void)
{
    return 1;
}

/* 화면에 블록을 그려 넣은 줄 - 블록이 바뀌면 이 줄들을 꼭 다시 그려야
   잔상이 남지 않는다 (video_present 가 줄을 내보낼 때마다 적는다) */
static unsigned char piece_shown[SCREEN_ROWS];

/* 지금 위치의 블록이 글자 줄 row 에 걸치나 */
static int piece_covers(int row)
{
    int line0 = row * 16, i, top;

    for (i = 0; i < piece.n; i++) {
        top = piece.y.pos + piece.dy[i] * 16;
        if (top < CLIP_Y1 && top + 16 > CLIP_Y0 && top < line0 + 16 && top + 16 > line0)
            return 1;
    }
    return 0;
}

/* 블록이 바뀌었다: 전에 그려 둔 줄과 새로 걸치는 줄을 모두 다시 그리게 */
static void piece_changed(void)
{
    int r;

    for (r = 0; r < SCREEN_ROWS; r++)
        if (piece_shown[r] || piece_covers(r))
            row_dirty[r] = 1;
}

static void axis_snap(slide_axis *a, int target)
{
    a->pos = a->from = a->to = target;
    a->moving = 0;
}

static void axis_move(slide_axis *a, int target, uclock_t now, uclock_t time, int ease)
{
    if (target == a->to)
        return;
    a->from   = a->pos;                            /* 움직이던 자리에서 이어서 */
    a->to     = target;
    a->start  = now;
    a->time   = time;
    a->ease   = ease;
    a->moving = 1;
}

/* 지금 시각의 위치로.  바뀌었으면 1 */
static int axis_update(slide_axis *a, uclock_t now)
{
    int old = a->pos;
    double t;

    if (!a->moving)
        return 0;
    if (now - a->start >= a->time) {
        a->pos = a->to;
        a->moving = 0;
    } else {
        t = (double)(now - a->start) / a->time;
        if (a->ease == EASE_FALL)
            t = t * t;                             /* 중력: 거리 = 시간^2 에 비례 */
        else if (a->ease == EASE_OUT)
            t = 1.0 - (1.0 - t) * (1.0 - t);       /* 처음 빠르고 끝에서 부드럽게 */
        a->pos = a->from + (int)((a->to - a->from) * t + (a->to > a->from ? 0.5 : -0.5));
    }
    return a->pos != old;
}

static int piece_update(uclock_t now)
{
    int cx = axis_update(&piece.x, now);
    int cy = axis_update(&piece.y, now);
    return cx || cy;
}

static void present_rows(void);

/* 가만히 있다가 가속도 DROP_GRAVITY 로 d 픽셀을 떨어지는 데 걸리는 시간
   d = g t^2 / 2  ->  t = sqrt(2d / g).  (위치는 axis_update 에서 d * (t/T)^2) */
static uclock_t fall_time(int d)
{
    double x = 2.0 * (d > 0 ? d : 1) / DROP_GRAVITY, r = x > 1.0 ? x : 1.0;
    int i;

    for (i = 0; i < 20; i++)                       /* 제곱근 (뉴턴법) */
        r = 0.5 * (r + x / r);
    return (uclock_t)(r * UCLOCKS_PER_SEC);
}

void video_set_piece(int key, int col, int row, int n,
                     const signed char *dx, const signed char *dy, const unsigned char *code,
                     int dropped)
{
    int tx = col * 16, ty = row * 16;
    uclock_t now = uclock();
    int i;

    piece_update(now);

    /* key < 0 : 움직이는 블록이 없다.  n == 0 : 블록은 있지만 아직 안 보이는
       위 줄(0..2행)에 있다 - 이때도 위치는 기억해야 나오자마자 Space 를 눌러도
       떨어지는 모습이 보인다 */
    if (key < 0 || key != piece.key ||
        tx - piece.x.to > SLIDE_MAX || piece.x.to - tx > SLIDE_MAX) {
        axis_snap(&piece.x, tx);                   /* 새 블록, 회전, 블록 없음 */
        axis_snap(&piece.y, ty);
    } else {
        axis_move(&piece.x, tx, now, SLIDE_TIME, EASE_LINEAR);
        if (dropped && ty > piece.y.to)            /* Space: 바닥까지 떨어진다 */
            axis_move(&piece.y, ty, now, fall_time(ty - piece.y.pos), EASE_FALL);
        else if (ty != piece.y.to && !(piece.y.moving && piece.y.ease == EASE_FALL))
            axis_snap(&piece.y, ty);               /* 저절로 / 아래 화살표: 칸 단위 */
        else if (ty != piece.y.to)
            axis_move(&piece.y, ty, now, SLIDE_TIME, EASE_OUT);   /* 떨어지던 중에 바뀜 */
    }

    piece.key = key;
    piece.n = n > 16 ? 16 : n;
    for (i = 0; i < piece.n; i++) {
        piece.dx[i] = dx[i];
        piece.dy[i] = dy[i];
        piece.code[i] = code[i];
    }
    piece_changed();                               /* 전 자리 지우고 새 자리 그리기 */
}

/* 기다리는 동안: 움직이는 중이면 위치를 옮겨 다시 내보낸다 */
static int retrace_was;                            /* 지난번에 귀선 중이었나 */

void video_idle(void)
{
    int now = inportb(0x3DA) & 0x08;               /* VGA 입력 상태: 수직 귀선 */
    int started = now && !retrace_was;

    retrace_was = now;
    if (!started)                                  /* 화면 한 장에 한 번만 */
        return;
    if (piece_update(uclock()))
        piece_changed();
    present_rows();
}

/* 글자 줄 하나(16 화면 줄) = fb + 블록 겹쳐 그리기 */
static const unsigned char *compose_row(int row)
{
    static unsigned char buf[16 * SCREEN_W];
    const unsigned char *s;
    int line0 = row * 16, i, px, py, x, y, x0, x1, y0, y1;

    if (piece.n == 0)
        return fb + line0 * SCREEN_W;
    memcpy(buf, fb + line0 * SCREEN_W, sizeof buf);
    for (i = 0; i < piece.n; i++) {
        px = piece.x.pos + piece.dx[i] * 16;
        py = piece.y.pos + piece.dy[i] * 16;
        x0 = px < CLIP_X0 ? CLIP_X0 : px;
        x1 = px + 16 > CLIP_X1 ? CLIP_X1 : px + 16;
        y0 = py < CLIP_Y0 ? CLIP_Y0 : py;
        y1 = py + 16 > CLIP_Y1 ? CLIP_Y1 : py + 16;
        if (y0 < line0)
            y0 = line0;
        if (y1 > line0 + 16)
            y1 = line0 + 16;
        s = sprite[piece.code[i]];
        for (y = y0; y < y1; y++)
            for (x = x0; x < x1; x++)
                buf[(y - line0) * SCREEN_W + x] = s[(y - py) * 16 + (x - px)];
    }
    return buf;
}

static void present_rows(void)
{
    unsigned char half[SCREEN_W / 2];
    const unsigned char *src, *rowbuf;
    int row, i, x;

    for (row = 0; row < SCREEN_ROWS; row++) {
        if (!row_dirty[row])
            continue;
        row_dirty[row] = 0;
        rowbuf = compose_row(row);
        piece_shown[row] = (unsigned char)piece_covers(row);

        if (video_mode == 0x13) {                  /* 320x200: 한 점 건너 한 점 */
            for (i = 0; i < 8; i++) {
                src = rowbuf + i * 2 * SCREEN_W;
                for (x = 0; x < SCREEN_W / 2; x++)
                    half[x] = src[x * 2];
                movedata(_my_ds(), (unsigned)half, _dos_ds,
                         0xA0000 + (row * 8 + i) * (SCREEN_W / 2), SCREEN_W / 2);
            }
        } else if (line_bytes == SCREEN_W) {
            vram_write((unsigned long)(row * 16 + top_margin) * line_bytes,
                       rowbuf, 16 * SCREEN_W);
        } else {
            for (i = 0; i < 16; i++)
                vram_write((unsigned long)(row * 16 + i + top_margin) * line_bytes,
                           rowbuf + i * SCREEN_W, SCREEN_W);
        }
    }
}

/* ---------------------------------------------------------------------------
 *  바뀐 줄을 내보낸다.  수직 귀선이 시작될 때까지 기다렸다가 (최대 20ms)
 *  한꺼번에 써서 찢김/깜빡임이 없게 한다.
 * ------------------------------------------------------------------------- */
void video_present(void)
{
    uclock_t limit = uclock() + UCLOCKS_PER_SEC / 50;

    while ((inportb(0x3DA) & 0x08) && uclock() < limit)
        ;
    while (!(inportb(0x3DA) & 0x08) && uclock() < limit)
        ;
    retrace_was = 1;
    if (piece_update(uclock()))
        piece_changed();
    present_rows();
}

/* ---------------------------------------------------------------------------
 *  원래 putptn 자리.  글자 칸 (x, y) 에 16x16 스프라이트를 찍는다.
 * ------------------------------------------------------------------------- */
void put_glyph(int x, int y, int code)
{
    const unsigned char *s = sprite[code & 0xFF];
    unsigned char *d = fb + y * 16 * SCREEN_W + x * 16;
    int i;

    for (i = 0; i < 16; i++) {
        memcpy(d, s, 16);
        d += SCREEN_W;
        s += 16;
    }
    row_dirty[y] = 1;
}

void invert_cells(int x, int y, int w, int h)
{
    unsigned char *d;
    int line, i;

    for (line = y * 16; line < (y + h) * 16; line++) {
        d = fb + line * SCREEN_W + x * 16;
        for (i = 0; i < w * 16; i++)
            *d++ ^= 0xFF;
    }
    mark_rows(y * 16, (y + h) * 16 - 1);
}

/* 다음 스테이지 미리보기: 원본의 8x8 무늬 대신 그 칸 스프라이트를 반으로 줄여 찍는다 */
void put_preview_cell(int col, int row, unsigned char cell)
{
    const unsigned char *s = sprite[cell];
    int px = PREVIEW_X + col * 8;
    int py = PREVIEW_Y + row * 8;
    unsigned char *d;
    int x, y;

    for (y = 0; y < 8; y++) {
        d = fb + (py + y) * SCREEN_W + px;
        for (x = 0; x < 8; x++)
            *d++ = s[(y * 2) * 16 + x * 2];
    }
    mark_rows(py, py + 7);
}

void copy_cell_row(int dst_row, int src_row, int x, int w)
{
    if (dst_row < 0 || dst_row >= SCREEN_ROWS || src_row < 0 || src_row >= SCREEN_ROWS)
        return;
    {
        int i;
        for (i = 0; i < 16; i++)
            memcpy(fb + (dst_row * 16 + i) * SCREEN_W + x * 16,
                   fb + (src_row * 16 + i) * SCREEN_W + x * 16, w * 16);
    }
    row_dirty[dst_row] = 1;
}

void clear_cell_row(int row, int x, int w)
{
    int i;

    if (row < 0 || row >= SCREEN_ROWS)
        return;
    for (i = 0; i < 16; i++)
        memset(fb + (row * 16 + i) * SCREEN_W + x * 16, 0, w * 16);
    row_dirty[row] = 1;
}
