/* ============================================================================
 *  system.c  -  파일, 키보드, 시계, 소리, 난수
 *               (원래 KOR-SUB.C 앞부분 + 터보 C 런타임 흉내)
 * ----------------------------------------------------------------------------
 *  원본은 BIOS 데이터 영역을 직접 만졌다.
 *      0040:001A / 001C   키보드 버퍼 머리 / 꼬리
 *      0040:006C          시계 틱 (초당 18.2번 증가)
 *  djgpp 에서도 _farpeek/_farpoke 로 같은 곳을 읽고 쓸 수 있어서 그대로 옮겼다.
 * ========================================================================== */
#include <bios.h>                /* bioskey */
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <dpmi.h>                /* __dpmi_yield */
#include <go32.h>                /* _dos_ds */
#include <sys/farptr.h>          /* _farpeekw, _farpokew, _farpeekb */
#include <pc.h>                  /* inportb, outportb */

#include "korea.h"

#define BDA_KBD_HEAD    0x41A
#define BDA_KBD_TAIL    0x41C
#define BDA_TICKS       0x46C
#define KBD_SLOT        0x30     /* 버퍼 머리/꼬리를 이 자리로 되돌린다 */

#define STAGE_RECORD    205      /* 스테이지 하나 = 지도 200 + 설정 5 바이트 */

/* ---------------------------------------------------------------------------
 *  원래: stage_load  (KOR-SUB.C:56, 239A)
 *  KOREA.STG (20500바이트) = 스테이지 100개 x (20x10 지도 + 설정 5바이트)
 *      설정: 떨어지는 간격, 아이템, 기믹, 보너스, 기믹 간격
 *  읽은 뒤 지금 스테이지(stage_no)의 지도를 판에 옮긴다.  파일이 없으면 -1.
 * ------------------------------------------------------------------------- */
int load_stages(void)
{
    signed char buf[MAP_ROWS * MAP_COLS];
    const signed char *p;
    int fd, i, j, k;

    fd = open("korea.stg", O_RDONLY | O_BINARY);
    if (fd == -1)
        return -1;

    for (i = 0; i < STAGE_COUNT; i++) {
        read(fd, buf, MAP_ROWS * MAP_COLS);
        p = buf;
        for (j = 0; j < MAP_ROWS; j++)
            for (k = 0; k < MAP_COLS; k++)
                stage_map[i][j][k] = (unsigned char)*p++;

        read(fd, buf, STAGE_RECORD - MAP_ROWS * MAP_COLS);
        stage_fall_delay[i]   = buf[0];
        stage_item[i]         = buf[1];
        stage_gimmick[i]      = buf[2];
        stage_bonus[i]        = buf[3];
        stage_gimmick_time[i] = buf[4];
    }
    close(fd);
    map_to_board();
    return 0;
}

/* ---------------------------------------------------------------------------
 *  원래: user_stage_save  (KOR-SUB.C:83, 24B7)
 *  편집 중인 판을 지도에 되돌려 놓고 100개를 모두 쓴다.
 * ------------------------------------------------------------------------- */
int save_stages(void)
{
    char buf[MAP_ROWS * MAP_COLS];
    char *p;
    int fd, i, j, k;

    fd = open("korea.stg", O_RDWR | O_CREAT | O_BINARY, S_IREAD | S_IWRITE);
    if (fd == -1)
        return -1;

    board_to_map();
    for (i = 0; i < STAGE_COUNT; i++) {
        p = buf;
        for (j = 0; j < MAP_ROWS; j++)
            for (k = 0; k < MAP_COLS; k++)
                *p++ = (char)stage_map[i][j][k];
        write(fd, buf, MAP_ROWS * MAP_COLS);

        buf[0] = (char)stage_fall_delay[i];
        buf[1] = (char)stage_item[i];
        buf[2] = (char)stage_gimmick[i];
        buf[3] = (char)stage_bonus[i];
        buf[4] = (char)stage_gimmick_time[i];
        write(fd, buf, STAGE_RECORD - MAP_ROWS * MAP_COLS);
    }
    return close(fd);
}

/* ---------------------------------------------------------------------------
 *  원래: inkey  (KOR-SUB.C:142, 26ED)
 *  bioskey(cmd) 로 읽어 ASCII 가 있으면 ASCII, 없으면 0x100 + 스캔 코드.
 *  원본에 없던 것: 키를 기다리는 동안 화면을 내보낸다.
 * ------------------------------------------------------------------------- */
