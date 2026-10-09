/* ============================================================================
 *  musvgm.c  -  배경음악과 효과음, 애드립(OPL2) VGM 재생  ->  KOREAVGA.EXE
 * ----------------------------------------------------------------------------
 *  원판의 PC 스피커 곡 대신 애드립으로 곡을 연주한다.  곡은 tools/mkmusic.py
 *  가 만든 VGM 이고, 모두 SOUND.DAT 한 파일에 묶여 있다.
 *      SOUND.DAT   0..7 "KRSND10"+0,  8..9 곡 수,
 *                  곡마다 20바이트 (이름 12 / 시작 위치 4 / 길이 4), 그 뒤 VGM 자료
 *      KTITLE.VGM  첫 메뉴      아리랑 (되풀이)
 *      KGAME.VGM   게임 중      코로베이니키 + 아리랑 메들리 (되풀이)
 *      KCLEAR.VGM  스테이지 깸  짧은 가락 (채널 5 는 비워 둔다)
 *      KOVER.VGM   게임 끝      짧은 가락
 *      KCOUNT.VGM  효과음       보너스를 점수로 바꿀 때 "띠링" (채널 5 만 쓴다)
 *  곡과 효과음은 따로 흘러가므로 겹쳐서 울릴 수 있다.
 *  애드립이 없거나 파일이 없으면 조용히 넘어간다.
 *  F1 (option_bits 의 OPT_MUSIC) 로 곡을 끄고 켤 수 있고, 처음에는 켜져 있다.
 *
 *  그 밖의 효과음은 원판처럼 PC 스피커로 내고, 시계 틱마다 끈다(bgm_tick).
 * ========================================================================== */
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>                /* uclock */
#include <pc.h>                  /* inportb, outportb */

#include "korea.h"

#define OPL_ADDR   0x388
#define OPL_DATA   0x389

#define SOUND_DAT  "sound.dat"
#define SOUND_MAGIC "KRSND10"

static const char *const song_file[] = {
    NULL, "KTITLE.VGM", "KGAME.VGM", "KCLEAR.VGM", "KOVER.VGM"
};
static const char *const effect_file[] = {
    "KCOUNT.VGM"
};

/* VGM 자료 하나를 흘려보내는 상태 */
typedef struct {
    unsigned char *buf;
    long           len, pos, loop;
    uclock_t       next;
    int            on;
} vgm_stream;

static int        opl_found = -1;          /* -1 아직 안 봄, 0 없음, 1 있음 */
static int        cur_song;                /* 올려 둔 곡 */
static int        paused;                  /* F1 로 멈춤 */
static vgm_stream song;
static vgm_stream effect;
static int        effect_loaded = -1;      /* effect.buf 에 올린 효과음 번호 */

/* OPL2 는 레지스터를 쓴 뒤 조금 쉬어야 한다 - 상태 포트를 몇 번 읽는다 */
static void opl_wait(int n)
{
    int i;
    for (i = 0; i < n; i++)
        (void)inportb(OPL_ADDR);
}

static void opl_write(int reg, int val)
{
    outportb(OPL_ADDR, (unsigned char)reg);
    opl_wait(6);
    outportb(OPL_DATA, (unsigned char)val);
    opl_wait(35);
}

/* 타이머1 을 돌려 상태 비트가 바뀌는지 본다 */
static int opl_detect(void)
{
    unsigned char s1, s2;

    opl_write(4, 0x60);
    opl_write(4, 0x80);
    s1 = inportb(OPL_ADDR);
    opl_write(2, 0xFF);
    opl_write(4, 0x21);
    opl_wait(400);
    s2 = inportb(OPL_ADDR);
    opl_write(4, 0x60);
    opl_write(4, 0x80);
    return (s1 & 0xE0) == 0x00 && (s2 & 0xE0) == 0xC0;
}

static int opl_ready(void)
{
    if (opl_found < 0)
        opl_found = opl_detect();
    return opl_found;
}

