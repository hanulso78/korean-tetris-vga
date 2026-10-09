# -*- coding: utf-8 -*-
"""KOREAVGA.EXE 배경음악 - 애드립(OPL2) VGM 곡을 만들어 SOUND.DAT 로 묶는다.

   쓰는 법 :  python mkmusic.py [만들 폴더] [--vgm]   (기본: 이 폴더의 한 칸 위)
              --vgm 을 주면 묶기 전의 VGM 파일도 따로 남긴다 (들어 보기용)

   SOUND.DAT 구조
       0..7    "KRSND10" + 0
       8..9    곡 수 (2바이트, 낮은 자리 먼저)
       10..    곡마다 20바이트  이름 12 (0 으로 채움) / 시작 위치 4 / 길이 4
       그 뒤   VGM 자료 (VGM 파일 그대로)

       KTITLE.VGM  메뉴       아리랑 - 록 편곡 (D장조, 132 BPM, 되풀이)
       KGAME.VGM   게임 중    코로베이니키 -> 아리랑 메들리 (170 BPM, 되풀이)
       KCLEAR.VGM  스테이지 깸  "넘어간다" 가락으로 만든 짧은 팡파르
       KOVER.VGM   게임 끝    느리게 가라앉는 단조 가락
       KCOUNT.VGM  효과음     보너스를 점수로 바꿀 때 "띠링" (채널 5 만 쓴다)

   두 가락 모두 오래된 민요(저작권 없음)이고 편곡은 여기서 새로 했다.
   OPL2 리듬 모드: 가락 채널 0..5 + 베이스드럼/스네어/하이햇/탐/심벌.
       0 리드   1 리드 겹침(옥타브)   2 베이스   3..5 코드 또는 가야금풍 뜯기
"""
import os, struct, sys

SR = 44100

# ---------------------------------------------------------------- 음색 ------
# (모듈레이터 20 40 60 80 E0), (캐리어 20 40 60 80 E0), C0
P_LEAD   = ((0x21, 0x15, 0xF4, 0x35, 0x00), (0x21, 0x02, 0xF2, 0x15, 0x00), 0x0C)
P_LEAD2  = ((0x21, 0x18, 0xF4, 0x35, 0x00), (0x21, 0x0A, 0xF2, 0x15, 0x00), 0x0C)
P_BASS   = ((0x20, 0x1D, 0xB4, 0x0F, 0x00), (0x21, 0x00, 0xC3, 0x0F, 0x00), 0x3E)
P_STAB   = ((0x22, 0x1E, 0xF3, 0x16, 0x00), (0x21, 0x10, 0xF3, 0x16, 0x00), 0x01)
P_PLUCK  = ((0x01, 0x1B, 0xF6, 0x56, 0x00), (0x01, 0x06, 0xF4, 0x57, 0x00), 0x0A)
P_PAD    = ((0x21, 0x22, 0x74, 0x24, 0x00), (0x21, 0x0C, 0x63, 0x25, 0x00), 0x0C)
# 리듬부
P_BD     = ((0x00, 0x07, 0xD8, 0x0F, 0x00), (0x00, 0x00, 0xF5, 0x0F, 0x00), 0x38)
P_HH_SD  = ((0x01, 0x0C, 0xF8, 0x0F, 0x00), (0x01, 0x04, 0xF7, 0x0F, 0x00), 0x39)
P_TOM_CY = ((0x04, 0x05, 0xF7, 0x0F, 0x00), (0x0E, 0x0C, 0xC9, 0x0F, 0x00), 0x3D)

BD, SD, TOM, CYM, HH = 0x10, 0x08, 0x04, 0x02, 0x01

OP1 = [0x00, 0x01, 0x02, 0x08, 0x09, 0x0A, 0x10, 0x11, 0x12]
OP2 = [0x03, 0x04, 0x05, 0x0B, 0x0C, 0x0D, 0x13, 0x14, 0x15]

def fnum_block(midi):
    f = 440.0 * 2.0 ** ((midi - 69) / 12.0)
    for blk in range(8):
        fn = int(round(f * (1 << (20 - blk)) / 49716.0))
        if fn < 1024 and (fn >= 300 or blk == 7):
            return fn, blk
    return 1023, 7

