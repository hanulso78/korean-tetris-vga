# -*- coding: utf-8 -*-
"""KOREA.PTN (16x16 흑백 글자 256개) 를 색칠해서 KOREA256.SPR 을 만든다.

   쓰는 법 :  python mkspr256.py [KOREA.PTN] [KOREA256.SPR] [--preview 폴더]

   KOREA256.SPR 구조 (66,312 바이트)
       0..7        "KOR256S" + 0
       8..775      팔레트 256색 x (R,G,B)  VGA DAC 값 0..63
       776..       글자 256개 x 16x16 = 256 바이트씩, 한 픽셀 = 팔레트 번호

   팔레트 0..127 만 그림에 쓰고, 128..255 는 그 반대색(63-값)을 거꾸로
   채운다 (팔레트[255-i] = 63 - 팔레트[i]).  그래서 원본처럼 화면 바이트를
   0xFF 로 XOR 하면 반전된 색이 되고, 한 번 더 XOR 하면 제자리로 온다
   (편집기 커서, TURBO 아이템의 번쩍임).

   --preview 를 주면 ../data.c 의 화면 문자열로 메뉴/게임/편집기 화면을
   PNG 로 그려 본다 (PIL 필요).
"""
import os, re, struct, sys

# ---------------------------------------------------------------- 팔레트 ----
PAL = [(0, 0, 0)] * 256          # 0..255 RGB 0..255

def setc(i, rgb):
    PAL[i] = tuple(max(0, min(255, int(round(v)))) for v in rgb)

# 0..15 회색
for i in range(16):
    setc(i, (i * 17, i * 17, i * 17))

# 16 + 색상*12 + 밝기(0 어두움..11 밝음)
HUES = [(230, 30, 40),    # 0 빨강
        (250, 130, 20),   # 1 주황
        (250, 220, 30),   # 2 노랑
        (40, 200, 60),    # 3 초록
        (30, 200, 220),   # 4 하늘
        (40, 90, 240),    # 5 파랑
        (150, 60, 230),   # 6 보라
        (240, 60, 190)]   # 7 분홍
RED, ORANGE, YELLOW, GREEN, CYAN, BLUE, PURPLE, PINK = range(8)

for h, base in enumerate(HUES):
    for s in range(12):
        t = s / 11.0
        if t < 0.5:
            k = 0.12 + t / 0.5 * 0.88
            rgb = [c * k for c in base]
        else:
            k = (t - 0.5) / 0.5 * 0.85
            rgb = [c + (255 - c) * k for c in base]
        setc(16 + h * 12 + s, rgb)

def H(h, s):
    return 16 + h * 12 + max(0, min(11, s))

BOARD_BG, BOARD_GRID, BOARD_DOT = 112, 113, 114
SKIN, SKIN_DARK, HAIR = 115, 116, 117
PANEL_BG, PATTERN_A, PATTERN_B = 118, 119, 120
GOLD_DARK, GOLD, GOLD_LIGHT = 121, 122, 123
STEEL_DARK, STEEL, STEEL_LIGHT = 124, 125, 126
WHITE_WARM = 127

setc(BOARD_BG,    (6, 10, 34))
setc(BOARD_GRID,  (16, 24, 64))
setc(BOARD_DOT,   (70, 90, 160))
setc(SKIN,        (252, 204, 150))
setc(SKIN_DARK,   (200, 140, 96))
setc(HAIR,        (90, 50, 20))
setc(PANEL_BG,    (10, 6, 30))
setc(PATTERN_A,   (44, 26, 96))
setc(PATTERN_B,   (22, 14, 58))
setc(GOLD_DARK,   (150, 86, 10))
setc(GOLD,        (230, 170, 30))
setc(GOLD_LIGHT,  (255, 236, 140))
setc(STEEL_DARK,  (36, 56, 100))
setc(STEEL,       (90, 132, 190))
setc(STEEL_LIGHT, (180, 220, 255))
setc(WHITE_WARM,  (255, 248, 232))

for i in range(128):                       # 반대색 거울
    PAL[255 - i] = tuple(255 - v for v in PAL[i])