/* 효과음이 울리는 중이면 효과음 채널(5: 키 B5, 음량 4A/4D)은 건드리지 않는다 */
static void opl_silence(void)
{
    int keep = effect.on;
    int i;

    for (i = 0xB0; i <= 0xB8; i++)
        if (!(keep && i == 0xB5))
            opl_write(i, 0x00);                     /* 키 오프 */
    opl_write(0xBD, 0x00);                          /* 리듬부 끄기 */
    for (i = 0x40; i <= 0x55; i++)
        if (!(keep && (i == 0x4A || i == 0x4D)))
            opl_write(i, 0x3F);                     /* 음량 최소 */
}

/* 칩을 처음 켠 상태로 - 끝날 때 소리 꼬리가 남지 않게 */
static void opl_reset(void)
{
    int i;

    opl_silence();
    for (i = 0x60; i <= 0x75; i++)
        opl_write(i, 0xFF);
    for (i = 0x80; i <= 0x95; i++)
        opl_write(i, 0xFF);
    for (i = 0x01; i <= 0xF5; i++)
        opl_write(i, 0x00);
}

static unsigned long le32(const unsigned char *p)
{
    return p[0] | (unsigned long)p[1] << 8 | (unsigned long)p[2] << 16 | (unsigned long)p[3] << 24;
}

static uclock_t samples_to_uclock(long n)
{
    return (uclock_t)((double)n * UCLOCKS_PER_SEC / 44100.0);
}

/* SOUND.DAT 목차에서 name 을 찾아 그 VGM 을 통째로 읽어 온다.  못 찾으면 0 */
static int stream_load(vgm_stream *s, const char *name)
{
    unsigned char head[10], entry[20];
    unsigned long off = 0, size = 0;
    int fd, count, i, found = 0;

    free(s->buf);
    s->buf = NULL;
    s->len = 0;
    s->on  = 0;

    fd = open(SOUND_DAT, O_RDONLY | O_BINARY);
    if (fd == -1)
        return 0;
    if (read(fd, head, 10) != 10 || memcmp(head, SOUND_MAGIC, 8) != 0) {
        close(fd);
        return 0;
    }
    count = head[8] | head[9] << 8;
    for (i = 0; i < count && !found; i++) {
        if (read(fd, entry, 20) != 20)
            break;
        if (strncmp((char *)entry, name, 12) == 0) {
            off   = le32(entry + 12);
            size  = le32(entry + 16);
            found = 1;
        }
    }
    if (!found || size < 0x40 || size > 1024L * 1024L ||
        lseek(fd, off, SEEK_SET) != (off_t)off || (s->buf = malloc(size)) == NULL) {
        close(fd);
        return 0;
    }
    s->len = read(fd, s->buf, size);
    close(fd);
    if (s->len < 0x40 || memcmp(s->buf, "Vgm ", 4) != 0) {
        free(s->buf);
        s->buf = NULL;
        return 0;
    }
    return 1;
}

/* 처음부터 흘려보내기 시작한다 */
static void stream_start(vgm_stream *s)
{
    unsigned long loop, data;

    loop = le32(s->buf + 0x1C);                     /* 되풀이 시작 (상대값) */
    s->loop = loop ? (long)(0x1C + loop) : 0;
    if (s->loop >= s->len)
        s->loop = 0;
    data = le32(s->buf + 0x34);                     /* 자료 시작 (1.50 판부터) */
    s->pos  = data ? (long)(0x34 + data) : 0x40;
    s->next = uclock();
    s->on   = 1;
}