NAMES = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}

def midi(name):
    k = NAMES[name[0]]
    i = 1
    while i < len(name) and name[i] in '#b':
        k += 1 if name[i] == '#' else -1
        i += 1
    return (int(name[i:]) + 1) * 12 + k

def seq(text):
    """'E5/4 B4/2 r/2 ...' -> [(시작, 길이, midi 또는 None)]  단위 16분음표"""
    out, t = [], 0
    for tok in text.split():
        name, ln = tok.split('/')
        ln = int(ln)
        out.append((t, ln, None if name == 'r' else midi(name)))
        t += ln
    return out, t

# ---------------------------------------------------------------- 악보 틀 ---
class Song:
    def __init__(self, bpm):
        self.tick_samples = SR * 60.0 / bpm / 4          # 16분음표 한 칸
        self.ev = []                                     # (칸, 순서, 종류, 값...)
        self.loop_tick = None
        self.end_tick = 0

    def patch(self, t, ch, p):
        self.ev.append((t, 0, 'patch', ch, p))

    def note(self, t, ln, ch, m, gap=0.12, shift=0):
        if m is None:
            return
        self.ev.append((t, 2, 'on', ch, m + shift))
        self.ev.append((t + ln - min(gap, ln * 0.5), 1, 'off', ch, 0))
        self.end_tick = max(self.end_tick, t + ln)

    def melody(self, t, text, ch, shift=0, gap=0.12):
        notes, total = seq(text)
        for st, ln, m in notes:
            self.note(t + st, ln, ch, m, gap, shift)
        return total

    def drum(self, t, mask):
        self.ev.append((t, 3, 'drum', mask, 0))
        self.end_tick = max(self.end_tick, t + 1)

    def tom_pitch(self, t, m):
        self.ev.append((t, 0, 'tompitch', 8, m))

    def level(self, t, ch, tl):
        self.ev.append((t, 0, 'level', ch, tl))

class Writer:
    def __init__(self):
        self.d = bytearray()
        self.samples = 0

    def w(self, reg, val):
        self.d += bytes((0x5A, reg & 0xFF, val & 0xFF))

    def wait_until(self, s):
        n = int(round(s)) - self.samples
        if n <= 0:
            return
        self.samples += n
        while n > 65535:
            self.d += bytes((0x61, 0xFF, 0xFF))
            n -= 65535
        self.d += bytes((0x61, n & 0xFF, n >> 8))

    def patch(self, ch, p):
        mod, car, c0 = p
        for r, v in zip((0x20, 0x40, 0x60, 0x80, 0xE0), mod):
            self.w(r + OP1[ch], v)
        if car:
            for r, v in zip((0x20, 0x40, 0x60, 0x80, 0xE0), car):
                self.w(r + OP2[ch], v)
        self.w(0xC0 + ch, c0)

