/* ============================================================================
 *  music.c  -  배경음악, 원판 그대로 PC 스피커  (원래 KOR-BGM.C)  ->  KOREA.EXE
 * ========================================================================== */
#include "korea.h"

/* 원판에는 곡 바꾸기가 없다 - 게임 중 F1 로 켜고 끄는 한 곡뿐 */
void music_init(void)       { }
void music_play(int song)   { (void)song; }
void music_poll(void)       { }

/* 효과음 - 원판 그대로 PC 스피커.  보너스를 점수로 바꿀 때 200Hz 를 한 틱 */
void music_effect(int effect)
{
    if (effect == EFFECT_BONUS_COUNT)
        sound_on(200);
}

/* ---------------------------------------------------------------------------
 *  원래: music_play  (KOR-BGM.C:41, 01BC)
 *  시계 한 틱(1/18.2초)마다 wait_tick 이 부른다.
 *  bgm_score 는 (음 번호, 길이) 쌍이고, 길이만큼 틱이 지나면 다음 음으로 간다.
 *  소리를 켤 때마다 주파수를 1Hz 씩 올려서 음이 살짝 떨리게 들린다(원본대로).
 * ------------------------------------------------------------------------- */
void bgm_tick(void)
{
    if (option_bits & OPT_MUSIC)
        sound_on(bgm_freq++);
    else
        sound_off();

    if (bgm_wait-- == 0) {
        bgm_freq = note_freq[bgm_score[bgm_song][bgm_pos++]];
        bgm_wait = bgm_score[bgm_song][bgm_pos++];
        if (bgm_wait == 0)
            bgm_pos = 0;
    }
}
