# -*- coding: utf-8 -*-
"""배포용 파일을 release 폴더에 만든다.

   쓰는 법 :  python mkrelease.py          (먼저 make -f korea.mak 로 빌드)

       release/KOREA/      KOREA.EXE    원판 그대로 (흑백, PC 스피커)
       release/KOREAVGA/   KOREAVGA.EXE 256색 + 애드립 음악
       release/korea.zip   두 폴더를 묶은 것

   README.TXT 는 도스에서 읽을 수 있게 CP949(완성형), CRLF 로 쓴다.
"""
import os, shutil, zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.normpath(os.path.join(HERE, '..'))
OUT = os.path.join(SRC, 'release')

README_MONO = """코리아 (KOREA) - 1990년 원판 + VGA

  1990년 PARK S.G. 님이 터보 C 로 만든 KOREA.EXE 를 역어셈블해서
  C 로 옮긴 것입니다.  게임 규칙, 스테이지 100개, 소리, 속도는 원판
  그대로이고 다음만 다릅니다.

    1) 화면을 VGA 640x480 으로 그립니다.
       원판은 허큘리스(640x400 흑백)나 CGA 에서 돌았습니다.
       허큘리스 화면을 그대로 옮겨 그리므로 원판과 똑같이 보입니다.

    2) 위 화살표로도 블록을 돌릴 수 있습니다 (원판은 숫자판 5 만).

게임
  떨어지는 블록으로 줄을 채워 지우는 테트리스 형식입니다.
  판 곳곳에 갇힌 사람을 줄을 지워서 모두 구하면 다음 스테이지로 갑니다.
  가끔 블록 대신 아이템이 떨어집니다 - Space 로 쏩니다.
      MAKE ROCKET   내려가다 멈춘 자리에 벽돌을 만든다
      ERASE ROCKET  내려가다 처음 만난 벽돌을 지운다
      BOMB          둘레를 벽돌로 채워 한꺼번에 지운다
      LASER         그 줄을 채워 지운다
      TURBO         벽돌들을 아래로 모은다
  스테이지마다 정해진 시간(TIMER)이 되면 판이 밀리거나 벽돌이 생기는
  일(OPTION)이 일어납니다.

조작
  메뉴     위/아래 또는 1/2 로 고르고 Enter 나 Space,  Esc 끝내기
  게임     왼쪽/오른쪽  옮기기          아래     한 칸 내리기
           위, 숫자판 5 돌리기          Space    바닥까지 떨어뜨리기
           F1           배경음악 켜기/끄기
           Esc          끝내기

스테이지 편집기 (메뉴 STAGE EDIT)
  화살표 커서, A..Z 벽돌 넣기(O 는 사람), Space 지우기
  PgUp/PgDn 다음/이전 스테이지,  8 2 4 6 판 밀기
  Enter 복사, BackSpace 붙여넣기, Del 비우기
  Ctrl+S / Alt+S 속도,  Alt+P / Ctrl+P 아이템,  Alt+O / Ctrl+O 기믹
  Alt+B / Ctrl+B 보너스,  Alt+T / Ctrl+T 기믹 시간
  Ctrl+Enter  KOREA.STG 에 저장,  Esc 메뉴로

실행
  DOSBox 나 도스에서 이 폴더로 가서  KOREA  라고 칩니다.

이 폴더의 파일
  KOREA.EXE      게임
  CWSDPMI.EXE    도스에서 32비트로 돌리기 위한 DPMI 서버 (같이 있어야 합니다)
  KOREA.PTN      16x16 글꼴/그림 256개 (1990년 원본 파일)
  KOREA.STG      스테이지 100개 (1990년 원본 파일, 편집기로 고칠 수 있습니다)
"""

