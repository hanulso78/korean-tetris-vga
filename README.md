# KOREA (코리아) — 1990년 DOS 게임 C 이식 + 256색 개선판

1990년 PARK S.G. 님이 Turbo C 2.0 (small 모델) 으로 만든 16비트 DOS 게임
`KOREA.EXE` 를 역어셈블해 C 로 다시 옮기고, 같은 소스에 256색/애드립 백엔드를
붙인 프로젝트입니다. djgpp 로 빌드하는 32비트 DPMI 프로그램입니다.

| 타깃 | 화면 백엔드 | 음악 백엔드 | 설명 |
| --- | --- | --- | --- |
| `KOREA.EXE` | `vidmono.c` — 허큘리스 640x400 1bpp 를 VGA 모드 12h 로 옮김 | `music.c` — PC 스피커 | 원판 동작 그대로 |
| `KOREAVGA.EXE` | `vid256.c` — VESA 256색 스프라이트 | `musvgm.c` — 애드립(OPL2) VGM | 그래픽·사운드 개선판 |

게임 로직(규칙, 스테이지 100개, 속도)은 두 타깃이 같은 코드를 씁니다.

## 스크린샷

| 첫 화면 (256색) | 게임 (256색) |
| --- | --- |
| ![첫 화면](docs/title_vga.png) | ![게임 화면](docs/play_vga.png) |

| 스테이지 편집기 (256색) | 첫 화면 (원판 흑백) |
| --- | --- |
| ![편집기](docs/editor_vga.png) | ![원판 첫 화면](docs/title_mono.png) |

`tools/shot.py` 로 DOSBox 를 띄워 찍었습니다.

## 빌드

필요한 것: djgpp (gcc, make). 상위 폴더의 `..\..\djgpp.bat` 으로 환경을 연 창에서

```
make -f korea.mak          # 두 타깃 모두
make -f korea.mak mono     # KOREA.EXE
make -f korea.mak vga      # KOREAVGA.EXE
make -f korea.mak clean
```

- 컴파일 옵션 `-O2 -Wall`, 링크 뒤 `strip`.
- `data.c` 는 두 번 컴파일됩니다. 256색판은 `-DKOREAVGA` 로 `datavga.o` 를 만들고,
  만든 사람 표시와 `enhanced_rules` 플래그만 다릅니다.

데이터 파일 다시 만들기 / 배포 (Python 3):

```
python tools/mkspr256.py          # KOREA.PTN -> KOREA256.SPR  (--preview 폴더: PNG 미리보기, PIL 필요)
python tools/mkmusic.py           # SOUND.DAT                  (--vgm: 묶기 전 VGM 도 남김)
python tools/mkrelease.py         # release/KOREA, release/KOREAVGA, release/korea.zip
python tools/shot.py [이름]       # DOSBox 로 docs/*.png 찍기 (환경 변수 DOSBOX 로 경로 지정)
```

## 실행

DOS 또는 DOSBox 에서 해당 폴더로 이동해 `KOREA` / `KOREAVGA` 를 실행합니다.

| 타깃 | 필요한 파일 |
| --- | --- |
| `KOREA.EXE` | `CWSDPMI.EXE`, `KOREA.PTN`, `KOREA.STG` |
| `KOREAVGA.EXE` | `CWSDPMI.EXE`, `KOREA256.SPR`, `KOREA.STG`, `SOUND.DAT` |

조작: ← → 이동, ↓ 한 칸 내리기, ↑ / 숫자판 5 회전, Space 하드 드롭,
F1 배경음악 켜기/끄기, Esc 종료.

## 구조

### 메인 루프

`korea.c` 의 `main()` 은 원판과 같은 상태 머신입니다. `game_state` 값에 따라
`state_*()` 함수를 한 번 부르고, 메뉴·편집기가 아니면 `draw_board()` →
`update_status()` → `wait_tick()` 순으로 한 프레임을 끝냅니다.
시간 기준은 BIOS 시계 틱(18.2Hz, `0040:006C`)이며 원판 속도를 그대로 냅니다.