def render(song, name, effect=False):
    """effect=True 면 효과음: 리듬부/전체 설정을 건드리지 않고 쓴 채널만 끈다
       (곡이 울리는 중에 겹쳐 틀기 때문)"""
    v = Writer()
    rhythm = 0x20
    if not effect:
        v.w(0x01, 0x20)
        v.w(0x08, 0x00)
        v.patch(6, P_BD)
        v.patch(7, P_HH_SD)
        v.patch(8, P_TOM_CY)
        for ch, m in ((6, 36), (7, 60), (8, 50)):
            fn, blk = fnum_block(m)
            v.w(0xA0 + ch, fn & 0xFF)
            v.w(0xB0 + ch, blk << 2 | fn >> 8)
        v.w(0xBD, rhythm)

    events = sorted(song.ev, key=lambda e: (e[0], e[1]))
    loop_offset = None
    carrier_patch = {}
    i = 0
    while i < len(events):
        t = events[i][0]
        if song.loop_tick is not None and loop_offset is None and t >= song.loop_tick:
            v.wait_until(song.loop_tick * song.tick_samples)
            loop_offset = len(v.d)
        v.wait_until(t * song.tick_samples)
        mask = 0
        while i < len(events) and events[i][0] == t:
            e = events[i]
            kind = e[2]
            if kind == 'patch':
                v.patch(e[3], e[4])
                carrier_patch[e[3]] = e[4]
            elif kind == 'on':
                fn, blk = fnum_block(e[4])
                v.w(0xB0 + e[3], blk << 2 | fn >> 8)          # 먼저 키 오프
                v.w(0xA0 + e[3], fn & 0xFF)
                v.w(0xB0 + e[3], 0x20 | blk << 2 | fn >> 8)
            elif kind == 'off':
                v.w(0xB0 + e[3], 0x00)
            elif kind == 'drum':
                mask |= e[3]
            elif kind == 'tompitch':
                fn, blk = fnum_block(e[4])
                v.w(0xA8, fn & 0xFF)
                v.w(0xB8, blk << 2 | fn >> 8)
            elif kind == 'level':
                ch, tl = e[3], e[4]
                v.w(0x40 + OP2[ch], tl)
            i += 1
        if mask:
            v.w(0xBD, rhythm & ~mask)
            v.w(0xBD, rhythm | mask)

    v.wait_until(song.end_tick * song.tick_samples)
    used = sorted({e[3] for e in song.ev if e[2] == 'on'}) if effect else range(9)
    for ch in used:
        v.w(0xB0 + ch, 0x00)
    v.d += b'\x66'

    DATA = 0x100
    hdr = bytearray(DATA)
    hdr[0:4] = b'Vgm '
    struct.pack_into('<I', hdr, 0x04, DATA + len(v.d) - 4)
    struct.pack_into('<I', hdr, 0x08, 0x151)
    struct.pack_into('<I', hdr, 0x18, v.samples)
    if loop_offset is not None:
        struct.pack_into('<I', hdr, 0x1C, DATA + loop_offset - 0x1C)
        struct.pack_into('<I', hdr, 0x20, v.samples - int(round(song.loop_tick * song.tick_samples)))
    struct.pack_into('<I', hdr, 0x34, DATA - 0x34)
    struct.pack_into('<I', hdr, 0x50, 3579545)                 # YM3812 클럭
    print('%-11s %6d 바이트  %5.1f초%s' % (name, DATA + len(v.d),
          v.samples / SR, '  (되풀이)' if loop_offset is not None else ''))
    return name, bytes(hdr) + bytes(v.d)

def bundle(path, songs):
    """(이름, VGM 자료) 목록 -> SOUND.DAT"""
    head = bytearray(b'KRSND10\0')
    head += struct.pack('<H', len(songs))
    off = len(head) + 20 * len(songs)
    body = bytearray()
    for name, data in songs:
        head += name.encode('ascii').ljust(12, b'\0')[:12]
        head += struct.pack('<II', off + len(body), len(data))
        body += data
    with open(path, 'wb') as f:
        f.write(bytes(head) + bytes(body))
    print('%s  %d 바이트, %d 곡' % (os.path.basename(path), len(head) + len(body), len(songs)))

# ---------------------------------------------------------------- 반주 무늬 --
def bass_octaves(s, t, roots, ch=2, bars=None):
    """마디마다 근음을 8분음표 옥타브로 몰아친다"""
    for b, root in enumerate(roots):
        r = midi(root)
        for k in range(8):
            s.note(t + b * 16 + k * 2, 2, ch, r + (12 if k % 2 else 0), gap=0.35)

def bass_drive(s, t, roots, ch=2):
    """근음 8분음표에 마지막 박은 5도-옥타브로 올라간다"""
    for b, root in enumerate(roots):
        r = midi(root)
        pat = [0, 0, 12, 0, 0, 0, 12, 7]
        for k in range(8):
            s.note(t + b * 16 + k * 2, 2, ch, r + pat[k], gap=0.3)

CHORD = {'Am': ('A3', 'C4', 'E4'), 'E': ('G#3', 'B3', 'E4'), 'Dm': ('A3', 'D4', 'F4'),
         'C': ('G3', 'C4', 'E4'), 'F': ('A3', 'C4', 'F4'), 'G': ('G3', 'B3', 'D4'),
         'D': ('A3', 'D4', 'F#4'), 'Bm': ('B3', 'D4', 'F#4'), 'A': ('A3', 'C#4', 'E4'),
         'Em': ('G3', 'B3', 'E4')}