/* 시각이 된 명령을 칩에 보낸다.  끝나면 0 */
static int stream_poll(vgm_stream *s)
{
    uclock_t now;
    unsigned char c;
    const unsigned char *b = s->buf;

    now = uclock();
    if (now > s->next + UCLOCKS_PER_SEC / 4)        /* 한참 밀렸으면 지금에 맞춘다 */
        s->next = now;

    while (now >= s->next) {
        if (s->pos >= s->len) {
            if (!s->loop)
                return 0;
            s->pos = s->loop;
        }
        c = b[s->pos];
        if (c == 0x5A) {                            /* OPL2 레지스터 쓰기 */
            opl_write(b[s->pos + 1], b[s->pos + 2]);
            s->pos += 3;
        } else if (c == 0x61) {                     /* n 샘플 쉬기 */
            s->next += samples_to_uclock(b[s->pos + 1] | b[s->pos + 2] << 8);
            s->pos += 3;
        } else if (c == 0x62) {
            s->next += samples_to_uclock(735);
            s->pos++;
        } else if (c == 0x63) {
            s->next += samples_to_uclock(882);
            s->pos++;
        } else if (c >= 0x70 && c <= 0x7F) {
            s->next += samples_to_uclock((c & 15) + 1);
            s->pos++;
        } else if (c == 0x66) {                     /* 끝 */
            if (!s->loop)
                return 0;
            s->pos = s->loop;
        } else if (c >= 0x51 && c <= 0x5F) {        /* 다른 칩 - 건너뛴다 */
            s->pos += 3;
        } else {
            s->pos++;
        }
        now = uclock();
    }
    return 1;
}

static void start_song(void)
{
    int i;

    for (i = 0x20; i <= 0xF5; i++)
        opl_write(i, 0x00);
    opl_write(0x01, 0x20);                          /* 웨이브폼 선택 허용 */
    opl_silence();
    stream_start(&song);
}

static void stop_song(void)
{
    if (song.on) {
        song.on = 0;
        opl_silence();
    }
}

static void music_exit(void)
{
    song.on = effect.on = 0;
    if (opl_found == 1)
        opl_reset();
}

void music_init(void)
{
    option_bits |= OPT_MUSIC;
    atexit(music_exit);
}

/* ---------------------------------------------------------------------------
 *  곡을 바꾼다.  같은 곡이 이미 울리고 있으면 그대로 둔다.
 * ------------------------------------------------------------------------- */
void music_play(int which)
{
    if (!opl_ready())
        return;
    if (which == cur_song && (song.on || paused))
        return;

    stop_song();
    paused = 0;
    cur_song = which;
    if (which == SONG_NONE || !stream_load(&song, song_file[which]))
        return;
    if (option_bits & OPT_MUSIC)
        start_song();
    else
        paused = 1;
}

/* ---------------------------------------------------------------------------
 *  효과음 - 곡과 따로 처음부터 울린다 (같은 효과음이 울리던 중이면 새로 시작).
 *  음색도 VGM 안에서 매번 다시 쓰므로 곡이 칩을 지운 뒤에도 제 소리가 난다.
 * ------------------------------------------------------------------------- */
void music_effect(int which)
{
    if (!opl_ready())
        return;
    if (effect_loaded != which) {
        effect_loaded = -1;
        if (!stream_load(&effect, effect_file[which]))
            return;
        effect_loaded = which;
    }
    opl_write(0x01, 0x20);
    stream_start(&effect);
}

/* ---------------------------------------------------------------------------
 *  wait_tick / get_key 가 기다리는 동안 계속 부른다.
 * ------------------------------------------------------------------------- */
void music_poll(void)
{
    if (song.on && !stream_poll(&song))
        stop_song();
    if (effect.on && !stream_poll(&effect))
        effect.on = 0;
}

/* ---------------------------------------------------------------------------
 *  원래 music_play 자리 - 시계 틱마다.
 *  F1 로 음악을 끄고 켜는 것을 반영하고, 원판처럼 PC 스피커 효과음은 한 틱만
 *  울리게 끈다.
 * ------------------------------------------------------------------------- */
void bgm_tick(void)
{
    sound_off();

    if (!(option_bits & OPT_MUSIC)) {
        if (song.on) {
            stop_song();
            paused = 1;
        }
    } else if (paused && song.buf) {
        paused = 0;
        start_song();
    }
}