# ---------------------------------------------------------------- 글꼴 ------
def load_ptn(path):
    d = open(path, 'rb').read()
    glyphs = []
    for c in range(256):
        m = []
        for r in range(16):
            w = d[c * 32 + r * 2] | d[c * 32 + r * 2 + 1] << 8
            # 화면에는 낮은 바이트가 왼쪽, 각 바이트는 비트7 이 왼쪽
            bits = [(w >> (7 - b)) & 1 for b in range(8)] + \
                   [(w >> (15 - b)) & 1 for b in range(8)]
            m.append(bits)
        glyphs.append(m)
    return glyphs

def on(m, x, y):
    return 0 <= x < 16 and 0 <= y < 16 and m[y][x]

def neighbors_on(m, x, y):
    return sum(on(m, x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))

def new():
    return [[0] * 16 for _ in range(16)]

def fill(bg):
    return [[bg] * 16 for _ in range(16)]

# ---------------------------------------------------------------- 칠하기 ----
def gem(m, hue, lift=0):
    """블록: 유리 벽돌
       - 몸통은 위가 밝고 아래로 갈수록 짙어지는 반투명 유리 (원본 무늬는 옅게 비친다)
       - 왼쪽 위에서 오른쪽 아래로 비스듬히 지나가는 굵고 가는 빛줄기 두 개
       - 오른쪽 아래 안쪽은 빛이 모여 다시 밝아진다 (유리 속 굴절)
       - 테두리: 위/왼쪽은 하얗게 빛나고 아래/오른쪽은 어둡게 꺾인다"""
    g = new()
    for y in range(16):
        for x in range(16):
            d = x + y
            s = 7 - y // 5 + lift                      # 위가 밝은 몸통
            s += 1 if m[y][x] else 0                   # 원본 무늬는 한 단계만
            if 5 <= d <= 8:                            # 굵은 빛줄기
                s = 10 + (1 if d in (6, 7) else 0)
            elif d == 11:                              # 가는 빛줄기
                s = max(s, 9)
            elif d >= 22:                              # 오른쪽 아래 속빛
                s += 2
            g[y][x] = H(hue, s)
    for i in range(16):                                # 테두리
        g[i][0] = g[0][i] = H(hue, 11)
        g[i][1] = g[1][i] = H(hue, 9 + lift)
        g[i][15] = g[15][i] = H(hue, 2)
        g[i][14] = g[14][i] = H(hue, 4)
    g[0][0] = g[0][1] = g[1][0] = 15                   # 모서리 하이라이트
    g[15][0] = g[0][15] = H(hue, 7)
    g[14][1] = g[1][14] = H(hue, 6)
    return g