```
ST_MENU(100) ─▶ ST_NEW_GAME(2) ─▶ ST_START_STAGE(3) ─▶ ST_SPAWN_PIECE(6)
                                                          │
          ┌───────────────────────────────────────────────┘
          ▼
   ST_MOVE_PIECE(20) / ST_MOVE_ITEM(23) ─▶ ST_LOCK_PIECE(26) ─▶ ST_CHECK_LINES(30)
     ─▶ ST_FLASH_LINES(31) ─▶ ST_COLLAPSE_LINES(33) ─▶ ST_CHECK_TARGETS(40)
     ─▶ ST_STAGE_CLEAR(80) ─▶ ST_CLEAR_ANIM(83)      (사람을 모두 구했을 때)
   ST_GIMMICK(50), ST_LOSE_LIFE(60), ST_GAME_OVER(66), ST_EDITOR(200)
```

### 백엔드 인터페이스

원판이 화면 메모리와 스피커를 직접 만지던 곳은 모두 `korea.h` 의 함수로 바꿨고,
링크할 때 백엔드를 고릅니다.

- **화면** — `load_font`, `video_init/shutdown/present`, `put_glyph`, `invert_cells`,
  `copy_cell_row`, `clear_cell_row`, `put_preview_cell`, `video_set_piece`,
  `video_smooth_piece`, `video_has_color`, `video_idle`. 좌표는 40x25 글자 칸(16x16 픽셀).
- **음악** — `music_init`, `music_play`, `music_poll`, `music_effect`, `bgm_tick`.

`vid256.c` 는 640x400 8bpp 오프스크린 버퍼에 그린 뒤 바뀐 글자 줄만 화면으로 옮깁니다.
모드는 VESA `0x100`(640x400) → `0x101`(640x480, 가운데 정렬) → 모드 `13h`(320x200, 축소)
순으로 시도하고, LFB 가 없으면 뱅크 전환을 씁니다. 원판의 XOR 0xFF 반전 효과는
팔레트를 `pal[255-i] = 반대색(pal[i])` 로 짜서 그대로 살렸습니다.

`video_set_piece` 는 떨어지는 블록을 판과 따로 그려 칸 사이를 부드럽게 옮깁니다.
흑백판은 `video_smooth_piece() == 0` 이라 원판처럼 판에 직접 찍습니다.

### 원본 대조

실행 파일 뒤에 Turbo Debugger 심볼이 붙어 있어 원래 소스 파일명, 함수·변수 이름,
줄 번호를 복원할 수 있었습니다. C 소스에서는 이름을 새로 붙였고, 원래 이름은
`korea.h` 선언 옆과 각 함수 머리 주석(`원래: 이름 (파일:줄, 코드 오프셋)`)에 남겼습니다.
`listing.asm` 은 주석을 단 전체 역어셈블 결과입니다.

| 소스 | 원래 파일 | 내용 |
| --- | --- | --- |
| `korea.h` | — | 공용 선언, 상수, 원래 이름 대조표 |
| `korea.c` | `KOREA.C` | `main`, 전역 변수 |
| `data.c` | DGROUP | 데이터 세그먼트 초기값 (화면 문자열, 블록 모양, 악보, 음계표) |
| `menu.c` | `KOR-TIT.C` | 첫 메뉴 |
| `editor.c` | `KOR-STG.C` | 스테이지 편집기 |
| `text.c` | `KOR-GRP.C` | 글자 출력, 창 스크롤, 줄 입력 |
| `game.c` | `KOR-INT.C` | 게임 상태 처리 |
| `system.c` | `KOR-SUB.C` 앞부분 | 파일, 키보드(BIOS 버퍼 직접 접근), 시계, 사운드, Turbo C 호환 `rand` |
| `board.c` | `KOR-SUB.C` 나머지 | 판·점수판 그리기, 충돌 판정, 아이템, 기믹 |
| `vidmono.c` | `KOR-GRP.C` | 흑백 화면 백엔드 (허큘리스 흉내) |
| `music.c` | `KOR-BGM.C` | PC 스피커 음악 |
| `vid256.c` | — (새로 작성) | 256색 화면 백엔드 |
| `musvgm.c` | — (새로 작성) | OPL2 VGM 재생기 |