README_VGA = """코리아 (KOREA) - 256색 개선판

  1990년 PARK S.G. 님이 터보 C 로 만든 KOREA.EXE 를 C 로 옮기고
  화면과 소리를 새로 꾸민 판입니다.  게임 규칙과 스테이지 100개는
  원판 그대로입니다.

    - VESA 256색 640x400 화면 (없으면 640x480, 그것도 없으면 320x200)
    - 원판 흑백 그림 256개를 색칠한 스프라이트 (유리 벽돌, 태극기 ...)
    - 첫 화면 KOREAN TETRIS 로고를 글자마다 다른 색으로
    - 애드립(OPL2) 배경음악
        첫 화면   아리랑 (록 편곡)
        게임 중   코로베이니키(테트리스 원곡 민요) + 아리랑 메들리
        스테이지를 깼을 때, 게임이 끝났을 때, 보너스를 셀 때 효과음
    - 블록이 옆으로 부드럽게 미끄러지고, Space 로 떨어뜨리면
      점점 빨라지며 떨어지는 모습이 보입니다
    - 블록이 나오자마자 Space 를 눌러도 떨어집니다
      (원판은 맨 위 두 줄에서는 무시했습니다)
    - 위 화살표로도 블록을 돌릴 수 있습니다
    - 메뉴에 QUIT (원판의 만들다 만 두 메뉴 대신)

게임
  떨어지는 블록으로 줄을 채워 지우는 테트리스 형식입니다.
  판 곳곳에 갇힌 사람을 줄을 지워서 모두 구하면 다음 스테이지로 갑니다.
  가끔 블록 대신 아이템이 떨어집니다 - Space 로 쏩니다.
      MAKE ROCKET   내려가다 멈춘 자리에 벽돌을 만든다
      ERASE ROCKET  내려가다 처음 만난 벽돌을 지운다
      BOMB          둘레를 벽돌로 채워 한꺼번에 지운다
      LASER         그 줄을 채워 지운다
      TURBO         벽돌들을 아래로 모은다
  스테이지마다 정해진 시간(TIMER)이 되면 판이 밀리거나 벽돌이 생기는
  일(OPTION)이 일어납니다.

조작
  메뉴     위/아래 또는 1/2 로 고르고 Enter 나 Space,  Esc 끝내기
  게임     왼쪽/오른쪽  옮기기          아래     한 칸 내리기
           위, 숫자판 5 돌리기          Space    바닥까지 떨어뜨리기
           F1           배경음악 끄기/켜기
           Esc          끝내기

스테이지 편집기 (메뉴 STAGE EDIT)
  화살표 커서, A..Z 벽돌 넣기(O 는 사람), Space 지우기
  PgUp/PgDn 다음/이전 스테이지,  8 2 4 6 판 밀기
  Enter 복사, BackSpace 붙여넣기, Del 비우기
  Ctrl+S / Alt+S 속도,  Alt+P / Ctrl+P 아이템,  Alt+O / Ctrl+O 기믹
  Alt+B / Ctrl+B 보너스,  Alt+T / Ctrl+T 기믹 시간
  Ctrl+Enter  KOREA.STG 에 저장,  Esc 메뉴로

실행
  DOSBox 나 도스에서 이 폴더로 가서  KOREAVGA  라고 칩니다.
  음악을 들으려면 애드립이나 사운드 블라스터(포트 388h)가 있어야 합니다.
  (DOSBox 는 기본 설정 그대로 들립니다)

이 폴더의 파일
  KOREAVGA.EXE   게임
  CWSDPMI.EXE    도스에서 32비트로 돌리기 위한 DPMI 서버 (같이 있어야 합니다)
  KOREA256.SPR   256색 스프라이트 256장과 팔레트
  KOREA.STG      스테이지 100개 (1990년 원본 파일, 편집기로 고칠 수 있습니다)
  SOUND.DAT      애드립 곡/효과음 다섯 개를 묶은 것
"""

PACKAGES = [
    ('KOREA', [('korea.exe', 'KOREA.EXE'), ('CWSDPMI.EXE', 'CWSDPMI.EXE'),
               ('KOREA.PTN', 'KOREA.PTN'), ('KOREA.STG', 'KOREA.STG')], README_MONO),
    ('KOREAVGA', [('koreavga.exe', 'KOREAVGA.EXE'), ('CWSDPMI.EXE', 'CWSDPMI.EXE'),
                  ('KOREA256.SPR', 'KOREA256.SPR'), ('KOREA.STG', 'KOREA.STG'),
                  ('SOUND.DAT', 'SOUND.DAT')], README_VGA),
]

def main():
    if os.path.isdir(OUT):
        shutil.rmtree(OUT)
    os.makedirs(OUT)
    zpath = os.path.join(OUT, 'korea.zip')
    with zipfile.ZipFile(zpath, 'w', zipfile.ZIP_DEFLATED) as z:
        for folder, files, readme in PACKAGES:
            d = os.path.join(OUT, folder)
            os.makedirs(d)
            for src, dst in files:
                shutil.copyfile(os.path.join(SRC, src), os.path.join(d, dst))
            with open(os.path.join(d, 'README.TXT'), 'wb') as f:
                f.write(readme.replace('\n', '\r\n').encode('cp949'))
            for name in sorted(os.listdir(d)):
                z.write(os.path.join(d, name), folder + '/' + name)
                print('%-9s %-13s %7d' % (folder, name, os.path.getsize(os.path.join(d, name))))
    print('korea.zip', os.path.getsize(zpath))

if __name__ == '__main__':
    main()
