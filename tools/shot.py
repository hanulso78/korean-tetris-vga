# -*- coding: utf-8 -*-
"""DOSBox 로 게임을 띄우고 창을 바깥에서 찍는다 (게임 쪽은 손대지 않는다).

   쓰는 법 :  python tools/shot.py             네 장 모두 docs/ 에 만든다
              python tools/shot.py title_vga   한 장만

   DOSBox 창을 띄우고, 키를 몇 개 넣어 원하는 화면까지 간 다음,
   DOSBox 자체 화면 저장(Ctrl+F5)으로 그림을 받는다.  소리는 끄고 돌린다.
   키를 넣을 때 DOSBox 창이 잠깐 앞으로 올라온다.
"""
import os, sys, time, glob, shutil, subprocess, tempfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
DOSBOX = os.environ.get('DOSBOX', r'D:\Works\dos-dev-system\dosbox\dosbox.exe')
OUT = os.path.join(ROOT, 'docs')

#  이름            뜰 명령        보낼 키            기다릴 초(띄운 뒤, 키 보낸 뒤)
SHOTS = [
    ('title_vga',  'koreavga',    '',                 7, 0),
    ('play_vga',   'koreavga',    '{ENTER}',          7, 9),
    ('editor_vga', 'koreavga',    '{DOWN},{ENTER}',   7, 4),
    ('title_mono', 'korea',       '',                 7, 0),
]

CONF = '''[sdl]
fullscreen=false
output=surface
windowresolution=original
[dosbox]
machine=svga_s3
memsize=32
captures=%s
[mixer]
nosound=true
[cpu]
core=auto
cycles=max
[autoexec]
mount C "%s"
C:
%s
exit
'''

#  SDL 은 창이 앞에 있을 때만 키를 받는다.  그래서 DOSBox 창을 앞으로 끌어와
#  (여러 번 시도한다) 그 창이 앞에 있는 게 확인될 때만 키를 보낸다.
#  화면은 DOSBox 자체 캡처(Ctrl+F5)로 받는다 - 게임 해상도 그대로 나오고
#  다른 창이 위에 겹쳐 있어도 상관없다.
PS = r'''
Add-Type -AssemblyName System.Windows.Forms,Microsoft.VisualBasic
Add-Type @"
using System;using System.Runtime.InteropServices;
public class W{
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h,int c);
 [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h,IntPtr a,int x,int y,int w,int t,uint f);
 [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a,uint b,bool c);
 [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h,IntPtr p);
 [DllImport("user32.dll",EntryPoint="GetWindowThreadProcessId")] public static extern uint GetWinPid(IntPtr h,ref int p);
 [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
}
"@
$p=Get-Process -Id DOSPID -ErrorAction SilentlyContinue
if($p -eq $null){Write-Output "no process";exit}
$h=$p.MainWindowHandle
if($h -eq 0){Write-Output "no window";exit}
$SEND='SENDKEYS'
$ok=$false
for($i=0;$i -lt 20 -and -not $ok;$i++){                         # 앞으로 끌어오기, 될 때까지
  $fgw=[W]::GetForegroundWindow()
  $fgt=[W]::GetWindowThreadProcessId($fgw,[IntPtr]::Zero)
  [void][W]::AttachThreadInput($fgt,[W]::GetCurrentThreadId(),$true)
  [void][W]::ShowWindow($h,9)                                   # SW_RESTORE
  [void][W]::SetWindowPos($h,[IntPtr]-1,0,0,0,0,0x0003)         # HWND_TOPMOST
  [void][W]::SetForegroundWindow($h)
  try{[Microsoft.VisualBasic.Interaction]::AppActivate(DOSPID)}catch{}
  [void][W]::AttachThreadInput($fgt,[W]::GetCurrentThreadId(),$false)
  Start-Sleep -Milliseconds 500
  $q=0; [void][W]::GetWinPid([W]::GetForegroundWindow(),[ref]$q)
  $ok = ($q -eq DOSPID)
}
if(-not $ok){Write-Output "not focused";exit}                   # 키가 남의 창으로 가면 안 된다
function Send-Key($k){                                          # 보내기 직전에 다시 확인
  $q=0; [void][W]::GetWinPid([W]::GetForegroundWindow(),[ref]$q)
  if($q -ne DOSPID){Write-Output "focus lost";exit}
  [System.Windows.Forms.SendKeys]::SendWait($k)
}
foreach($k in $SEND.Split(',')){                                # 한 키씩 천천히
  if($k -ne ''){
    Send-Key $k
    Start-Sleep -Milliseconds 700
  }
}
Start-Sleep -Milliseconds AFTERMS
Send-Key "^{F5}"                                                # DOSBox 화면 저장
Start-Sleep -Milliseconds 1500
Write-Output "ok"
'''

def shoot(name, cmd, keys, wait, after):
    out = os.path.join(OUT, name + '.png')
    cap = os.path.join(tempfile.gettempdir(), 'koreacap')
    shutil.rmtree(cap, ignore_errors=True)
    os.makedirs(cap, exist_ok=True)
    conf = os.path.join(tempfile.gettempdir(), 'koreashot.conf')
    open(conf, 'w').write(CONF % (cap, ROOT, cmd))
    p = subprocess.Popen([DOSBOX, '-conf', conf, '-noconsole'], cwd=os.path.dirname(DOSBOX))
    time.sleep(wait)
    ps = (PS.replace('DOSPID', str(p.pid))
            .replace('SENDKEYS', keys).replace('AFTERMS', str(int(after * 1000))))
    sc = os.path.join(tempfile.gettempdir(), 'koreashot.ps1')
    open(sc, 'w').write(ps)
    r = subprocess.run(['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', sc],
                       capture_output=True, text=True)
    subprocess.run(['taskkill', '/PID', str(p.pid), '/F'], capture_output=True)   # 내가 띄운 것만 닫는다
    got = sorted(glob.glob(os.path.join(cap, '*.png')))
    if got:
        shutil.copyfile(got[-1], out)
    print('%-11s %s %s' % (name, (r.stdout + r.stderr).strip().replace('\n', ' '),
                           os.path.basename(got[-1]) if got else 'NO SHOT'))
    return bool(got)

def main():
    os.makedirs(OUT, exist_ok=True)
    want = sys.argv[1:]
    for s in SHOTS:
        if want and s[0] not in want:
            continue
        for _ in range(4):              # 남의 창이 포커스를 뺏으면 다시 해 본다
            if shoot(*s):
                break
            time.sleep(3)

if __name__ == '__main__':
    main()