원판과 의도적으로 다른 점: 스테이지 번호를 `% 100` 으로 감싸 표 밖을 읽지 않음
(`STAGE_IX`), ↑ 키로도 회전, 256색판의 블록 슬라이드·하드 드롭 애니메이션,
메뉴의 미완성 두 항목을 QUIT 로 교체. 새로 넣은 코드는 주석에 `(새로 넣음)` 으로 표시했습니다.

## 게임 데이터

판은 `board[26][16]`, 실제 필드는 10열(3..12) x 23행(0..22) 이고 위 3행은 보이지 않습니다.

| 칸 값 | 의미 |
| --- | --- |
| `0x00` | 빈 칸 |
| `0x01..0x10` | 떨어지는 중인 블록 |
| `0x12..0x19` | 지워지는 줄 반짝임 |
| `0x60+` | 굳은 블록 (블록 글자 + 0x60) |
| `0x6E` | 아이템이 남긴 벽돌 |
| `0x6F` | 구해야 할 사람 — 판에서 모두 사라지면 스테이지 클리어 |
| `0x7F` | 벽 |

블록은 보통 7종 + 아이템 5종(로켓 2, 폭탄, 레이저, 터보). 스테이지마다 정해진 시간에
판이 밀리거나 벽돌이 생기는 기믹이 발동합니다.

## 파일 포맷

모든 정수는 리틀 엔디언입니다.

**`KOREA.PTN`** (8,192 B, 1990년 원본) — 16x16 1bpp 글자 256개, 글자당 32바이트.

**`KOREA.STG`** (20,500 B, 1990년 원본) — 스테이지 100개 x 205바이트.

| 오프셋 | 크기 | 내용 |
| --- | --- | --- |
| 0 | 200 | 20행 x 10열 지도 (칸 값) |
| 200 | 1 | 떨어지는 간격 |
| 201 | 1 | 아이템 |
| 202 | 1 | 기믹 종류 |
| 203 | 1 | 보너스 |
| 204 | 1 | 기믹 간격 |

**`KOREA256.SPR`** (66,312 B, `mkspr256.py` 생성)

| 오프셋 | 크기 | 내용 |
| --- | --- | --- |
| 0 | 8 | `"KOR256S\0"` |
| 8 | 768 | 팔레트 256 x RGB (VGA DAC 0..63). 0..127 만 그림에 쓰고 128..255 는 반대색 |
| 776 | 65,536 | 16x16 스프라이트 256개, 픽셀당 팔레트 인덱스 1바이트 |

**`SOUND.DAT`** (`mkmusic.py` 생성)

| 오프셋 | 크기 | 내용 |
| --- | --- | --- |
| 0 | 8 | `"KRSND10\0"` |
| 8 | 2 | 곡 수 N |
| 10 | 20 x N | 디렉터리: 이름 12 (0 채움) / 시작 오프셋 4 / 길이 4 |
| … | … | VGM 파일 본문 그대로 |

수록 곡: `KTITLE.VGM`(메뉴, 아리랑 록 편곡), `KGAME.VGM`(코로베이니키 + 아리랑 메들리),
`KCLEAR.VGM`(스테이지 클리어), `KOVER.VGM`(게임 오버), `KCOUNT.VGM`(보너스 집계 효과음, 채널 5 전용).
OPL2 리듬 모드로 가락 6채널 + 드럼 5종을 쓰며, 곡과 효과음 스트림은 따로 흘러가 겹쳐 울릴 수 있습니다.
애드립이 없거나 파일이 없으면 소리 없이 진행합니다. 두 가락 모두 저작권이 없는 민요이고 편곡은 새로 했습니다.

## 저장소 구성

```
*.c *.h korea.mak     소스와 빌드 스크립트
listing.asm           원판 역어셈블 (주석)
KOREA.PTN KOREA.STG   1990년 원본 데이터
KOREA256.SPR SOUND.DAT  생성된 데이터 (tools/ 로 다시 만들 수 있음)
CWSDPMI.EXE           DPMI 호스트
tools/                데이터 생성, 배포, 스크린샷 스크립트
docs/                 스크린샷
release/              배포본 (README.TXT 는 CP949, CRLF)
```