def stabs(s, t, chords, syncopated=False):
    """엇박(8분 뒤)마다 짧게 치는 코드"""
    for b, name in enumerate(chords):
        spots = (2, 6, 10, 14) if not syncopated else (2, 5, 8, 10, 14)
        for k in spots:
            for v, n in enumerate(CHORD[name]):
                s.note(t + b * 16 + k, 1, 3 + v, midi(n), gap=0.25)

def pluck_arp(s, t, chords, up=12):
    """가야금 뜯듯이 16분음표로 오르내리는 분산화음"""
    order = [0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 2, 3, 2]
    for b, name in enumerate(chords):
        tones = [midi(n) + up for n in CHORD[name]]
        tones.append(tones[0] + 12)
        for k in range(16):
            s.note(t + b * 16 + k, 1, 3 + (k % 3), tones[order[k]], gap=0.0)

def drums_rock(s, t, bars, busy=False, crash=True, fill=True):
    for b in range(bars):
        o = t + b * 16
        s.drum(o, BD | (CYM if crash and b == 0 else 0))
        s.drum(o + 4, SD)
        s.drum(o + 8, BD)
        if busy:
            s.drum(o + 6, BD)
            s.drum(o + 11, BD)
        s.drum(o + 12, SD)
        step = 1 if busy else 2
        for k in range(0, 16, step):
            if k not in (0, 4, 8, 12) or not busy:
                s.drum(o + k, HH)
        last = fill and b == bars - 1
        if last:
            for k, m in zip((8, 10, 12, 13, 14, 15), (55, 52, 50, 48, 45, 43)):
                s.tom_pitch(o + k, m)
                s.drum(o + k, TOM if k < 12 or k % 2 == 0 else SD)

def drums_build(s, t, bars):
    """들어가기: 스네어가 8분 -> 16분으로 몰아친다"""
    for b in range(bars):
        o = t + b * 16
        s.drum(o, BD | CYM if b == 0 else BD)
        step = 2 if b < bars - 1 else 1
        for k in range(0, 16, step):
            s.drum(o + k, SD if k >= 8 or b == bars - 1 else HH)

# ---------------------------------------------------------------- 가락 ------
KOROBEINIKI = [
    "E5/4 B4/2 C5/2 D5/4 C5/2 B4/2",
    "A4/4 A4/2 C5/2 E5/4 D5/2 C5/2",
    "B4/6 C5/2 D5/4 E5/4",
    "C5/4 A4/4 A4/4 r/4",
    "r/2 D5/4 F5/2 A5/4 G5/2 F5/2",
    "E5/6 C5/2 E5/4 D5/2 C5/2",
    "B4/4 B4/2 C5/2 D5/4 E5/4",
    "C5/4 A4/4 A4/4 r/4",
]
K_ROOTS  = ['E2', 'A2', 'G#2', 'A2', 'D2', 'C2', 'E2', 'A2']
K_CHORDS = ['E', 'Am', 'E', 'Am', 'Dm', 'C', 'E', 'Am']

# 아리랑 앞 두 줄 (아리랑 아리랑 아라리요 / 아리랑 고개로 넘어간다) - C장조
ARIRANG = [
    "G4/6 A4/2 G4/4 A4/4",
    "C5/6 D5/2 C5/4 D5/4",
    "E5/4 D5/2 C5/2 A4/4 C5/2 D5/2",
    "C5/4 A4/4 G4/8",
    "G4/6 A4/2 G4/4 A4/4",
    "C5/6 D5/2 C5/4 D5/4",
    "E5/4 D5/2 C5/2 A4/4 G4/2 A4/2",
    "C5/12 r/4",
]
A_ROOTS  = ['C2', 'F2', 'A2', 'C2', 'C2', 'F2', 'A2', 'C2']
A_CHORDS = ['C', 'F', 'Am', 'C', 'C', 'F', 'Am', 'C']