int get_key(int cmd)
{
    int key, lo, hi;

    if (cmd == 0) {
        video_present();
        while (!bioskey(1)) {
            music_poll();
            video_idle();
            __dpmi_yield();
        }
    }
    key = bioskey(cmd);
    lo  = key & 0xFF;
    hi  = (key & 0xFF00) >> 8;
    return lo ? lo : hi + 0x100;
}

/* ---------------------------------------------------------------------------
 *  원래: key_scan_init  (KOR-SUB.C:151, 2727)
 *  키보드 버퍼를 비운다 (머리 = 꼬리 = 0x30).
 * ------------------------------------------------------------------------- */
void flush_keys(void)
{
    _farpokew(_dos_ds, BDA_KBD_TAIL, KBD_SLOT);
    _farpokew(_dos_ds, BDA_KBD_HEAD, KBD_SLOT);
}

/* ---------------------------------------------------------------------------
 *  원래: key_scan  (KOR-SUB.C:160, 2754)
 *  기다리지 않고 키를 본다.  버퍼가 비어 있으면 0.
 *  아니면 버퍼를 비우고, 비운 뒤 첫 번째로 눌린 키(0040:0030)의 스캔 코드를
 *  돌려준다.  그래서 키를 오래 누르고 있어도 한 틱에 한 번만 받는다.
 * ------------------------------------------------------------------------- */
int poll_key(void)
{
    if (_farpeekw(_dos_ds, BDA_KBD_HEAD) == _farpeekw(_dos_ds, BDA_KBD_TAIL))
        return 0;
    _farpokew(_dos_ds, BDA_KBD_TAIL, KBD_SLOT);
    _farpokew(_dos_ds, BDA_KBD_HEAD, KBD_SLOT);
    return (signed char)_farpeekb(_dos_ds, 0x400 + KBD_SLOT + 1);
}

/* ---------------------------------------------------------------------------
 *  원래: clock_wait  (KOR-SUB.C:174, 27A6)
 *  BIOS 시계 틱이 바뀔 때까지 기다린다 = 게임의 한 프레임 (1/18.2초).
 *  애니메이션 카운터를 돌리고 배경음악을 한 틱 진행한다.
 *  원본에 없던 것: 기다리기 전에 화면을 내보낸다.
 * ------------------------------------------------------------------------- */
void wait_tick(void)
{
    unsigned short now;

    video_present();
    now = _farpeekw(_dos_ds, BDA_TICKS);
    while (_farpeekw(_dos_ds, BDA_TICKS) == now) {
        music_poll();
        video_idle();
        __dpmi_yield();
    }

    anim_tick = anim_tick % 127 + 1;
    bgm_tick();
}

/* ---------------------------------------------------------------------------
 *  원래: sec_wait  (KOR-SUB.C:185, 27E2)   이름과 달리 초가 아니라 틱 수
 * ------------------------------------------------------------------------- */
void wait_ticks(int n)
{
    while (n--)
        wait_tick();
}

/* ---------------------------------------------------------------------------
 *  터보 C 런타임 rand / srand (코드 5A5B/5A6C) 와 같은 난수 계열.
 *      seed = seed * 0x015A4E35 + 1,  결과 = (seed >> 16) & 0x7FFF
 *  djgpp 의 rand 는 범위(RAND_MAX)가 달라서 원본과 같은 확률이 되도록 따로 둔다.
 * ------------------------------------------------------------------------- */
static unsigned long rand_seed = 1;

void srand16(unsigned seed)
{
    rand_seed = (unsigned short)seed;
}

int rand16(void)
{
    rand_seed = (rand_seed * 0x015A4E35UL + 1) & 0xFFFFFFFFUL;
    return (int)((rand_seed >> 16) & 0x7FFF);
}

/* ---------------------------------------------------------------------------
 *  터보 C 런타임 sound / nosound (코드 5ADA/5B06) 흉내.
 *  djgpp 의 sound 와 달리 18Hz 이하는 무시하고(이전 소리가 계속 난다),
 *  스피커가 이미 켜져 있으면 분주비만 바꾼다.
 * ------------------------------------------------------------------------- */
void sound_on(int hz)
{
    unsigned div;
    unsigned char v;

    if ((unsigned short)hz <= 18)
        return;
    div = (unsigned)(1193180UL / (unsigned short)hz);

    v = inportb(0x61);
    if ((v & 3) == 0) {
        outportb(0x61, v | 3);
        outportb(0x43, 0xB6);
    }
    outportb(0x42, (unsigned char)div);
    outportb(0x42, (unsigned char)(div >> 8));
}

void sound_off(void)
{
    outportb(0x61, inportb(0x61) & 0xFC);
}