def sprite(m, hue, bg, lift=0, outline=True):
    """작은 그림: 위는 밝고 아래로 갈수록 진하게, 둘레에 어두운 테"""
    g = fill(bg)
    for y in range(16):
        for x in range(16):
            if m[y][x]:
                g[y][x] = H(hue, 11 - y * 5 // 15 + lift)
            elif outline and neighbors_on(m, x, y):
                g[y][x] = H(hue, 2)
    return g

def text(m, hue_top, hue_bottom, bg=PANEL_BG):
    """글자: 세로 그러데이션 + 오른쪽 아래 그림자"""
    g = fill(bg)
    for y in range(16):
        for x in range(16):
            if m[y][x]:
                hue = hue_top if y < 8 else hue_bottom
                g[y][x] = H(hue, 11 - y * 6 // 15)
            elif on(m, x - 1, y - 1):
                g[y][x] = H(hue_bottom, 1)
    return g

def person(m):
    """사람 칸: 금색 액자, 하늘색 배경, 살색 얼굴/팔, 빨간 윗옷, 파란 바지"""
    g = new()
    for y in range(16):
        for x in range(16):
            frame = x < 2 or x > 13 or y < 2 or y > 13
            if frame:
                if m[y][x]:
                    g[y][x] = GOLD_LIGHT if x + y < 15 else (GOLD if x + y < 20 else GOLD_DARK)
                else:
                    g[y][x] = GOLD_DARK
            elif m[y][x]:
                if y <= 5:
                    g[y][x] = SKIN
                elif y <= 9 and 6 <= x <= 9:
                    g[y][x] = H(RED, 7)
                elif y >= 10:
                    g[y][x] = H(BLUE, 7)
                else:
                    g[y][x] = SKIN_DARK
            else:
                g[y][x] = H(CYAN, 2 + (13 - y) // 5)
    return g

def board_empty(m):
    g = fill(BOARD_BG)
    for i in range(16):
        g[0][i] = g[i][0] = BOARD_GRID
    for y in range(16):
        for x in range(16):
            if m[y][x]:
                g[y][x] = BOARD_DOT
    return g

def ornament(m):
    """판 둘레 장식: 굵은 줄은 금색, 무늬는 강철색"""
    g = fill(PATTERN_B)
    for y in range(16):
        for x in range(16):
            if m[y][x]:
                n = neighbors_on(m, x, y)
                if n >= 3:
                    g[y][x] = GOLD_LIGHT if y < 5 else (GOLD if y < 11 else GOLD_DARK)
                else:
                    g[y][x] = STEEL_LIGHT if (x + y) % 4 < 2 else STEEL
            else:
                g[y][x] = STEEL_DARK if neighbors_on(m, x, y) >= 2 else PATTERN_B
    return g

# ---- 게임판 / 미리보기 창 테두리 (원본 사슬 무늬 대신 반듯한 금색 기둥) ----
OUTLINE = 1
TUBE = [OUTLINE, GOLD_DARK, GOLD, GOLD_LIGHT, GOLD_LIGHT, GOLD, GOLD, GOLD,
        GOLD, GOLD, GOLD, GOLD_DARK, GOLD_DARK, H(ORANGE, 3), H(ORANGE, 2), OUTLINE]

def rail_vertical():
    """세로 기둥: 가로로 원기둥 명암, 한 칸(16)마다 이음매"""
    g = new()
    for y in range(16):
        for x in range(16):
            g[y][x] = TUBE[x]
    for x in range(1, 15):
        g[15][x] = H(ORANGE, 2)                        # 이음매 그림자
        g[0][x] = GOLD_LIGHT if 2 <= x <= 10 else g[0][x]
    return g

def rail_horizontal():
    """가로 받침: 세로로 원기둥 명암, 한 칸마다 이음매"""
    g = new()
    for y in range(16):
        for x in range(16):
            g[y][x] = TUBE[y]
    for y in range(1, 15):
        g[y][15] = H(ORANGE, 2)
        g[y][0] = GOLD_LIGHT if 2 <= y <= 10 else g[y][0]
    return g

def rail_corner():
    """모서리 블록: 위/왼쪽 밝고 아래/오른쪽 어둡게, 가운데 못"""
    g = new()
    for y in range(16):
        for x in range(16):
            if x in (0, 15) or y in (0, 15):
                v = OUTLINE
            elif x <= 2 or y <= 2:
                v = GOLD_LIGHT if x + y < 16 else GOLD
            elif x >= 13 or y >= 13:
                v = H(ORANGE, 2) if x + y > 14 else GOLD_DARK
            else:
                v = GOLD
            g[y][x] = v
    for x, y, v in ((7, 6, GOLD_LIGHT), (6, 7, GOLD_LIGHT), (7, 7, 15),
                    (8, 8, GOLD_DARK), (8, 7, GOLD_DARK), (7, 8, GOLD_DARK)):
        g[y][x] = v
    return g

def rail_cap():
    """기둥 윗머리: 세로 기둥 + 위쪽을 둥글게 막은 뚜껑"""
    g = rail_vertical()
    for x in range(16):
        g[0][x] = OUTLINE
        g[1][x] = OUTLINE if x in (0, 15) else GOLD_LIGHT
    g[0][0] = g[0][15] = g[1][0] = g[1][15] = PATTERN_B
    return g

def rail_shadow(left):
    """기둥 바깥쪽 띠: 기둥에 붙은 쪽이 밝은 차분한 강철색 그림자"""
    g = new()
    ramp = [PATTERN_B, PATTERN_B, PATTERN_B, PATTERN_B, PATTERN_A, PATTERN_A,
            STEEL_DARK, STEEL_DARK, STEEL_DARK, STEEL_DARK, STEEL, STEEL,
            STEEL, STEEL_LIGHT, STEEL, OUTLINE]
    for y in range(16):
        for x in range(16):
            g[y][x] = ramp[x] if left else ramp[15 - x]
    return g

def frame_glyphs():
    """글자 번호 -> 테두리 그림.  (쓰는 곳: data.c 게임/편집기 화면)
         u p..q..r s t v    게임판:  u/v 바깥 띠, p 기둥 머리, q 기둥, r/t 아래 모서리, s 받침
         w x / y z / { | }  미리보기 창: 위 모서리, 옆 기둥, 아래 모서리/받침"""
    vert, horiz, corner = rail_vertical(), rail_horizontal(), rail_corner()
    return {
        ord('p'): rail_cap(), ord('q'): vert, ord('r'): corner, ord('s'): horiz,
        ord('t'): corner, ord('u'): rail_shadow(True), ord('v'): rail_shadow(False),
        ord('w'): corner, ord('x'): corner, ord('y'): vert, ord('z'): vert,
        ord('{'): corner, ord('|'): horiz, ord('}'): corner,
    }

def box_line(m):
    """점수판/NEXT 창 이중 테두리.  원본은 바깥쪽에 한 칸 건너 한 점씩 찍은
       점선이 있는데 256색에서는 지저분해 보여서 뺀다 (이웃이 없는 외딴 점)"""
    m = [[m[y][x] and neighbors_on(m, x, y) > 0 for x in range(16)] for y in range(16)]
    g = fill(PANEL_BG)
    for y in range(16):
        for x in range(16):
            if m[y][x]:
                g[y][x] = GOLD_LIGHT if (x + y) % 6 < 2 else GOLD
            elif on(m, x - 1, y) or on(m, x, y - 1):
                g[y][x] = GOLD_DARK if neighbors_on(m, x, y) >= 2 else PANEL_BG
    return g

FLAG_TILES = [[0xD0 + i for i in range(9)],             # 스테이지 1 지도에 놓인 차례 (9x4)
              [0xD9 + i for i in range(9)],
              [0xE2 + i for i in range(9)],
              [0xEB + i for i in range(9)]]
TAEGUK_BOX = (47, 15, 97, 49)                             # 태극이 걸친 픽셀 상자 (x0,y0,x1,y1)
                                                          # 조각 3..5열 x 1..2행에 위아래 1줄씩 더

def flag_all(glyphs):
    """태극기 36조각을 한 장(144x64)으로 붙여서 한꺼번에 칠한다.
       조각마다 따로 칠하면 조각 경계에서 이웃 점을 못 봐서 흰 점/파란 점이 섞인다.
         - 흰 바탕, 검은 괘와 테두리
         - 태극 상자 안에서 상자 가장자리와 흰 점으로 이어진 곳 = 원 바깥 (흰색)
         - 원 안: 원본 체크무늬 = 빨강, 검정 = 파랑.  외딴 점은 주변 색으로 정리"""
    W, Hh = 144, 64
    M = [[0] * W for _ in range(Hh)]
    for r, row in enumerate(FLAG_TILES):
        for c, code in enumerate(row):
            for y in range(16):
                for x in range(16):
                    M[r * 16 + y][c * 16 + x] = glyphs[code][y][x]

    x0, y0, x1, y1 = TAEGUK_BOX
    outside = set()
    stack = [(x, y) for x in range(x0, x1) for y in (y0, y1 - 1)] +             [(x, y) for y in range(y0, y1) for x in (x0, x1 - 1)]
    while stack:
        x, y = stack.pop()
        if not (x0 <= x < x1 and y0 <= y < y1) or (x, y) in outside or not M[y][x]:
            continue
        outside.add((x, y))
        stack += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]

    def at(x, y):
        return M[y][x] if 0 <= x < W and 0 <= y < Hh else 1

    color = {}                                            # 원 안: 'R' 또는 'B'
    for y in range(y0, y1):
        for x in range(x0, x1):
            if (x, y) in outside:
                continue
            v = M[y][x]
            diff = sum(1 for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)) if at(x + dx, y + dy) != v)
            color[(x, y)] = 'R' if diff >= 3 else ('B' if not v else '?')
    for _ in range(2):                                    # 외딴 점 정리: 주변 5x5 다수결
        nxt = {}
        for (x, y), cl in color.items():
            n = {'R': 0, 'B': 0}
            for dx in range(-2, 3):
                for dy in range(-2, 3):
                    k = color.get((x + dx, y + dy))
                    if k in n and (dx or dy):
                        n[k] += 1
            if n['R'] > n['B']:
                nxt[(x, y)] = 'R'
            elif n['B'] > n['R']:
                nxt[(x, y)] = 'B'
            else:
                nxt[(x, y)] = cl if cl != '?' else 'R'
        color = nxt

    out = {}
    for r, row in enumerate(FLAG_TILES):
        for c, code in enumerate(row):
            g = new()
            for y in range(16):
                for x in range(16):
                    X, Y = c * 16 + x, r * 16 + y
                    cl = color.get((X, Y))
                    if cl == 'R':
                        g[y][x] = H(RED, 5)
                    elif cl == 'B':
                        g[y][x] = H(BLUE, 4)
                    elif M[Y][X]:
                        g[y][x] = WHITE_WARM if (X + Y) % 8 else 15
                    else:
                        g[y][x] = 1
            out[code] = g
    return out