def transpose(names, k):
    out = []
    for n in names:
        m = midi(n) + k
        octave, step = divmod(m, 12)
        out.append(['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'][step] + str(octave - 1))
    return out

def put_lines(s, t, lines, ch, shift=0, gap=0.12):
    for b, line in enumerate(lines):
        s.melody(t + b * 16, line, ch, shift, gap)

# ---------------------------------------------------------------- 곡 --------
def song_game():
    s = Song(170)
    s.patch(0, 0, P_LEAD)
    s.patch(0, 1, P_LEAD2)
    s.patch(0, 2, P_BASS)
    s.patch(0, 3, P_STAB); s.patch(0, 4, P_STAB); s.patch(0, 5, P_STAB)

    # 들어가기 2마디: A 음 옥타브 베이스 + 스네어 몰아치기
    bass_octaves(s, 0, ['A2', 'A2'])
    stabs(s, 0, ['Am', 'E'])
    drums_build(s, 0, 2)
    t = 32
    s.loop_tick = t

    # 코로베이니키 1: 리드 + 옥타브 베이스 + 엇박 코드
    put_lines(s, t, KOROBEINIKI, 0)
    bass_octaves(s, t, K_ROOTS)
    stabs(s, t, K_CHORDS)
    drums_rock(s, t, 8, busy=False)
    t += 8 * 16

    # 코로베이니키 2: 한 옥타브 위를 겹치고 드럼을 조인다
    put_lines(s, t, KOROBEINIKI, 0)
    put_lines(s, t, KOROBEINIKI, 1, shift=12)
    bass_drive(s, t, K_ROOTS)
    stabs(s, t, K_CHORDS, syncopated=True)
    drums_rock(s, t, 8, busy=True)
    t += 8 * 16

    # 아리랑 1: 가야금풍 분산화음 위에 가락
    for ch in (3, 4, 5):
        s.patch(t, ch, P_PLUCK)
    put_lines(s, t, ARIRANG, 0, shift=12)
    pluck_arp(s, t, A_CHORDS)
    bass_octaves(s, t, A_ROOTS)
    drums_rock(s, t, 8, busy=False)
    t += 8 * 16

    # 아리랑 2: 옥타브 겹침 + 코드 + 조인 드럼, 마지막에 필인
    for ch in (3, 4, 5):
        s.patch(t, ch, P_STAB)
    put_lines(s, t, ARIRANG, 0, shift=12)
    put_lines(s, t, ARIRANG, 1, shift=24)
    bass_drive(s, t, A_ROOTS)
    stabs(s, t, A_CHORDS, syncopated=True)
    drums_rock(s, t, 8, busy=True)
    t += 8 * 16
    for ch in (3, 4, 5):                        # 되풀이 전에 코드 음색을 돌려놓는다
        s.patch(t - 1, ch, P_STAB)
    s.end_tick = t
    return s

def song_title():
    s = Song(132)
    k = 2                                       # D장조로
    lines = []
    for line in ARIRANG:
        toks = []
        for tok in line.split():
            name, ln = tok.split('/')
            toks.append((name if name == 'r' else transpose([name], k)[0]) + '/' + ln)
        lines.append(' '.join(toks))
    roots  = transpose(A_ROOTS, k)
    chords = ['D', 'G', 'Bm', 'D', 'D', 'G', 'Bm', 'D']

    s.patch(0, 0, P_LEAD)
    s.patch(0, 1, P_LEAD2)
    s.patch(0, 2, P_BASS)
    for ch in (3, 4, 5):
        s.patch(0, ch, P_PLUCK)

    # 들어가기: 가야금풍 뜯기 2마디 + 드럼 몰아치기
    pluck_arp(s, 0, ['D', 'D'])
    bass_octaves(s, 0, ['D2', 'D2'])
    drums_build(s, 0, 2)
    t = 32
    s.loop_tick = t

    put_lines(s, t, lines, 0, shift=12)
    pluck_arp(s, t, chords)
    bass_octaves(s, t, roots)
    drums_rock(s, t, 8)
    t += 8 * 16

    put_lines(s, t, lines, 0, shift=12)
    put_lines(s, t, lines, 1, shift=24)
    pluck_arp(s, t, chords, up=24)
    bass_drive(s, t, roots)
    drums_rock(s, t, 8, busy=True)
    t += 8 * 16
    s.end_tick = t
    return s

