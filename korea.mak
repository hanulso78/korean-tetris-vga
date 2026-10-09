# ============================================================================
#  KOREA  -  djgpp 빌드
# ----------------------------------------------------------------------------
#  ..\..\djgpp.bat 로 연 창에서 이 폴더로 와서
#
#      make -f korea.mak            둘 다 만든다
#      make -f korea.mak mono       KOREA.EXE     원판 그대로 (흑백, PC 스피커)
#      make -f korea.mak vga        KOREAVGA.EXE  256색 스프라이트 + 애드립 음악
#      make -f korea.mak clean
#
#  (korea.mak 을 makefile 로 이름만 바꾸면 그냥 make 로도 된다)
#
#  ---------------------------------------------------------------------------
#  KOREA.EXE    - 1990년 원판(KOREA.EXE, 터보 C 2.0)을 역어셈블해 C 로 옮긴 것.
#       게임 규칙, 스테이지, 소리, 속도(BIOS 시계 18.2Hz)는 원판 그대로이고
#       화면만 VGA 640x480(모드 12h)으로 그린다.  원판은 허큘리스(640x400
#       흑백)나 CGA 로 그렸는데, 허큘리스 화면 메모리와 같은 모양의 버퍼에
#       원판과 똑같이 그린 뒤 VGA 가운데로 옮기므로 허큘리스판과 똑같이 보인다.
#       필요한 파일 : CWSDPMI.EXE, KOREA.PTN (글꼴), KOREA.STG (스테이지 100개)
#
#  KOREAVGA.EXE - 같은 게임을 256색으로.
#       - VESA 640x400 256색 (없으면 640x480, 그것도 없으면 320x200)
#       - 흑백 글자 256개를 색칠한 스프라이트 KOREA256.SPR 로 그린다
#         (tools/mkspr256.py 가 KOREA.PTN 에서 만든다)
#       - 배경음악을 애드립(OPL2) VGM 으로 연주한다 (F1 로 끄고 켠다)
#           메뉴 - 아리랑,  게임 - 코로베이니키+아리랑,
#           스테이지 깸, 게임 끝, 보너스 세는 효과음 - VGM 다섯 개를 SOUND.DAT 에 묶음
#         (tools/mkmusic.py 가 만든다)
#       필요한 파일 : CWSDPMI.EXE, KOREA256.SPR, KOREA.STG, SOUND.DAT
#
#  소스 (괄호 안은 원래 소스 파일)
#       korea.h    공용 선언, 원래 이름 대조표
#       korea.c    main, 전역 변수              (KOREA.C)
#       data.c     데이터 세그먼트 초기값        (DGROUP)
#                  256색판은 -DKOREAVGA 로 따로 컴파일 (만든 사람 표시)
#       menu.c     첫 메뉴                      (KOR-TIT.C)
#       editor.c   스테이지 편집기              (KOR-STG.C)
#       text.c     글자 출력/창 스크롤          (KOR-GRP.C)
#       game.c     게임 상태 처리               (KOR-INT.C)
#       system.c   파일/키보드/시계/소리        (KOR-SUB.C 앞부분)
#       board.c    판/점수판/아이템             (KOR-SUB.C 나머지)
#     KOREA.EXE 만
#       vidmono.c  화면 - 허큘리스 흉내         (KOR-GRP.C)
#       music.c    배경음악 - PC 스피커         (KOR-BGM.C)
#     KOREAVGA.EXE 만
#       vid256.c   화면 - VESA 256색 스프라이트
#       musvgm.c   배경음악 - 애드립 VGM
# ============================================================================

CC      = gcc
CFLAGS  = -O2 -Wall

COMMON  = korea.o menu.o editor.o text.o game.o system.o board.o
MONO    = $(COMMON) data.o vidmono.o music.o
VGA     = $(COMMON) datavga.o vid256.o musvgm.o

all: korea.exe koreavga.exe

mono: korea.exe
vga:  koreavga.exe

korea.exe: $(MONO)
	$(CC) $(CFLAGS) -o korea.exe $(MONO)
	strip korea.exe

koreavga.exe: $(VGA)
	$(CC) $(CFLAGS) -o koreavga.exe $(VGA)
	strip koreavga.exe

korea.o:   korea.c   korea.h
data.o:    data.c    korea.h
menu.o:    menu.c    korea.h
editor.o:  editor.c  korea.h
text.o:    text.c    korea.h
game.o:    game.c    korea.h
system.o:  system.c  korea.h
board.o:   board.c   korea.h
vidmono.o: vidmono.c korea.h
music.o:   music.c   korea.h
vid256.o:  vid256.c  korea.h
musvgm.o:  musvgm.c  korea.h

# 256색판은 만든 사람 표시만 다르다 (data.c 의 KOREAVGA)
datavga.o: data.c    korea.h
	$(CC) $(CFLAGS) -DKOREAVGA -c data.c -o datavga.o

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(COMMON) data.o datavga.o vidmono.o music.o vid256.o musvgm.o korea.exe koreavga.exe

.PHONY: all mono vga clean