DROP_CX, DROP_CY, DROP_R = 7.5, 8.0, 6.3                  # 물방울/거품이 같이 쓰는 동그라미

def drop_disk():
    """16x16 안의 동그라미 (True = 안쪽)"""
    return [[((x + 0.5 - DROP_CX) ** 2 + (y + 0.5 - DROP_CY) ** 2) ** 0.5 <= DROP_R
             for x in range(16)] for y in range(16)]

def water_drop():
    """물방울: 동그랗고 투명한 방울.
       왼쪽 위에서 빛이 들어와 흰 하이라이트, 오른쪽 아래 가장자리는 짙고
       바닥 안쪽에는 빛이 모인 밝은 반사"""
    g = fill(PANEL_BG)
    disk = drop_disk()
    for y in range(16):
        for x in range(16):
            if not disk[y][x]:
                continue
            px, py = x + 0.5, y + 0.5
            dd = ((px - DROP_CX) ** 2 + (py - DROP_CY) ** 2) ** 0.5
            light = ((px - 5.5) ** 2 + (py - 6.0) ** 2) ** 0.5
            sh = 10 - light * 0.55                         # 빛 쪽이 밝게, 부드럽게
            if DROP_R - dd < 1.2:                          # 가장자리
                sh = 5 if (px + py > DROP_CX + DROP_CY) else 8
            g[y][x] = H(CYAN, int(round(max(sh, 4))))
    for x, y in ((4, 4), (5, 4), (4, 5), (3, 5), (3, 6)):  # 하이라이트
        g[y][x] = 15
    for x, y in ((9, 12), (10, 11), (11, 10)):             # 바닥 안쪽 반사
        g[y][x] = H(CYAN, 11)
    return g