def song_clear():
    s = Song(180)
    s.patch(0, 0, P_LEAD)
    s.patch(0, 1, P_LEAD2)
    s.patch(0, 2, P_BASS)
    for ch in (3, 4):                           # 채널 5 는 효과음(KCOUNT) 자리
        s.patch(0, ch, P_STAB)
    # "넘어간다" 가락을 몰아쳐서 C 로 끝낸다
    line = "E5/1 D5/1 C5/1 A4/1 G4/1 A4/1 C5/2 E5/2 G5/2 C6/8"
    s.melody(0, line, 0, gap=0.05)
    s.melody(0, line, 1, shift=-12, gap=0.05)
    for st, name in ((0, 'Am'), (4, 'F'), (8, 'G'), (12, 'C')):
        for v, n in enumerate(CHORD[name][1:]):     # 근음은 베이스가 맡는다
            s.note(st, 4 if st < 12 else 8, 3 + v, midi(n) + 12, gap=0.2)
    for st, r in ((0, 'A2'), (4, 'F2'), (8, 'G2'), (12, 'C2')):
        s.note(st, 4 if st < 12 else 8, 2, midi(r))
    for k in range(12):
        s.drum(k, SD if k % 2 else BD | SD)
    s.drum(12, BD | CYM)
    s.end_tick = 24
    return s

def song_over():
    s = Song(84)
    s.patch(0, 0, P_LEAD)
    s.patch(0, 2, P_BASS)
    for ch in (3, 4, 5):
        s.patch(0, ch, P_PAD)
    s.melody(0, "E5/4 C5/4 A4/4 G#4/4 A4/12", 0, gap=0.3)
    for st, ln, name in ((0, 8, 'Am'), (8, 8, 'E'), (16, 12, 'Am')):
        for v, n in enumerate(CHORD[name]):
            s.note(st, ln, 3 + v, midi(n), gap=0.3)
    for st, ln, r in ((0, 4, 'A2'), (4, 4, 'G2'), (8, 4, 'F2'), (12, 4, 'E2'), (16, 12, 'A1')):
        s.note(st, ln, 2, midi(r), gap=0.3)
    s.drum(0, BD | CYM)
    s.drum(8, BD)
    s.drum(16, BD | CYM)
    s.end_tick = 28
    return s

# 효과음 음색: 쇳소리가 섞인 짧은 종소리 (서스테인 없이 바로 사라진다)
P_COIN = ((0x03, 0x1A, 0xF6, 0x47, 0x00), (0x01, 0x02, 0xF7, 0x48, 0x00), 0x06)

def effect_count():
    """보너스 10점마다 한 번 - 시계 한 틱(55ms) 안에 끝나는 "띠링" (채널 5)"""
    s = Song(60)                                # 16분음표 한 칸 = 1/4초
    s.tick_samples = SR * 0.012                 # 여기서는 한 칸 = 12ms
    s.patch(0, 5, P_COIN)
    s.note(0, 1.5, 5, midi('E6'), gap=0.0)
    s.note(1.5, 2.5, 5, midi('B6'), gap=0.0)
    s.end_tick = 4
    return s

def main():
    here = os.path.dirname(os.path.abspath(__file__))
    args = [a for a in sys.argv[1:] if a != '--vgm']
    out = args[0] if args else os.path.join(here, '..')
    songs = [render(song_title(),   'KTITLE.VGM'),
             render(song_game(),    'KGAME.VGM'),
             render(song_clear(),   'KCLEAR.VGM'),
             render(song_over(),    'KOVER.VGM'),
             render(effect_count(), 'KCOUNT.VGM', effect=True)]
    bundle(os.path.join(out, 'SOUND.DAT'), songs)
    if '--vgm' in sys.argv:
        for name, data in songs:
            with open(os.path.join(out, name), 'wb') as f:
                f.write(data)

if __name__ == '__main__':
    main()