def water_bubble():
    """빈 물방울(거품): 채워진 물방울과 같은 동그라미의 가장자리만 테로 그리고,
       속은 테 안쪽만 살짝 비치게, 왼쪽 위에 흰 반사"""
    g = fill(PANEL_BG)
    disk = drop_disk()
    def inside(x, y):
        return 0 <= x < 16 and 0 <= y < 16 and disk[y][x]
    ring = [[disk[y][x] and not all(inside(x + dx, y + dy)
             for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
             for x in range(16)] for y in range(16)]
    for y in range(16):
        for x in range(16):
            if ring[y][x]:
                g[y][x] = H(CYAN, 9 if (x < DROP_CX and y < DROP_CY) else 6)
            elif disk[y][x] and any(ring[y + dy][x + dx]
                                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                g[y][x] = H(BLUE, 2)                       # 테 안쪽만 살짝 비친다
    for x, y in ((4, 4), (5, 4), (4, 5), (3, 5), (3, 6)):  # 물방울과 같은 자리 반사
        g[y][x] = 15
    return g

def build(glyphs):
    spr = [fill(PANEL_BG) for _ in range(256)]

    def put(c, g):
        spr[c] = g

    put(0x00, board_empty(glyphs[0x00]))

    block_hue = [None, RED, ORANGE, YELLOW, GREEN, CYAN, BLUE, PURPLE]
    for k in range(1, 8):
        put(k, gem(glyphs[k], block_hue[k], lift=1))            # 떨어지는 블록
        put(0x60 + k, gem(glyphs[0x60 + k], block_hue[k]))       # 굳은 블록

    for c, hue in ((0x68, PINK), (0x69, GREEN), (0x6A, CYAN), (0x6B, BLUE), (0x6C, PURPLE)):
        put(c, gem(glyphs[c], hue, lift=-1))
    g = gem(glyphs[0x6D], ORANGE, lift=-2)
    put(0x6D, g)
    put(0x6E, gem(glyphs[0x6E], YELLOW, lift=-1))               # 아이템 벽돌

    # 첫 화면 로고용 무지개 벽돌 (원본에서 비어 있던 0x97..0x9E).
    # 모양은 로고 글자 'e'(0x65) 와 같고 색만 다르다 - menu.c 가 글자마다 바꿔 찍는다
    for i, hue in enumerate((RED, ORANGE, YELLOW, GREEN, CYAN, BLUE, PURPLE, PINK)):
        put(0x97 + i, gem(glyphs[0x65], hue, lift=1))

    put(0x6F, person(glyphs[0x6F]))
    for c in range(0xB0, 0xD0):
        put(c, person(glyphs[c]))

    item_hue = [ORANGE, YELLOW, RED, CYAN, YELLOW]
    for i in range(5):
        put(0x08 + i, sprite(glyphs[0x08 + i], item_hue[i], BOARD_BG))
        put(0x0D + i, sprite(glyphs[0x0D + i], item_hue[i], BOARD_BG, lift=2))
        put(0x90 + i, sprite(glyphs[0x90 + i], item_hue[i], PANEL_BG))
    put(0x95, sprite(glyphs[0x95], CYAN, PANEL_BG))
    put(0x96, sprite(glyphs[0x96], PINK, PANEL_BG))
    put(0x2F, sprite(glyphs[0x2F], PINK, BOARD_BG))

    flash = [(YELLOW, 11), (YELLOW, 9), (YELLOW, 7), (ORANGE, 7),
             (ORANGE, 5), (RED, 6), (RED, 4), (PINK, 3)]
    for i, (hue, s) in enumerate(flash):
        g = fill(BOARD_BG)
        m = glyphs[0x12 + i]
        for y in range(16):
            for x in range(16):
                if m[y][x]:
                    g[y][x] = H(hue, s + (1 if x + y < 14 else 0))
        put(0x12 + i, g)

    for c in (0x1A, 0x95):                                        # 레이저
        m = glyphs[c]
        g = fill(BOARD_BG if c == 0x1A else PANEL_BG)
        rows = [y for y in range(16) if any(m[y])]
        for y in rows:
            for x in range(16):
                g[y][x] = H(CYAN, 11 if m[y][x] else 6)
        if rows:
            for x in range(16):
                if rows[0] > 0:
                    g[rows[0] - 1][x] = H(CYAN, 3)
                if rows[-1] < 15:
                    g[rows[-1] + 1][x] = H(CYAN, 3)
        put(c, g)

    for c in range(0x1B, 0x20):                                   # 폭발
        m = glyphs[c]
        g = fill(BOARD_BG)
        for y in range(16):
            for x in range(16):
                r = abs(x - 7.5) + abs(y - 7.5)
                if m[y][x]:
                    g[y][x] = H(YELLOW, 11) if r < 5 else (H(ORANGE, 8) if r < 10 else H(RED, 7))
                elif r < (c - 0x1A) * 3:
                    g[y][x] = H(RED, 3)
        put(c, g)

    for c in range(0x22, 0x28):                                   # 반짝임
        put(c, sprite(glyphs[c], PINK, BOARD_BG, lift=1))
    for c in range(0x28, 0x2D):                                   # 로켓 고리
        put(c, sprite(glyphs[c], ORANGE, BOARD_BG, lift=1))
    put(0x2D, text(glyphs[0x2D], YELLOW, ORANGE))
    put(0x2E, text(glyphs[0x2E], YELLOW, ORANGE))

    put(0x21, [[(PATTERN_A if (x + y) % 8 < 4 else PATTERN_B) if glyphs[0x21][y][x]
                else PANEL_BG for x in range(16)] for y in range(16)])

    for c in list(range(0x30, 0x3A)):
        put(c, text(glyphs[c], CYAN, BLUE))
    for c in (0x3A, 0x3B):
        put(c, text(glyphs[c], YELLOW, ORANGE))
    for c in range(0x41, 0x5B):
        put(c, text(glyphs[c], YELLOW, ORANGE))

    for c, g in frame_glyphs().items():                         # 게임판/미리보기 창 테두리
        put(c, g)
    for c in range(0x80, 0x8B):
        put(c, box_line(glyphs[c]))

    put(0x8B, water_bubble())                                    # 꺼진 등 / 목숨 잃을 때 빈칸
    put(0x8C, water_drop())                                      # 켜진 등 / 목숨 잃을 때 찬 칸
    put(0x8D, sprite(glyphs[0x8D], RED, PANEL_BG, lift=1))       # 목숨

    for c, g in flag_all(glyphs).items():
        put(c, g)

    rainbow = [RED, ORANGE, YELLOW, GREEN, CYAN, BLUE, PURPLE, PINK]
    put(0xF4, sprite(glyphs[0xF4], PINK, BOARD_BG, lift=1))
    for i, c in enumerate(range(0xF5, 0xFD)):
        put(c, sprite(glyphs[c], rainbow[i], BOARD_BG, lift=1))

    for i, c in enumerate(range(0xFD, 0x100)):                    # 메뉴 화살표
        put(c, sprite(glyphs[c], [YELLOW, ORANGE, RED][i], PANEL_BG, lift=1))
    return spr

# ---------------------------------------------------------------- 저장 ------
def save(path, spr):
    with open(path, 'wb') as f:
        f.write(b'KOR256S\0')
        for r, g, b in PAL:
            f.write(bytes((r * 63 // 255, g * 63 // 255, b * 63 // 255)))
        for c in range(256):
            for y in range(16):
                f.write(bytes(spr[c][y]))

# ---------------------------------------------------------------- 미리보기 ---
def read_screens(data_c, defines=('KOREAVGA',)):
    """data.c 의 화면 문자열을 읽는다.  #ifdef/#ifndef/#else/#endif 와 문자열
       #define 은 KOREAVGA.EXE 로 빌드할 때처럼 풀어서 본다."""
    lines, macros, keep = [], {}, [True]
    for line in open(data_c, encoding='utf-8').read().splitlines():
        t = line.strip()
        if t.startswith('#ifdef') or t.startswith('#ifndef'):
            on = t.split()[1] in defines
            keep.append(keep[-1] and (on if t.startswith('#ifdef') else not on))
            continue
        if t.startswith('#else'):
            keep[-1] = keep[-2] and not keep[-1]
            continue
        if t.startswith('#endif'):
            keep.pop()
            continue
        if not keep[-1]:
            continue
        m = re.match(r'#define\s+(\w+)\s+(".*")', t)
        if m:
            macros[m.group(1)] = m.group(2)
            continue
        lines.append(line)
    src = '\n'.join(lines)

    screens = {}
    for name in ('menu_screen', 'editor_screen', 'play_screen'):
        body = re.search(name + r'\[25\]\[41\] = \{(.*?)\};', src, re.S).group(1)
        rows = []
        for line in body.splitlines():                 # 한 줄 = 화면 한 행
            for k, v in macros.items():
                line = re.sub(r'\b%s\b' % k, lambda _m, v=v: v, line)
            lits = re.findall(r'"((?:[^"\\]|\\.)*)"', line.split('/*')[0])
            if not lits:
                continue
            lit = ''.join(lits)                        # 이어 붙인 문자열 상수
            out = bytearray()
            i = 0
            while i < len(lit):
                if lit[i] == '\\':
                    if lit[i + 1] in '01234567':
                        out.append(int(lit[i + 1:i + 4], 8)); i += 4
                    else:
                        out.append(ord(lit[i + 1])); i += 2
                else:
                    out.append(ord(lit[i])); i += 1
            rows.append(bytes(out))
        assert len(rows) == 25, (name, len(rows))
        screens[name] = rows
    return screens

def preview(spr, outdir, here):
    from PIL import Image
    screens = read_screens(os.path.join(here, '..', 'data.c'))
    stg = open(os.path.join(here, '..', 'KOREA.STG'), 'rb').read()

    def render(grid, extra=None):
        im = Image.new('RGB', (640, 400))
        px = im.load()
        for cy in range(25):
            for cx in range(40):
                g = spr[grid[cy][cx]]
                for y in range(16):
                    for x in range(16):
                        px[cx * 16 + x, cy * 16 + y] = PAL[g[y][x]]
        if extra:
            extra(px)
        return im.resize((1280, 800), Image.NEAREST)

    def grid_of(rows):
        return [list(r[:40]) for r in rows]

    g = grid_of(screens['menu_screen'])
    g[17][2] = 0xFD
    render(g).save(os.path.join(outdir, 'pv_menu.png'))

    g = grid_of(screens['play_screen'])
    stage = 0
    for r in range(20):
        for c in range(10):
            g[r + 3][c + 11] = stg[stage * 205 + r * 10 + c]
    for r, c, v in ((15, 13, 0x62), (16, 13, 0x62), (16, 14, 0x62), (17, 14, 0x63), (17, 15, 0x63),
                    (16, 15, 0x63), (17, 16, 0x64), (17, 17, 0x64), (17, 18, 0x64), (17, 19, 0x64),
                    (17, 12, 0x61), (16, 12, 0x61), (17, 11, 0x65), (16, 11, 0x66), (15, 11, 0x67),
                    (5, 15, 0x01), (5, 16, 0x01), (5, 17, 0x01), (6, 16, 0x01),
                    (9, 18, 0x0B)):
        g[r][c] = v
    for (r, c, v) in ((6, 2, 0x62), (6, 3, 0x62), (7, 1, 0x62), (7, 2, 0x62),
                      (9, 2, 0x93), (18, 38, 0x8D), (20, 38, 0x8C)):
        g[r][c] = v
    for i, ch in enumerate(b'0012'):
        g[6][35 + i] = ch
    nxt = 1
    def mini(px):
        for i in range(20):
            for j in range(10):
                s = spr[stg[nxt * 205 + i * 10 + j]]
                for y in range(8):
                    for x in range(8):
                        px[16 + j * 8 + x, 208 + i * 8 + y] = PAL[s[y * 2][x * 2]]
    render(g, mini).save(os.path.join(outdir, 'pv_play.png'))

    g = grid_of(screens['editor_screen'])
    for r in range(20):
        for c in range(10):
            g[r + 4][c + 15] = stg[1 * 205 + r * 10 + c]
    render(g).save(os.path.join(outdir, 'pv_editor.png'))

    im = Image.new('RGB', (16 * 20, 16 * 20), (60, 60, 60))
    px = im.load()
    for c in range(256):
        for y in range(16):
            for x in range(16):
                px[(c % 16) * 20 + x, (c // 16) * 20 + y] = PAL[spr[c][y][x]]
    im.resize((640 * 2, 640 * 2), Image.NEAREST).save(os.path.join(outdir, 'pv_sprites.png'))

def main():
    here = os.path.dirname(os.path.abspath(__file__))
    args = sys.argv[1:]
    if '--preview' in args:
        i = args.index('--preview')
        del args[i:i + 2]
    src = args[0] if len(args) > 0 else os.path.join(here, '..', 'KOREA.PTN')
    dst = args[1] if len(args) > 1 else os.path.join(here, '..', 'KOREA256.SPR')
    spr = build(load_ptn(src))
    save(dst, spr)
    print('wrote', dst, os.path.getsize(dst), 'bytes')
    if '--preview' in sys.argv:
        outdir = sys.argv[sys.argv.index('--preview') + 1]
        preview(spr, outdir, here)
        print('preview ->', outdir)

if __name__ == '__main__':
    main()
