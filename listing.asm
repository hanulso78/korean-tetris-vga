
;======================================================================
; MODULE KOR-BGM.C
;======================================================================

; ---------------------------------------------------------------
_music_play:   ; 0x01bc..0x023d  locals:
                                  ; ---- KOR-BGM.C:41
01bc  push   bp
01bd  mov    bp,sp
                                  ; ---- KOR-BGM.C:43
01bf  test   WORD PTR [_information],0x1
01c5  je     0x1d6
01c7  mov    ax,[_play_data]
01ca  inc    WORD PTR [_play_data]
01ce  push   ax
01cf  call   _sound
01d2  inc    sp
01d3  inc    sp
01d4  jmp    0x1d9
                                  ; ---- KOR-BGM.C:44
01d6  call   _nosound
                                  ; ---- KOR-BGM.C:45
01d9  mov    ax,[_play_wait]
01dc  dec    WORD PTR [_play_wait]
01e0  or     ax,ax
01e2  jne    0x23b
                                  ; ---- KOR-BGM.C:46
01e4  mov    ax,[_music_select]
01e7  mov    dx,0xc8
01ea  mul    dx
01ec  mov    bx,ax
01ee  add    bx,0x94
01f2  mov    ax,ds
01f4  mov    es,ax
01f6  add    bx,WORD PTR [_play_point]
01fa  mov    al,BYTE PTR es:[bx]
01fd  cbw
01fe  mov    bx,ax
0200  shl    bx,1
0202  mov    ax,WORD PTR [bx+0x224]               ; bx+_oct_data
0206  mov    [_play_data],ax
0209  inc    WORD PTR [_play_point]
                                  ; ---- KOR-BGM.C:47
020d  mov    ax,[_music_select]
0210  mov    dx,0xc8
0213  mul    dx
0215  mov    bx,ax
0217  add    bx,0x94
021b  mov    ax,ds
021d  mov    es,ax
021f  add    bx,WORD PTR [_play_point]
0223  mov    al,BYTE PTR es:[bx]
0226  cbw
0227  mov    [_play_wait],ax
022a  inc    WORD PTR [_play_point]
                                  ; ---- KOR-BGM.C:48
022e  cmp    WORD PTR [_play_wait],0x0
0233  jne    0x23b
0235  mov    WORD PTR [_play_point],0x0
                                  ; ---- KOR-BGM.C:50
023b  pop    bp
023c  ret

;======================================================================
; MODULE KOR-TIT.C
;======================================================================

; ---------------------------------------------------------------
_select_subrutine:   ; 0x023d..0x0261  locals: bp+4=s
                                  ; ---- KOR-TIT.C:12
023d  push   bp
023e  mov    bp,sp
                                  ; ---- KOR-TIT.C:14
0240  mov    ax,WORD PTR [bp+0x4]                 ; s
0243  cmp    ax,0x1
0246  je     0x24f
0248  cmp    ax,0x2
024b  je     0x257
024d  jmp    0x25f
                                  ; ---- KOR-TIT.C:15
024f  mov    WORD PTR [_flag],0x2
0255  jmp    0x25f
                                  ; ---- KOR-TIT.C:16
0257  mov    WORD PTR [_flag],0xc8
025d  jmp    0x25f
                                  ; ---- KOR-TIT.C:18
025f  pop    bp
0260  ret

; ---------------------------------------------------------------
_game_title:   ; 0x0261..0x047b  locals: bp-2=key, bp-4=ry, bp-6=j, bp-8=i, di=ss, si=y
                                  ; ---- KOR-TIT.C:21
0261  push   bp
0262  mov    bp,sp
0264  sub    sp,0x8
0267  push   si                                   ; si=y
0268  push   di                                   ; di=ss
                                  ; ---- KOR-TIT.C:25
0269  xor    si,si                                ; si=y
026b  mov    WORD PTR [_locy],si                  ; si=y
026f  mov    WORD PTR [_locx],si                  ; si=y
0273  mov    WORD PTR [bp-0x6],si                 ; j | si=y
0276  mov    WORD PTR [bp-0x8],si                 ; i | si=y
                                  ; ---- KOR-TIT.C:26
0279  call   _nosound
                                  ; ---- KOR-TIT.C:27
027c  push   ds
027d  mov    ax,0x27e                             ; "                                        "
0280  push   ax
0281  call   _lprint
0284  add    sp,0x4
                                  ; ---- KOR-TIT.C:28
0287  push   ds
0288  mov    ax,0x2a7                             ; " e  e  eeee  eee   eeee   ee   e  e     "
028b  push   ax
028c  call   _lprint
028f  add    sp,0x4
                                  ; ---- KOR-TIT.C:29
0292  push   ds
0293  mov    ax,0x2d0                             ; " e e   e  e  e  e  e     e  e  ee e     "
0296  push   ax
0297  call   _lprint
029a  add    sp,0x4
                                  ; ---- KOR-TIT.C:30
029d  push   ds
029e  mov    ax,0x2f9                             ; " ee    e  e  eee   eee   eeee  e ee     "
02a1  push   ax
02a2  call   _lprint
02a5  add    sp,0x4
                                  ; ---- KOR-TIT.C:31
02a8  push   ds
02a9  mov    ax,0x322                             ; " e e   e  e  e  e  e     e  e  e  e     "
02ac  push   ax
02ad  call   _lprint
02b0  add    sp,0x4
                                  ; ---- KOR-TIT.C:32
02b3  push   ds
02b4  mov    ax,0x34b                             ; " e  e  eeee  e  e  eeee  e  e  e  e     "
02b7  push   ax
02b8  call   _lprint
02bb  add    sp,0x4
                                  ; ---- KOR-TIT.C:33
02be  push   ds
02bf  mov    ax,0x374                             ; "                                        "
02c2  push   ax
02c3  call   _lprint
02c6  add    sp,0x4
                                  ; ---- KOR-TIT.C:34
02c9  push   ds
02ca  mov    ax,0x39d                             ; "                                        "
02cd  push   ax
02ce  call   _lprint
02d1  add    sp,0x4
                                  ; ---- KOR-TIT.C:35
02d4  push   ds
02d5  mov    ax,0x3c6                             ; "       eeeee eeee  eeeee eee   eee eeee "
02d8  push   ax
02d9  call   _lprint
02dc  add    sp,0x4
                                  ; ---- KOR-TIT.C:36
02df  push   ds
02e0  mov    ax,0x3ef                             ; "         e   e       e   e  e   e  e    "
02e3  push   ax
02e4  call   _lprint
02e7  add    sp,0x4
                                  ; ---- KOR-TIT.C:37
02ea  push   ds
02eb  mov    ax,0x418                             ; "         e   eee     e   eee    e  eeee "
02ee  push   ax
02ef  call   _lprint
02f2  add    sp,0x4
                                  ; ---- KOR-TIT.C:38
02f5  push   ds
02f6  mov    ax,0x441                             ; "         e   e       e   e  e   e     e "
02f9  push   ax
02fa  call   _lprint
02fd  add    sp,0x4
                                  ; ---- KOR-TIT.C:39
0300  push   ds
0301  mov    ax,0x46a                             ; "         e   eeee    e   e  e  eee eeee "
0304  push   ax
0305  call   _lprint
0308  add    sp,0x4
                                  ; ---- KOR-TIT.C:40
030b  push   ds
030c  mov    ax,0x493                             ; "                                        "
030f  push   ax
0310  call   _lprint
0313  add    sp,0x4
                                  ; ---- KOR-TIT.C:41
0316  push   ds
0317  mov    ax,0x4bc                             ; "                                        "
031a  push   ax
031b  call   _lprint
031e  add    sp,0x4
                                  ; ---- KOR-TIT.C:42
0321  push   ds
0322  mov    ax,0x4e5                             ; "                                        "
0325  push   ax
0326  call   _lprint
0329  add    sp,0x4
                                  ; ---- KOR-TIT.C:43
032c  push   ds
032d  mov    ax,0x50e                             ; "                                        "
0330  push   ax
0331  call   _lprint
0334  add    sp,0x4
                                  ; ---- KOR-TIT.C:44
0337  push   ds
0338  mov    ax,0x537                             ; "    GAME   START                        "
033b  push   ax
033c  call   _lprint
033f  add    sp,0x4
                                  ; ---- KOR-TIT.C:45
0342  push   ds
0343  mov    ax,0x560                             ; "                                        "
0346  push   ax
0347  call   _lprint
034a  add    sp,0x4
                                  ; ---- KOR-TIT.C:46
034d  push   ds
034e  mov    ax,0x589                             ; "    STAGE  EDIT                         "
0351  push   ax
0352  call   _lprint
0355  add    sp,0x4
                                  ; ---- KOR-TIT.C:47
0358  push   ds
0359  mov    ax,0x5b2                             ; "                                        "
035c  push   ax
035d  call   _lprint
0360  add    sp,0x4
                                  ; ---- KOR-TIT.C:48
0363  push   ds
0364  mov    ax,0x5db                             ; "    EDIT   GAME  START                  "
0367  push   ax
0368  call   _lprint
036b  add    sp,0x4
                                  ; ---- KOR-TIT.C:49
036e  push   ds
036f  mov    ax,0x604                             ; "                                        "
0372  push   ax
0373  call   _lprint
0376  add    sp,0x4
                                  ; ---- KOR-TIT.C:50
0379  push   ds
037a  mov    ax,0x62d                             ; "    INPUT  PASSWORD                     "
037d  push   ax
037e  call   _lprint
0381  add    sp,0x4
                                  ; ---- KOR-TIT.C:51
0384  push   ds
0385  mov    ax,0x656                             ; "                                        "
0388  push   ax
0389  call   _lprint
038c  add    sp,0x4
                                  ; ---- KOR-TIT.C:53
038f  call   _key_scan_init
0392  jmp    0x472
                                  ; ---- KOR-TIT.C:56
0395  call   _key_scan
0398  mov    WORD PTR [bp-0x2],ax                 ; key
                                  ; ---- KOR-TIT.C:57
039b  xor    di,di                                ; di=ss
                                  ; ---- KOR-TIT.C:58
039d  mov    WORD PTR [bp-0x4],si                 ; ry | si=y
                                  ; ---- KOR-TIT.C:59
03a0  mov    ax,WORD PTR [bp-0x2]                 ; key
03a3  cmp    ax,0x1c
03a6  je     0x3e9
03a8  jg     0x3bb
03aa  cmp    ax,0x1
03ad  je     0x3ee
03af  cmp    ax,0x2
03b2  je     0x3cc
03b4  cmp    ax,0x3
03b7  je     0x3d0
03b9  jmp    0x3fa
03bb  cmp    ax,0x39
03be  je     0x3e9
03c0  cmp    ax,0x48
03c3  je     0x3d5
03c5  cmp    ax,0x50
03c8  je     0x3df
03ca  jmp    0x3fa
                                  ; ---- KOR-TIT.C:60
03cc  xor    si,si                                ; si=y
03ce  jmp    0x3fa
                                  ; ---- KOR-TIT.C:61
03d0  mov    si,0x1                               ; si=y
03d3  jmp    0x3fa
                                  ; ---- KOR-TIT.C:62
03d5  mov    ax,si                                ; si=y
03d7  dec    ax
03d8  and    ax,0x3
03db  mov    si,ax                                ; si=y
03dd  jmp    0x3fa
                                  ; ---- KOR-TIT.C:63
03df  mov    ax,si                                ; si=y
03e1  inc    ax
03e2  and    ax,0x3
03e5  mov    si,ax                                ; si=y
03e7  jmp    0x3fa
                                  ; ---- KOR-TIT.C:65
03e9  mov    di,si                                ; si=y | di=ss
03eb  inc    di                                   ; di=ss
03ec  jmp    0x3fa
                                  ; ---- KOR-TIT.C:66
03ee  call   _textset
03f1  mov    ax,0x1
03f4  push   ax
03f5  call   _exit
03f8  inc    sp
03f9  inc    sp
                                  ; ---- KOR-TIT.C:69
03fa  mov    ax,WORD PTR [bp-0x6]                 ; j
03fd  inc    ax
03fe  mov    bx,0x3
0401  cwd
0402  idiv   bx
0404  mov    WORD PTR [bp-0x6],dx                 ; j
                                  ; ---- KOR-TIT.C:70
0407  cmp    WORD PTR [bp-0x6],0x0                ; j
040b  jne    0x41a
040d  mov    ax,WORD PTR [bp-0x8]                 ; i
0410  inc    ax
0411  mov    bx,0x3
0414  cwd
0415  idiv   bx
0417  mov    WORD PTR [bp-0x8],dx                 ; i
                                  ; ---- KOR-TIT.C:71
041a  call   _clock_wait
                                  ; ---- KOR-TIT.C:72
041d  push   ds
041e  mov    ax,WORD PTR [bp-0x8]                 ; i
0421  add    ax,0xfd
0424  mov    cl,0x5
0426  shl    ax,cl
0428  add    ax,0x20ae
042b  push   ax
042c  mov    ax,si                                ; si=y
042e  shl    ax,1
0430  add    ax,0x11
0433  push   ax
0434  mov    ax,0x2
0437  push   ax
0438  call   _putptn
043b  add    sp,0x8
                                  ; ---- KOR-TIT.C:73
043e  mov    ax,WORD PTR [bp-0x4]                 ; ry
0441  cmp    ax,si                                ; si=y
0443  je     0x45d
0445  push   ds
0446  mov    ax,0x24ae                            ; &_chr+0x400?
0449  push   ax
044a  mov    ax,WORD PTR [bp-0x4]                 ; ry
044d  shl    ax,1
044f  add    ax,0x11
0452  push   ax
0453  mov    ax,0x2
0456  push   ax
0457  call   _putptn
045a  add    sp,0x8
                                  ; ---- KOR-TIT.C:74
045d  or     di,di                                ; di=ss
045f  je     0x472
                                  ; ---- KOR-TIT.C:75
0461  push   di                                   ; di=ss
0462  call   _select_subrutine
0465  inc    sp
0466  inc    sp
                                  ; ---- KOR-TIT.C:76
0467  mov    ax,0x3
046a  push   ax
046b  call   _sec_wait
046e  inc    sp
046f  inc    sp
0470  jmp    0x475
                                  ; ---- KOR-TIT.C:55
0472  jmp    0x395
                                  ; ---- KOR-TIT.C:81
0475  pop    di                                   ; di=ss
0476  pop    si                                   ; si=y
0477  mov    sp,bp
0479  pop    bp
047a  ret

;======================================================================
; MODULE KOR-STG.C
;======================================================================

; ---------------------------------------------------------------
_user_stage_title:   ; 0x047b..0x059b  locals:
                                  ; ---- KOR-STG.C:57
047b  push   bp
047c  mov    bp,sp
                                  ; ---- KOR-STG.C:59
047e  xor    ax,ax
0480  mov    [_locy],ax
0483  mov    [_locx],ax
                                  ; ---- KOR-STG.C:61
0486  push   ds
0487  mov    ax,0x6bc                             ; "        STAGE  EDIT  VERSION 1.5        "
048a  push   ax
048b  call   _lprint
048e  add    sp,0x4
                                  ; ---- KOR-STG.C:62
0491  push   ds
0492  mov    ax,0x6e5                             ; "                                        "
0495  push   ax
0496  call   _lprint
0499  add    sp,0x4
                                  ; ---- KOR-STG.C:63
049c  push   ds
049d  mov    ax,0x70e                             ; "                                        "
04a0  push   ax
04a1  call   _lprint
04a4  add    sp,0x4
                                  ; ---- KOR-STG.C:64
04a7  push   ds
04a8  mov    ax,0x737                             ; "                                        "
04ab  push   ax
04ac  call   _lprint
04af  add    sp,0x4
                                  ; ---- KOR-STG.C:65
04b2  push   ds
04b3  mov    ax,0x760                             ; &msg+0xc2?
04b6  push   ax
04b7  call   _lprint
04ba  add    sp,0x4
                                  ; ---- KOR-STG.C:66
04bd  push   ds
04be  mov    ax,0x789                             ; "  b ; B       q          q  STAGE  ; 00 "
04c1  push   ax
04c2  call   _lprint
04c5  add    sp,0x4
                                  ; ---- KOR-STG.C:67
04c8  push   ds
04c9  mov    ax,0x7b2                             ; &msg+0x114?
04cc  push   ax
04cd  call   _lprint
04d0  add    sp,0x4
                                  ; ---- KOR-STG.C:68
04d3  push   ds
04d4  mov    ax,0x7db                             ; "  d ; D       q          q  SPEED  ; 00 "
04d7  push   ax
04d8  call   _lprint
04db  add    sp,0x4
                                  ; ---- KOR-STG.C:69
04de  push   ds
04df  mov    ax,0x804                             ; &msg+0x166?
04e2  push   ax
04e3  call   _lprint
04e6  add    sp,0x4
                                  ; ---- KOR-STG.C:70
04e9  push   ds
04ea  mov    ax,0x82d                             ; "  f ; F       q          q  POWER  ; 00 "
04ed  push   ax
04ee  call   _lprint
04f1  add    sp,0x4
                                  ; ---- KOR-STG.C:71
04f4  push   ds
04f5  mov    ax,0x856                             ; &msg+0x1b8?
04f8  push   ax
04f9  call   _lprint
04fc  add    sp,0x4
                                  ; ---- KOR-STG.C:72
04ff  push   ds
0500  mov    ax,0x87f                             ; "  h ; H       q          q  OPTION ;  0 "
0503  push   ax
0504  call   _lprint
0507  add    sp,0x4
                                  ; ---- KOR-STG.C:73
050a  push   ds
050b  mov    ax,0x8a8                             ; &msg+0x20a?
050e  push   ax
050f  call   _lprint
0512  add    sp,0x4
                                  ; ---- KOR-STG.C:74
0515  push   ds
0516  mov    ax,0x8d1                             ; "  j ; J       q          q  BONUS  ; 00 "
0519  push   ax
051a  call   _lprint
051d  add    sp,0x4
                                  ; ---- KOR-STG.C:75
0520  push   ds
0521  mov    ax,0x8fa                             ; &msg+0x25c?
0524  push   ax
0525  call   _lprint
0528  add    sp,0x4
                                  ; ---- KOR-STG.C:76
052b  push   ds
052c  mov    ax,0x923                             ; "  l ; L       q          q  TIMER  ; 00 "
052f  push   ax
0530  call   _lprint
0533  add    sp,0x4
                                  ; ---- KOR-STG.C:77
0536  push   ds
0537  mov    ax,0x94c                             ; &msg+0x2ae?
053a  push   ax
053b  call   _lprint
053e  add    sp,0x4
                                  ; ---- KOR-STG.C:78
0541  push   ds
0542  mov    ax,0x975                             ; "  n ; N       q          q              "
0545  push   ax
0546  call   _lprint
0549  add    sp,0x4
                                  ; ---- KOR-STG.C:79
054c  push   ds
054d  mov    ax,0x99e                             ; "  o ; O       q          q              "
0550  push   ax
0551  call   _lprint
0554  add    sp,0x4
                                  ; ---- KOR-STG.C:80
0557  push   ds
0558  mov    ax,0x9c7                             ; "              q          q              "
055b  push   ax
055c  call   _lprint
055f  add    sp,0x4
                                  ; ---- KOR-STG.C:81
0562  push   ds
0563  mov    ax,0x9f0                             ; "              q          q              "
0566  push   ax
0567  call   _lprint
056a  add    sp,0x4
                                  ; ---- KOR-STG.C:82
056d  push   ds
056e  mov    ax,0xa19                             ; " PROGRAMMER   q          q              "
0571  push   ax
0572  call   _lprint
0575  add    sp,0x4
                                  ; ---- KOR-STG.C:83
0578  push   ds
0579  mov    ax,0xa42                             ; "              q          q              "
057c  push   ax
057d  call   _lprint
0580  add    sp,0x4
                                  ; ---- KOR-STG.C:84
0583  push   ds
0584  mov    ax,0xa6b                             ; "   P.S.G.     q          q              "
0587  push   ax
0588  call   _lprint
058b  add    sp,0x4
                                  ; ---- KOR-STG.C:85
058e  push   ds
058f  mov    ax,0xa94                             ; "              rsssssssssst              "
0592  push   ax
0593  call   _lprint
0596  add    sp,0x4
                                  ; ---- KOR-STG.C:86
0599  pop    bp
059a  ret

; ---------------------------------------------------------------
_put_cursor:   ; 0x059b..0x05e9  locals: bp-4=vad, di=yy, si=i
                                  ; ---- KOR-STG.C:89
059b  push   bp
059c  mov    bp,sp
059e  sub    sp,0x4
05a1  push   si                                   ; si=i
05a2  push   di                                   ; di=yy
                                  ; ---- KOR-STG.C:92
05a3  mov    di,WORD PTR [_kory]                  ; di=yy
05a7  mov    cl,0x4
05a9  shl    di,cl                                ; di=yy
05ab  add    di,0x10                              ; di=yy
                                  ; ---- KOR-STG.C:93
05ae  xor    si,si                                ; si=i
05b0  jmp    0x5de
                                  ; ---- KOR-STG.C:94
05b2  mov    bx,di                                ; di=yy
05b4  add    bx,si                                ; si=i
05b6  shl    bx,1
05b8  shl    bx,1
05ba  les    bx,DWORD PTR [bx+0x1a6c]             ; bx+_yad
05be  mov    ax,[_korx]
05c1  add    ax,0xc
05c4  shl    ax,1
05c6  add    bx,ax
05c8  mov    WORD PTR [bp-0x2],es
05cb  mov    WORD PTR [bp-0x4],bx                 ; vad
                                  ; ---- KOR-STG.C:95
05ce  les    bx,DWORD PTR [bp-0x4]                ; vad
05d1  mov    ax,WORD PTR es:[bx]
05d4  xor    ax,0xffff
05d7  les    bx,DWORD PTR [bp-0x4]                ; vad
05da  mov    WORD PTR es:[bx],ax
05dd  inc    si                                   ; si=i
05de  cmp    si,0x10                              ; si=i
05e1  jl     0x5b2
                                  ; ---- KOR-STG.C:97
05e3  pop    di                                   ; di=yy
05e4  pop    si                                   ; si=i
05e5  mov    sp,bp
05e7  pop    bp
05e8  ret

; ---------------------------------------------------------------
_screen_left:   ; 0x05e9..0x0662  locals: bp-2=r, di=i, si=j
                                  ; ---- KOR-STG.C:100
05e9  push   bp
05ea  mov    bp,sp
05ec  sub    sp,0x2
05ef  push   si                                   ; si=j
05f0  push   di                                   ; di=i
                                  ; ---- KOR-STG.C:103
05f1  mov    di,0x3                               ; di=i
05f4  jmp    0x657
                                  ; ---- KOR-STG.C:104
05f6  mov    bx,di                                ; di=i
05f8  mov    cl,0x4
05fa  shl    bx,cl
05fc  add    bx,0x18ba
0600  mov    ax,ds
0602  mov    es,ax
0604  mov    al,BYTE PTR es:[bx+0x3]
0608  mov    ah,0x0
060a  mov    WORD PTR [bp-0x2],ax                 ; r
                                  ; ---- KOR-STG.C:105
060d  mov    si,0x3                               ; si=j
0610  jmp    0x63a
                                  ; ---- KOR-STG.C:106
0612  mov    bx,di                                ; di=i
0614  mov    cl,0x4
0616  shl    bx,cl
0618  add    bx,0x18ba
061c  mov    ax,ds
061e  mov    es,ax
0620  add    bx,si                                ; si=j
0622  mov    al,BYTE PTR es:[bx+0x1]
0626  mov    bx,di                                ; di=i
0628  mov    cl,0x4
062a  shl    bx,cl
062c  add    bx,0x18ba
0630  push   ax
0631  mov    ax,ds
0633  mov    es,ax
0635  pop    ax
0636  mov    BYTE PTR es:[bx+si],al               ; si=j
0639  inc    si                                   ; si=j
063a  cmp    si,0xd                               ; si=j
063d  jl     0x612
                                  ; ---- KOR-STG.C:107
063f  mov    al,BYTE PTR [bp-0x2]                 ; r
0642  mov    bx,di                                ; di=i
0644  mov    cl,0x4
0646  shl    bx,cl
0648  add    bx,0x18ba
064c  push   ax
064d  mov    ax,ds
064f  mov    es,ax
0651  pop    ax
0652  mov    BYTE PTR es:[bx+0xc],al
0656  inc    di                                   ; di=i
0657  cmp    di,0x17                              ; di=i
065a  jl     0x5f6
                                  ; ---- KOR-STG.C:109
065c  pop    di                                   ; di=i
065d  pop    si                                   ; si=j
065e  mov    sp,bp
0660  pop    bp
0661  ret

; ---------------------------------------------------------------
_screen_right:   ; 0x0662..0x06db  locals: bp-2=r, di=i, si=j
                                  ; ---- KOR-STG.C:112
0662  push   bp
0663  mov    bp,sp
0665  sub    sp,0x2
0668  push   si                                   ; si=j
0669  push   di                                   ; di=i
                                  ; ---- KOR-STG.C:115
066a  mov    di,0x3                               ; di=i
066d  jmp    0x6d0
                                  ; ---- KOR-STG.C:116
066f  mov    bx,di                                ; di=i
0671  mov    cl,0x4
0673  shl    bx,cl
0675  add    bx,0x18ba
0679  mov    ax,ds
067b  mov    es,ax
067d  mov    al,BYTE PTR es:[bx+0xc]
0681  mov    ah,0x0
0683  mov    WORD PTR [bp-0x2],ax                 ; r
                                  ; ---- KOR-STG.C:117
0686  mov    si,0xc                               ; si=j
0689  jmp    0x6b3
                                  ; ---- KOR-STG.C:118
068b  mov    bx,di                                ; di=i
068d  mov    cl,0x4
068f  shl    bx,cl
0691  add    bx,0x18ba
0695  mov    ax,ds
0697  mov    es,ax
0699  add    bx,si                                ; si=j
069b  dec    bx
069c  mov    al,BYTE PTR es:[bx]
069f  mov    bx,di                                ; di=i
06a1  mov    cl,0x4
06a3  shl    bx,cl
06a5  add    bx,0x18ba
06a9  push   ax
06aa  mov    ax,ds
06ac  mov    es,ax
06ae  pop    ax
06af  mov    BYTE PTR es:[bx+si],al               ; si=j
06b2  dec    si                                   ; si=j
06b3  cmp    si,0x3                               ; si=j
06b6  jg     0x68b
                                  ; ---- KOR-STG.C:119
06b8  mov    al,BYTE PTR [bp-0x2]                 ; r
06bb  mov    bx,di                                ; di=i
06bd  mov    cl,0x4
06bf  shl    bx,cl
06c1  add    bx,0x18ba
06c5  push   ax
06c6  mov    ax,ds
06c8  mov    es,ax
06ca  pop    ax
06cb  mov    BYTE PTR es:[bx+0x3],al
06cf  inc    di                                   ; di=i
06d0  cmp    di,0x17                              ; di=i
06d3  jl     0x66f
                                  ; ---- KOR-STG.C:121
06d5  pop    di                                   ; di=i
06d6  pop    si                                   ; si=j
06d7  mov    sp,bp
06d9  pop    bp
06da  ret

; ---------------------------------------------------------------
_screen_up:   ; 0x06db..0x0734  locals: bp-2=n, di=i, si=j
                                  ; ---- KOR-STG.C:124
06db  push   bp
06dc  mov    bp,sp
06de  sub    sp,0x2
06e1  push   si                                   ; si=j
06e2  push   di                                   ; di=i
                                  ; ---- KOR-STG.C:128
06e3  mov    di,0x3                               ; di=i
06e6  jmp    0x729
                                  ; ---- KOR-STG.C:129
06e8  mov    al,BYTE PTR [di+0x18ea]              ; _STAGE+0x30 | di=i
06ec  mov    ah,0x0
06ee  mov    WORD PTR [bp-0x2],ax                 ; n
                                  ; ---- KOR-STG.C:130
06f1  mov    si,0x3                               ; si=j
06f4  jmp    0x71c
                                  ; ---- KOR-STG.C:131
06f6  mov    bx,si                                ; si=j
06f8  inc    bx
06f9  mov    cl,0x4
06fb  shl    bx,cl
06fd  add    bx,0x18ba
0701  mov    ax,ds
0703  mov    es,ax
0705  mov    al,BYTE PTR es:[bx+di]               ; di=i
0708  mov    bx,si                                ; si=j
070a  mov    cl,0x4
070c  shl    bx,cl
070e  add    bx,0x18ba
0712  push   ax
0713  mov    ax,ds
0715  mov    es,ax
0717  pop    ax
0718  mov    BYTE PTR es:[bx+di],al               ; di=i
071b  inc    si                                   ; si=j
071c  cmp    si,0x16                              ; si=j
071f  jl     0x6f6
                                  ; ---- KOR-STG.C:132
0721  mov    al,BYTE PTR [bp-0x2]                 ; n
0724  mov    BYTE PTR [di+0x1a1a],al              ; _STAGE+0x160 | di=i
0728  inc    di                                   ; di=i
0729  cmp    di,0xd                               ; di=i
072c  jl     0x6e8
                                  ; ---- KOR-STG.C:134
072e  pop    di                                   ; di=i
072f  pop    si                                   ; si=j
0730  mov    sp,bp
0732  pop    bp
0733  ret

; ---------------------------------------------------------------
_screen_down:   ; 0x0734..0x078d  locals: bp-2=n, di=i, si=j
                                  ; ---- KOR-STG.C:137
0734  push   bp
0735  mov    bp,sp
0737  sub    sp,0x2
073a  push   si                                   ; si=j
073b  push   di                                   ; di=i
                                  ; ---- KOR-STG.C:141
073c  mov    di,0x3                               ; di=i
073f  jmp    0x782
                                  ; ---- KOR-STG.C:142
0741  mov    al,BYTE PTR [di+0x1a1a]              ; _STAGE+0x160 | di=i
0745  mov    ah,0x0
0747  mov    WORD PTR [bp-0x2],ax                 ; n
                                  ; ---- KOR-STG.C:143
074a  mov    si,0x16                              ; si=j
074d  jmp    0x775
                                  ; ---- KOR-STG.C:144
074f  mov    bx,si                                ; si=j
0751  dec    bx
0752  mov    cl,0x4
0754  shl    bx,cl
0756  add    bx,0x18ba
075a  mov    ax,ds
075c  mov    es,ax
075e  mov    al,BYTE PTR es:[bx+di]               ; di=i
0761  mov    bx,si                                ; si=j
0763  mov    cl,0x4
0765  shl    bx,cl
0767  add    bx,0x18ba
076b  push   ax
076c  mov    ax,ds
076e  mov    es,ax
0770  pop    ax
0771  mov    BYTE PTR es:[bx+di],al               ; di=i
0774  dec    si                                   ; si=j
0775  cmp    si,0x3                               ; si=j
0778  jg     0x74f
                                  ; ---- KOR-STG.C:145
077a  mov    al,BYTE PTR [bp-0x2]                 ; n
077d  mov    BYTE PTR [di+0x18ea],al              ; _STAGE+0x30 | di=i
0781  inc    di                                   ; di=i
0782  cmp    di,0xd                               ; di=i
0785  jl     0x741
                                  ; ---- KOR-STG.C:147
0787  pop    di                                   ; di=i
0788  pop    si                                   ; si=j
0789  mov    sp,bp
078b  pop    bp
078c  ret

; ---------------------------------------------------------------
_screen_store:   ; 0x078d..0x07d7  locals: di=i, si=j
                                  ; ---- KOR-STG.C:150
078d  push   bp
078e  mov    bp,sp
0790  push   si                                   ; si=j
0791  push   di                                   ; di=i
                                  ; ---- KOR-STG.C:153
0792  xor    di,di                                ; di=i
0794  jmp    0x7ce
                                  ; ---- KOR-STG.C:154
0796  xor    si,si                                ; si=j
0798  jmp    0x7c8
                                  ; ---- KOR-STG.C:155
079a  mov    bx,di                                ; di=i
079c  add    bx,0x3
079f  mov    cl,0x4
07a1  shl    bx,cl
07a3  add    bx,0x18ba
07a7  mov    ax,ds
07a9  mov    es,ax
07ab  add    bx,si                                ; si=j
07ad  mov    al,BYTE PTR es:[bx+0x3]
07b1  push   ax
07b2  mov    ax,di                                ; di=i
07b4  mov    dx,0xa
07b7  mul    dx
07b9  mov    bx,ax
07bb  add    bx,0x17ee
07bf  mov    ax,ds
07c1  mov    es,ax
07c3  pop    ax
07c4  mov    BYTE PTR es:[bx+si],al               ; si=j
07c7  inc    si                                   ; si=j
07c8  cmp    si,0xa                               ; si=j
07cb  jl     0x79a
07cd  inc    di                                   ; di=i
07ce  cmp    di,0x14                              ; di=i
07d1  jl     0x796
                                  ; ---- KOR-STG.C:156
07d3  pop    di                                   ; di=i
07d4  pop    si                                   ; si=j
07d5  pop    bp
07d6  ret

; ---------------------------------------------------------------
_screen_restore:   ; 0x07d7..0x0821  locals: di=i, si=j
                                  ; ---- KOR-STG.C:159
07d7  push   bp
07d8  mov    bp,sp
07da  push   si                                   ; si=j
07db  push   di                                   ; di=i
                                  ; ---- KOR-STG.C:162
07dc  xor    di,di                                ; di=i
07de  jmp    0x818
                                  ; ---- KOR-STG.C:163
07e0  xor    si,si                                ; si=j
07e2  jmp    0x812
                                  ; ---- KOR-STG.C:164
07e4  mov    ax,di                                ; di=i
07e6  mov    dx,0xa
07e9  mul    dx
07eb  mov    bx,ax
07ed  add    bx,0x17ee
07f1  mov    ax,ds
07f3  mov    es,ax
07f5  mov    al,BYTE PTR es:[bx+si]               ; si=j
07f8  mov    bx,di                                ; di=i
07fa  add    bx,0x3
07fd  mov    cl,0x4
07ff  shl    bx,cl
0801  add    bx,0x18ba
0805  push   ax
0806  mov    ax,ds
0808  mov    es,ax
080a  add    bx,si                                ; si=j
080c  pop    ax
080d  mov    BYTE PTR es:[bx+0x3],al
0811  inc    si                                   ; si=j
0812  cmp    si,0xa                               ; si=j
0815  jl     0x7e4
0817  inc    di                                   ; di=i
0818  cmp    di,0x14                              ; di=i
081b  jl     0x7e0
                                  ; ---- KOR-STG.C:165
081d  pop    di                                   ; di=i
081e  pop    si                                   ; si=j
081f  pop    bp
0820  ret

; ---------------------------------------------------------------
_screen_delete:   ; 0x0821..0x0856  locals: di=i, si=j
                                  ; ---- KOR-STG.C:168
0821  push   bp
0822  mov    bp,sp
0824  push   si                                   ; si=j
0825  push   di                                   ; di=i
                                  ; ---- KOR-STG.C:171
0826  xor    di,di                                ; di=i
0828  jmp    0x84d
                                  ; ---- KOR-STG.C:172
082a  xor    si,si                                ; si=j
082c  jmp    0x847
                                  ; ---- KOR-STG.C:173
082e  mov    bx,di                                ; di=i
0830  add    bx,0x3
0833  mov    cl,0x4
0835  shl    bx,cl
0837  add    bx,0x18ba
083b  mov    ax,ds
083d  mov    es,ax
083f  add    bx,si                                ; si=j
0841  mov    BYTE PTR es:[bx+0x3],0x0
0846  inc    si                                   ; si=j
0847  cmp    si,0xa                               ; si=j
084a  jl     0x82e
084c  inc    di                                   ; di=i
084d  cmp    di,0x14                              ; di=i
0850  jl     0x82a
                                  ; ---- KOR-STG.C:174
0852  pop    di                                   ; di=i
0853  pop    si                                   ; si=j
0854  pop    bp
0855  ret

; ---------------------------------------------------------------
_locprt:   ; 0x0856..0x0875  locals: bp+4=x, bp+6=y, bp+8=n
                                  ; ---- KOR-STG.C:177
0856  push   bp
0857  mov    bp,sp
                                  ; ---- KOR-STG.C:179
0859  push   ds
085a  mov    ax,WORD PTR [bp+0x8]                 ; n
085d  add    ax,0x30
0860  mov    cl,0x5
0862  shl    ax,cl
0864  add    ax,0x20ae
0867  push   ax
0868  push   WORD PTR [bp+0x6]                    ; y
086b  push   WORD PTR [bp+0x4]                    ; x
086e  call   _putptn
0871  mov    sp,bp
                                  ; ---- KOR-STG.C:180
0873  pop    bp
0874  ret

; ---------------------------------------------------------------
_locprtl:   ; 0x0875..0x08cc  locals: bp+4=x, bp+6=y, bp+8=n, di=j, si=i
                                  ; ---- KOR-STG.C:183
0875  push   bp
0876  mov    bp,sp
0878  push   si                                   ; si=i
0879  push   di                                   ; di=j
                                  ; ---- KOR-STG.C:185
087a  mov    ax,WORD PTR [bp+0x8]                 ; n
087d  mov    bx,0xa
0880  cwd
0881  idiv   bx
0883  mov    si,ax                                ; si=i
0885  mov    ax,WORD PTR [bp+0x8]                 ; n
0888  mov    bx,0xa
088b  cwd
088c  idiv   bx
088e  mov    di,dx                                ; di=j
                                  ; ---- KOR-STG.C:187
0890  push   ds
0891  mov    ax,si                                ; si=i
0893  add    ax,0x30
0896  mov    cl,0x5
0898  shl    ax,cl
089a  add    ax,0x20ae
089d  push   ax
089e  push   WORD PTR [bp+0x6]                    ; y
08a1  mov    ax,WORD PTR [bp+0x4]                 ; x
08a4  inc    WORD PTR [bp+0x4]                    ; x
08a7  push   ax
08a8  call   _putptn
08ab  add    sp,0x8
                                  ; ---- KOR-STG.C:188
08ae  push   ds
08af  mov    ax,di                                ; di=j
08b1  add    ax,0x30
08b4  mov    cl,0x5
08b6  shl    ax,cl
08b8  add    ax,0x20ae
08bb  push   ax
08bc  push   WORD PTR [bp+0x6]                    ; y
08bf  push   WORD PTR [bp+0x4]                    ; x
08c2  call   _putptn
08c5  add    sp,0x8
                                  ; ---- KOR-STG.C:189
08c8  pop    di                                   ; di=j
08c9  pop    si                                   ; si=i
08ca  pop    bp
08cb  ret

; ---------------------------------------------------------------
_cursor_move:   ; 0x08cc..0x0917  locals: bp+4=n
                                  ; ---- KOR-STG.C:192
08cc  push   bp
08cd  mov    bp,sp
                                  ; ---- KOR-STG.C:194
08cf  mov    ax,WORD PTR [bp+0x4]                 ; n
08d2  dec    ax
08d3  cmp    ax,0x3
08d6  ja     0x915
08d8  mov    bx,ax
08da  shl    bx,1
08dc  jmp    WORD PTR cs:[bx+0x8e1]               ; bx+msg+0x243
08e1  dw case_0 -> 0x8e9
08e3  dw case_1 -> 0x8f4
08e5  dw case_2 -> 0x8ff
08e7  dw case_3 -> 0x90a
                                  ; ---- KOR-STG.C:195
08e9  mov    ax,0x1
08ec  push   ax
08ed  call   _cursor_up
08f0  mov    sp,bp
08f2  jmp    0x915
                                  ; ---- KOR-STG.C:196
08f4  mov    ax,0x1
08f7  push   ax
08f8  call   _cursor_down
08fb  mov    sp,bp
08fd  jmp    0x915
                                  ; ---- KOR-STG.C:197
08ff  mov    ax,0x1
0902  push   ax
0903  call   _cursor_left
0906  mov    sp,bp
0908  jmp    0x915
                                  ; ---- KOR-STG.C:198
090a  mov    ax,0x1
090d  push   ax
090e  call   _cursor_right
0911  mov    sp,bp
0913  jmp    0x915
                                  ; ---- KOR-STG.C:200
0915  pop    bp
0916  ret

; ---------------------------------------------------------------
_cursor_right:   ; 0x0917..0x093c  locals: bp+4=f
                                  ; ---- KOR-STG.C:203
0917  push   bp
0918  mov    bp,sp
                                  ; ---- KOR-STG.C:205
091a  inc    WORD PTR [_korx]
091e  mov    ax,[_korx]
0921  cmp    ax,0xd
0924  jne    0x93a
                                  ; ---- KOR-STG.C:206
0926  mov    WORD PTR [_korx],0x3
                                  ; ---- KOR-STG.C:207
092c  cmp    WORD PTR [bp+0x4],0x0                ; f
0930  je     0x93a
0932  xor    ax,ax
0934  push   ax
0935  call   _cursor_down
0938  mov    sp,bp
                                  ; ---- KOR-STG.C:209
093a  pop    bp
093b  ret

; ---------------------------------------------------------------
_cursor_left:   ; 0x093c..0x0961  locals: bp+4=f
                                  ; ---- KOR-STG.C:212
093c  push   bp
093d  mov    bp,sp
                                  ; ---- KOR-STG.C:214
093f  dec    WORD PTR [_korx]
0943  mov    ax,[_korx]
0946  cmp    ax,0x2
0949  jne    0x95f
                                  ; ---- KOR-STG.C:215
094b  mov    WORD PTR [_korx],0xc
                                  ; ---- KOR-STG.C:216
0951  cmp    WORD PTR [bp+0x4],0x0                ; f
0955  je     0x95f
0957  xor    ax,ax
0959  push   ax
095a  call   _cursor_up
095d  mov    sp,bp
                                  ; ---- KOR-STG.C:218
095f  pop    bp
0960  ret

; ---------------------------------------------------------------
_cursor_down:   ; 0x0961..0x0986  locals: bp+4=f
                                  ; ---- KOR-STG.C:221
0961  push   bp
0962  mov    bp,sp
                                  ; ---- KOR-STG.C:223
0964  inc    WORD PTR [_kory]
0968  mov    ax,[_kory]
096b  cmp    ax,0x17
096e  jne    0x984
                                  ; ---- KOR-STG.C:224
0970  mov    WORD PTR [_kory],0x3
                                  ; ---- KOR-STG.C:225
0976  cmp    WORD PTR [bp+0x4],0x0                ; f
097a  je     0x984
097c  xor    ax,ax
097e  push   ax
097f  call   _cursor_right
0982  mov    sp,bp
                                  ; ---- KOR-STG.C:227
0984  pop    bp
0985  ret

; ---------------------------------------------------------------
_cursor_up:   ; 0x0986..0x09ab  locals: bp+4=f
                                  ; ---- KOR-STG.C:230
0986  push   bp
0987  mov    bp,sp
                                  ; ---- KOR-STG.C:232
0989  dec    WORD PTR [_kory]
098d  mov    ax,[_kory]
0990  cmp    ax,0x2
0993  jne    0x9a9
                                  ; ---- KOR-STG.C:233
0995  mov    WORD PTR [_kory],0x16
                                  ; ---- KOR-STG.C:234
099b  cmp    WORD PTR [bp+0x4],0x0                ; f
099f  je     0x9a9
09a1  xor    ax,ax
09a3  push   ax
09a4  call   _cursor_left
09a7  mov    sp,bp
                                  ; ---- KOR-STG.C:236
09a9  pop    bp
09aa  ret

; ---------------------------------------------------------------
_stage_up:   ; 0x09ab..0x09c5  locals:
                                  ; ---- KOR-STG.C:239
09ab  push   bp
09ac  mov    bp,sp
                                  ; ---- KOR-STG.C:241
09ae  call   _stage_to_screen
                                  ; ---- KOR-STG.C:242
09b1  mov    al,[_point]
09b4  cbw
09b5  inc    ax
09b6  mov    bx,0x64
09b9  cwd
09ba  idiv   bx
09bc  mov    BYTE PTR [_point],dl
                                  ; ---- KOR-STG.C:243
09c0  call   _screen_to_stage
                                  ; ---- KOR-STG.C:244
09c3  pop    bp
09c4  ret

; ---------------------------------------------------------------
_stage_down:   ; 0x09c5..0x09e3  locals:
                                  ; ---- KOR-STG.C:247
09c5  push   bp
09c6  mov    bp,sp
                                  ; ---- KOR-STG.C:249
09c8  call   _stage_to_screen
                                  ; ---- KOR-STG.C:250
09cb  cmp    BYTE PTR [_point],0x0
09d0  jne    0x9d6
09d2  mov    al,0x63
09d4  jmp    0x9db
09d6  mov    al,[_point]
09d9  dec    al
09db  mov    [_point],al
                                  ; ---- KOR-STG.C:251
09de  call   _screen_to_stage
                                  ; ---- KOR-STG.C:252
09e1  pop    bp
09e2  ret

; ---------------------------------------------------------------
_cursor_set:   ; 0x09e3..0x0a30  locals: bp+4=k, si=k
                                  ; ---- KOR-STG.C:255
09e3  push   bp
09e4  mov    bp,sp
09e6  push   si                                   ; si=k
09e7  mov    si,WORD PTR [bp+0x4]                 ; k | si=k
                                  ; ---- KOR-STG.C:257
09ea  test   BYTE PTR [si+0x141b],0xc             ; __ctype+0x1 | si=k
09ef  je     0xa10
09f1  push   si                                   ; si=k
09f2  call   _tolower
09f5  inc    sp
09f6  inc    sp
09f7  mov    bx,WORD PTR [_kory]
09fb  mov    cl,0x4
09fd  shl    bx,cl
09ff  add    bx,0x18ba
0a03  push   ax
0a04  mov    ax,ds
0a06  mov    es,ax
0a08  add    bx,WORD PTR [_korx]
0a0c  pop    ax
0a0d  mov    BYTE PTR es:[bx],al
                                  ; ---- KOR-STG.C:258
0a10  cmp    si,0x20                              ; si=k
0a13  jne    0xa2d
0a15  mov    bx,WORD PTR [_kory]
0a19  mov    cl,0x4
0a1b  shl    bx,cl
0a1d  add    bx,0x18ba
0a21  mov    ax,ds
0a23  mov    es,ax
0a25  add    bx,WORD PTR [_korx]
0a29  mov    BYTE PTR es:[bx],0x0
                                  ; ---- KOR-STG.C:259
0a2d  pop    si                                   ; si=k
0a2e  pop    bp
0a2f  ret

; ---------------------------------------------------------------
_stage_put_option:   ; 0x0a30..0x0a53  locals: bp+4=d
                                  ; ---- KOR-STG.C:262
0a30  push   bp
0a31  mov    bp,sp
                                  ; ---- KOR-STG.C:266
0a33  mov    WORD PTR [_locx],0x24
                                  ; ---- KOR-STG.C:267
0a39  mov    WORD PTR [_locy],0xb
                                  ; ---- KOR-STG.C:268
0a3f  push   ds
0a40  mov    ax,WORD PTR [bp+0x4]                 ; d
0a43  mov    dx,0x5
0a46  mul    dx
0a48  add    ax,0x680                             ; "000"
0a4b  push   ax
0a4c  call   _lprint
0a4f  mov    sp,bp
                                  ; ---- KOR-STG.C:269
0a51  pop    bp
0a52  ret

; ---------------------------------------------------------------
_stage_put_power:   ; 0x0a53..0x0a76  locals: bp+4=d
                                  ; ---- KOR-STG.C:272
0a53  push   bp
0a54  mov    bp,sp
                                  ; ---- KOR-STG.C:276
0a56  mov    WORD PTR [_locx],0x24
                                  ; ---- KOR-STG.C:277
0a5c  mov    WORD PTR [_locy],0x9
                                  ; ---- KOR-STG.C:278
0a62  push   ds
0a63  mov    ax,WORD PTR [bp+0x4]                 ; d
0a66  mov    dx,0x5
0a69  mul    dx
0a6b  add    ax,0x69e                             ; "000"
0a6e  push   ax
0a6f  call   _lprint
0a72  mov    sp,bp
                                  ; ---- KOR-STG.C:279
0a74  pop    bp
0a75  ret

; ---------------------------------------------------------------
_put_env:   ; 0x0a76..0x0b05  locals:
                                  ; ---- KOR-STG.C:282
0a76  push   bp
0a77  mov    bp,sp
                                  ; ---- KOR-STG.C:284
0a79  mov    al,[_point]
0a7c  cbw
0a7d  inc    ax
0a7e  push   ax
0a7f  mov    ax,0x5
0a82  push   ax
0a83  mov    ax,0x25
0a86  push   ax
0a87  call   _locprtl
0a8a  add    sp,0x6
                                  ; ---- KOR-STG.C:285
0a8d  mov    al,[_point]
0a90  cbw
0a91  mov    bx,ax
0a93  shl    bx,1
0a95  mov    ax,0x9
0a98  mov    dx,WORD PTR [bx+0x40ae]              ; bx+_speed
0a9c  sub    ax,dx
0a9e  push   ax
0a9f  mov    ax,0x7
0aa2  push   ax
0aa3  mov    ax,0x26
0aa6  push   ax
0aa7  call   _locprt
0aaa  add    sp,0x6
                                  ; ---- KOR-STG.C:286
0aad  mov    al,[_point]
0ab0  cbw
0ab1  mov    bx,ax
0ab3  shl    bx,1
0ab5  push   WORD PTR [bx+0x424c]                 ; bx+_power
0ab9  call   _stage_put_power
0abc  inc    sp
0abd  inc    sp
                                  ; ---- KOR-STG.C:287
0abe  mov    al,[_point]
0ac1  cbw
0ac2  mov    bx,ax
0ac4  shl    bx,1
0ac6  push   WORD PTR [bx+0x4315]                 ; bx+_option
0aca  call   _stage_put_option
0acd  inc    sp
0ace  inc    sp
                                  ; ---- KOR-STG.C:288
0acf  mov    al,[_point]
0ad2  cbw
0ad3  mov    bx,ax
0ad5  shl    bx,1
0ad7  push   WORD PTR [bx+0x417e]                 ; bx+_bonus
0adb  mov    ax,0xd
0ade  push   ax
0adf  mov    ax,0x25
0ae2  push   ax
0ae3  call   _locprtl
0ae6  add    sp,0x6
                                  ; ---- KOR-STG.C:289
0ae9  mov    al,[_point]
0aec  cbw
0aed  mov    bx,ax
0aef  shl    bx,1
0af1  push   WORD PTR [bx-0x6cff]
0af5  mov    ax,0xf
0af8  push   ax
0af9  mov    ax,0x25
0afc  push   ax
0afd  call   _locprtl
0b00  add    sp,0x6
                                  ; ---- KOR-STG.C:290
0b03  pop    bp
0b04  ret

; ---------------------------------------------------------------
_add_speed:   ; 0x0b05..0x0b29  locals:
                                  ; ---- KOR-STG.C:293
0b05  push   bp
0b06  mov    bp,sp
                                  ; ---- KOR-STG.C:295
0b08  mov    al,[_point]
0b0b  cbw
0b0c  mov    bx,ax
0b0e  shl    bx,1
0b10  mov    ax,WORD PTR [bx+0x40ae]              ; bx+_speed
0b14  inc    ax
0b15  mov    bx,0xa
0b18  cwd
0b19  idiv   bx
0b1b  mov    al,[_point]
0b1e  cbw
0b1f  mov    bx,ax
0b21  shl    bx,1
0b23  mov    WORD PTR [bx+0x40ae],dx              ; bx+_speed
                                  ; ---- KOR-STG.C:296
0b27  pop    bp
0b28  ret

; ---------------------------------------------------------------
_sub_speed:   ; 0x0b29..0x0b5d  locals:
                                  ; ---- KOR-STG.C:299
0b29  push   bp
0b2a  mov    bp,sp
                                  ; ---- KOR-STG.C:301
0b2c  mov    al,[_point]
0b2f  cbw
0b30  mov    bx,ax
0b32  shl    bx,1
0b34  cmp    WORD PTR [bx+0x40ae],0x0             ; bx+_speed
0b39  je     0xb4a
0b3b  mov    al,[_point]
0b3e  cbw
0b3f  mov    bx,ax
0b41  shl    bx,1
0b43  mov    ax,WORD PTR [bx+0x40ae]              ; bx+_speed
0b47  dec    ax
0b48  jmp    0xb4d
0b4a  mov    ax,0x9
0b4d  push   ax
0b4e  mov    al,[_point]
0b51  cbw
0b52  mov    bx,ax
0b54  shl    bx,1
0b56  pop    ax
0b57  mov    WORD PTR [bx+0x40ae],ax              ; bx+_speed
                                  ; ---- KOR-STG.C:302
0b5b  pop    bp
0b5c  ret

; ---------------------------------------------------------------
_add_power:   ; 0x0b5d..0x0b81  locals:
                                  ; ---- KOR-STG.C:305
0b5d  push   bp
0b5e  mov    bp,sp
                                  ; ---- KOR-STG.C:307
0b60  mov    al,[_point]
0b63  cbw
0b64  mov    bx,ax
0b66  shl    bx,1
0b68  mov    ax,WORD PTR [bx+0x424c]              ; bx+_power
0b6c  inc    ax
0b6d  mov    bx,0x6
0b70  cwd
0b71  idiv   bx
0b73  mov    al,[_point]
0b76  cbw
0b77  mov    bx,ax
0b79  shl    bx,1
0b7b  mov    WORD PTR [bx+0x424c],dx              ; bx+_power
                                  ; ---- KOR-STG.C:308
0b7f  pop    bp
0b80  ret

; ---------------------------------------------------------------
_sub_power:   ; 0x0b81..0x0bb5  locals:
                                  ; ---- KOR-STG.C:311
0b81  push   bp
0b82  mov    bp,sp
                                  ; ---- KOR-STG.C:313
0b84  mov    al,[_point]
0b87  cbw
0b88  mov    bx,ax
0b8a  shl    bx,1
0b8c  cmp    WORD PTR [bx+0x424c],0x0             ; bx+_power
0b91  je     0xba2
0b93  mov    al,[_point]
0b96  cbw
0b97  mov    bx,ax
0b99  shl    bx,1
0b9b  mov    ax,WORD PTR [bx+0x424c]              ; bx+_power
0b9f  dec    ax
0ba0  jmp    0xba5
0ba2  mov    ax,0x5
0ba5  push   ax
0ba6  mov    al,[_point]
0ba9  cbw
0baa  mov    bx,ax
0bac  shl    bx,1
0bae  pop    ax
0baf  mov    WORD PTR [bx+0x424c],ax              ; bx+_power
                                  ; ---- KOR-STG.C:314
0bb3  pop    bp
0bb4  ret

; ---------------------------------------------------------------
_add_option:   ; 0x0bb5..0x0bd9  locals:
                                  ; ---- KOR-STG.C:317
0bb5  push   bp
0bb6  mov    bp,sp
                                  ; ---- KOR-STG.C:319
0bb8  mov    al,[_point]
0bbb  cbw
0bbc  mov    bx,ax
0bbe  shl    bx,1
0bc0  mov    ax,WORD PTR [bx+0x4315]              ; bx+_option
0bc4  inc    ax
0bc5  mov    bx,0x6
0bc8  cwd
0bc9  idiv   bx
0bcb  mov    al,[_point]
0bce  cbw
0bcf  mov    bx,ax
0bd1  shl    bx,1
0bd3  mov    WORD PTR [bx+0x4315],dx              ; bx+_option
                                  ; ---- KOR-STG.C:320
0bd7  pop    bp
0bd8  ret

; ---------------------------------------------------------------
_sub_option:   ; 0x0bd9..0x0c0d  locals:
                                  ; ---- KOR-STG.C:323
0bd9  push   bp
0bda  mov    bp,sp
                                  ; ---- KOR-STG.C:325
0bdc  mov    al,[_point]
0bdf  cbw
0be0  mov    bx,ax
0be2  shl    bx,1
0be4  cmp    WORD PTR [bx+0x4315],0x0             ; bx+_option
0be9  je     0xbfa
0beb  mov    al,[_point]
0bee  cbw
0bef  mov    bx,ax
0bf1  shl    bx,1
0bf3  mov    ax,WORD PTR [bx+0x4315]              ; bx+_option
0bf7  dec    ax
0bf8  jmp    0xbfd
0bfa  mov    ax,0x5
0bfd  push   ax
0bfe  mov    al,[_point]
0c01  cbw
0c02  mov    bx,ax
0c04  shl    bx,1
0c06  pop    ax
0c07  mov    WORD PTR [bx+0x4315],ax              ; bx+_option
                                  ; ---- KOR-STG.C:326
0c0b  pop    bp
0c0c  ret

; ---------------------------------------------------------------
_add_bonus:   ; 0x0c0d..0x0c31  locals:
                                  ; ---- KOR-STG.C:329
0c0d  push   bp
0c0e  mov    bp,sp
                                  ; ---- KOR-STG.C:331
0c10  mov    al,[_point]
0c13  cbw
0c14  mov    bx,ax
0c16  shl    bx,1
0c18  mov    ax,WORD PTR [bx+0x417e]              ; bx+_bonus
0c1c  inc    ax
0c1d  mov    bx,0x64
0c20  cwd
0c21  idiv   bx
0c23  mov    al,[_point]
0c26  cbw
0c27  mov    bx,ax
0c29  shl    bx,1
0c2b  mov    WORD PTR [bx+0x417e],dx              ; bx+_bonus
                                  ; ---- KOR-STG.C:332
0c2f  pop    bp
0c30  ret

; ---------------------------------------------------------------
_sub_bonus:   ; 0x0c31..0x0c65  locals:
                                  ; ---- KOR-STG.C:335
0c31  push   bp
0c32  mov    bp,sp
                                  ; ---- KOR-STG.C:337
0c34  mov    al,[_point]
0c37  cbw
0c38  mov    bx,ax
0c3a  shl    bx,1
0c3c  cmp    WORD PTR [bx+0x417e],0x0             ; bx+_bonus
0c41  je     0xc52
0c43  mov    al,[_point]
0c46  cbw
0c47  mov    bx,ax
0c49  shl    bx,1
0c4b  mov    ax,WORD PTR [bx+0x417e]              ; bx+_bonus
0c4f  dec    ax
0c50  jmp    0xc55
0c52  mov    ax,0x63
0c55  push   ax
0c56  mov    al,[_point]
0c59  cbw
0c5a  mov    bx,ax
0c5c  shl    bx,1
0c5e  pop    ax
0c5f  mov    WORD PTR [bx+0x417e],ax              ; bx+_bonus
                                  ; ---- KOR-STG.C:338
0c63  pop    bp
0c64  ret

; ---------------------------------------------------------------
_add_optime:   ; 0x0c65..0x0c89  locals:
                                  ; ---- KOR-STG.C:341
0c65  push   bp
0c66  mov    bp,sp
                                  ; ---- KOR-STG.C:343
0c68  mov    al,[_point]
0c6b  cbw
0c6c  mov    bx,ax
0c6e  shl    bx,1
0c70  mov    ax,WORD PTR [bx-0x6cff]
0c74  inc    ax
0c75  mov    bx,0x64
0c78  cwd
0c79  idiv   bx
0c7b  mov    al,[_point]
0c7e  cbw
0c7f  mov    bx,ax
0c81  shl    bx,1
0c83  mov    WORD PTR [bx-0x6cff],dx
                                  ; ---- KOR-STG.C:344
0c87  pop    bp
0c88  ret

; ---------------------------------------------------------------
_sub_optime:   ; 0x0c89..0x0cbd  locals:
                                  ; ---- KOR-STG.C:347
0c89  push   bp
0c8a  mov    bp,sp
                                  ; ---- KOR-STG.C:349
0c8c  mov    al,[_point]
0c8f  cbw
0c90  mov    bx,ax
0c92  shl    bx,1
0c94  cmp    WORD PTR [bx-0x6cff],0x0
0c99  je     0xcaa
0c9b  mov    al,[_point]
0c9e  cbw
0c9f  mov    bx,ax
0ca1  shl    bx,1
0ca3  mov    ax,WORD PTR [bx-0x6cff]
0ca7  dec    ax
0ca8  jmp    0xcad
0caa  mov    ax,0x63
0cad  push   ax
0cae  mov    al,[_point]
0cb1  cbw
0cb2  mov    bx,ax
0cb4  shl    bx,1
0cb6  pop    ax
0cb7  mov    WORD PTR [bx-0x6cff],ax
                                  ; ---- KOR-STG.C:350
0cbb  pop    bp
0cbc  ret

; ---------------------------------------------------------------
_user_stage:   ; 0x0cbd..0x0e83  locals: si=value
                                  ; ---- KOR-STG.C:354
0cbd  push   bp
0cbe  mov    bp,sp
0cc0  push   si                                   ; si=value
                                  ; ---- KOR-STG.C:358
0cc1  call   _stage_load
                                  ; ---- KOR-STG.C:359
0cc4  xor    ax,ax
0cc6  mov    [_locy],ax
0cc9  mov    [_locx],ax
                                  ; ---- KOR-STG.C:360
0ccc  mov    WORD PTR [_korx],0x8
0cd2  mov    WORD PTR [_kory],0xd
                                  ; ---- KOR-STG.C:361
0cd8  call   _user_stage_title
                                  ; ---- KOR-STG.C:362
0cdb  mov    BYTE PTR [_point],0x0
                                  ; ---- KOR-STG.C:363
0ce0  call   _screen_to_stage
                                  ; ---- KOR-STG.C:364
0ce3  call   _put_env
                                  ; ---- KOR-STG.C:367
0ce6  call   _put_stage2
                                  ; ---- KOR-STG.C:368
0ce9  call   _put_cursor
                                  ; ---- KOR-STG.C:369
0cec  call   _put_env
                                  ; ---- KOR-STG.C:370
0cef  xor    ax,ax
0cf1  push   ax
0cf2  call   _inkey
0cf5  inc    sp
0cf6  inc    sp
0cf7  mov    si,ax                                ; si=value
                                  ; ---- KOR-STG.C:371
0cf9  mov    ax,si                                ; si=value
0cfb  cmp    ax,0x38
0cfe  jne    0xd03
0d00  jmp    0xe17
0d03  jg     0xd6e
0d05  cmp    ax,0x10
0d08  jne    0xd0d
0d0a  jmp    0xe49
0d0d  jg     0xd3e
0d0f  dec    ax
0d10  dec    ax
0d11  cmp    ax,0xd
0d14  jbe    0xd19
0d16  jmp    0xe6c
0d19  mov    bx,ax
0d1b  shl    bx,1
0d1d  jmp    WORD PTR cs:[bx+0xd22]               ; bx+op_msg+0x184
0d22  dw case_0 -> 0xe5d
0d24  dw case_1 -> 0xe6c
0d26  dw case_2 -> 0xe6c
0d28  dw case_3 -> 0xe6c
0d2a  dw case_4 -> 0xe6c
0d2c  dw case_5 -> 0xe6c
0d2e  dw case_6 -> 0xe30
0d30  dw case_7 -> 0xe0d
0d32  dw case_8 -> 0xe12
0d34  dw case_9 -> 0xe6c
0d36  dw case_10 -> 0xe6c
0d38  dw case_11 -> 0xe2b
0d3a  dw case_12 -> 0xe6c
0d3c  dw case_13 -> 0xe53
0d3e  cmp    ax,0x32
0d41  jne    0xd46
0d43  jmp    0xe1c
0d46  jg     0xd5b
0d48  cmp    ax,0x13
0d4b  jne    0xd50
0d4d  jmp    0xe3a
0d50  cmp    ax,0x14
0d53  jne    0xd58
0d55  jmp    0xe67
0d58  jmp    0xe6c
0d5b  cmp    ax,0x34
0d5e  jne    0xd63
0d60  jmp    0xe21
0d63  cmp    ax,0x36
0d66  jne    0xd6b
0d68  jmp    0xe26
0d6b  jmp    0xe6c
0d6e  cmp    ax,0x149
0d71  jne    0xd76
0d73  jmp    0xe03
0d76  jg     0xdad
0d78  cmp    ax,0x11f
0d7b  jne    0xd80
0d7d  jmp    0xe3f
0d80  jg     0xd9d
0d82  cmp    ax,0x114
0d85  jne    0xd8a
0d87  jmp    0xe62
0d8a  cmp    ax,0x118
0d8d  jne    0xd92
0d8f  jmp    0xe4e
0d92  cmp    ax,0x119
0d95  jne    0xd9a
0d97  jmp    0xe44
0d9a  jmp    0xe6c
0d9d  cmp    ax,0x130
0da0  jne    0xda5
0da2  jmp    0xe58
0da5  cmp    ax,0x148
0da8  je     0xdd3
0daa  jmp    0xe6c
0dad  sub    ax,0x14b
0db0  cmp    ax,0x8
0db3  jbe    0xdb8
0db5  jmp    0xe6c
0db8  mov    bx,ax
0dba  shl    bx,1
0dbc  jmp    WORD PTR cs:[bx+0xdc1]               ; bx+op_msg+0x223
0dc1  dw case_0 -> 0xdeb
0dc3  dw case_1 -> 0xe6c
0dc5  dw case_2 -> 0xdf7
0dc7  dw case_3 -> 0xe6c
0dc9  dw case_4 -> 0xe6c
0dcb  dw case_5 -> 0xddf
0dcd  dw case_6 -> 0xe08
0dcf  dw case_7 -> 0xe6c
0dd1  dw case_8 -> 0xe35
                                  ; ---- KOR-STG.C:372
0dd3  mov    ax,0x1
0dd6  push   ax
0dd7  call   _cursor_move
0dda  inc    sp
0ddb  inc    sp
0ddc  jmp    0xe72
                                  ; ---- KOR-STG.C:373
0ddf  mov    ax,0x2
0de2  push   ax
0de3  call   _cursor_move
0de6  inc    sp
0de7  inc    sp
0de8  jmp    0xe72
                                  ; ---- KOR-STG.C:374
0deb  mov    ax,0x3
0dee  push   ax
0def  call   _cursor_move
0df2  inc    sp
0df3  inc    sp
0df4  jmp    0xe72
                                  ; ---- KOR-STG.C:375
0df7  mov    ax,0x4
0dfa  push   ax
0dfb  call   _cursor_move
0dfe  inc    sp
0dff  inc    sp
0e00  jmp    0xe72
                                  ; ---- KOR-STG.C:376
0e03  call   _stage_up
0e06  jmp    0xe72
                                  ; ---- KOR-STG.C:377
0e08  call   _stage_down
0e0b  jmp    0xe72
                                  ; ---- KOR-STG.C:378
0e0d  call   _add_option
0e10  jmp    0xe72
                                  ; ---- KOR-STG.C:379
0e12  call   _user_stage_save
0e15  jmp    0xe72
                                  ; ---- KOR-STG.C:380
0e17  call   _screen_up
0e1a  jmp    0xe72
                                  ; ---- KOR-STG.C:381
0e1c  call   _screen_down
0e1f  jmp    0xe72
                                  ; ---- KOR-STG.C:382
0e21  call   _screen_left
0e24  jmp    0xe72
                                  ; ---- KOR-STG.C:383
0e26  call   _screen_right
0e29  jmp    0xe72
                                  ; ---- KOR-STG.C:384
0e2b  call   _screen_store
0e2e  jmp    0xe72
                                  ; ---- KOR-STG.C:385
0e30  call   _screen_restore
0e33  jmp    0xe72
                                  ; ---- KOR-STG.C:386
0e35  call   _screen_delete
0e38  jmp    0xe72
                                  ; ---- KOR-STG.C:387
0e3a  call   _add_speed
0e3d  jmp    0xe72
                                  ; ---- KOR-STG.C:388
0e3f  call   _sub_speed
0e42  jmp    0xe72
                                  ; ---- KOR-STG.C:389
0e44  call   _add_power
0e47  jmp    0xe72
                                  ; ---- KOR-STG.C:390
0e49  call   _sub_power
0e4c  jmp    0xe72
                                  ; ---- KOR-STG.C:391
0e4e  call   _add_option
0e51  jmp    0xe72
                                  ; ---- KOR-STG.C:392
0e53  call   _sub_option
0e56  jmp    0xe72
                                  ; ---- KOR-STG.C:393
0e58  call   _add_bonus
0e5b  jmp    0xe72
                                  ; ---- KOR-STG.C:394
0e5d  call   _sub_bonus
0e60  jmp    0xe72
                                  ; ---- KOR-STG.C:395
0e62  call   _add_optime
0e65  jmp    0xe72
                                  ; ---- KOR-STG.C:396
0e67  call   _sub_optime
0e6a  jmp    0xe72
                                  ; ---- KOR-STG.C:397
0e6c  push   si                                   ; si=value
0e6d  call   _cursor_set
0e70  inc    sp
0e71  inc    sp
                                  ; ---- KOR-STG.C:399
0e72  cmp    si,0x1b                              ; si=value
0e75  je     0xe7a
0e77  jmp    0xce6
                                  ; ---- KOR-STG.C:401
0e7a  mov    WORD PTR [_flag],0x64
                                  ; ---- KOR-STG.C:402
0e80  pop    si                                   ; si=value
0e81  pop    bp
0e82  ret

;======================================================================
; MODULE KOR-GRP.C
;======================================================================

; ---------------------------------------------------------------
_get_graph_driver:   ; 0x0e83..0x0eb2  locals:
                                  ; ---- KOR-GRP.C:46
0e83  push   bp
0e84  mov    bp,sp
                                  ; ---- KOR-GRP.C:48
0e86  int    0x11
                                  ; ---- KOR-GRP.C:49
0e88  test   al,0x10
0e8a  je     0xe91
0e8c  mov    ax,0x1
0e8f  jmp    0xe93
0e91  xor    ax,ax
0e93  mov    [_grp_driver],ax
                                  ; ---- KOR-GRP.C:50
0e96  cmp    WORD PTR [_grp_driver],0x0
0e9b  je     0xea4
0e9d  mov    dx,0xb000
0ea0  xor    ax,ax
0ea2  jmp    0xea9
0ea4  mov    dx,0xb800
0ea7  xor    ax,ax
0ea9  mov    WORD PTR [_PAGE1+0x2],dx
0ead  mov    [_PAGE1],ax
                                  ; ---- KOR-GRP.C:51
0eb0  pop    bp
0eb1  ret

; ---------------------------------------------------------------
_mode_set:   ; 0x0eb2..0x0f1a  locals: bp+4=mode, bp-4=tabl_6845, bp-6=i, si=mode
                                  ; ---- KOR-GRP.C:54
0eb2  push   bp
0eb3  mov    bp,sp
0eb5  sub    sp,0x6
0eb8  push   si                                   ; si=mode
0eb9  mov    si,WORD PTR [bp+0x4]                 ; mode | si=mode
                                  ; ---- KOR-GRP.C:57
0ebc  cmp    si,0x1                               ; si=mode
0ebf  jne    0xec6
0ec1  mov    bx,0xfee                             ; &_gtable?
0ec4  jmp    0xec9
0ec6  mov    bx,0xfe2                             ; &_ttable?
0ec9  mov    ax,ds
0ecb  mov    es,ax
0ecd  mov    WORD PTR [bp-0x2],es
0ed0  mov    WORD PTR [bp-0x4],bx                 ; tabl_6845
                                  ; ---- KOR-GRP.C:59
0ed3  mov    al,0x3
0ed5  mov    dx,0x3bf                             ; &_information+0x143?
0ed8  out    dx,al
                                  ; ---- KOR-GRP.C:60
0ed9  mov    al,0x1
0edb  mov    dx,0x3bf                             ; &_information+0x143?
0ede  out    dx,al
                                  ; ---- KOR-GRP.C:61
0edf  mov    al,BYTE PTR [si+0xffa]               ; _state | si=mode
0ee3  mov    dx,0x3b8                             ; &_information+0x13c?
0ee6  out    dx,al
                                  ; ---- KOR-GRP.C:62
0ee7  mov    WORD PTR [bp-0x6],0x0                ; i
0eec  jmp    0xf05
                                  ; ---- KOR-GRP.C:63
0eee  mov    al,BYTE PTR [bp-0x6]                 ; i
0ef1  mov    dx,0x3b4                             ; &_information+0x138?
0ef4  out    dx,al
                                  ; ---- KOR-GRP.C:64
0ef5  les    bx,DWORD PTR [bp-0x4]                ; tabl_6845
0ef8  inc    WORD PTR [bp-0x4]                    ; tabl_6845
0efb  mov    al,BYTE PTR es:[bx]
0efe  mov    dx,0x3b5                             ; &_information+0x139?
0f01  out    dx,al
0f02  inc    WORD PTR [bp-0x6]                    ; i
0f05  cmp    WORD PTR [bp-0x6],0xc                ; i
0f09  jl     0xeee
                                  ; ---- KOR-GRP.C:66
0f0b  mov    al,BYTE PTR [si+0xffa]               ; _state | si=mode
0f0f  or     al,0x8
0f11  mov    dx,0x3b8                             ; &_information+0x13c?
0f14  out    dx,al
                                  ; ---- KOR-GRP.C:67
0f15  pop    si                                   ; si=mode
0f16  mov    sp,bp
0f18  pop    bp
0f19  ret

; ---------------------------------------------------------------
_grset:   ; 0x0f1a..0x0f9f  locals: si=i
                                  ; ---- KOR-GRP.C:70
0f1a  push   bp
0f1b  mov    bp,sp
0f1d  push   si                                   ; si=i
                                  ; ---- KOR-GRP.C:74
0f1e  call   _get_graph_driver
                                  ; ---- KOR-GRP.C:75
0f21  les    bx,DWORD PTR [_PAGE1]
0f25  mov    WORD PTR [_HVRAM+0x2],es
0f29  mov    WORD PTR [_HVRAM],bx
                                  ; ---- KOR-GRP.C:76
0f2d  xor    si,si                                ; si=i
0f2f  jmp    0xf6a
                                  ; ---- KOR-GRP.C:77
0f31  mov    ax,si                                ; si=i
0f33  sar    ax,1
0f35  sar    ax,1
0f37  mov    dx,0x50
0f3a  mul    dx
0f3c  cwd
0f3d  add    ax,WORD PTR [_PAGE1]
0f41  adc    dx,WORD PTR [_PAGE1+0x2]
0f45  push   dx
0f46  push   ax
0f47  mov    ax,si                                ; si=i
0f49  and    ax,0x3
0f4c  mov    cl,0xd
0f4e  shl    ax,cl
0f50  cwd
0f51  pop    bx
0f52  pop    cx
0f53  add    bx,ax
0f55  adc    cx,dx
0f57  push   cx
0f58  push   bx
0f59  mov    bx,si                                ; si=i
0f5b  shl    bx,1
0f5d  shl    bx,1
0f5f  pop    ax
0f60  pop    dx
0f61  mov    WORD PTR [bx+0x1a6e],dx              ; bx+_yad+0x2
0f65  mov    WORD PTR [bx+0x1a6c],ax              ; bx+_yad
0f69  inc    si                                   ; si=i
0f6a  cmp    si,0x190                             ; si=i
0f6e  jl     0xf31
                                  ; ---- KOR-GRP.C:78
0f70  mov    ax,0x8000                            ; &_screen+0x3c23?
0f73  push   ax
0f74  xor    ax,ax
0f76  push   ax
0f77  push   WORD PTR [_HVRAM+0x2]
0f7b  push   WORD PTR [_HVRAM]
0f7f  call   _memset
0f82  add    sp,0x8
                                  ; ---- KOR-GRP.C:80
0f85  cmp    WORD PTR [_grp_driver],0x0
0f8a  je     0xf97
0f8c  mov    ax,0x1
0f8f  push   ax
0f90  call   _mode_set
0f93  inc    sp
0f94  inc    sp
0f95  jmp    0xf9c
                                  ; ---- KOR-GRP.C:82
0f97  mov    ax,0x5
                                  ; ---- KOR-GRP.C:83
0f9a  int    0x10
                                  ; ---- KOR-GRP.C:85
0f9c  pop    si                                   ; si=i
0f9d  pop    bp
0f9e  ret

; ---------------------------------------------------------------
_textset:   ; 0x0f9f..0x0fd2  locals:
                                  ; ---- KOR-GRP.C:88
0f9f  push   bp
0fa0  mov    bp,sp
                                  ; ---- KOR-GRP.C:90
0fa2  mov    ax,0x8000                            ; &_screen+0x3c23?
0fa5  push   ax
0fa6  xor    ax,ax
0fa8  push   ax
0fa9  push   WORD PTR [_HVRAM+0x2]
0fad  push   WORD PTR [_HVRAM]
0fb1  call   _memset
0fb4  add    sp,0x8
                                  ; ---- KOR-GRP.C:91
0fb7  cmp    WORD PTR [_grp_driver],0x0
0fbc  je     0xfcb
                                  ; ---- KOR-GRP.C:92
0fbe  xor    ax,ax
0fc0  push   ax
0fc1  call   _mode_set
0fc4  inc    sp
0fc5  inc    sp
                                  ; ---- KOR-GRP.C:93
0fc6  mov    ax,0x7
                                  ; ---- KOR-GRP.C:94
0fc9  jmp    0xfce
                                  ; ---- KOR-GRP.C:95
0fcb  mov    ax,0x3
                                  ; ---- KOR-GRP.C:97
0fce  int    0x10
                                  ; ---- KOR-GRP.C:99
0fd0  pop    bp
0fd1  ret

; ---------------------------------------------------------------
_putptn_herc:   ; 0x0fd2..0x1119  locals: bp+4=px, bp+6=py, bp+8=ptnpt, bp-4=vad, si=i
                                  ; ---- KOR-GRP.C:102
0fd2  push   bp
0fd3  mov    bp,sp
0fd5  sub    sp,0x4
0fd8  push   si                                   ; si=i
                                  ; ---- KOR-GRP.C:107
0fd9  mov    ax,WORD PTR [bp+0x6]                 ; py
0fdc  shl    ax,1
0fde  shl    ax,1
0fe0  mov    dx,0x50
0fe3  mul    dx
0fe5  cwd
0fe6  add    ax,WORD PTR [_PAGE1]
0fea  adc    dx,WORD PTR [_PAGE1+0x2]
0fee  mov    bx,WORD PTR [bp+0x4]                 ; px
0ff1  shl    bx,1
0ff3  add    ax,bx
0ff5  mov    WORD PTR [bp-0x2],dx
0ff8  mov    WORD PTR [bp-0x4],ax                 ; vad
                                  ; ---- KOR-GRP.C:108
0ffb  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
0ffe  mov    ax,WORD PTR es:[bx]
1001  les    bx,DWORD PTR [bp-0x4]                ; vad
1004  mov    WORD PTR es:[bx],ax
1007  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:109
100b  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
100e  mov    ax,WORD PTR es:[bx]
1011  les    bx,DWORD PTR [bp-0x4]                ; vad
1014  mov    WORD PTR es:[bx+0x2000],ax           ; bx+_yad+0x594
1019  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:110
101d  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
1020  mov    ax,WORD PTR es:[bx]
1023  les    bx,DWORD PTR [bp-0x4]                ; vad
1026  mov    WORD PTR es:[bx+0x4000],ax           ; bx+_chr+0x1f52
102b  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:111
102f  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
1032  mov    ax,WORD PTR es:[bx]
1035  les    bx,DWORD PTR [bp-0x4]                ; vad
1038  mov    WORD PTR es:[bx+0x6000],ax           ; bx+_screen+0x1c23
103d  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:112
1041  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
1044  mov    ax,WORD PTR es:[bx]
1047  les    bx,DWORD PTR [bp-0x4]                ; vad
104a  mov    WORD PTR es:[bx+0x50],ax
104e  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:113
1052  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
1055  mov    ax,WORD PTR es:[bx]
1058  les    bx,DWORD PTR [bp-0x4]                ; vad
105b  mov    WORD PTR es:[bx+0x2050],ax           ; bx+_yad+0x5e4
1060  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:114
1064  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
1067  mov    ax,WORD PTR es:[bx]
106a  les    bx,DWORD PTR [bp-0x4]                ; vad
106d  mov    WORD PTR es:[bx+0x4050],ax           ; bx+_chr+0x1fa2
1072  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:115
1076  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
1079  mov    ax,WORD PTR es:[bx]
107c  les    bx,DWORD PTR [bp-0x4]                ; vad
107f  mov    WORD PTR es:[bx+0x6050],ax           ; bx+_screen+0x1c73
1084  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:116
1088  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
108b  mov    ax,WORD PTR es:[bx]
108e  les    bx,DWORD PTR [bp-0x4]                ; vad
1091  mov    WORD PTR es:[bx+0xa0],ax             ; bx+_play+0xc
1096  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:117
109a  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
109d  mov    ax,WORD PTR es:[bx]
10a0  les    bx,DWORD PTR [bp-0x4]                ; vad
10a3  mov    WORD PTR es:[bx+0x20a0],ax           ; bx+_yad+0x634
10a8  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:118
10ac  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
10af  mov    ax,WORD PTR es:[bx]
10b2  les    bx,DWORD PTR [bp-0x4]                ; vad
10b5  mov    WORD PTR es:[bx+0x40a0],ax           ; bx+_chr+0x1ff2
10ba  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:119
10be  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
10c1  mov    ax,WORD PTR es:[bx]
10c4  les    bx,DWORD PTR [bp-0x4]                ; vad
10c7  mov    WORD PTR es:[bx+0x60a0],ax           ; bx+_screen+0x1cc3
10cc  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:120
10d0  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
10d3  mov    ax,WORD PTR es:[bx]
10d6  les    bx,DWORD PTR [bp-0x4]                ; vad
10d9  mov    WORD PTR es:[bx+0xf0],ax             ; bx+_play+0x5c
10de  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:121
10e2  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
10e5  mov    ax,WORD PTR es:[bx]
10e8  les    bx,DWORD PTR [bp-0x4]                ; vad
10eb  mov    WORD PTR es:[bx+0x20f0],ax           ; bx+_chr+0x42
10f0  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:122
10f4  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
10f7  mov    ax,WORD PTR es:[bx]
10fa  les    bx,DWORD PTR [bp-0x4]                ; vad
10fd  mov    WORD PTR es:[bx+0x40f0],ax           ; bx+_speed+0x42
1102  add    WORD PTR [bp+0x8],0x2                ; ptnpt
                                  ; ---- KOR-GRP.C:123
1106  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
1109  mov    ax,WORD PTR es:[bx]
110c  les    bx,DWORD PTR [bp-0x4]                ; vad
110f  mov    WORD PTR es:[bx+0x60f0],ax           ; bx+_screen+0x1d13
                                  ; ---- KOR-GRP.C:124
1114  pop    si                                   ; si=i
1115  mov    sp,bp
1117  pop    bp
1118  ret

; ---------------------------------------------------------------
_putptn_cga:   ; 0x1119..0x1220  locals: bp+4=px, bp+6=py, bp+8=ptnpt, bp-4=vad, si=i
                                  ; ---- KOR-GRP.C:154
1119  push   bp
111a  mov    bp,sp
111c  sub    sp,0x4
111f  push   si                                   ; si=i
                                  ; ---- KOR-GRP.C:159
1120  mov    ax,WORD PTR [bp+0x6]                 ; py
1123  shl    ax,1
1125  shl    ax,1
1127  mov    dx,0x50
112a  mul    dx
112c  cwd
112d  add    ax,WORD PTR [_PAGE1]
1131  adc    dx,WORD PTR [_PAGE1+0x2]
1135  mov    bx,WORD PTR [bp+0x4]                 ; px
1138  shl    bx,1
113a  add    ax,bx
113c  mov    WORD PTR [bp-0x2],dx
113f  mov    WORD PTR [bp-0x4],ax                 ; vad
                                  ; ---- KOR-GRP.C:160
1142  add    WORD PTR [bp+0x8],0x2                ; ptnpt
1146  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
1149  mov    ax,WORD PTR es:[bx]
114c  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
114f  or     ax,WORD PTR es:[bx]
1152  les    bx,DWORD PTR [bp-0x4]                ; vad
1155  mov    WORD PTR es:[bx],ax
                                  ; ---- KOR-GRP.C:161
1158  add    WORD PTR [bp+0x8],0x2                ; ptnpt
115c  add    WORD PTR [bp+0x8],0x2                ; ptnpt
1160  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
1163  mov    ax,WORD PTR es:[bx]
1166  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
1169  or     ax,WORD PTR es:[bx]
116c  les    bx,DWORD PTR [bp-0x4]                ; vad
116f  mov    WORD PTR es:[bx+0x2000],ax           ; bx+_yad+0x594
                                  ; ---- KOR-GRP.C:162
1174  add    WORD PTR [bp+0x8],0x2                ; ptnpt
1178  add    WORD PTR [bp+0x8],0x2                ; ptnpt
117c  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
117f  mov    ax,WORD PTR es:[bx]
1182  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
1185  or     ax,WORD PTR es:[bx]
1188  les    bx,DWORD PTR [bp-0x4]                ; vad
118b  mov    WORD PTR es:[bx+0x50],ax
                                  ; ---- KOR-GRP.C:163
118f  add    WORD PTR [bp+0x8],0x2                ; ptnpt
1193  add    WORD PTR [bp+0x8],0x2                ; ptnpt
1197  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
119a  mov    ax,WORD PTR es:[bx]
119d  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
11a0  or     ax,WORD PTR es:[bx]
11a3  les    bx,DWORD PTR [bp-0x4]                ; vad
11a6  mov    WORD PTR es:[bx+0x2050],ax           ; bx+_yad+0x5e4
                                  ; ---- KOR-GRP.C:164
11ab  add    WORD PTR [bp+0x8],0x2                ; ptnpt
11af  add    WORD PTR [bp+0x8],0x2                ; ptnpt
11b3  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
11b6  mov    ax,WORD PTR es:[bx]
11b9  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
11bc  or     ax,WORD PTR es:[bx]
11bf  les    bx,DWORD PTR [bp-0x4]                ; vad
11c2  mov    WORD PTR es:[bx+0xa0],ax             ; bx+_play+0xc
                                  ; ---- KOR-GRP.C:165
11c7  add    WORD PTR [bp+0x8],0x2                ; ptnpt
11cb  add    WORD PTR [bp+0x8],0x2                ; ptnpt
11cf  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
11d2  mov    ax,WORD PTR es:[bx]
11d5  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
11d8  or     ax,WORD PTR es:[bx]
11db  les    bx,DWORD PTR [bp-0x4]                ; vad
11de  mov    WORD PTR es:[bx+0x20a0],ax           ; bx+_yad+0x634
                                  ; ---- KOR-GRP.C:166
11e3  add    WORD PTR [bp+0x8],0x2                ; ptnpt
11e7  add    WORD PTR [bp+0x8],0x2                ; ptnpt
11eb  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
11ee  mov    ax,WORD PTR es:[bx]
11f1  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
11f4  or     ax,WORD PTR es:[bx]
11f7  les    bx,DWORD PTR [bp-0x4]                ; vad
11fa  mov    WORD PTR es:[bx+0xf0],ax             ; bx+_play+0x5c
                                  ; ---- KOR-GRP.C:167
11ff  add    WORD PTR [bp+0x8],0x2                ; ptnpt
1203  add    WORD PTR [bp+0x8],0x2                ; ptnpt
1207  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
120a  mov    ax,WORD PTR es:[bx]
120d  les    bx,DWORD PTR [bp+0x8]                ; ptnpt
1210  or     ax,WORD PTR es:[bx]
1213  les    bx,DWORD PTR [bp-0x4]                ; vad
1216  mov    WORD PTR es:[bx+0x20f0],ax           ; bx+_chr+0x42
                                  ; ---- KOR-GRP.C:168
121b  pop    si                                   ; si=i
121c  mov    sp,bp
121e  pop    bp
121f  ret

; ---------------------------------------------------------------
_putptn:   ; 0x1220..0x1250  locals: bp+4=px, bp+6=py, bp+8=ptnpt
                                  ; ---- KOR-GRP.C:185
1220  push   bp
1221  mov    bp,sp
                                  ; ---- KOR-GRP.C:187
1223  cmp    WORD PTR [_grp_driver],0x0
1228  je     0x123d
122a  push   WORD PTR [bp+0xa]
122d  push   WORD PTR [bp+0x8]                    ; ptnpt
1230  push   WORD PTR [bp+0x6]                    ; py
1233  push   WORD PTR [bp+0x4]                    ; px
1236  call   _putptn_herc
1239  mov    sp,bp
123b  jmp    0x124e
                                  ; ---- KOR-GRP.C:188
123d  push   WORD PTR [bp+0xa]
1240  push   WORD PTR [bp+0x8]                    ; ptnpt
1243  push   WORD PTR [bp+0x6]                    ; py
1246  push   WORD PTR [bp+0x4]                    ; px
1249  call   _putptn_cga
124c  mov    sp,bp
                                  ; ---- KOR-GRP.C:189
124e  pop    bp
124f  ret

; ---------------------------------------------------------------
_up_scroll:   ; 0x1250..0x1315  locals: bp-4=vad2, bp-8=vad1, di=i, si=j
                                  ; ---- KOR-GRP.C:192
1250  push   bp
1251  mov    bp,sp
1253  sub    sp,0x8
1256  push   si                                   ; si=j
1257  push   di                                   ; di=i
                                  ; ---- KOR-GRP.C:197
1258  xor    di,di                                ; di=i
125a  jmp    0x12c5
                                  ; ---- KOR-GRP.C:198
125c  mov    si,WORD PTR [_windowy1]              ; si=j
1260  jmp    0x12bc
                                  ; ---- KOR-GRP.C:199
1262  mov    bx,si                                ; si=j
1264  mov    cl,0x4
1266  shl    bx,cl
1268  add    bx,di                                ; di=i
126a  shl    bx,1
126c  shl    bx,1
126e  les    bx,DWORD PTR [bx+0x1a6c]             ; bx+_yad
1272  mov    ax,[_windowx1]
1275  shl    ax,1
1277  add    bx,ax
1279  mov    WORD PTR [bp-0x6],es
127c  mov    WORD PTR [bp-0x8],bx                 ; vad1
                                  ; ---- KOR-GRP.C:200
127f  mov    bx,si                                ; si=j
1281  mov    cl,0x4
1283  shl    bx,cl
1285  add    bx,di                                ; di=i
1287  add    bx,0x10
128a  shl    bx,1
128c  shl    bx,1
128e  les    bx,DWORD PTR [bx+0x1a6c]             ; bx+_yad
1292  mov    ax,[_windowx1]
1295  shl    ax,1
1297  add    bx,ax
1299  mov    WORD PTR [bp-0x2],es
129c  mov    WORD PTR [bp-0x4],bx                 ; vad2
                                  ; ---- KOR-GRP.C:201
129f  mov    ax,[_windowx2]
12a2  sub    ax,WORD PTR [_windowx1]
12a6  shl    ax,1
12a8  push   ax
12a9  push   WORD PTR [bp-0x2]
12ac  push   WORD PTR [bp-0x4]                    ; vad2
12af  push   WORD PTR [bp-0x6]
12b2  push   WORD PTR [bp-0x8]                    ; vad1
12b5  call   _memcpy
12b8  add    sp,0xa
12bb  inc    si                                   ; si=j
12bc  mov    ax,[_windowy2]
12bf  dec    ax
12c0  cmp    ax,si                                ; si=j
12c2  jg     0x1262
12c4  inc    di                                   ; di=i
12c5  cmp    di,0x10                              ; di=i
12c8  jl     0x125c
                                  ; ---- KOR-GRP.C:203
12ca  xor    di,di                                ; di=i
12cc  jmp    0x130a
                                  ; ---- KOR-GRP.C:204
12ce  mov    bx,WORD PTR [_windowy2]
12d2  mov    cl,0x4
12d4  shl    bx,cl
12d6  add    bx,di                                ; di=i
12d8  add    bx,0xfff0
12db  shl    bx,1
12dd  shl    bx,1
12df  les    bx,DWORD PTR [bx+0x1a6c]             ; bx+_yad
12e3  mov    ax,[_windowx1]
12e6  shl    ax,1
12e8  add    bx,ax
12ea  mov    WORD PTR [bp-0x6],es
12ed  mov    WORD PTR [bp-0x8],bx                 ; vad1
                                  ; ---- KOR-GRP.C:205
12f0  mov    ax,[_windowx2]
12f3  sub    ax,WORD PTR [_windowx1]
12f7  shl    ax,1
12f9  push   ax
12fa  xor    ax,ax
12fc  push   ax
12fd  push   WORD PTR [bp-0x6]
1300  push   WORD PTR [bp-0x8]                    ; vad1
1303  call   _memset
1306  add    sp,0x8
1309  inc    di                                   ; di=i
130a  cmp    di,0x10                              ; di=i
130d  jl     0x12ce
                                  ; ---- KOR-GRP.C:207
130f  pop    di                                   ; di=i
1310  pop    si                                   ; si=j
1311  mov    sp,bp
1313  pop    bp
1314  ret

; ---------------------------------------------------------------
_down_scroll:   ; 0x1315..0x13d8  locals: bp-4=vad2, bp-8=vad1, di=i, si=j
                                  ; ---- KOR-GRP.C:210
1315  push   bp
1316  mov    bp,sp
1318  sub    sp,0x8
131b  push   si                                   ; si=j
131c  push   di                                   ; di=i
                                  ; ---- KOR-GRP.C:215
131d  xor    di,di                                ; di=i
131f  jmp    0x138b
                                  ; ---- KOR-GRP.C:216
1321  mov    si,WORD PTR [_windowy2]              ; si=j
1325  dec    si                                   ; si=j
1326  jmp    0x1382
                                  ; ---- KOR-GRP.C:217
1328  mov    bx,si                                ; si=j
132a  mov    cl,0x4
132c  shl    bx,cl
132e  add    bx,di                                ; di=i
1330  shl    bx,1
1332  shl    bx,1
1334  les    bx,DWORD PTR [bx+0x1a6c]             ; bx+_yad
1338  mov    ax,[_windowx1]
133b  shl    ax,1
133d  add    bx,ax
133f  mov    WORD PTR [bp-0x6],es
1342  mov    WORD PTR [bp-0x8],bx                 ; vad1
                                  ; ---- KOR-GRP.C:218
1345  mov    bx,si                                ; si=j
1347  mov    cl,0x4
1349  shl    bx,cl
134b  add    bx,di                                ; di=i
134d  add    bx,0xfff0
1350  shl    bx,1
1352  shl    bx,1
1354  les    bx,DWORD PTR [bx+0x1a6c]             ; bx+_yad
1358  mov    ax,[_windowx1]
135b  shl    ax,1
135d  add    bx,ax
135f  mov    WORD PTR [bp-0x2],es
1362  mov    WORD PTR [bp-0x4],bx                 ; vad2
                                  ; ---- KOR-GRP.C:219
1365  mov    ax,[_windowx2]
1368  sub    ax,WORD PTR [_windowx1]
136c  shl    ax,1
136e  push   ax
136f  push   WORD PTR [bp-0x2]
1372  push   WORD PTR [bp-0x4]                    ; vad2
1375  push   WORD PTR [bp-0x6]
1378  push   WORD PTR [bp-0x8]                    ; vad1
137b  call   _memcpy
137e  add    sp,0xa
1381  dec    si                                   ; si=j
1382  mov    ax,[_windowy1]
1385  inc    ax
1386  cmp    ax,si                                ; si=j
1388  jl     0x1328
138a  inc    di                                   ; di=i
138b  cmp    di,0x10                              ; di=i
138e  jl     0x1321
                                  ; ---- KOR-GRP.C:221
1390  xor    di,di                                ; di=i
1392  jmp    0x13cd
                                  ; ---- KOR-GRP.C:222
1394  mov    bx,WORD PTR [_windowy1]
1398  mov    cl,0x4
139a  shl    bx,cl
139c  add    bx,di                                ; di=i
139e  shl    bx,1
13a0  shl    bx,1
13a2  les    bx,DWORD PTR [bx+0x1a6c]             ; bx+_yad
13a6  mov    ax,[_windowx1]
13a9  shl    ax,1
13ab  add    bx,ax
13ad  mov    WORD PTR [bp-0x6],es
13b0  mov    WORD PTR [bp-0x8],bx                 ; vad1
                                  ; ---- KOR-GRP.C:223
13b3  mov    ax,[_windowx2]
13b6  sub    ax,WORD PTR [_windowx1]
13ba  shl    ax,1
13bc  push   ax
13bd  xor    ax,ax
13bf  push   ax
13c0  push   WORD PTR [bp-0x6]
13c3  push   WORD PTR [bp-0x8]                    ; vad1
13c6  call   _memset
13c9  add    sp,0x8
13cc  inc    di                                   ; di=i
13cd  cmp    di,0x10                              ; di=i
13d0  jl     0x1394
                                  ; ---- KOR-GRP.C:225
13d2  pop    di                                   ; di=i
13d3  pop    si                                   ; si=j
13d4  mov    sp,bp
13d6  pop    bp
13d7  ret

; ---------------------------------------------------------------
_window_cls:   ; 0x13d8..0x142a  locals: bp-4=vad, si=i
                                  ; ---- KOR-GRP.C:228
13d8  push   bp
13d9  mov    bp,sp
13db  sub    sp,0x4
13de  push   si                                   ; si=i
                                  ; ---- KOR-GRP.C:233
13df  mov    si,WORD PTR [_windowy1]              ; si=i
13e3  mov    cl,0x4
13e5  shl    si,cl                                ; si=i
13e7  jmp    0x141a
                                  ; ---- KOR-GRP.C:234
13e9  mov    bx,si                                ; si=i
13eb  shl    bx,1
13ed  shl    bx,1
13ef  les    bx,DWORD PTR [bx+0x1a6c]             ; bx+_yad
13f3  mov    ax,[_windowx1]
13f6  shl    ax,1
13f8  add    bx,ax
13fa  mov    WORD PTR [bp-0x2],es
13fd  mov    WORD PTR [bp-0x4],bx                 ; vad
                                  ; ---- KOR-GRP.C:235
1400  mov    ax,[_windowx2]
1403  sub    ax,WORD PTR [_windowx1]
1407  shl    ax,1
1409  push   ax
140a  xor    ax,ax
140c  push   ax
140d  push   WORD PTR [bp-0x2]
1410  push   WORD PTR [bp-0x4]                    ; vad
1413  call   _memset
1416  add    sp,0x8
1419  inc    si                                   ; si=i
141a  mov    ax,[_windowy2]
141d  mov    cl,0x4
141f  shl    ax,cl
1421  cmp    ax,si                                ; si=i
1423  jg     0x13e9
                                  ; ---- KOR-GRP.C:237
1425  pop    si                                   ; si=i
1426  mov    sp,bp
1428  pop    bp
1429  ret

; ---------------------------------------------------------------
_lprint:   ; 0x142a..0x1484  locals: bp+4=ptndata
                                  ; ---- KOR-GRP.C:240
142a  push   bp
142b  mov    bp,sp
142d  jmp    0x1479
                                  ; ---- KOR-GRP.C:243
142f  push   ds
1430  les    bx,DWORD PTR [bp+0x4]                ; ptndata
1433  inc    WORD PTR [bp+0x4]                    ; ptndata
1436  mov    al,BYTE PTR es:[bx]
1439  mov    ah,0x0
143b  mov    cl,0x5
143d  shl    ax,cl
143f  add    ax,0x20ae
1442  push   ax
1443  push   WORD PTR [_locy]
1447  push   WORD PTR [_locx]
144b  call   _putptn
144e  mov    sp,bp
                                  ; ---- KOR-GRP.C:244
1450  inc    WORD PTR [_locx]
1454  mov    ax,[_locx]
1457  cmp    ax,WORD PTR [_windowx2]
145b  jne    0x1479
                                  ; ---- KOR-GRP.C:245
145d  mov    ax,[_windowx1]
1460  mov    [_locx],ax
                                  ; ---- KOR-GRP.C:246
1463  inc    WORD PTR [_locy]
1467  mov    ax,[_locy]
146a  cmp    ax,WORD PTR [_windowy2]
146e  jne    0x1479
                                  ; ---- KOR-GRP.C:247
1470  dec    WORD PTR [_locy]
                                  ; ---- KOR-GRP.C:248
1474  call   _up_scroll
1477  mov    sp,bp
                                  ; ---- KOR-GRP.C:242
1479  les    bx,DWORD PTR [bp+0x4]                ; ptndata
147c  cmp    BYTE PTR es:[bx],0x0
1480  jne    0x142f
                                  ; ---- KOR-GRP.C:252
1482  pop    bp
1483  ret

; ---------------------------------------------------------------
_cprint:   ; 0x1484..0x14cd  locals: bp+4=ptndata
                                  ; ---- KOR-GRP.C:255
1484  push   bp
1485  mov    bp,sp
                                  ; ---- KOR-GRP.C:257
1487  push   ds
1488  mov    al,BYTE PTR [bp+0x4]                 ; ptndata
148b  mov    ah,0x0
148d  mov    cl,0x5
148f  shl    ax,cl
1491  add    ax,0x20ae
1494  push   ax
1495  push   WORD PTR [_locy]
1499  push   WORD PTR [_locx]
149d  call   _putptn
14a0  mov    sp,bp
                                  ; ---- KOR-GRP.C:258
14a2  inc    WORD PTR [_locx]
14a6  mov    ax,[_locx]
14a9  cmp    ax,WORD PTR [_windowx2]
14ad  jne    0x14cb
                                  ; ---- KOR-GRP.C:259
14af  mov    ax,[_windowx1]
14b2  mov    [_locx],ax
                                  ; ---- KOR-GRP.C:260
14b5  inc    WORD PTR [_locy]
14b9  mov    ax,[_locy]
14bc  cmp    ax,WORD PTR [_windowy2]
14c0  jne    0x14cb
                                  ; ---- KOR-GRP.C:261
14c2  dec    WORD PTR [_locy]
                                  ; ---- KOR-GRP.C:262
14c6  call   _up_scroll
14c9  mov    sp,bp
                                  ; ---- KOR-GRP.C:265
14cb  pop    bp
14cc  ret

; ---------------------------------------------------------------
_crlf:   ; 0x14cd..0x14ec  locals:
                                  ; ---- KOR-GRP.C:268
14cd  push   bp
14ce  mov    bp,sp
                                  ; ---- KOR-GRP.C:270
14d0  mov    ax,[_windowx1]
14d3  mov    [_locx],ax
                                  ; ---- KOR-GRP.C:271
14d6  inc    WORD PTR [_locy]
14da  mov    ax,[_locy]
14dd  cmp    ax,WORD PTR [_windowy2]
14e1  jne    0x14ea
                                  ; ---- KOR-GRP.C:272
14e3  dec    WORD PTR [_locy]
                                  ; ---- KOR-GRP.C:273
14e7  call   _up_scroll
                                  ; ---- KOR-GRP.C:275
14ea  pop    bp
14eb  ret

; ---------------------------------------------------------------
_cinkey:   ; 0x14ec..0x1546  locals: si=k
                                  ; ---- KOR-GRP.C:278
14ec  push   bp
14ed  mov    bp,sp
14ef  push   si                                   ; si=k
14f0  jmp    0x1541
                                  ; ---- KOR-GRP.C:283
14f2  xor    ax,ax
14f4  push   ax
14f5  call   _inkey
14f8  inc    sp
14f9  inc    sp
14fa  mov    si,ax                                ; si=k
                                  ; ---- KOR-GRP.C:284
14fc  test   BYTE PTR [si+0x141b],0x8             ; __ctype+0x1 | si=k
1501  je     0x1506
1503  sub    si,0x20                              ; si=k
                                  ; ---- KOR-GRP.C:285
1506  test   BYTE PTR [si+0x141b],0x2             ; __ctype+0x1 | si=k
150b  jne    0x1524
150d  test   BYTE PTR [si+0x141b],0x4             ; __ctype+0x1 | si=k
1512  jne    0x1524
1514  push   si                                   ; si=k
1515  push   ds
1516  mov    ax,0xafa                             ; ".- \:"
1519  push   ax
151a  call   _strchr
151d  add    sp,0x6
1520  or     ax,ax
1522  je     0x1528
1524  mov    ax,si                                ; si=k
1526  jmp    0x1543
                                  ; ---- KOR-GRP.C:286
1528  cmp    si,0x14b                             ; si=k
152c  je     0x1533
152e  cmp    si,0x8                               ; si=k
1531  jne    0x1537
1533  xor    ax,ax
1535  jmp    0x1543
                                  ; ---- KOR-GRP.C:287
1537  cmp    si,0xd                               ; si=k
153a  jne    0x1541
153c  mov    ax,0x1
153f  jmp    0x1543
                                  ; ---- KOR-GRP.C:282
1541  jmp    0x14f2
                                  ; ---- KOR-GRP.C:289
1543  pop    si                                   ; si=k
1544  pop    bp
1545  ret

; ---------------------------------------------------------------
_linkey:   ; 0x1546..0x15c5  locals: bp+4=str, bp-2=k, si=l
                                  ; ---- KOR-GRP.C:292
1546  push   bp
1547  mov    bp,sp
1549  sub    sp,0x2
154c  push   si                                   ; si=l
                                  ; ---- KOR-GRP.C:294
154d  xor    si,si                                ; si=l
154f  jmp    0x15be
                                  ; ---- KOR-GRP.C:297
1551  mov    al,0x3e
1553  push   ax
1554  call   _cprint
1557  inc    sp
1558  inc    sp
                                  ; ---- KOR-GRP.C:298
1559  dec    WORD PTR [_locx]
                                  ; ---- KOR-GRP.C:299
155d  call   _cinkey
1560  mov    WORD PTR [bp-0x2],ax                 ; k
                                  ; ---- KOR-GRP.C:300
1563  cmp    WORD PTR [bp-0x2],0x1                ; k
1567  jle    0x158a
                                  ; ---- KOR-GRP.C:301
1569  inc    si                                   ; si=l
156a  mov    ax,si                                ; si=l
156c  cmp    ax,0x21
156f  jge    0x1587
                                  ; ---- KOR-GRP.C:302
1571  push   WORD PTR [bp-0x2]                    ; k
1574  call   _cprint
1577  inc    sp
1578  inc    sp
                                  ; ---- KOR-GRP.C:303
1579  mov    al,BYTE PTR [bp-0x2]                 ; k
157c  les    bx,DWORD PTR [bp+0x4]                ; str
157f  mov    BYTE PTR es:[bx],al
1582  inc    WORD PTR [bp+0x4]                    ; str
                                  ; ---- KOR-GRP.C:304
1585  jmp    0x1588
                                  ; ---- KOR-GRP.C:305
1587  dec    si                                   ; si=l
                                  ; ---- KOR-GRP.C:306
1588  jmp    0x15be
                                  ; ---- KOR-GRP.C:308
158a  cmp    WORD PTR [bp-0x2],0x0                ; k
158e  je     0x15a6
                                  ; ---- KOR-GRP.C:309
1590  les    bx,DWORD PTR [bp+0x4]                ; str
1593  mov    BYTE PTR es:[bx],0x0
                                  ; ---- KOR-GRP.C:310
1597  mov    al,0x20
1599  push   ax
159a  call   _cprint
159d  inc    sp
159e  inc    sp
                                  ; ---- KOR-GRP.C:311
159f  call   _crlf
15a2  jmp    0x15c0
                                  ; ---- KOR-GRP.C:313
15a4  jmp    0x15be
                                  ; ---- KOR-GRP.C:315
15a6  or     si,si                                ; si=l
15a8  je     0x15be
                                  ; ---- KOR-GRP.C:316
15aa  mov    al,0x20
15ac  push   ax
15ad  call   _cprint
15b0  inc    sp
15b1  inc    sp
                                  ; ---- KOR-GRP.C:317
15b2  dec    WORD PTR [_locx]
                                  ; ---- KOR-GRP.C:318
15b6  dec    WORD PTR [_locx]
                                  ; ---- KOR-GRP.C:319
15ba  dec    si                                   ; si=l
                                  ; ---- KOR-GRP.C:320
15bb  dec    WORD PTR [bp+0x4]                    ; str
                                  ; ---- KOR-GRP.C:296
15be  jmp    0x1551
                                  ; ---- KOR-GRP.C:324
15c0  pop    si                                   ; si=l
15c1  mov    sp,bp
15c3  pop    bp
15c4  ret

; ---------------------------------------------------------------
_chrinit:   ; 0x15c5..0x168c  locals: bp-1084=buf, bp-1086=fdi, bp-1088=m, bp-1090=l, bp-1092=i, bp-60=name, di=j, si=k
                                  ; ---- KOR-GRP.C:327
15c5  push   bp
15c6  mov    bp,sp
15c8  sub    sp,0x444
15cc  push   si                                   ; si=k
15cd  push   di                                   ; di=j
15ce  push   ss
15cf  lea    ax,[bp-0x3c]                         ; name
15d2  push   ax
15d3  push   ds
15d4  mov    ax,0xabe                             ; "korea.PTN"
15d7  push   ax
15d8  mov    cx,0x3c
15db  call   0x0:0x5a94
                                  ; ---- KOR-GRP.C:333
15e0  mov    ax,0x8001                            ; &_screen+0x3c24?
15e3  push   ax
15e4  push   ss
15e5  lea    ax,[bp-0x3c]                         ; name
15e8  push   ax
15e9  call   _open
15ec  add    sp,0x6
15ef  mov    WORD PTR [bp-0x43e],ax               ; fdi
15f3  cmp    ax,0xffff
15f6  jne    0x15fe
                                  ; ---- KOR-GRP.C:334
15f8  mov    ax,0xffff
15fb  jmp    0x1686
                                  ; ---- KOR-GRP.C:336
15fe  mov    WORD PTR [bp-0x444],0x0              ; i
1604  jmp    0x1676
                                  ; ---- KOR-GRP.C:337
1606  mov    ax,WORD PTR [bp-0x444]               ; i
160a  mov    cl,0x4
160c  shl    ax,cl
160e  mov    WORD PTR [bp-0x442],ax               ; l
                                  ; ---- KOR-GRP.C:338
1612  mov    ax,0x200                             ; &_play+0x16c?
1615  push   ax
1616  push   ss
1617  lea    ax,[bp-0x43c]                        ; buf
161b  push   ax
161c  push   WORD PTR [bp-0x43e]                  ; fdi
1620  call   _read
1623  add    sp,0x8
                                  ; ---- KOR-GRP.C:339
1626  xor    di,di                                ; di=j
1628  jmp    0x166d
                                  ; ---- KOR-GRP.C:340
162a  mov    ax,di                                ; di=j
162c  mov    cl,0x4
162e  shl    ax,cl
1630  mov    WORD PTR [bp-0x440],ax               ; m
                                  ; ---- KOR-GRP.C:341
1634  xor    si,si                                ; si=k
1636  jmp    0x1667
                                  ; ---- KOR-GRP.C:342
1638  mov    bx,WORD PTR [bp-0x440]               ; m
163c  add    bx,si                                ; si=k
163e  shl    bx,1
1640  lea    ax,[bp-0x43c]                        ; buf
1644  add    bx,ax
1646  mov    ax,WORD PTR ss:[bx]
1649  mov    bx,WORD PTR [bp-0x442]               ; l
164d  add    bx,di                                ; di=j
164f  mov    cl,0x5
1651  shl    bx,cl
1653  add    bx,0x20ae
1657  push   ax
1658  mov    ax,ds
165a  mov    es,ax
165c  mov    ax,si                                ; si=k
165e  shl    ax,1
1660  add    bx,ax
1662  pop    ax
1663  mov    WORD PTR es:[bx],ax
1666  inc    si                                   ; si=k
1667  cmp    si,0x10                              ; si=k
166a  jl     0x1638
166c  inc    di                                   ; di=j
166d  cmp    di,0x10                              ; di=j
1670  jl     0x162a
1672  inc    WORD PTR [bp-0x444]                  ; i
1676  cmp    WORD PTR [bp-0x444],0x10             ; i
167b  jl     0x1606
                                  ; ---- KOR-GRP.C:345
167d  push   WORD PTR [bp-0x43e]                  ; fdi
1681  call   _close
1684  inc    sp
1685  inc    sp
                                  ; ---- KOR-GRP.C:346
1686  pop    di                                   ; di=j
1687  pop    si                                   ; si=k
1688  mov    sp,bp
168a  pop    bp
168b  ret

;======================================================================
; MODULE KOR-INT.C
;======================================================================

; ---------------------------------------------------------------
_game_start_init:   ; 0x168c..0x16fe  locals:
                                  ; ---- KOR-INT.C:63
168c  push   bp
168d  mov    bp,sp
                                  ; ---- KOR-INT.C:65
168f  xor    ax,ax
1691  mov    [_locy],ax
1694  mov    [_locx],ax
                                  ; ---- KOR-INT.C:66
1697  call   _title
                                  ; ---- KOR-INT.C:68
169a  call   _key_scan_init
                                  ; ---- KOR-INT.C:69
169d  xor    ax,ax
169f  push   ax
16a0  push   ax
16a1  call   _time
16a4  add    sp,0x4
16a7  push   ax
16a8  call   _srand
16ab  inc    sp
16ac  inc    sp
                                  ; ---- KOR-INT.C:71
16ad  call   _rand
16b0  mov    bx,0x7
16b3  cwd
16b4  idiv   bx
16b6  mov    WORD PTR [_STICK],dx
                                  ; ---- KOR-INT.C:72
16ba  call   _rand
16bd  mov    bx,0x7
16c0  cwd
16c1  idiv   bx
16c3  mov    WORD PTR [_STICK+0x2],dx
                                  ; ---- KOR-INT.C:73
16c7  mov    BYTE PTR [_point],0x0
                                  ; ---- KOR-INT.C:74
16cc  mov    WORD PTR [_score+0x2],0x0
16d2  mov    WORD PTR [_score],0x0
                                  ; ---- KOR-INT.C:75
16d8  mov    WORD PTR [_life],0x1
                                  ; ---- KOR-INT.C:76
16de  mov    al,0x0
16e0  mov    [_power_simul],al
16e3  mov    ah,0x0
16e5  mov    [_simul],ax
                                  ; ---- KOR-INT.C:78
16e8  mov    WORD PTR [_flag],0x3
                                  ; ---- KOR-INT.C:80
16ee  xor    ax,ax
16f0  mov    [_play_wait],ax
16f3  mov    [_play_data],ax
16f6  mov    [_play_point],ax
16f9  mov    [_music_select],ax
                                  ; ---- KOR-INT.C:83
16fc  pop    bp
16fd  ret

; ---------------------------------------------------------------
_stage_init:   ; 0x16fe..0x17f0  locals: di=i, si=j
                                  ; ---- KOR-INT.C:90
16fe  push   bp
16ff  mov    bp,sp
1701  push   si                                   ; si=j
1702  push   di                                   ; di=i
                                  ; ---- KOR-INT.C:94
1703  xor    di,di                                ; di=i
1705  jmp    0x175a
                                  ; ---- KOR-INT.C:95
1707  xor    si,si                                ; si=j
1709  jmp    0x1737
                                  ; ---- KOR-INT.C:96
170b  mov    al,0x7f
170d  mov    bx,di                                ; di=i
170f  add    bx,0x17
1712  mov    cl,0x4
1714  shl    bx,cl
1716  add    bx,0x18ba
171a  push   ax
171b  mov    ax,ds
171d  mov    es,ax
171f  pop    ax
1720  mov    BYTE PTR es:[bx+si],al               ; si=j
1723  mov    bx,di                                ; di=i
1725  mov    cl,0x4
1727  shl    bx,cl
1729  add    bx,0x18ba
172d  push   ax
172e  mov    ax,ds
1730  mov    es,ax
1732  pop    ax
1733  mov    BYTE PTR es:[bx+si],al               ; si=j
1736  inc    si                                   ; si=j
1737  cmp    si,0x10                              ; si=j
173a  jl     0x170b
                                  ; ---- KOR-INT.C:97
173c  mov    si,0x3                               ; si=j
173f  jmp    0x1754
                                  ; ---- KOR-INT.C:98
1741  mov    bx,di                                ; di=i
1743  mov    cl,0x4
1745  shl    bx,cl
1747  add    bx,0x18ba
174b  mov    ax,ds
174d  mov    es,ax
174f  mov    BYTE PTR es:[bx+si],0x0              ; si=j
1753  inc    si                                   ; si=j
1754  cmp    si,0xd                               ; si=j
1757  jl     0x1741
1759  inc    di                                   ; di=i
175a  cmp    di,0x3                               ; di=i
175d  jl     0x1707
                                  ; ---- KOR-INT.C:101
175f  xor    di,di                                ; di=i
1761  jmp    0x1795
                                  ; ---- KOR-INT.C:102
1763  xor    si,si                                ; si=j
1765  jmp    0x178f
                                  ; ---- KOR-INT.C:103
1767  mov    bx,di                                ; di=i
1769  mov    cl,0x4
176b  shl    bx,cl
176d  add    bx,0x18ba
1771  mov    ax,ds
1773  mov    es,ax
1775  mov    BYTE PTR es:[bx+si],0x7f             ; si=j
                                  ; ---- KOR-INT.C:104
1779  mov    bx,di                                ; di=i
177b  mov    cl,0x4
177d  shl    bx,cl
177f  add    bx,0x18ba
1783  mov    ax,ds
1785  mov    es,ax
1787  add    bx,si                                ; si=j
1789  mov    BYTE PTR es:[bx+0xd],0x7f
178e  inc    si                                   ; si=j
178f  cmp    si,0x3                               ; si=j
1792  jl     0x1767
1794  inc    di                                   ; di=i
1795  cmp    di,0x17                              ; di=i
1798  jl     0x1763
                                  ; ---- KOR-INT.C:107
179a  call   _screen_to_stage
                                  ; ---- KOR-INT.C:109
179d  mov    al,[_point]
17a0  cbw
17a1  mov    bx,ax
17a3  shl    bx,1
17a5  mov    ax,WORD PTR [bx-0x6cff]
17a9  mov    [_timer_w],ax
                                  ; ---- KOR-INT.C:110
17ac  mov    al,[_point]
17af  cbw
17b0  mov    bx,ax
17b2  shl    bx,1
17b4  mov    ax,WORD PTR [bx+0x40ae]              ; bx+_speed
17b8  mov    [_speed_w],ax
                                  ; ---- KOR-INT.C:111
17bb  mov    al,[_point]
17be  cbw
17bf  mov    bx,ax
17c1  shl    bx,1
17c3  mov    ax,WORD PTR [bx+0x417e]              ; bx+_bonus
17c7  mov    dx,0x5
17ca  mul    dx
17cc  mov    [_bonus_w],ax
                                  ; ---- KOR-INT.C:113
17cf  xor    ax,ax
17d1  mov    [_speed_sec],ax
17d4  mov    [_mili_sec],ax
17d7  mov    [_play_point],ax
17da  mov    [_stick_power],ax
17dd  mov    [_help_power],ax
                                  ; ---- KOR-INT.C:115
17e0  call   _grp_put_init
                                  ; ---- KOR-INT.C:117
17e3  call   _next_stage_put
                                  ; ---- KOR-INT.C:119
17e6  mov    WORD PTR [_flag],0x6
                                  ; ---- KOR-INT.C:121
17ec  pop    di                                   ; di=i
17ed  pop    si                                   ; si=j
17ee  pop    bp
17ef  ret

; ---------------------------------------------------------------
_get_stick:   ; 0x17f0..0x19af  locals: bp-4=p, bp-6=l, bp-8=i, di=j, si=k
                                  ; ---- KOR-INT.C:129
17f0  push   bp
17f1  mov    bp,sp
17f3  sub    sp,0x8
17f6  push   si                                   ; si=k
17f7  push   di                                   ; di=j
                                  ; ---- KOR-INT.C:134
17f8  mov    ax,0x82d                             ; "  f ; F       q          q  POWER  ; 00 "
17fb  push   ax
17fc  call   _sound
17ff  inc    sp
1800  inc    sp
                                  ; ---- KOR-INT.C:135
1801  mov    ax,[_STICK+0x2]
1804  mov    [_STICK+0x4],ax
                                  ; ---- KOR-INT.C:136
1807  mov    ax,[_STICK]
180a  mov    [_STICK+0x2],ax
                                  ; ---- KOR-INT.C:137
                                  ; ---- KOR-INT.C:138
180d  call   _rand
1810  mov    bx,0x32
1813  cwd
1814  idiv   bx
1816  or     dx,dx
1818  je     0x1825
181a  call   _rand
181d  mov    bx,0x5
1820  cwd
1821  idiv   bx
1823  jmp    0x1851
1825  mov    al,[_point]
1828  cbw
1829  mov    bx,ax
182b  shl    bx,1
182d  cmp    WORD PTR [bx+0x424c],0x0             ; bx+_power
1832  je     0x1845
1834  mov    al,[_point]
1837  cbw
1838  mov    bx,ax
183a  shl    bx,1
183c  mov    dx,WORD PTR [bx+0x424c]              ; bx+_power
1840  add    dx,0x6
1843  jmp    0x1851
1845  call   _rand
1848  mov    bx,0x5
184b  cwd
184c  idiv   bx
184e  add    dx,0x7
1851  mov    WORD PTR [_STICK],dx
                                  ; ---- KOR-INT.C:139
1855  inc    WORD PTR [_help_power]
                                  ; ---- KOR-INT.C:140
1859  cmp    WORD PTR [_help_power],0xf
185e  jle    0x189d
1860  cmp    WORD PTR [_stick_power],0xa
1865  jle    0x189d
                                  ; ---- KOR-INT.C:141
1867  call   _rand
186a  mov    bx,0x3
186d  cwd
186e  idiv   bx
1870  or     dx,dx
1872  jne    0x189d
                                  ; ---- KOR-INT.C:142
1874  call   _rand
1877  mov    bx,0x5
187a  cwd
187b  idiv   bx
187d  mov    WORD PTR [bp-0x8],dx                 ; i
                                  ; ---- KOR-INT.C:143
1880  mov    ax,WORD PTR [bp-0x8]                 ; i
1883  add    ax,0x7
1886  mov    [_STICK],ax
                                  ; ---- KOR-INT.C:144
1889  cmp    WORD PTR [_help_power],0x5
188e  jle    0x1898
1890  mov    ax,[_help_power]
1893  add    ax,0xfffb
1896  jmp    0x189a
1898  xor    ax,ax
189a  mov    [_help_power],ax
                                  ; ---- KOR-INT.C:148
189d  mov    WORD PTR [bp-0x8],0x9                ; i
18a2  mov    WORD PTR [bp-0x6],0x0                ; l
18a7  jmp    0x1904
                                  ; ---- KOR-INT.C:149
18a9  mov    bx,WORD PTR [bp-0x6]                 ; l
18ac  shl    bx,1
18ae  mov    bx,WORD PTR [bx+0x1a5e]              ; bx+_STICK
18b2  mov    cl,0x6
18b4  shl    bx,cl
18b6  add    bx,0x1056
18ba  mov    ax,ds
18bc  mov    es,ax
18be  mov    WORD PTR [bp-0x2],es
18c1  mov    WORD PTR [bp-0x4],bx                 ; p
                                  ; ---- KOR-INT.C:150
18c4  mov    di,WORD PTR [bp-0x8]                 ; i | di=j
18c7  jmp    0x18f4
                                  ; ---- KOR-INT.C:151
18c9  mov    si,0x1                               ; si=k
18cc  jmp    0x18ee
                                  ; ---- KOR-INT.C:152
18ce  push   ds
18cf  les    bx,DWORD PTR [bp-0x4]                ; p
18d2  inc    WORD PTR [bp-0x4]                    ; p
18d5  mov    al,BYTE PTR es:[bx]
18d8  mov    ah,0x0
18da  add    ax,0x60
18dd  mov    cl,0x5
18df  shl    ax,cl
18e1  add    ax,0x20ae
18e4  push   ax
18e5  push   di                                   ; di=j
18e6  push   si                                   ; si=k
18e7  call   _putptn
18ea  add    sp,0x8
18ed  inc    si                                   ; si=k
18ee  cmp    si,0x5                               ; si=k
18f1  jl     0x18ce
18f3  inc    di                                   ; di=j
18f4  mov    ax,WORD PTR [bp-0x8]                 ; i
18f7  inc    ax
18f8  inc    ax
18f9  cmp    ax,di                                ; di=j
18fb  jg     0x18c9
18fd  sub    WORD PTR [bp-0x8],0x3                ; i
1901  inc    WORD PTR [bp-0x6]                    ; l
1904  cmp    WORD PTR [bp-0x8],0x5                ; i
1908  jg     0x18a9
                                  ; ---- KOR-INT.C:155
190a  xor    ax,ax
190c  mov    [_d_wait],ax
190f  mov    [_set_wait],ax
1912  mov    [_power_y],ax
1915  mov    [_power_x],ax
1918  mov    [_stick_img],ax
                                  ; ---- KOR-INT.C:156
191b  mov    WORD PTR [_sub_flag],0x63
                                  ; ---- KOR-INT.C:157
1921  mov    WORD PTR [_korx],0x6
1927  mov    WORD PTR [_kory],0x1
                                  ; ---- KOR-INT.C:159
192d  cmp    WORD PTR [_STICK+0x4],0x6
1932  jle    0x1969
                                  ; ---- KOR-INT.C:160
1934  mov    ax,[_STICK+0x4]
1937  add    ax,0xfffa
193a  mov    dx,0xe
193d  mul    dx
193f  mov    bx,ax
1941  add    bx,0x1002                            ; "BY  PARK S.G."
1945  mov    ax,ds
1947  mov    es,ax
1949  mov    WORD PTR [bp-0x2],es
194c  mov    WORD PTR [bp-0x4],bx                 ; p
                                  ; ---- KOR-INT.C:161
194f  mov    WORD PTR [_flag],0x17
                                  ; ---- KOR-INT.C:162
1955  mov    WORD PTR [_korx],0x8
                                  ; ---- KOR-INT.C:163
195b  mov    WORD PTR [_kory],0x2
                                  ; ---- KOR-INT.C:164
1961  mov    WORD PTR [_stick_img],0x1
                                  ; ---- KOR-INT.C:165
1967  jmp    0x1977
                                  ; ---- KOR-INT.C:167
1969  mov    WORD PTR [bp-0x2],ds
196c  mov    WORD PTR [bp-0x4],0x1002             ; p
                                  ; ---- KOR-INT.C:168
1971  mov    WORD PTR [_flag],0x14
                                  ; ---- KOR-INT.C:171
1977  mov    WORD PTR [_locx],0x1a
                                  ; ---- KOR-INT.C:172
197d  mov    WORD PTR [_locy],0x16
                                  ; ---- KOR-INT.C:173
1983  push   WORD PTR [bp-0x2]
1986  push   WORD PTR [bp-0x4]                    ; p
1989  call   _lprint
198c  add    sp,0x4
                                  ; ---- KOR-INT.C:175
198f  call   _stage_check
1992  or     ax,ax
1994  jne    0x199d
1996  call   _stage_down_check
1999  or     ax,ax
199b  je     0x19a9
                                  ; ---- KOR-INT.C:176
199d  mov    WORD PTR [_flag],0x3c
                                  ; ---- KOR-INT.C:177
19a3  mov    WORD PTR [_sub_flag],0x3
                                  ; ---- KOR-INT.C:179
19a9  pop    di                                   ; di=j
19aa  pop    si                                   ; si=k
19ab  mov    sp,bp
19ad  pop    bp
19ae  ret

; ---------------------------------------------------------------
_run_stick:   ; 0x19af..0x1b58  locals: bp-2=check_flag, bp-4=k, di=stop_flag, si=f
                                  ; ---- KOR-INT.C:186
19af  push   bp
19b0  mov    bp,sp
19b2  sub    sp,0x4
19b5  push   si                                   ; si=f
19b6  push   di                                   ; di=stop_flag
                                  ; ---- KOR-INT.C:189
19b7  xor    si,si                                ; si=f
19b9  mov    WORD PTR [bp-0x2],0x0                ; check_flag
19be  xor    di,di                                ; di=stop_flag
                                  ; ---- KOR-INT.C:190
19c0  mov    ax,[_korx]
19c3  mov    [_korxr],ax
19c6  mov    ax,[_kory]
19c9  mov    [_koryr],ax
19cc  mov    ax,[_stick_img]
19cf  mov    [_stick_rimg],ax
                                  ; ---- KOR-INT.C:191
19d2  call   _key_scan
19d5  mov    WORD PTR [bp-0x4],ax                 ; k
                                  ; ---- KOR-INT.C:192
19d8  mov    ax,WORD PTR [bp-0x4]                 ; k
19db  cmp    ax,0x3e
19de  jne    0x19e3
19e0  jmp    0x1a82
19e3  jg     0x1a0c
19e5  cmp    ax,0x3b
19e8  jne    0x19ed
19ea  jmp    0x1a6a
19ed  jg     0x19ff
19ef  cmp    ax,0x1
19f2  jne    0x19f7
19f4  jmp    0x1a8a
19f7  cmp    ax,0x39
19fa  je     0x1a5f
19fc  jmp    0x1a99
19ff  cmp    ax,0x3c
1a02  je     0x1a72
1a04  cmp    ax,0x3d
1a07  je     0x1a7a
1a09  jmp    0x1a99
1a0c  sub    ax,0x4b
1a0f  cmp    ax,0x5
1a12  jbe    0x1a17
1a14  jmp    0x1a99
1a17  mov    bx,ax
1a19  shl    bx,1
1a1b  jmp    WORD PTR cs:[bx+0x1a20]              ; bx+_STAGE+0x166
1a20  dw case_0 -> 0x1a3e
1a22  dw case_1 -> 0x1a2c
1a24  dw case_2 -> 0x1a47
1a26  dw case_3 -> 0x1a99
1a28  dw case_4 -> 0x1a99
1a2a  dw case_5 -> 0x1a50
                                  ; ---- KOR-INT.C:193
1a2c  inc    WORD PTR [_stick_img]
1a30  mov    ax,[_stick_img]
1a33  and    ax,0x3
1a36  mov    [_stick_img],ax
1a39  mov    si,0x2                               ; si=f
1a3c  jmp    0x1a99
                                  ; ---- KOR-INT.C:194
1a3e  dec    WORD PTR [_korx]
1a42  mov    si,0x1                               ; si=f
1a45  jmp    0x1a99
                                  ; ---- KOR-INT.C:195
1a47  inc    WORD PTR [_korx]
1a4b  mov    si,0x1                               ; si=f
1a4e  jmp    0x1a99
                                  ; ---- KOR-INT.C:196
1a50  inc    WORD PTR [_kory]
1a54  mov    WORD PTR [_d_wait],0x0
1a5a  mov    si,0x1                               ; si=f
1a5d  jmp    0x1a99
                                  ; ---- KOR-INT.C:197
1a5f  call   _kor_y_end
                                  ; ---- KOR-INT.C:198
1a62  call   _stage_stick_clear
1a65  call   _stage_store
1a68  jmp    0x1a99
                                  ; ---- KOR-INT.C:199
1a6a  xor    WORD PTR [_information],0x1
1a70  jmp    0x1a99
                                  ; ---- KOR-INT.C:200
1a72  xor    WORD PTR [_information],0x2
1a78  jmp    0x1a99
                                  ; ---- KOR-INT.C:201
1a7a  xor    WORD PTR [_information],0x4
1a80  jmp    0x1a99
                                  ; ---- KOR-INT.C:202
1a82  xor    WORD PTR [_information],0x8
1a88  jmp    0x1a99
                                  ; ---- KOR-INT.C:203
1a8a  call   _textset
1a8d  call   _nosound
1a90  mov    ax,0x1
1a93  push   ax
1a94  call   _exit
1a97  inc    sp
1a98  inc    sp
                                  ; ---- KOR-INT.C:207
1a99  or     si,si                                ; si=f
1a9b  je     0x1ac4
                                  ; ---- KOR-INT.C:208
1a9d  call   _stage_check
1aa0  mov    WORD PTR [bp-0x2],ax                 ; check_flag
                                  ; ---- KOR-INT.C:209
1aa3  call   _stage_stick_clear
                                  ; ---- KOR-INT.C:210
1aa6  call   _stage_store
                                  ; ---- KOR-INT.C:211
1aa9  cmp    si,0x1                               ; si=f
1aac  jne    0x1ab3
1aae  call   _stage_down_check
1ab1  mov    di,ax                                ; di=stop_flag
                                  ; ---- KOR-INT.C:212
1ab3  cmp    WORD PTR [bp-0x2],0x0                ; check_flag
1ab7  je     0x1ac2
1ab9  or     di,di                                ; di=stop_flag
1abb  je     0x1ac2
1abd  mov    si,0x1                               ; si=f
1ac0  jmp    0x1ac4
1ac2  xor    si,si                                ; si=f
                                  ; ---- KOR-INT.C:214
1ac4  call   _stage_down_check
1ac7  mov    di,ax                                ; di=stop_flag
                                  ; ---- KOR-INT.C:215
1ac9  inc    WORD PTR [_d_wait]
1acd  mov    ax,[_d_wait]
1ad0  cmp    ax,WORD PTR [_speed_w]
1ad4  jle    0x1af1
                                  ; ---- KOR-INT.C:216
1ad6  mov    WORD PTR [_d_wait],0x0
                                  ; ---- KOR-INT.C:217
1adc  or     di,di                                ; di=stop_flag
1ade  je     0x1ae5
1ae0  mov    si,0x1                               ; si=f
1ae3  jmp    0x1aef
                                  ; ---- KOR-INT.C:219
1ae5  inc    WORD PTR [_kory]
                                  ; ---- KOR-INT.C:220
1ae9  call   _stage_stick_clear
                                  ; ---- KOR-INT.C:221
1aec  call   _stage_store
                                  ; ---- KOR-INT.C:223
1aef  jmp    0x1afe
                                  ; ---- KOR-INT.C:224
1af1  or     di,di                                ; di=stop_flag
1af3  je     0x1afa
1af5  mov    si,0x1                               ; si=f
1af8  jmp    0x1afe
                                  ; ---- KOR-INT.C:225
1afa  inc    WORD PTR [_set_wait]
                                  ; ---- KOR-INT.C:226
1afe  push   ds
1aff  or     si,si                                ; si=f
1b01  jne    0x1b09
1b03  cmp    WORD PTR [bp-0x2],0x0                ; check_flag
1b07  je     0x1b0e
1b09  mov    ax,0x1
1b0c  jmp    0x1b10
1b0e  xor    ax,ax
1b10  add    ax,0x8b
1b13  mov    cl,0x5
1b15  shl    ax,cl
1b17  add    ax,0x20ae
1b1a  push   ax
1b1b  mov    ax,0x14
1b1e  push   ax
1b1f  mov    ax,0x26
1b22  push   ax
1b23  call   _putptn
1b26  add    sp,0x8
                                  ; ---- KOR-INT.C:227
1b29  or     si,si                                ; si=f
1b2b  je     0x1b33
1b2d  mov    ax,[_set_wait]
1b30  inc    ax
1b31  jmp    0x1b42
1b33  cmp    WORD PTR [_set_wait],0x0
1b38  je     0x1b40
1b3a  mov    ax,[_set_wait]
1b3d  dec    ax
1b3e  jmp    0x1b42
1b40  xor    ax,ax
1b42  mov    [_set_wait],ax
                                  ; ---- KOR-INT.C:228
1b45  cmp    WORD PTR [_set_wait],0xa
1b4a  jle    0x1b52
1b4c  mov    WORD PTR [_flag],0x1a
                                  ; ---- KOR-INT.C:230
1b52  pop    di                                   ; di=stop_flag
1b53  pop    si                                   ; si=f
1b54  mov    sp,bp
1b56  pop    bp
1b57  ret

; ---------------------------------------------------------------
_run_power:   ; 0x1b58..0x1d9e  locals: bp-2=q, bp-4=check_flag, bp-6=k, di=stop_flag, si=f
                                  ; ---- KOR-INT.C:237
1b58  push   bp
1b59  mov    bp,sp
1b5b  sub    sp,0x6
1b5e  push   si                                   ; si=f
1b5f  push   di                                   ; di=stop_flag
                                  ; ---- KOR-INT.C:240
1b60  xor    si,si                                ; si=f
1b62  mov    WORD PTR [bp-0x4],0x0                ; check_flag
1b67  xor    di,di                                ; di=stop_flag
1b69  mov    WORD PTR [bp-0x2],0x0                ; q
                                  ; ---- KOR-INT.C:241
1b6e  mov    ax,[_korx]
1b71  mov    [_korxr],ax
1b74  mov    ax,[_kory]
1b77  mov    [_koryr],ax
1b7a  mov    ax,[_stick_img]
1b7d  mov    [_stick_rimg],ax
                                  ; ---- KOR-INT.C:243
1b80  mov    bx,WORD PTR [_kory]
1b84  mov    cl,0x4
1b86  shl    bx,cl
1b88  add    bx,0x18ba
1b8c  mov    ax,ds
1b8e  mov    es,ax
1b90  add    bx,WORD PTR [_korx]
1b94  mov    BYTE PTR es:[bx],0x0
                                  ; ---- KOR-INT.C:244
1b98  xor    BYTE PTR [_power_simul],0x5
                                  ; ---- KOR-INT.C:245
1b9d  call   _key_scan
1ba0  mov    WORD PTR [bp-0x6],ax                 ; k
                                  ; ---- KOR-INT.C:246
1ba3  mov    ax,WORD PTR [bp-0x6]                 ; k
1ba6  cmp    ax,0x3d
1ba9  jne    0x1bae
1bab  jmp    0x1c1f
1bae  jg     0x1bcf
1bb0  cmp    ax,0x3b
1bb3  je     0x1c0f
1bb5  jg     0x1bc7
1bb7  cmp    ax,0x1
1bba  jne    0x1bbf
1bbc  jmp    0x1c2f
1bbf  cmp    ax,0x39
1bc2  je     0x1c0a
1bc4  jmp    0x1c3b
1bc7  cmp    ax,0x3c
1bca  je     0x1c17
1bcc  jmp    0x1c3b
1bcf  cmp    ax,0x4d
1bd2  je     0x1bf2
1bd4  jg     0x1be2
1bd6  cmp    ax,0x3e
1bd9  je     0x1c27
1bdb  cmp    ax,0x4b
1bde  je     0x1be9
1be0  jmp    0x1c3b
1be2  cmp    ax,0x50
1be5  je     0x1bfb
1be7  jmp    0x1c3b
                                  ; ---- KOR-INT.C:247
1be9  dec    WORD PTR [_korx]
1bed  mov    si,0x1                               ; si=f
1bf0  jmp    0x1c3b
                                  ; ---- KOR-INT.C:248
1bf2  inc    WORD PTR [_korx]
1bf6  mov    si,0x1                               ; si=f
1bf9  jmp    0x1c3b
                                  ; ---- KOR-INT.C:249
1bfb  inc    WORD PTR [_kory]
1bff  mov    WORD PTR [_d_wait],0x0
1c05  mov    si,0x1                               ; si=f
1c08  jmp    0x1c3b
                                  ; ---- KOR-INT.C:250
1c0a  call   _power_proc_set
1c0d  jmp    0x1c3b
                                  ; ---- KOR-INT.C:251
1c0f  xor    WORD PTR [_information],0x1
1c15  jmp    0x1c3b
                                  ; ---- KOR-INT.C:252
1c17  xor    WORD PTR [_information],0x2
1c1d  jmp    0x1c3b
                                  ; ---- KOR-INT.C:253
1c1f  xor    WORD PTR [_information],0x4
1c25  jmp    0x1c3b
                                  ; ---- KOR-INT.C:254
1c27  xor    WORD PTR [_information],0x8
1c2d  jmp    0x1c3b
                                  ; ---- KOR-INT.C:255
1c2f  call   _textset
1c32  mov    ax,0x1
1c35  push   ax
1c36  call   _exit
1c39  inc    sp
1c3a  inc    sp
                                  ; ---- KOR-INT.C:259
1c3b  call   _power_process
1c3e  mov    WORD PTR [bp-0x2],ax                 ; q
                                  ; ---- KOR-INT.C:260
1c41  cmp    WORD PTR [bp-0x2],0x0                ; q
1c45  je     0x1c50
                                  ; ---- KOR-INT.C:261
1c47  mov    WORD PTR [_flag],0x1e
1c4d  jmp    0x1d98
                                  ; ---- KOR-INT.C:265
1c50  or     si,si                                ; si=f
1c52  je     0x1cae
                                  ; ---- KOR-INT.C:266
1c54  mov    bx,WORD PTR [_kory]
1c58  mov    cl,0x4
1c5a  shl    bx,cl
1c5c  add    bx,0x18ba
1c60  mov    ax,ds
1c62  mov    es,ax
1c64  add    bx,WORD PTR [_korx]
1c68  cmp    BYTE PTR es:[bx],0x0
1c6c  je     0x1c7f
                                  ; ---- KOR-INT.C:267
1c6e  mov    WORD PTR [bp-0x4],0x1                ; check_flag
                                  ; ---- KOR-INT.C:268
1c73  mov    ax,[_korxr]
1c76  mov    [_korx],ax
                                  ; ---- KOR-INT.C:269
1c79  mov    ax,[_koryr]
1c7c  mov    [_kory],ax
                                  ; ---- KOR-INT.C:271
1c7f  mov    bx,WORD PTR [_kory]
1c83  inc    bx
1c84  mov    cl,0x4
1c86  shl    bx,cl
1c88  add    bx,0x18ba
1c8c  mov    ax,ds
1c8e  mov    es,ax
1c90  add    bx,WORD PTR [_korx]
1c94  cmp    BYTE PTR es:[bx],0x60
1c98  jbe    0x1c9d
1c9a  mov    di,0x1                               ; di=stop_flag
                                  ; ---- KOR-INT.C:272
1c9d  cmp    WORD PTR [bp-0x4],0x0                ; check_flag
1ca1  je     0x1cac
1ca3  or     di,di                                ; di=stop_flag
1ca5  je     0x1cac
1ca7  mov    si,0x1                               ; si=f
1caa  jmp    0x1cae
1cac  xor    si,si                                ; si=f
                                  ; ---- KOR-INT.C:274
1cae  mov    bx,WORD PTR [_kory]
1cb2  inc    bx
1cb3  mov    cl,0x4
1cb5  shl    bx,cl
1cb7  add    bx,0x18ba
1cbb  mov    ax,ds
1cbd  mov    es,ax
1cbf  add    bx,WORD PTR [_korx]
1cc3  cmp    BYTE PTR es:[bx],0x60
1cc7  jbe    0x1ccc
1cc9  mov    di,0x1                               ; di=stop_flag
                                  ; ---- KOR-INT.C:275
1ccc  inc    WORD PTR [_d_wait]
1cd0  mov    ax,[_d_wait]
1cd3  cmp    ax,WORD PTR [_speed_w]
1cd7  jle    0x1cee
                                  ; ---- KOR-INT.C:276
1cd9  mov    WORD PTR [_d_wait],0x0
                                  ; ---- KOR-INT.C:277
1cdf  or     di,di                                ; di=stop_flag
1ce1  je     0x1ce8
1ce3  mov    si,0x1                               ; si=f
1ce6  jmp    0x1cec
                                  ; ---- KOR-INT.C:279
1ce8  inc    WORD PTR [_kory]
                                  ; ---- KOR-INT.C:281
1cec  jmp    0x1cfb
                                  ; ---- KOR-INT.C:282
1cee  or     di,di                                ; di=stop_flag
1cf0  je     0x1cf7
1cf2  mov    si,0x1                               ; si=f
1cf5  jmp    0x1cfb
                                  ; ---- KOR-INT.C:283
1cf7  inc    WORD PTR [_set_wait]
                                  ; ---- KOR-INT.C:284
1cfb  mov    bx,WORD PTR [_STICK+0x4]
1cff  mov    cl,0x6
1d01  shl    bx,cl
1d03  add    bx,0x1056
1d07  mov    ax,ds
1d09  mov    es,ax
1d0b  mov    al,BYTE PTR es:[bx+0x10]
1d0f  add    al,BYTE PTR [_power_simul]
1d13  mov    bx,WORD PTR [_kory]
1d17  mov    cl,0x4
1d19  shl    bx,cl
1d1b  add    bx,0x18ba
1d1f  push   ax
1d20  mov    ax,ds
1d22  mov    es,ax
1d24  add    bx,WORD PTR [_korx]
1d28  pop    ax
1d29  mov    BYTE PTR es:[bx],al
                                  ; ---- KOR-INT.C:285
1d2c  push   ds
1d2d  or     si,si                                ; si=f
1d2f  jne    0x1d37
1d31  cmp    WORD PTR [bp-0x4],0x0                ; check_flag
1d35  je     0x1d3c
1d37  mov    ax,0x1
1d3a  jmp    0x1d3e
1d3c  xor    ax,ax
1d3e  add    ax,0x8b
1d41  mov    cl,0x5
1d43  shl    ax,cl
1d45  add    ax,0x20ae
1d48  push   ax
1d49  mov    ax,0x14
1d4c  push   ax
1d4d  mov    ax,0x26
1d50  push   ax
1d51  call   _putptn
1d54  add    sp,0x8
                                  ; ---- KOR-INT.C:286
1d57  or     si,si                                ; si=f
1d59  je     0x1d61
1d5b  mov    ax,[_set_wait]
1d5e  inc    ax
1d5f  jmp    0x1d70
1d61  cmp    WORD PTR [_set_wait],0x0
1d66  je     0x1d6e
1d68  mov    ax,[_set_wait]
1d6b  dec    ax
1d6c  jmp    0x1d70
1d6e  xor    ax,ax
1d70  mov    [_set_wait],ax
                                  ; ---- KOR-INT.C:287
1d73  cmp    WORD PTR [_set_wait],0xa
1d78  jle    0x1d98
                                  ; ---- KOR-INT.C:288
1d7a  mov    WORD PTR [_flag],0x1e
                                  ; ---- KOR-INT.C:289
1d80  mov    bx,WORD PTR [_kory]
1d84  mov    cl,0x4
1d86  shl    bx,cl
1d88  add    bx,0x18ba
1d8c  mov    ax,ds
1d8e  mov    es,ax
1d90  add    bx,WORD PTR [_korx]
1d94  mov    BYTE PTR es:[bx],0x6e
                                  ; ---- KOR-INT.C:292
1d98  pop    di                                   ; di=stop_flag
1d99  pop    si                                   ; si=f
1d9a  mov    sp,bp
1d9c  pop    bp
1d9d  ret

; ---------------------------------------------------------------
_stage_stick_set:   ; 0x1d9e..0x1e12  locals: di=i, si=j
                                  ; ---- KOR-INT.C:300
1d9e  push   bp
1d9f  mov    bp,sp
1da1  push   si                                   ; si=j
1da2  push   di                                   ; di=i
                                  ; ---- KOR-INT.C:304
1da3  mov    di,0x16                              ; di=i
1da6  jmp    0x1df6
                                  ; ---- KOR-INT.C:305
1da8  mov    si,0x3                               ; si=j
1dab  jmp    0x1df0
                                  ; ---- KOR-INT.C:306
1dad  mov    bx,di                                ; di=i
1daf  mov    cl,0x4
1db1  shl    bx,cl
1db3  add    bx,0x18ba
1db7  mov    ax,ds
1db9  mov    es,ax
1dbb  cmp    BYTE PTR es:[bx+si],0x11             ; si=j
1dbf  jae    0x1def
1dc1  mov    bx,di                                ; di=i
1dc3  mov    cl,0x4
1dc5  shl    bx,cl
1dc7  add    bx,0x18ba
1dcb  mov    ax,ds
1dcd  mov    es,ax
1dcf  cmp    BYTE PTR es:[bx+si],0x0              ; si=j
1dd3  je     0x1def
                                  ; ---- KOR-INT.C:307
1dd5  mov    bx,di                                ; di=i
1dd7  mov    cl,0x4
1dd9  shl    bx,cl
1ddb  add    bx,0x18ba
1ddf  mov    ax,ds
1de1  mov    es,ax
1de3  add    BYTE PTR es:[bx+si],0x60             ; si=j
                                  ; ---- KOR-INT.C:308
1de7  mov    ax,0x17
1dea  sub    ax,di                                ; di=i
1dec  mov    [_stick_power],ax
1def  inc    si                                   ; si=j
1df0  cmp    si,0xd                               ; si=j
1df3  jl     0x1dad
1df5  dec    di                                   ; di=i
1df6  or     di,di                                ; di=i
1df8  jne    0x1da8
                                  ; ---- KOR-INT.C:310
1dfa  mov    al,[_point]
1dfd  cbw
1dfe  inc    ax
1dff  cwd
1e00  add    WORD PTR [_score],ax
1e04  adc    WORD PTR [_score+0x2],dx
                                  ; ---- KOR-INT.C:311
1e08  mov    WORD PTR [_flag],0x1e
                                  ; ---- KOR-INT.C:312
1e0e  pop    di                                   ; di=i
1e0f  pop    si                                   ; si=j
1e10  pop    bp
1e11  ret

; ---------------------------------------------------------------
_stick_clear_check:   ; 0x1e12..0x1ed6  locals: bp-2=sc, bp-4=f, di=i, si=j
                                  ; ---- KOR-INT.C:319
1e12  push   bp
1e13  mov    bp,sp
1e15  sub    sp,0x4
1e18  push   si                                   ; si=j
1e19  push   di                                   ; di=i
                                  ; ---- KOR-INT.C:321
1e1a  mov    WORD PTR [bp-0x2],0x0                ; sc
                                  ; ---- KOR-INT.C:322
1e1f  mov    WORD PTR [_flag],0x32
                                  ; ---- KOR-INT.C:323
1e25  xor    di,di                                ; di=i
1e27  jmp    0x1e9a
                                  ; ---- KOR-INT.C:324
1e2a  mov    WORD PTR [bp-0x4],0x1                ; f
1e2f  mov    si,0x3                               ; si=j
1e32  jmp    0x1e4e
                                  ; ---- KOR-INT.C:325
1e34  mov    bx,di                                ; di=i
1e36  mov    cl,0x4
1e38  shl    bx,cl
1e3a  add    bx,0x18ba
1e3e  mov    ax,ds
1e40  mov    es,ax
1e42  cmp    BYTE PTR es:[bx+si],0x0              ; si=j
1e46  jne    0x1e4d
1e48  mov    WORD PTR [bp-0x4],0x0                ; f
1e4d  inc    si                                   ; si=j
1e4e  cmp    si,0xd                               ; si=j
1e51  jl     0x1e34
                                  ; ---- KOR-INT.C:326
1e53  cmp    WORD PTR [bp-0x4],0x0                ; f
1e57  je     0x1e99
                                  ; ---- KOR-INT.C:327
1e59  inc    WORD PTR [bp-0x2]                    ; sc
                                  ; ---- KOR-INT.C:328
1e5c  mov    WORD PTR [_flag],0x1f
                                  ; ---- KOR-INT.C:329
1e62  mov    WORD PTR [_sub_flag],0x12
                                  ; ---- KOR-INT.C:330
1e68  cmp    WORD PTR [_help_power],0x3
1e6d  jle    0x1e77
1e6f  mov    ax,[_help_power]
1e72  add    ax,0xfffd
1e75  jmp    0x1e79
1e77  xor    ax,ax
1e79  mov    [_help_power],ax
                                  ; ---- KOR-INT.C:331
1e7c  mov    si,0x3                               ; si=j
1e7f  jmp    0x1e94
                                  ; ---- KOR-INT.C:332
1e81  mov    bx,di                                ; di=i
1e83  mov    cl,0x4
1e85  shl    bx,cl
1e87  add    bx,0x18ba
1e8b  mov    ax,ds
1e8d  mov    es,ax
1e8f  mov    BYTE PTR es:[bx+si],0x12             ; si=j
1e93  inc    si                                   ; si=j
1e94  cmp    si,0xd                               ; si=j
1e97  jl     0x1e81
1e99  inc    di                                   ; di=i
1e9a  cmp    di,0x17                              ; di=i
1e9d  jge    0x1ea2
1e9f  jmp    0x1e2a
                                  ; ---- KOR-INT.C:335
1ea2  cmp    WORD PTR [bp-0x2],0x5                ; sc
1ea6  jle    0x1ead
1ea8  mov    ax,0x7d0                             ; &msg+0x132?
1eab  jmp    0x1ec7
1ead  cmp    WORD PTR [bp-0x2],0x0                ; sc
1eb1  je     0x1ec5
1eb3  mov    cl,BYTE PTR [bp-0x2]                 ; sc
1eb6  add    cl,0xff
1eb9  mov    ax,0x1
1ebc  shl    ax,cl
1ebe  mov    dx,0x64
1ec1  mul    dx
1ec3  jmp    0x1ec7
1ec5  xor    ax,ax
1ec7  cwd
1ec8  add    WORD PTR [_score],ax
1ecc  adc    WORD PTR [_score+0x2],dx
                                  ; ---- KOR-INT.C:336
1ed0  pop    di                                   ; di=i
1ed1  pop    si                                   ; si=j
1ed2  mov    sp,bp
1ed4  pop    bp
1ed5  ret

; ---------------------------------------------------------------
_stick_clear_sub1:   ; 0x1ed6..0x1f46  locals: di=i, si=j
                                  ; ---- KOR-INT.C:344
1ed6  push   bp
1ed7  mov    bp,sp
1ed9  push   si                                   ; si=j
1eda  push   di                                   ; di=i
                                  ; ---- KOR-INT.C:347
1edb  xor    di,di                                ; di=i
1edd  jmp    0x1f16
                                  ; ---- KOR-INT.C:348
1edf  mov    bx,di                                ; di=i
1ee1  mov    cl,0x4
1ee3  shl    bx,cl
1ee5  add    bx,0x18ba
1ee9  mov    ax,ds
1eeb  mov    es,ax
1eed  mov    al,BYTE PTR es:[bx+0x3]
1ef1  mov    ah,0x0
1ef3  cmp    ax,WORD PTR [_sub_flag]
1ef7  jne    0x1f15
                                  ; ---- KOR-INT.C:349
1ef9  mov    si,0x3                               ; si=j
1efc  jmp    0x1f10
                                  ; ---- KOR-INT.C:350
1efe  mov    bx,di                                ; di=i
1f00  mov    cl,0x4
1f02  shl    bx,cl
1f04  add    bx,0x18ba
1f08  mov    ax,ds
1f0a  mov    es,ax
1f0c  inc    BYTE PTR es:[bx+si]                  ; si=j
1f0f  inc    si                                   ; si=j
1f10  cmp    si,0xd                               ; si=j
1f13  jl     0x1efe
1f15  inc    di                                   ; di=i
1f16  cmp    di,0x17                              ; di=i
1f19  jl     0x1edf
                                  ; ---- KOR-INT.C:353
1f1b  call   _rand
1f1e  mov    bx,0x2710                            ; &_chr+0x662?
1f21  cwd
1f22  idiv   bx
1f24  add    dx,0x64
1f27  push   dx
1f28  call   _sound
1f2b  inc    sp
1f2c  inc    sp
                                  ; ---- KOR-INT.C:354
1f2d  inc    WORD PTR [_sub_flag]
1f31  mov    ax,[_sub_flag]
1f34  cmp    ax,0x19
1f37  jne    0x1f42
                                  ; ---- KOR-INT.C:355
1f39  mov    WORD PTR [_flag],0x21
                                  ; ---- KOR-INT.C:356
1f3f  call   _nosound
                                  ; ---- KOR-INT.C:358
1f42  pop    di                                   ; di=i
1f43  pop    si                                   ; si=j
1f44  pop    bp
1f45  ret

; ---------------------------------------------------------------
_stick_clear_sub2:   ; 0x1f46..0x1fcc  locals: bp-2=p2, di=i, si=p1
                                  ; ---- KOR-INT.C:366
1f46  push   bp
1f47  mov    bp,sp
1f49  sub    sp,0x2
1f4c  push   si                                   ; si=p1
1f4d  push   di                                   ; di=i
                                  ; ---- KOR-INT.C:370
1f4e  xor    di,di                                ; di=i
1f50  jmp    0x1fbb
                                  ; ---- KOR-INT.C:371
1f52  mov    si,0x16                              ; si=p1
                                  ; ---- KOR-INT.C:372
1f55  mov    WORD PTR [bp-0x2],0x16               ; p2
1f5a  jmp    0x1f9a
                                  ; ---- KOR-INT.C:373
1f5c  mov    bx,WORD PTR [bp-0x2]                 ; p2
1f5f  mov    cl,0x4
1f61  shl    bx,cl
1f63  add    bx,0x18ba
1f67  mov    ax,ds
1f69  mov    es,ax
1f6b  cmp    BYTE PTR es:[bx+di],0x19             ; di=i
1f6f  je     0x1f97
1f71  mov    bx,WORD PTR [bp-0x2]                 ; p2
1f74  mov    cl,0x4
1f76  shl    bx,cl
1f78  add    bx,0x18ba
1f7c  mov    ax,ds
1f7e  mov    es,ax
1f80  mov    al,BYTE PTR es:[bx+di]               ; di=i
1f83  mov    bx,si                                ; si=p1
1f85  mov    cl,0x4
1f87  shl    bx,cl
1f89  add    bx,0x18ba
1f8d  push   ax
1f8e  mov    ax,ds
1f90  mov    es,ax
1f92  pop    ax
1f93  mov    BYTE PTR es:[bx+di],al               ; di=i
1f96  dec    si                                   ; si=p1
1f97  dec    WORD PTR [bp-0x2]                    ; p2
1f9a  cmp    WORD PTR [bp-0x2],0x0                ; p2
1f9e  jge    0x1f5c
1fa0  jmp    0x1fb5
                                  ; ---- KOR-INT.C:375
1fa2  mov    bx,si                                ; si=p1
1fa4  mov    cl,0x4
1fa6  shl    bx,cl
1fa8  add    bx,0x18ba
1fac  mov    ax,ds
1fae  mov    es,ax
1fb0  mov    BYTE PTR es:[bx+di],0x0              ; di=i
                                  ; ---- KOR-INT.C:374
1fb4  dec    si                                   ; si=p1
1fb5  cmp    si,0x2                               ; si=p1
1fb8  jg     0x1fa2
1fba  inc    di                                   ; di=i
1fbb  cmp    di,0xd                               ; di=i
1fbe  jl     0x1f52
                                  ; ---- KOR-INT.C:377
1fc0  mov    WORD PTR [_flag],0x28
                                  ; ---- KOR-INT.C:378
1fc6  pop    di                                   ; di=i
1fc7  pop    si                                   ; si=p1
1fc8  mov    sp,bp
1fca  pop    bp
1fcb  ret

; ---------------------------------------------------------------
_stick_clear_sub3:   ; 0x1fcc..0x2053  locals: bp-2=p2, di=i, si=p1
                                  ; ---- KOR-INT.C:385
1fcc  push   bp
1fcd  mov    bp,sp
1fcf  sub    sp,0x2
1fd2  push   si                                   ; si=p1
1fd3  push   di                                   ; di=i
                                  ; ---- KOR-INT.C:389
1fd4  mov    di,0x3                               ; di=i
1fd7  jmp    0x2042
                                  ; ---- KOR-INT.C:390
1fd9  mov    si,0x16                              ; si=p1
                                  ; ---- KOR-INT.C:391
1fdc  mov    WORD PTR [bp-0x2],0x16               ; p2
1fe1  jmp    0x2021
                                  ; ---- KOR-INT.C:392
1fe3  mov    bx,WORD PTR [bp-0x2]                 ; p2
1fe6  mov    cl,0x4
1fe8  shl    bx,cl
1fea  add    bx,0x18ba
1fee  mov    ax,ds
1ff0  mov    es,ax
1ff2  cmp    BYTE PTR es:[bx+di],0x60             ; di=i
1ff6  jbe    0x201e
1ff8  mov    bx,WORD PTR [bp-0x2]                 ; p2
1ffb  mov    cl,0x4
1ffd  shl    bx,cl
1fff  add    bx,0x18ba
2003  mov    ax,ds
2005  mov    es,ax
2007  mov    al,BYTE PTR es:[bx+di]               ; di=i
200a  mov    bx,si                                ; si=p1
200c  mov    cl,0x4
200e  shl    bx,cl
2010  add    bx,0x18ba
2014  push   ax
2015  mov    ax,ds
2017  mov    es,ax
2019  pop    ax
201a  mov    BYTE PTR es:[bx+di],al               ; di=i
201d  dec    si                                   ; si=p1
201e  dec    WORD PTR [bp-0x2]                    ; p2
2021  cmp    WORD PTR [bp-0x2],0x0                ; p2
2025  jne    0x1fe3
2027  jmp    0x203c
                                  ; ---- KOR-INT.C:394
2029  mov    bx,si                                ; si=p1
202b  mov    cl,0x4
202d  shl    bx,cl
202f  add    bx,0x18ba
2033  mov    ax,ds
2035  mov    es,ax
2037  mov    BYTE PTR es:[bx+di],0x0              ; di=i
                                  ; ---- KOR-INT.C:393
203b  dec    si                                   ; si=p1
203c  cmp    si,0x2                               ; si=p1
203f  jg     0x2029
2041  inc    di                                   ; di=i
2042  cmp    di,0xd                               ; di=i
2045  jl     0x1fd9
                                  ; ---- KOR-INT.C:396
2047  mov    WORD PTR [_flag],0x6
                                  ; ---- KOR-INT.C:397
204d  pop    di                                   ; di=i
204e  pop    si                                   ; si=p1
204f  mov    sp,bp
2051  pop    bp
2052  ret

; ---------------------------------------------------------------
_screen_up_check:   ; 0x2053..0x2094  locals: di=i, si=j
                                  ; ---- KOR-INT.C:404
2053  push   bp
2054  mov    bp,sp
2056  push   si                                   ; si=j
2057  push   di                                   ; di=i
                                  ; ---- KOR-INT.C:407
2058  mov    WORD PTR [_flag],0x50
                                  ; ---- KOR-INT.C:408
205e  mov    di,0x16                              ; di=i
2061  jmp    0x208b
                                  ; ---- KOR-INT.C:409
2063  mov    si,0x3                               ; si=j
2066  jmp    0x2085
                                  ; ---- KOR-INT.C:410
2068  mov    bx,di                                ; di=i
206a  mov    cl,0x4
206c  shl    bx,cl
206e  add    bx,0x18ba
2072  mov    ax,ds
2074  mov    es,ax
2076  cmp    BYTE PTR es:[bx+si],0x6f             ; si=j
207a  jne    0x2084
                                  ; ---- KOR-INT.C:411
207c  mov    WORD PTR [_flag],0x32
2082  jmp    0x2090
2084  inc    si                                   ; si=j
2085  cmp    si,0xd                               ; si=j
2088  jl     0x2068
208a  dec    di                                   ; di=i
208b  cmp    di,0x2                               ; di=i
208e  jg     0x2063
                                  ; ---- KOR-INT.C:414
2090  pop    di                                   ; di=i
2091  pop    si                                   ; si=j
2092  pop    bp
2093  ret

; ---------------------------------------------------------------
_run_option:   ; 0x2094..0x20f9  locals:
                                  ; ---- KOR-INT.C:422
2094  push   bp
2095  mov    bp,sp
                                  ; ---- KOR-INT.C:426
2097  mov    WORD PTR [_flag],0x6
                                  ; ---- KOR-INT.C:427
209d  cmp    WORD PTR [_timer_w],0x0
20a2  jne    0x20f7
                                  ; ---- KOR-INT.C:428
20a4  mov    al,[_point]
20a7  cbw
20a8  mov    bx,ax
20aa  shl    bx,1
20ac  mov    ax,WORD PTR [bx+0x4315]              ; bx+_option
20b0  dec    ax
20b1  cmp    ax,0x4
20b4  ja     0x20e2
20b6  mov    bx,ax
20b8  shl    bx,1
20ba  jmp    WORD PTR cs:[bx+0x20bf]              ; bx+_chr+0x11
20bf  dw case_0 -> 0x20c9
20c1  dw case_1 -> 0x20ce
20c3  dw case_2 -> 0x20d3
20c5  dw case_3 -> 0x20d8
20c7  dw case_4 -> 0x20dd
                                  ; ---- KOR-INT.C:429
20c9  call   _left_rotate
20cc  jmp    0x20e2
                                  ; ---- KOR-INT.C:430
20ce  call   _right_rotate
20d1  jmp    0x20e2
                                  ; ---- KOR-INT.C:431
20d3  call   _make_point
20d6  jmp    0x20e2
                                  ; ---- KOR-INT.C:432
20d8  call   _erase_point
20db  jmp    0x20e2
                                  ; ---- KOR-INT.C:433
20dd  call   _up_stage
20e0  jmp    0x20e2
                                  ; ---- KOR-INT.C:435
20e2  mov    al,[_point]
20e5  cbw
20e6  mov    bx,ax
20e8  shl    bx,1
20ea  mov    ax,WORD PTR [bx-0x6cff]
20ee  mov    [_timer_w],ax
                                  ; ---- KOR-INT.C:436
20f1  mov    WORD PTR [_flag],0x1e
                                  ; ---- KOR-INT.C:439
20f7  pop    bp
20f8  ret

; ---------------------------------------------------------------
_subtract_stick:   ; 0x20f9..0x216a  locals: si=i
                                  ; ---- KOR-INT.C:446
20f9  push   bp
20fa  mov    bp,sp
20fc  push   si                                   ; si=i
                                  ; ---- KOR-INT.C:450
20fd  mov    si,0x3                               ; si=i
2100  jmp    0x2134
                                  ; ---- KOR-INT.C:451
2102  mov    bx,WORD PTR [_sub_flag]
2106  mov    cl,0x4
2108  shl    bx,cl
210a  add    bx,0x18ba
210e  mov    ax,ds
2110  mov    es,ax
2112  cmp    BYTE PTR es:[bx+si],0x0              ; si=i
2116  je     0x211c
2118  mov    al,0x8c
211a  jmp    0x211e
211c  mov    al,0x8b
211e  mov    bx,WORD PTR [_sub_flag]
2122  mov    cl,0x4
2124  shl    bx,cl
2126  add    bx,0x18ba
212a  push   ax
212b  mov    ax,ds
212d  mov    es,ax
212f  pop    ax
2130  mov    BYTE PTR es:[bx+si],al               ; si=i
2133  inc    si                                   ; si=i
2134  cmp    si,0xd                               ; si=i
2137  jl     0x2102
                                  ; ---- KOR-INT.C:452
2139  inc    WORD PTR [_sub_flag]
213d  mov    ax,[_sub_flag]
2140  cmp    ax,0x18
2143  jne    0x2167
                                  ; ---- KOR-INT.C:453
2145  mov    ax,0x12
2148  push   ax
2149  call   _sec_wait
214c  inc    sp
214d  inc    sp
                                  ; ---- KOR-INT.C:454
214e  mov    WORD PTR [_flag],0x3
                                  ; ---- KOR-INT.C:455
2154  cmp    WORD PTR [_life],0x0
2159  je     0x2161
215b  dec    WORD PTR [_life]
215f  jmp    0x2167
                                  ; ---- KOR-INT.C:456
2161  mov    WORD PTR [_flag],0x42
                                  ; ---- KOR-INT.C:458
2167  pop    si                                   ; si=i
2168  pop    bp
2169  ret

; ---------------------------------------------------------------
_game_over:   ; 0x216a..0x21cb  locals: di=i, si=j
                                  ; ---- KOR-INT.C:465
216a  push   bp
216b  mov    bp,sp
216d  push   si                                   ; si=j
216e  push   di                                   ; di=i
                                  ; ---- KOR-INT.C:469
216f  call   _nosound
                                  ; ---- KOR-INT.C:470
2172  mov    di,0x16                              ; di=i
2175  jmp    0x21b3
                                  ; ---- KOR-INT.C:471
2177  mov    WORD PTR [_locx],0xb
                                  ; ---- KOR-INT.C:472
217d  mov    WORD PTR [_locy],di                  ; di=i
                                  ; ---- KOR-INT.C:473
2181  call   _put_stage
                                  ; ---- KOR-INT.C:474
2184  push   ds
2185  mov    ax,0xb00                             ; "GAME  OVER"
2188  push   ax
2189  call   _lprint
218c  add    sp,0x4
                                  ; ---- KOR-INT.C:475
218f  xor    si,si                                ; si=j
2191  jmp    0x21a4
                                  ; ---- KOR-INT.C:476
2193  mov    ax,di                                ; di=i
2195  mov    dx,0xa
2198  mul    dx
219a  mov    bx,ax
219c  add    bx,si                                ; si=j
219e  mov    BYTE PTR [bx-0x6df3],0xff
21a3  inc    si                                   ; si=j
21a4  cmp    si,0xa                               ; si=j
21a7  jl     0x2193
                                  ; ---- KOR-INT.C:477
21a9  mov    ax,0x2
21ac  push   ax
21ad  call   _sec_wait
21b0  inc    sp
21b1  inc    sp
21b2  dec    di                                   ; di=i
21b3  cmp    di,0x8                               ; di=i
21b6  jg     0x2177
                                  ; ---- KOR-INT.C:479
21b8  mov    ax,0x24
21bb  push   ax
21bc  call   _sec_wait
21bf  inc    sp
21c0  inc    sp
                                  ; ---- KOR-INT.C:480
21c1  mov    WORD PTR [_flag],0x64
                                  ; ---- KOR-INT.C:481
21c7  pop    di                                   ; di=i
21c8  pop    si                                   ; si=j
21c9  pop    bp
21ca  ret

; ---------------------------------------------------------------
_screen_clear_up:   ; 0x21cb..0x2322  locals: bp-2=t, di=i, si=j
                                  ; ---- KOR-INT.C:488
21cb  push   bp
21cc  mov    bp,sp
21ce  sub    sp,0x2
21d1  push   si                                   ; si=j
21d2  push   di                                   ; di=i
                                  ; ---- KOR-INT.C:492
21d3  inc    BYTE PTR [_point]
                                  ; ---- KOR-INT.C:493
21d7  call   _nosound
                                  ; ---- KOR-INT.C:494
21da  call   _clock_wait
                                  ; ---- KOR-INT.C:496
21dd  mov    WORD PTR [_locx],0xb
                                  ; ---- KOR-INT.C:497
21e3  mov    WORD PTR [_locy],0x7
                                  ; ---- KOR-INT.C:498
21e9  push   ds
21ea  mov    ax,0xb0b                             ; "  CLEAR.  "
21ed  push   ax
21ee  call   _lprint
21f1  add    sp,0x4
                                  ; ---- KOR-INT.C:499
21f4  mov    WORD PTR [_locx],0xb
                                  ; ---- KOR-INT.C:500
21fa  mov    WORD PTR [_locy],0x9
                                  ; ---- KOR-INT.C:502
2200  mov    WORD PTR [bp-0x2],0xa                ; t
                                  ; ---- KOR-INT.C:503
2205  cmp    WORD PTR [_bonus_w],0x12c
220b  jle    0x221a
220d  push   ds
220e  mov    ax,0xb16                             ; "VERY GOOD."
2211  push   ax
2212  call   _lprint
2215  add    sp,0x4
2218  jmp    0x2276
                                  ; ---- KOR-INT.C:504
221a  cmp    WORD PTR [_bonus_w],0xc8
2220  jle    0x2234
2222  push   ds
2223  mov    ax,0xb21                             ; "   GOOD.  "
2226  push   ax
2227  call   _lprint
222a  add    sp,0x4
222d  mov    WORD PTR [bp-0x2],0x14               ; t
2232  jmp    0x2276
                                  ; ---- KOR-INT.C:505
2234  cmp    WORD PTR [_bonus_w],0x64
2239  jle    0x224d
223b  push   ds
223c  mov    ax,0xb2c                             ; "   NICE.  "
223f  push   ax
2240  call   _lprint
2243  add    sp,0x4
2246  mov    WORD PTR [bp-0x2],0x1e               ; t
224b  jmp    0x2276
                                  ; ---- KOR-INT.C:506
224d  cmp    WORD PTR [_bonus_w],0x0
2252  je     0x2266
2254  push   ds
2255  mov    ax,0xb37                             ; "   FINE.  "
2258  push   ax
2259  call   _lprint
225c  add    sp,0x4
225f  mov    WORD PTR [bp-0x2],0x28               ; t
2264  jmp    0x2276
                                  ; ---- KOR-INT.C:507
2266  push   ds
2267  mov    ax,0xb42                             ; " NO BONUS."
226a  push   ax
226b  call   _lprint
226e  add    sp,0x4
2271  mov    WORD PTR [bp-0x2],0x32               ; t
                                  ; ---- KOR-INT.C:508
2276  push   WORD PTR [bp-0x2]                    ; t
2279  call   _sec_wait
227c  inc    sp
227d  inc    sp
                                  ; ---- KOR-INT.C:510
227e  mov    ax,[_bonus_w]
2281  mov    bx,0xa
2284  cwd
2285  idiv   bx
2287  mov    ax,dx
2289  cwd
228a  add    WORD PTR [_score],ax
228e  adc    WORD PTR [_score+0x2],dx
                                  ; ---- KOR-INT.C:511
2292  mov    ax,[_bonus_w]
2295  mov    bx,0xa
2298  cwd
2299  idiv   bx
229b  sub    WORD PTR [_bonus_w],dx
229f  jmp    0x22cd
                                  ; ---- KOR-INT.C:514
22a1  call   _put_bonus
                                  ; ---- KOR-INT.C:515
22a4  call   _put_score
                                  ; ---- KOR-INT.C:516
22a7  mov    ax,0xc8
22aa  push   ax
22ab  call   _sound
22ae  inc    sp
22af  inc    sp
                                  ; ---- KOR-INT.C:517
22b0  call   _clock_wait
                                  ; ---- KOR-INT.C:518
22b3  mov    al,[_point]
22b6  cbw
22b7  mov    dx,0xa
22ba  mul    dx
22bc  cwd
22bd  add    WORD PTR [_score],ax
22c1  adc    WORD PTR [_score+0x2],dx
                                  ; ---- KOR-INT.C:519
22c5  sub    WORD PTR [_bonus_w],0xa
                                  ; ---- KOR-INT.C:520
22ca  call   _nosound
                                  ; ---- KOR-INT.C:513
22cd  cmp    WORD PTR [_bonus_w],0x0
22d2  jne    0x22a1
                                  ; ---- KOR-INT.C:523
22d4  mov    WORD PTR [_flag],0x53
                                  ; ---- KOR-INT.C:524
22da  mov    WORD PTR [_sub_flag],0x18
                                  ; ---- KOR-INT.C:525
22e0  mov    di,0x3                               ; di=i
22e3  jmp    0x2317
                                  ; ---- KOR-INT.C:526
22e5  mov    si,0x3                               ; si=j
22e8  jmp    0x2311
                                  ; ---- KOR-INT.C:527
22ea  mov    bx,di                                ; di=i
22ec  mov    cl,0x4
22ee  shl    bx,cl
22f0  add    bx,0x18ba
22f4  mov    ax,ds
22f6  mov    es,ax
22f8  cmp    BYTE PTR es:[bx+si],0x0              ; si=j
22fc  je     0x2310
22fe  mov    bx,di                                ; di=i
2300  mov    cl,0x4
2302  shl    bx,cl
2304  add    bx,0x18ba
2308  mov    ax,ds
230a  mov    es,ax
230c  mov    BYTE PTR es:[bx+si],0xf5             ; si=j
2310  inc    si                                   ; si=j
2311  cmp    si,0xd                               ; si=j
2314  jl     0x22ea
2316  inc    di                                   ; di=i
2317  cmp    di,0x17                              ; di=i
231a  jl     0x22e5
                                  ; ---- KOR-INT.C:529
231c  pop    di                                   ; di=i
231d  pop    si                                   ; si=j
231e  mov    sp,bp
2320  pop    bp
2321  ret

; ---------------------------------------------------------------
_screen_up_sub:   ; 0x2322..0x239a  locals: di=i, si=j
                                  ; ---- KOR-INT.C:537
2322  push   bp
2323  mov    bp,sp
2325  push   si                                   ; si=j
2326  push   di                                   ; di=i
                                  ; ---- KOR-INT.C:541
2327  mov    di,0x3                               ; di=i
232a  jmp    0x2364
                                  ; ---- KOR-INT.C:542
232c  mov    si,0x3                               ; si=j
232f  jmp    0x235e
                                  ; ---- KOR-INT.C:543
2331  mov    bx,di                                ; di=i
2333  mov    cl,0x4
2335  shl    bx,cl
2337  add    bx,0x18ba
233b  mov    ax,ds
233d  mov    es,ax
233f  cmp    BYTE PTR es:[bx+si],0x0              ; si=j
2343  je     0x235d
2345  mov    al,[_sub_flag]
2348  add    al,0xdd
234a  mov    bx,di                                ; di=i
234c  mov    cl,0x4
234e  shl    bx,cl
2350  add    bx,0x18ba
2354  push   ax
2355  mov    ax,ds
2357  mov    es,ax
2359  pop    ax
235a  mov    BYTE PTR es:[bx+si],al               ; si=j
235d  inc    si                                   ; si=j
235e  cmp    si,0xd                               ; si=j
2361  jl     0x2331
2363  inc    di                                   ; di=i
2364  cmp    di,0x17                              ; di=i
2367  jl     0x232c
                                  ; ---- KOR-INT.C:544
2369  mov    ax,[_sub_flag]
236c  add    ax,0xffe8
236f  mov    cl,0x9
2371  shl    ax,cl
2373  mov    dx,0x1770                            ; &__stdoutStarted+0x96?
2376  sub    dx,ax
2378  push   dx
2379  call   _sound
237c  inc    sp
237d  inc    sp
                                  ; ---- KOR-INT.C:545
237e  inc    WORD PTR [_sub_flag]
2382  mov    ax,[_sub_flag]
2385  cmp    ax,0x20
2388  jne    0x2396
                                  ; ---- KOR-INT.C:546
238a  mov    WORD PTR [_flag],0x3
                                  ; ---- KOR-INT.C:547
2390  call   _nosound
                                  ; ---- KOR-INT.C:548
2393  call   _next_stage_put
                                  ; ---- KOR-INT.C:551
2396  pop    di                                   ; di=i
2397  pop    si                                   ; si=j
2398  pop    bp
2399  ret

;======================================================================
; MODULE KOR-SUB.C
;======================================================================

; ---------------------------------------------------------------
_stage_load:   ; 0x239a..0x24b7  locals: bp-204=buf, bp-244=name, bp-246=fdi, bp-248=j, bp-4=p, di=i, si=k
                                  ; ---- KOR-SUB.C:56
239a  push   bp
239b  mov    bp,sp
239d  sub    sp,0xf8
23a1  push   si                                   ; si=k
23a2  push   di                                   ; di=i
23a3  push   ss
23a4  lea    ax,[bp-0xf4]                         ; name
23a8  push   ax
23a9  push   ds
23aa  mov    ax,0xb4e                             ; "korea.stg"
23ad  push   ax
23ae  mov    cx,0x28
23b1  call   0x0:0x5a94
                                  ; ---- KOR-SUB.C:61
23b6  mov    ax,0x8001                            ; &_screen+0x3c24?
23b9  push   ax
23ba  push   ss
23bb  lea    ax,[bp-0xf4]                         ; name
23bf  push   ax
23c0  call   _open
23c3  add    sp,0x6
23c6  mov    WORD PTR [bp-0xf6],ax                ; fdi
23ca  cmp    ax,0xffff
23cd  jne    0x23d5
                                  ; ---- KOR-SUB.C:62
23cf  mov    ax,0xffff
23d2  jmp    0x24b1
                                  ; ---- KOR-SUB.C:64
23d5  xor    di,di                                ; di=i
23d7  jmp    0x2499
                                  ; ---- KOR-SUB.C:65
23da  mov    ax,0xc8
23dd  push   ax
23de  push   ss
23df  lea    ax,[bp-0xcc]                         ; buf
23e3  push   ax
23e4  push   WORD PTR [bp-0xf6]                   ; fdi
23e8  call   _read
23eb  add    sp,0x8
                                  ; ---- KOR-SUB.C:66
23ee  mov    bx,ss
23f0  mov    es,bx
23f2  lea    bx,[bp-0xcc]                         ; buf
23f6  mov    WORD PTR [bp-0x2],es
23f9  mov    WORD PTR [bp-0x4],bx                 ; p
                                  ; ---- KOR-SUB.C:67
23fc  mov    WORD PTR [bp-0xf8],0x0               ; j
2402  jmp    0x243c
                                  ; ---- KOR-SUB.C:68
2404  xor    si,si                                ; si=k
2406  jmp    0x2433
                                  ; ---- KOR-SUB.C:69
2408  les    bx,DWORD PTR [bp-0x4]                ; p
240b  mov    al,BYTE PTR es:[bx]
240e  push   ax
240f  mov    ax,di                                ; di=i
2411  mov    dx,0xc8
2414  mul    dx
2416  mov    bx,ax
2418  add    bx,0x43dd
241c  mov    ax,ds
241e  mov    es,ax
2420  mov    ax,WORD PTR [bp-0xf8]                ; j
2424  mov    dx,0xa
2427  mul    dx
2429  add    bx,ax
242b  pop    ax
242c  mov    BYTE PTR es:[bx+si],al               ; si=k
242f  inc    WORD PTR [bp-0x4]                    ; p
2432  inc    si                                   ; si=k
2433  cmp    si,0xa                               ; si=k
2436  jl     0x2408
2438  inc    WORD PTR [bp-0xf8]                   ; j
243c  cmp    WORD PTR [bp-0xf8],0x14              ; j
2441  jl     0x2404
                                  ; ---- KOR-SUB.C:70
2443  mov    ax,0x5
2446  push   ax
2447  push   ss
2448  lea    ax,[bp-0xcc]                         ; buf
244c  push   ax
244d  push   WORD PTR [bp-0xf6]                   ; fdi
2451  call   _read
2454  add    sp,0x8
                                  ; ---- KOR-SUB.C:71
2457  mov    al,BYTE PTR [bp-0xcc]                ; buf
245b  cbw
245c  mov    bx,di                                ; di=i
245e  shl    bx,1
2460  mov    WORD PTR [bx+0x40ae],ax              ; bx+_speed
                                  ; ---- KOR-SUB.C:72
2464  mov    al,BYTE PTR [bp-0xcb]
2468  cbw
2469  mov    bx,di                                ; di=i
246b  shl    bx,1
246d  mov    WORD PTR [bx+0x424c],ax              ; bx+_power
                                  ; ---- KOR-SUB.C:73
2471  mov    al,BYTE PTR [bp-0xca]
2475  cbw
2476  mov    bx,di                                ; di=i
2478  shl    bx,1
247a  mov    WORD PTR [bx+0x4315],ax              ; bx+_option
                                  ; ---- KOR-SUB.C:74
247e  mov    al,BYTE PTR [bp-0xc9]
2482  cbw
2483  mov    bx,di                                ; di=i
2485  shl    bx,1
2487  mov    WORD PTR [bx+0x417e],ax              ; bx+_bonus
                                  ; ---- KOR-SUB.C:75
248b  mov    al,BYTE PTR [bp-0xc8]
248f  cbw
2490  mov    bx,di                                ; di=i
2492  shl    bx,1
2494  mov    WORD PTR [bx-0x6cff],ax
2498  inc    di                                   ; di=i
2499  cmp    di,0x64                              ; di=i
249c  jge    0x24a1
249e  jmp    0x23da
                                  ; ---- KOR-SUB.C:77
24a1  push   WORD PTR [bp-0xf6]                   ; fdi
24a5  call   _close
24a8  inc    sp
24a9  inc    sp
                                  ; ---- KOR-SUB.C:78
24aa  call   _screen_to_stage
                                  ; ---- KOR-SUB.C:79
24ad  xor    ax,ax
24af  jmp    0x24b1
                                  ; ---- KOR-SUB.C:80
24b1  pop    di                                   ; di=i
24b2  pop    si                                   ; si=k
24b3  mov    sp,bp
24b5  pop    bp
24b6  ret

; ---------------------------------------------------------------
_user_stage_save:   ; 0x24b7..0x25cd  locals: bp-204=buf, bp-244=name, bp-246=fdo, bp-248=j, bp-4=p, di=i, si=k
                                  ; ---- KOR-SUB.C:83
24b7  push   bp
24b8  mov    bp,sp
24ba  sub    sp,0xf8
24be  push   si                                   ; si=k
24bf  push   di                                   ; di=i
24c0  push   ss
24c1  lea    ax,[bp-0xf4]                         ; name
24c5  push   ax
24c6  push   ds
24c7  mov    ax,0xb76                             ; "korea.stg"
24ca  push   ax
24cb  mov    cx,0x28
24ce  call   0x0:0x5a94
                                  ; ---- KOR-SUB.C:88
24d3  mov    ax,0x180                             ; &_play+0xec?
24d6  push   ax
24d7  mov    ax,0x8104                            ; &_screen+0x3d27?
24da  push   ax
24db  push   ss
24dc  lea    ax,[bp-0xf4]                         ; name
24e0  push   ax
24e1  call   _open
24e4  add    sp,0x8
24e7  mov    WORD PTR [bp-0xf6],ax                ; fdo
24eb  cmp    ax,0xffff
24ee  jne    0x24f6
                                  ; ---- KOR-SUB.C:89
24f0  mov    ax,0xffff
24f3  jmp    0x25c7
                                  ; ---- KOR-SUB.C:91
24f6  call   _stage_to_screen
                                  ; ---- KOR-SUB.C:92
24f9  xor    di,di                                ; di=i
24fb  jmp    0x25b6
                                  ; ---- KOR-SUB.C:93
24fe  mov    bx,ss
2500  mov    es,bx
2502  lea    bx,[bp-0xcc]                         ; buf
2506  mov    WORD PTR [bp-0x2],es
2509  mov    WORD PTR [bp-0x4],bx                 ; p
                                  ; ---- KOR-SUB.C:94
250c  mov    WORD PTR [bp-0xf8],0x0               ; j
2512  jmp    0x254a
                                  ; ---- KOR-SUB.C:95
2514  xor    si,si                                ; si=k
2516  jmp    0x2541
                                  ; ---- KOR-SUB.C:96
2518  mov    ax,di                                ; di=i
251a  mov    dx,0xc8
251d  mul    dx
251f  mov    bx,ax
2521  add    bx,0x43dd
2525  mov    ax,ds
2527  mov    es,ax
2529  mov    ax,WORD PTR [bp-0xf8]                ; j
252d  mov    dx,0xa
2530  mul    dx
2532  add    bx,ax
2534  mov    al,BYTE PTR es:[bx+si]               ; si=k
2537  les    bx,DWORD PTR [bp-0x4]                ; p
253a  mov    BYTE PTR es:[bx],al
253d  inc    WORD PTR [bp-0x4]                    ; p
2540  inc    si                                   ; si=k
2541  cmp    si,0xa                               ; si=k
2544  jl     0x2518
2546  inc    WORD PTR [bp-0xf8]                   ; j
254a  cmp    WORD PTR [bp-0xf8],0x14              ; j
254f  jl     0x2514
                                  ; ---- KOR-SUB.C:97
2551  mov    ax,0xc8
2554  push   ax
2555  push   ss
2556  lea    ax,[bp-0xcc]                         ; buf
255a  push   ax
255b  push   WORD PTR [bp-0xf6]                   ; fdo
255f  call   _write
2562  add    sp,0x8
                                  ; ---- KOR-SUB.C:98
2565  mov    bx,di                                ; di=i
2567  shl    bx,1
2569  mov    al,BYTE PTR [bx+0x40ae]              ; bx+_speed
256d  mov    BYTE PTR [bp-0xcc],al                ; buf
                                  ; ---- KOR-SUB.C:99
2571  mov    bx,di                                ; di=i
2573  shl    bx,1
2575  mov    al,BYTE PTR [bx+0x424c]              ; bx+_power
2579  mov    BYTE PTR [bp-0xcb],al
                                  ; ---- KOR-SUB.C:100
257d  mov    bx,di                                ; di=i
257f  shl    bx,1
2581  mov    al,BYTE PTR [bx+0x4315]              ; bx+_option
2585  mov    BYTE PTR [bp-0xca],al
                                  ; ---- KOR-SUB.C:101
2589  mov    bx,di                                ; di=i
258b  shl    bx,1
258d  mov    al,BYTE PTR [bx+0x417e]              ; bx+_bonus
2591  mov    BYTE PTR [bp-0xc9],al
                                  ; ---- KOR-SUB.C:102
2595  mov    bx,di                                ; di=i
2597  shl    bx,1
2599  mov    al,BYTE PTR [bx-0x6cff]
259d  mov    BYTE PTR [bp-0xc8],al
                                  ; ---- KOR-SUB.C:103
25a1  mov    ax,0x5
25a4  push   ax
25a5  push   ss
25a6  lea    ax,[bp-0xcc]                         ; buf
25aa  push   ax
25ab  push   WORD PTR [bp-0xf6]                   ; fdo
25af  call   _write
25b2  add    sp,0x8
25b5  inc    di                                   ; di=i
25b6  cmp    di,0x64                              ; di=i
25b9  jge    0x25be
25bb  jmp    0x24fe
                                  ; ---- KOR-SUB.C:105
25be  push   WORD PTR [bp-0xf6]                   ; fdo
25c2  call   _close
25c5  inc    sp
25c6  inc    sp
                                  ; ---- KOR-SUB.C:106
25c7  pop    di                                   ; di=i
25c8  pop    si                                   ; si=k
25c9  mov    sp,bp
25cb  pop    bp
25cc  ret

; ---------------------------------------------------------------
_title:   ; 0x25cd..0x26ed  locals:
                                  ; ---- KOR-SUB.C:110
25cd  push   bp
25ce  mov    bp,sp
                                  ; ---- KOR-SUB.C:112
25d0  xor    ax,ax
25d2  mov    [_locy],ax
25d5  mov    [_locx],ax
                                  ; ---- KOR-SUB.C:114
25d8  push   ds
25d9  mov    ax,0xbe0                             ; "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
25dc  push   ax
25dd  call   _lprint
25e0  add    sp,0x4
                                  ; ---- KOR-SUB.C:115
25e3  push   ds
25e4  mov    ax,0xc09                             ; "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
25e7  push   ax
25e8  call   _lprint
25eb  add    sp,0x4
                                  ; ---- KOR-SUB.C:116
25ee  push   ds
25ef  mov    ax,0xc32                             ; "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
25f2  push   ax
25f3  call   _lprint
25f6  add    sp,0x4
                                  ; ---- KOR-SUB.C:117
25f9  push   ds
25fa  mov    ax,0xc5b                             ; &op_msg+0xbd?
25fd  push   ax
25fe  call   _lprint
2601  add    sp,0x4
                                  ; ---- KOR-SUB.C:118
2604  push   ds
2605  mov    ax,0xc84                             ; &op_msg+0xe6?
2608  push   ax
2609  call   _lprint
260c  add    sp,0x4
                                  ; ---- KOR-SUB.C:119
260f  push   ds
2610  mov    ax,0xcad                             ; &op_msg+0x10f?
2613  push   ax
2614  call   _lprint
2617  add    sp,0x4
                                  ; ---- KOR-SUB.C:120
261a  push   ds
261b  mov    ax,0xcd6                             ; &op_msg+0x138?
261e  push   ax
261f  call   _lprint
2622  add    sp,0x4
                                  ; ---- KOR-SUB.C:121
2625  push   ds
2626  mov    ax,0xcff                             ; &op_msg+0x161?
2629  push   ax
262a  call   _lprint
262d  add    sp,0x4
                                  ; ---- KOR-SUB.C:122
2630  push   ds
2631  mov    ax,0xd28                             ; &op_msg+0x18a?
2634  push   ax
2635  call   _lprint
2638  add    sp,0x4
                                  ; ---- KOR-SUB.C:123
263b  push   ds
263c  mov    ax,0xd51                             ; &op_msg+0x1b3?
263f  push   ax
2640  call   _lprint
2643  add    sp,0x4
                                  ; ---- KOR-SUB.C:124
2646  push   ds
2647  mov    ax,0xd7a                             ; &op_msg+0x1dc?
264a  push   ax
264b  call   _lprint
264e  add    sp,0x4
                                  ; ---- KOR-SUB.C:125
2651  push   ds
2652  mov    ax,0xda3                             ; &op_msg+0x205?
2655  push   ax
2656  call   _lprint
2659  add    sp,0x4
                                  ; ---- KOR-SUB.C:126
265c  push   ds
265d  mov    ax,0xdcc                             ; &op_msg+0x22e?
2660  push   ax
2661  call   _lprint
2664  add    sp,0x4
                                  ; ---- KOR-SUB.C:127
2667  push   ds
2668  mov    ax,0xdf5                             ; &op_msg+0x257?
266b  push   ax
266c  call   _lprint
266f  add    sp,0x4
                                  ; ---- KOR-SUB.C:128
2672  push   ds
2673  mov    ax,0xe1e                             ; &op_msg+0x280?
2676  push   ax
2677  call   _lprint
267a  add    sp,0x4
                                  ; ---- KOR-SUB.C:129
267d  push   ds
267e  mov    ax,0xe47                             ; &op_msg+0x2a9?
2681  push   ax
2682  call   _lprint
2685  add    sp,0x4
                                  ; ---- KOR-SUB.C:130
2688  push   ds
2689  mov    ax,0xe70                             ; &op_msg+0x2d2?
268c  push   ax
268d  call   _lprint
2690  add    sp,0x4
                                  ; ---- KOR-SUB.C:131
2693  push   ds
2694  mov    ax,0xe99                             ; &op_msg+0x2fb?
2697  push   ax
2698  call   _lprint
269b  add    sp,0x4
                                  ; ---- KOR-SUB.C:132
269e  push   ds
269f  mov    ax,0xec2                             ; &op_msg+0x324?
26a2  push   ax
26a3  call   _lprint
26a6  add    sp,0x4
                                  ; ---- KOR-SUB.C:133
26a9  push   ds
26aa  mov    ax,0xeeb                             ; &op_msg+0x34d?
26ad  push   ax
26ae  call   _lprint
26b1  add    sp,0x4
                                  ; ---- KOR-SUB.C:134
26b4  push   ds
26b5  mov    ax,0xf14                             ; &op_msg+0x376?
26b8  push   ax
26b9  call   _lprint
26bc  add    sp,0x4
                                  ; ---- KOR-SUB.C:135
26bf  push   ds
26c0  mov    ax,0xf3d                             ; &op_msg+0x39f?
26c3  push   ax
26c4  call   _lprint
26c7  add    sp,0x4
                                  ; ---- KOR-SUB.C:136
26ca  push   ds
26cb  mov    ax,0xf66                             ; &op_msg+0x3c8?
26ce  push   ax
26cf  call   _lprint
26d2  add    sp,0x4
                                  ; ---- KOR-SUB.C:137
26d5  push   ds
26d6  mov    ax,0xf8f                             ; &op_msg+0x3f1?
26d9  push   ax
26da  call   _lprint
26dd  add    sp,0x4
                                  ; ---- KOR-SUB.C:138
26e0  push   ds
26e1  mov    ax,0xfb8                             ; "{|||||}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
26e4  push   ax
26e5  call   _lprint
26e8  add    sp,0x4
                                  ; ---- KOR-SUB.C:139
26eb  pop    bp
26ec  ret

; ---------------------------------------------------------------
_inkey:   ; 0x26ed..0x2727  locals: bp+4=k, bp-2=hi, di=lo, si=key
                                  ; ---- KOR-SUB.C:142
26ed  push   bp
26ee  mov    bp,sp
26f0  sub    sp,0x2
26f3  push   si                                   ; si=key
26f4  push   di                                   ; di=lo
                                  ; ---- KOR-SUB.C:144
26f5  push   WORD PTR [bp+0x4]                    ; k
26f8  call   _bioskey
26fb  inc    sp
26fc  inc    sp
26fd  mov    si,ax                                ; si=key
                                  ; ---- KOR-SUB.C:145
26ff  mov    di,si                                ; si=key | di=lo
2701  and    di,0xff                              ; di=lo
                                  ; ---- KOR-SUB.C:146
2705  mov    ax,si                                ; si=key
2707  and    ax,0xff00
270a  mov    cl,0x8
270c  shr    ax,cl
270e  mov    WORD PTR [bp-0x2],ax                 ; hi
                                  ; ---- KOR-SUB.C:147
2711  or     di,di                                ; di=lo
2713  je     0x2719
2715  mov    ax,di                                ; di=lo
2717  jmp    0x271f
2719  mov    ax,WORD PTR [bp-0x2]                 ; hi
271c  add    ax,0x100
271f  jmp    0x2721
                                  ; ---- KOR-SUB.C:148
2721  pop    di                                   ; di=lo
2722  pop    si                                   ; si=key
2723  mov    sp,bp
2725  pop    bp
2726  ret

; ---------------------------------------------------------------
_key_scan_init:   ; 0x2727..0x2754  locals: bp-4=e, bp-8=s
                                  ; ---- KOR-SUB.C:151
2727  push   bp
2728  mov    bp,sp
272a  sub    sp,0x8
                                  ; ---- KOR-SUB.C:154
272d  mov    WORD PTR [bp-0x6],0x40
2732  mov    WORD PTR [bp-0x8],0x1a               ; s
                                  ; ---- KOR-SUB.C:155
2737  mov    WORD PTR [bp-0x2],0x40
273c  mov    WORD PTR [bp-0x4],0x1c               ; e
                                  ; ---- KOR-SUB.C:156
2741  mov    ax,0x30
2744  les    bx,DWORD PTR [bp-0x4]                ; e
2747  mov    WORD PTR es:[bx],ax
274a  les    bx,DWORD PTR [bp-0x8]                ; s
274d  mov    WORD PTR es:[bx],ax
                                  ; ---- KOR-SUB.C:157
2750  mov    sp,bp
2752  pop    bp
2753  ret

; ---------------------------------------------------------------
_key_scan:   ; 0x2754..0x27a6  locals: bp-12=s, bp-4=p, bp-8=e
                                  ; ---- KOR-SUB.C:160
2754  push   bp
2755  mov    bp,sp
2757  sub    sp,0xc
                                  ; ---- KOR-SUB.C:164
275a  mov    WORD PTR [bp-0xa],0x40
275f  mov    WORD PTR [bp-0xc],0x1a               ; s
                                  ; ---- KOR-SUB.C:165
2764  mov    WORD PTR [bp-0x6],0x40
2769  mov    WORD PTR [bp-0x8],0x1c               ; e
                                  ; ---- KOR-SUB.C:166
276e  mov    WORD PTR [bp-0x2],0x40
2773  mov    WORD PTR [bp-0x4],0x31               ; p
                                  ; ---- KOR-SUB.C:167
2778  les    bx,DWORD PTR [bp-0xc]                ; s
277b  mov    ax,WORD PTR es:[bx]
277e  les    bx,DWORD PTR [bp-0x8]                ; e
2781  cmp    ax,WORD PTR es:[bx]
2784  jne    0x278a
2786  xor    ax,ax
2788  jmp    0x27a2
                                  ; ---- KOR-SUB.C:168
278a  mov    ax,0x30
278d  les    bx,DWORD PTR [bp-0x8]                ; e
2790  mov    WORD PTR es:[bx],ax
2793  les    bx,DWORD PTR [bp-0xc]                ; s
2796  mov    WORD PTR es:[bx],ax
                                  ; ---- KOR-SUB.C:169
2799  les    bx,DWORD PTR [bp-0x4]                ; p
279c  mov    al,BYTE PTR es:[bx]
279f  cbw
27a0  jmp    0x27a2
                                  ; ---- KOR-SUB.C:170
27a2  mov    sp,bp
27a4  pop    bp
27a5  ret

; ---------------------------------------------------------------
_clock_wait:   ; 0x27a6..0x27e2  locals: bp-4=tma, si=tm
                                  ; ---- KOR-SUB.C:174
27a6  push   bp
27a7  mov    bp,sp
27a9  sub    sp,0x4
27ac  push   si                                   ; si=tm
                                  ; ---- KOR-SUB.C:177
27ad  mov    WORD PTR [bp-0x2],0x0
27b2  mov    WORD PTR [bp-0x4],0x46c              ; tma
                                  ; ---- KOR-SUB.C:178
27b7  les    bx,DWORD PTR [bp-0x4]                ; tma
27ba  mov    si,WORD PTR es:[bx]                  ; si=tm
                                  ; ---- KOR-SUB.C:179
27bd  jmp    0x27bf
27bf  les    bx,DWORD PTR [bp-0x4]                ; tma
27c2  mov    ax,WORD PTR es:[bx]
27c5  cmp    ax,si                                ; si=tm
27c7  je     0x27bf
                                  ; ---- KOR-SUB.C:180
27c9  mov    ax,[_simul]
27cc  mov    bx,0x7f
27cf  cwd
27d0  idiv   bx
27d2  mov    WORD PTR [_simul],dx
27d6  inc    WORD PTR [_simul]
                                  ; ---- KOR-SUB.C:181
27da  call   _music_play
                                  ; ---- KOR-SUB.C:183
27dd  pop    si                                   ; si=tm
27de  mov    sp,bp
27e0  pop    bp
27e1  ret

; ---------------------------------------------------------------
_sec_wait:   ; 0x27e2..0x27f8  locals: bp+4=i, si=i
                                  ; ---- KOR-SUB.C:185
27e2  push   bp
27e3  mov    bp,sp
27e5  push   si                                   ; si=i
27e6  mov    si,WORD PTR [bp+0x4]                 ; i | si=i
27e9  jmp    0x27ee
                                  ; ---- KOR-SUB.C:188
27eb  call   _clock_wait
                                  ; ---- KOR-SUB.C:187
27ee  mov    ax,si                                ; si=i
27f0  dec    si                                   ; si=i
27f1  or     ax,ax
27f3  jne    0x27eb
                                  ; ---- KOR-SUB.C:189
27f5  pop    si                                   ; si=i
27f6  pop    bp
27f7  ret

; ---------------------------------------------------------------
_put_stage:   ; 0x27f8..0x28b4  locals: bp-1=xx, bp-10=stage_adrs, bp-2=yy, bp-6=chk_stage_adrs
                                  ; ---- KOR-SUB.C:192
27f8  push   bp
27f9  mov    bp,sp
27fb  sub    sp,0xa
                                  ; ---- KOR-SUB.C:195
27fe  mov    WORD PTR [bp-0x4],ds
2801  mov    WORD PTR [bp-0x6],0x922b             ; chk_stage_adrs
                                  ; ---- KOR-SUB.C:198
2806  mov    BYTE PTR [bp-0x2],0x3                ; yy
280a  jmp    0x28a7
                                  ; ---- KOR-SUB.C:199
280d  mov    al,BYTE PTR [bp-0x2]                 ; yy
2810  cbw
2811  mov    bx,ax
2813  mov    cl,0x4
2815  shl    bx,cl
2817  add    bx,0x18ba
281b  mov    ax,ds
281d  mov    es,ax
281f  add    bx,0x3
2822  mov    WORD PTR [bp-0x8],es
2825  mov    WORD PTR [bp-0xa],bx                 ; stage_adrs
                                  ; ---- KOR-SUB.C:200
2828  mov    BYTE PTR [bp-0x1],0xb                ; xx
282c  jmp    0x289e
                                  ; ---- KOR-SUB.C:201
282e  les    bx,DWORD PTR [bp-0xa]                ; stage_adrs
2831  mov    al,BYTE PTR es:[bx]
2834  les    bx,DWORD PTR [bp-0x6]                ; chk_stage_adrs
2837  cmp    al,BYTE PTR es:[bx]
283a  je     0x2869
                                  ; ---- KOR-SUB.C:202
283c  les    bx,DWORD PTR [bp-0xa]                ; stage_adrs
283f  mov    al,BYTE PTR es:[bx]
2842  les    bx,DWORD PTR [bp-0x6]                ; chk_stage_adrs
2845  mov    BYTE PTR es:[bx],al
                                  ; ---- KOR-SUB.C:203
2848  push   ds
2849  les    bx,DWORD PTR [bp-0xa]                ; stage_adrs
284c  mov    al,BYTE PTR es:[bx]
284f  mov    ah,0x0
2851  mov    cl,0x5
2853  shl    ax,cl
2855  add    ax,0x20ae
2858  push   ax
2859  mov    al,BYTE PTR [bp-0x2]                 ; yy
285c  cbw
285d  push   ax
285e  mov    al,BYTE PTR [bp-0x1]                 ; xx
2861  cbw
2862  push   ax
2863  call   _putptn
2866  add    sp,0x8
                                  ; ---- KOR-SUB.C:205
2869  les    bx,DWORD PTR [bp-0xa]                ; stage_adrs
286c  cmp    BYTE PTR es:[bx],0x6f
2870  jne    0x2895
                                  ; ---- KOR-SUB.C:206
2872  push   ds
2873  mov    ax,[_simul]
2876  sar    ax,1
2878  sar    ax,1
287a  add    ax,0xb0
287d  mov    cl,0x5
287f  shl    ax,cl
2881  add    ax,0x20ae
2884  push   ax
2885  mov    al,BYTE PTR [bp-0x2]                 ; yy
2888  cbw
2889  push   ax
288a  mov    al,BYTE PTR [bp-0x1]                 ; xx
288d  cbw
288e  push   ax
288f  call   _putptn
2892  add    sp,0x8
2895  inc    BYTE PTR [bp-0x1]                    ; xx
2898  inc    WORD PTR [bp-0xa]                    ; stage_adrs
289b  inc    WORD PTR [bp-0x6]                    ; chk_stage_adrs
289e  cmp    BYTE PTR [bp-0x1],0x15               ; xx
28a2  jl     0x282e
28a4  inc    BYTE PTR [bp-0x2]                    ; yy
28a7  cmp    BYTE PTR [bp-0x2],0x17               ; yy
28ab  jge    0x28b0
28ad  jmp    0x280d
                                  ; ---- KOR-SUB.C:210
28b0  mov    sp,bp
28b2  pop    bp
28b3  ret

; ---------------------------------------------------------------
_put_stage2:   ; 0x28b4..0x2b59  locals: bp-12=ptnpt7, bp-16=ptnpt6, bp-20=ptnpt5, bp-24=ptnpt4, bp-28=ptnpt3, bp-32=ptnpt2, bp-36=ptnpt1, bp-4=ptnpt9, bp-40=ptnpt0, bp-42=py, bp-46=vad, bp-8=ptnpt8, di=i, si=yy
                                  ; ---- KOR-SUB.C:213
28b4  push   bp
28b5  mov    bp,sp
28b7  sub    sp,0x2e
28ba  push   si                                   ; si=yy
28bb  push   di                                   ; di=i
                                  ; ---- KOR-SUB.C:219
28bc  mov    WORD PTR [bp-0x2a],0x4               ; py
28c1  jmp    0x2b4a
                                  ; ---- KOR-SUB.C:220
28c4  mov    si,WORD PTR [bp-0x2a]                ; py | si=yy
28c7  dec    si                                   ; si=yy
                                  ; ---- KOR-SUB.C:221
28c8  mov    bx,si                                ; si=yy
28ca  mov    cl,0x4
28cc  shl    bx,cl
28ce  add    bx,0x18ba
28d2  mov    ax,ds
28d4  mov    es,ax
28d6  mov    al,BYTE PTR es:[bx+0x3]
28da  mov    ah,0x0
28dc  mov    bx,ax
28de  mov    cl,0x5
28e0  shl    bx,cl
28e2  add    bx,0x20ae
28e6  mov    ax,ds
28e8  mov    es,ax
28ea  mov    WORD PTR [bp-0x26],es
28ed  mov    WORD PTR [bp-0x28],bx                ; ptnpt0
                                  ; ---- KOR-SUB.C:222
28f0  mov    bx,si                                ; si=yy
28f2  mov    cl,0x4
28f4  shl    bx,cl
28f6  add    bx,0x18ba
28fa  mov    ax,ds
28fc  mov    es,ax
28fe  mov    al,BYTE PTR es:[bx+0x4]
2902  mov    ah,0x0
2904  mov    bx,ax
2906  mov    cl,0x5
2908  shl    bx,cl
290a  add    bx,0x20ae
290e  mov    ax,ds
2910  mov    es,ax
2912  mov    WORD PTR [bp-0x22],es
2915  mov    WORD PTR [bp-0x24],bx                ; ptnpt1
                                  ; ---- KOR-SUB.C:223
2918  mov    bx,si                                ; si=yy
291a  mov    cl,0x4
291c  shl    bx,cl
291e  add    bx,0x18ba
2922  mov    ax,ds
2924  mov    es,ax
2926  mov    al,BYTE PTR es:[bx+0x5]
292a  mov    ah,0x0
292c  mov    bx,ax
292e  mov    cl,0x5
2930  shl    bx,cl
2932  add    bx,0x20ae
2936  mov    ax,ds
2938  mov    es,ax
293a  mov    WORD PTR [bp-0x1e],es
293d  mov    WORD PTR [bp-0x20],bx                ; ptnpt2
                                  ; ---- KOR-SUB.C:224
2940  mov    bx,si                                ; si=yy
2942  mov    cl,0x4
2944  shl    bx,cl
2946  add    bx,0x18ba
294a  mov    ax,ds
294c  mov    es,ax
294e  mov    al,BYTE PTR es:[bx+0x6]
2952  mov    ah,0x0
2954  mov    bx,ax
2956  mov    cl,0x5
2958  shl    bx,cl
295a  add    bx,0x20ae
295e  mov    ax,ds
2960  mov    es,ax
2962  mov    WORD PTR [bp-0x1a],es
2965  mov    WORD PTR [bp-0x1c],bx                ; ptnpt3
                                  ; ---- KOR-SUB.C:225
2968  mov    bx,si                                ; si=yy
296a  mov    cl,0x4
296c  shl    bx,cl
296e  add    bx,0x18ba
2972  mov    ax,ds
2974  mov    es,ax
2976  mov    al,BYTE PTR es:[bx+0x7]
297a  mov    ah,0x0
297c  mov    bx,ax
297e  mov    cl,0x5
2980  shl    bx,cl
2982  add    bx,0x20ae
2986  mov    ax,ds
2988  mov    es,ax
298a  mov    WORD PTR [bp-0x16],es
298d  mov    WORD PTR [bp-0x18],bx                ; ptnpt4
                                  ; ---- KOR-SUB.C:226
2990  mov    bx,si                                ; si=yy
2992  mov    cl,0x4
2994  shl    bx,cl
2996  add    bx,0x18ba
299a  mov    ax,ds
299c  mov    es,ax
299e  mov    al,BYTE PTR es:[bx+0x8]
29a2  mov    ah,0x0
29a4  mov    bx,ax
29a6  mov    cl,0x5
29a8  shl    bx,cl
29aa  add    bx,0x20ae
29ae  mov    ax,ds
29b0  mov    es,ax
29b2  mov    WORD PTR [bp-0x12],es
29b5  mov    WORD PTR [bp-0x14],bx                ; ptnpt5
                                  ; ---- KOR-SUB.C:227
29b8  mov    bx,si                                ; si=yy
29ba  mov    cl,0x4
29bc  shl    bx,cl
29be  add    bx,0x18ba
29c2  mov    ax,ds
29c4  mov    es,ax
29c6  mov    al,BYTE PTR es:[bx+0x9]
29ca  mov    ah,0x0
29cc  mov    bx,ax
29ce  mov    cl,0x5
29d0  shl    bx,cl
29d2  add    bx,0x20ae
29d6  mov    ax,ds
29d8  mov    es,ax
29da  mov    WORD PTR [bp-0xe],es
29dd  mov    WORD PTR [bp-0x10],bx                ; ptnpt6
                                  ; ---- KOR-SUB.C:228
29e0  mov    bx,si                                ; si=yy
29e2  mov    cl,0x4
29e4  shl    bx,cl
29e6  add    bx,0x18ba
29ea  mov    ax,ds
29ec  mov    es,ax
29ee  mov    al,BYTE PTR es:[bx+0xa]
29f2  mov    ah,0x0
29f4  mov    bx,ax
29f6  mov    cl,0x5
29f8  shl    bx,cl
29fa  add    bx,0x20ae
29fe  mov    ax,ds
2a00  mov    es,ax
2a02  mov    WORD PTR [bp-0xa],es
2a05  mov    WORD PTR [bp-0xc],bx                 ; ptnpt7
                                  ; ---- KOR-SUB.C:229
2a08  mov    bx,si                                ; si=yy
2a0a  mov    cl,0x4
2a0c  shl    bx,cl
2a0e  add    bx,0x18ba
2a12  mov    ax,ds
2a14  mov    es,ax
2a16  mov    al,BYTE PTR es:[bx+0xb]
2a1a  mov    ah,0x0
2a1c  mov    bx,ax
2a1e  mov    cl,0x5
2a20  shl    bx,cl
2a22  add    bx,0x20ae
2a26  mov    ax,ds
2a28  mov    es,ax
2a2a  mov    WORD PTR [bp-0x6],es
2a2d  mov    WORD PTR [bp-0x8],bx                 ; ptnpt8
                                  ; ---- KOR-SUB.C:230
2a30  mov    bx,si                                ; si=yy
2a32  mov    cl,0x4
2a34  shl    bx,cl
2a36  add    bx,0x18ba
2a3a  mov    ax,ds
2a3c  mov    es,ax
2a3e  mov    al,BYTE PTR es:[bx+0xc]
2a42  mov    ah,0x0
2a44  mov    bx,ax
2a46  mov    cl,0x5
2a48  shl    bx,cl
2a4a  add    bx,0x20ae
2a4e  mov    ax,ds
2a50  mov    es,ax
2a52  mov    WORD PTR [bp-0x2],es
2a55  mov    WORD PTR [bp-0x4],bx                 ; ptnpt9
2a58  inc    si                                   ; si=yy
                                  ; ---- KOR-SUB.C:231
2a59  mov    cl,0x4
2a5b  shl    si,cl                                ; si=yy
                                  ; ---- KOR-SUB.C:232
2a5d  xor    di,di                                ; di=i
2a5f  jmp    0x2b3f
                                  ; ---- KOR-SUB.C:233
2a62  mov    bx,si                                ; si=yy
2a64  shl    bx,1
2a66  shl    bx,1
2a68  les    bx,DWORD PTR [bx+0x1a6c]             ; bx+_yad
2a6c  add    bx,0x1e
2a6f  mov    WORD PTR [bp-0x2c],es
2a72  mov    WORD PTR [bp-0x2e],bx                ; vad
2a75  inc    si                                   ; si=yy
                                  ; ---- KOR-SUB.C:234
2a76  les    bx,DWORD PTR [bp-0x28]               ; ptnpt0
2a79  mov    ax,WORD PTR es:[bx]
2a7c  les    bx,DWORD PTR [bp-0x2e]               ; vad
2a7f  mov    WORD PTR es:[bx],ax
2a82  add    WORD PTR [bp-0x28],0x2               ; ptnpt0
2a86  add    WORD PTR [bp-0x2e],0x2               ; vad
                                  ; ---- KOR-SUB.C:235
2a8a  les    bx,DWORD PTR [bp-0x24]               ; ptnpt1
2a8d  mov    ax,WORD PTR es:[bx]
2a90  les    bx,DWORD PTR [bp-0x2e]               ; vad
2a93  mov    WORD PTR es:[bx],ax
2a96  add    WORD PTR [bp-0x24],0x2               ; ptnpt1
2a9a  add    WORD PTR [bp-0x2e],0x2               ; vad
                                  ; ---- KOR-SUB.C:236
2a9e  les    bx,DWORD PTR [bp-0x20]               ; ptnpt2
2aa1  mov    ax,WORD PTR es:[bx]
2aa4  les    bx,DWORD PTR [bp-0x2e]               ; vad
2aa7  mov    WORD PTR es:[bx],ax
2aaa  add    WORD PTR [bp-0x20],0x2               ; ptnpt2
2aae  add    WORD PTR [bp-0x2e],0x2               ; vad
                                  ; ---- KOR-SUB.C:237
2ab2  les    bx,DWORD PTR [bp-0x1c]               ; ptnpt3
2ab5  mov    ax,WORD PTR es:[bx]
2ab8  les    bx,DWORD PTR [bp-0x2e]               ; vad
2abb  mov    WORD PTR es:[bx],ax
2abe  add    WORD PTR [bp-0x1c],0x2               ; ptnpt3
2ac2  add    WORD PTR [bp-0x2e],0x2               ; vad
                                  ; ---- KOR-SUB.C:238
2ac6  les    bx,DWORD PTR [bp-0x18]               ; ptnpt4
2ac9  mov    ax,WORD PTR es:[bx]
2acc  les    bx,DWORD PTR [bp-0x2e]               ; vad
2acf  mov    WORD PTR es:[bx],ax
2ad2  add    WORD PTR [bp-0x18],0x2               ; ptnpt4
2ad6  add    WORD PTR [bp-0x2e],0x2               ; vad
                                  ; ---- KOR-SUB.C:239
2ada  les    bx,DWORD PTR [bp-0x14]               ; ptnpt5
2add  mov    ax,WORD PTR es:[bx]
2ae0  les    bx,DWORD PTR [bp-0x2e]               ; vad
2ae3  mov    WORD PTR es:[bx],ax
2ae6  add    WORD PTR [bp-0x14],0x2               ; ptnpt5
2aea  add    WORD PTR [bp-0x2e],0x2               ; vad
                                  ; ---- KOR-SUB.C:240
2aee  les    bx,DWORD PTR [bp-0x10]               ; ptnpt6
2af1  mov    ax,WORD PTR es:[bx]
2af4  les    bx,DWORD PTR [bp-0x2e]               ; vad
2af7  mov    WORD PTR es:[bx],ax
2afa  add    WORD PTR [bp-0x10],0x2               ; ptnpt6
2afe  add    WORD PTR [bp-0x2e],0x2               ; vad
                                  ; ---- KOR-SUB.C:241
2b02  les    bx,DWORD PTR [bp-0xc]                ; ptnpt7
2b05  mov    ax,WORD PTR es:[bx]
2b08  les    bx,DWORD PTR [bp-0x2e]               ; vad
2b0b  mov    WORD PTR es:[bx],ax
2b0e  add    WORD PTR [bp-0xc],0x2                ; ptnpt7
2b12  add    WORD PTR [bp-0x2e],0x2               ; vad
                                  ; ---- KOR-SUB.C:242
2b16  les    bx,DWORD PTR [bp-0x8]                ; ptnpt8
2b19  mov    ax,WORD PTR es:[bx]
2b1c  les    bx,DWORD PTR [bp-0x2e]               ; vad
2b1f  mov    WORD PTR es:[bx],ax
2b22  add    WORD PTR [bp-0x8],0x2                ; ptnpt8
2b26  add    WORD PTR [bp-0x2e],0x2               ; vad
                                  ; ---- KOR-SUB.C:243
2b2a  les    bx,DWORD PTR [bp-0x4]                ; ptnpt9
2b2d  mov    ax,WORD PTR es:[bx]
2b30  les    bx,DWORD PTR [bp-0x2e]               ; vad
2b33  mov    WORD PTR es:[bx],ax
2b36  add    WORD PTR [bp-0x4],0x2                ; ptnpt9
2b3a  add    WORD PTR [bp-0x2e],0x2               ; vad
2b3e  inc    di                                   ; di=i
2b3f  cmp    di,0x10                              ; di=i
2b42  jge    0x2b47
2b44  jmp    0x2a62
2b47  inc    WORD PTR [bp-0x2a]                   ; py
2b4a  cmp    WORD PTR [bp-0x2a],0x18              ; py
2b4e  jge    0x2b53
2b50  jmp    0x28c4
                                  ; ---- KOR-SUB.C:246
2b53  pop    di                                   ; di=i
2b54  pop    si                                   ; si=yy
2b55  mov    sp,bp
2b57  pop    bp
2b58  ret

; ---------------------------------------------------------------
_stage_check:   ; 0x2b59..0x2bfb  locals: bp-1=j, bp-2=i, bp-6=p
                                  ; ---- KOR-SUB.C:249
2b59  push   bp
2b5a  mov    bp,sp
2b5c  sub    sp,0x6
                                  ; ---- KOR-SUB.C:253
2b5f  mov    bx,WORD PTR [_STICK+0x4]
2b63  mov    cl,0x6
2b65  shl    bx,cl
2b67  add    bx,0x1056
2b6b  mov    ax,ds
2b6d  mov    es,ax
2b6f  mov    ax,[_stick_img]
2b72  mov    cl,0x4
2b74  shl    ax,cl
2b76  add    bx,ax
2b78  mov    WORD PTR [bp-0x4],es
2b7b  mov    WORD PTR [bp-0x6],bx                 ; p
                                  ; ---- KOR-SUB.C:254
2b7e  mov    al,[_kory]
2b81  mov    BYTE PTR [bp-0x2],al                 ; i
2b84  jmp    0x2be4
                                  ; ---- KOR-SUB.C:255
2b86  mov    al,[_korx]
2b89  mov    BYTE PTR [bp-0x1],al                 ; j
2b8c  jmp    0x2bd2
                                  ; ---- KOR-SUB.C:256
2b8e  les    bx,DWORD PTR [bp-0x6]                ; p
2b91  inc    WORD PTR [bp-0x6]                    ; p
2b94  cmp    BYTE PTR es:[bx],0x0
2b98  je     0x2bcf
2b9a  mov    al,BYTE PTR [bp-0x2]                 ; i
2b9d  cbw
2b9e  mov    bx,ax
2ba0  mov    cl,0x4
2ba2  shl    bx,cl
2ba4  add    bx,0x18ba
2ba8  mov    ax,ds
2baa  mov    es,ax
2bac  mov    al,BYTE PTR [bp-0x1]                 ; j
2baf  cbw
2bb0  add    bx,ax
2bb2  cmp    BYTE PTR es:[bx],0x10
2bb6  jbe    0x2bcf
                                  ; ---- KOR-SUB.C:257
2bb8  mov    ax,[_korxr]
2bbb  mov    [_korx],ax
                                  ; ---- KOR-SUB.C:258
2bbe  mov    ax,[_koryr]
2bc1  mov    [_kory],ax
                                  ; ---- KOR-SUB.C:259
2bc4  mov    ax,[_stick_rimg]
2bc7  mov    [_stick_img],ax
                                  ; ---- KOR-SUB.C:260
2bca  mov    ax,0x1
2bcd  jmp    0x2bf7
2bcf  inc    BYTE PTR [bp-0x1]                    ; j
2bd2  mov    al,BYTE PTR [bp-0x1]                 ; j
2bd5  cbw
2bd6  mov    dx,WORD PTR [_korx]
2bda  add    dx,0x4
2bdd  cmp    ax,dx
2bdf  jl     0x2b8e
2be1  inc    BYTE PTR [bp-0x2]                    ; i
2be4  mov    al,BYTE PTR [bp-0x2]                 ; i
2be7  cbw
2be8  mov    dx,WORD PTR [_kory]
2bec  add    dx,0x4
2bef  cmp    ax,dx
2bf1  jl     0x2b86
                                  ; ---- KOR-SUB.C:262
2bf3  xor    ax,ax
2bf5  jmp    0x2bf7
                                  ; ---- KOR-SUB.C:263
2bf7  mov    sp,bp
2bf9  pop    bp
2bfa  ret

; ---------------------------------------------------------------
_stage_down_check:   ; 0x2bfb..0x2c74  locals: bp-4=p, di=i, si=j
                                  ; ---- KOR-SUB.C:266
2bfb  push   bp
2bfc  mov    bp,sp
2bfe  sub    sp,0x4
2c01  push   si                                   ; si=j
2c02  push   di                                   ; di=i
                                  ; ---- KOR-SUB.C:270
2c03  mov    bx,WORD PTR [_STICK+0x4]
2c07  mov    cl,0x6
2c09  shl    bx,cl
2c0b  add    bx,0x1056
2c0f  mov    ax,ds
2c11  mov    es,ax
2c13  mov    ax,[_stick_img]
2c16  mov    cl,0x4
2c18  shl    ax,cl
2c1a  add    bx,ax
2c1c  mov    WORD PTR [bp-0x2],es
2c1f  mov    WORD PTR [bp-0x4],bx                 ; p
                                  ; ---- KOR-SUB.C:271
2c22  mov    di,WORD PTR [_kory]                  ; di=i
2c26  jmp    0x2c60
                                  ; ---- KOR-SUB.C:272
2c28  mov    si,WORD PTR [_korx]                  ; si=j
2c2c  jmp    0x2c55
                                  ; ---- KOR-SUB.C:273
2c2e  les    bx,DWORD PTR [bp-0x4]                ; p
2c31  inc    WORD PTR [bp-0x4]                    ; p
2c34  cmp    BYTE PTR es:[bx],0x0
2c38  je     0x2c54
2c3a  mov    bx,di                                ; di=i
2c3c  inc    bx
2c3d  mov    cl,0x4
2c3f  shl    bx,cl
2c41  add    bx,0x18ba
2c45  mov    ax,ds
2c47  mov    es,ax
2c49  cmp    BYTE PTR es:[bx+si],0x10             ; si=j
2c4d  jbe    0x2c54
                                  ; ---- KOR-SUB.C:274
2c4f  mov    ax,0x1
2c52  jmp    0x2c6e
2c54  inc    si                                   ; si=j
2c55  mov    ax,[_korx]
2c58  add    ax,0x4
2c5b  cmp    ax,si                                ; si=j
2c5d  jg     0x2c2e
2c5f  inc    di                                   ; di=i
2c60  mov    ax,[_kory]
2c63  add    ax,0x4
2c66  cmp    ax,di                                ; di=i
2c68  jg     0x2c28
                                  ; ---- KOR-SUB.C:276
2c6a  xor    ax,ax
2c6c  jmp    0x2c6e
                                  ; ---- KOR-SUB.C:277
2c6e  pop    di                                   ; di=i
2c6f  pop    si                                   ; si=j
2c70  mov    sp,bp
2c72  pop    bp
2c73  ret

; ---------------------------------------------------------------
_stage_store:   ; 0x2c74..0x2cdf  locals: bp-4=p, di=i, si=j
                                  ; ---- KOR-SUB.C:280
2c74  push   bp
2c75  mov    bp,sp
2c77  sub    sp,0x4
2c7a  push   si                                   ; si=j
2c7b  push   di                                   ; di=i
                                  ; ---- KOR-SUB.C:285
2c7c  mov    bx,WORD PTR [_STICK+0x4]
2c80  mov    cl,0x6
2c82  shl    bx,cl
2c84  add    bx,0x1056
2c88  mov    ax,ds
2c8a  mov    es,ax
2c8c  mov    ax,[_stick_img]
2c8f  mov    cl,0x4
2c91  shl    ax,cl
2c93  add    bx,ax
2c95  mov    WORD PTR [bp-0x2],es
2c98  mov    WORD PTR [bp-0x4],bx                 ; p
                                  ; ---- KOR-SUB.C:286
2c9b  mov    di,WORD PTR [_kory]                  ; di=i
2c9f  jmp    0x2ccf
                                  ; ---- KOR-SUB.C:287
2ca1  mov    si,WORD PTR [_korx]                  ; si=j
2ca5  jmp    0x2cc4
                                  ; ---- KOR-SUB.C:288
2ca7  les    bx,DWORD PTR [bp-0x4]                ; p
2caa  mov    al,BYTE PTR es:[bx]
2cad  mov    bx,di                                ; di=i
2caf  mov    cl,0x4
2cb1  shl    bx,cl
2cb3  add    bx,0x18ba
2cb7  push   ax
2cb8  mov    ax,ds
2cba  mov    es,ax
2cbc  pop    ax
2cbd  add    BYTE PTR es:[bx+si],al               ; si=j
2cc0  inc    WORD PTR [bp-0x4]                    ; p
2cc3  inc    si                                   ; si=j
2cc4  mov    ax,[_korx]
2cc7  add    ax,0x4
2cca  cmp    ax,si                                ; si=j
2ccc  jg     0x2ca7
2cce  inc    di                                   ; di=i
2ccf  mov    ax,[_kory]
2cd2  add    ax,0x4
2cd5  cmp    ax,di                                ; di=i
2cd7  jg     0x2ca1
                                  ; ---- KOR-SUB.C:289
2cd9  pop    di                                   ; di=i
2cda  pop    si                                   ; si=j
2cdb  mov    sp,bp
2cdd  pop    bp
2cde  ret

; ---------------------------------------------------------------
_stage_stick_clear:   ; 0x2cdf..0x2d23  locals: di=i, si=j
                                  ; ---- KOR-SUB.C:292
2cdf  push   bp
2ce0  mov    bp,sp
2ce2  push   si                                   ; si=j
2ce3  push   di                                   ; di=i
                                  ; ---- KOR-SUB.C:296
2ce4  xor    di,di                                ; di=i
2ce6  jmp    0x2d1a
                                  ; ---- KOR-SUB.C:297
2ce8  mov    si,0x3                               ; si=j
2ceb  jmp    0x2d14
                                  ; ---- KOR-SUB.C:298
2ced  mov    bx,di                                ; di=i
2cef  mov    cl,0x4
2cf1  shl    bx,cl
2cf3  add    bx,0x18ba
2cf7  mov    ax,ds
2cf9  mov    es,ax
2cfb  cmp    BYTE PTR es:[bx+si],0x11             ; si=j
2cff  jae    0x2d13
2d01  mov    bx,di                                ; di=i
2d03  mov    cl,0x4
2d05  shl    bx,cl
2d07  add    bx,0x18ba
2d0b  mov    ax,ds
2d0d  mov    es,ax
2d0f  mov    BYTE PTR es:[bx+si],0x0              ; si=j
2d13  inc    si                                   ; si=j
2d14  cmp    si,0xd                               ; si=j
2d17  jl     0x2ced
2d19  inc    di                                   ; di=i
2d1a  cmp    di,0x17                              ; di=i
2d1d  jl     0x2ce8
                                  ; ---- KOR-SUB.C:299
2d1f  pop    di                                   ; di=i
2d20  pop    si                                   ; si=j
2d21  pop    bp
2d22  ret

; ---------------------------------------------------------------
_left_rotate:   ; 0x2d23..0x2db7  locals: bp-2=r, di=j, si=i
                                  ; ---- KOR-SUB.C:302
2d23  push   bp
2d24  mov    bp,sp
2d26  sub    sp,0x2
2d29  push   si                                   ; si=i
2d2a  push   di                                   ; di=j
                                  ; ---- KOR-SUB.C:305
2d2b  mov    si,0x3                               ; si=i
2d2e  jmp    0x2d91
                                  ; ---- KOR-SUB.C:306
2d30  mov    bx,si                                ; si=i
2d32  mov    cl,0x4
2d34  shl    bx,cl
2d36  add    bx,0x18ba
2d3a  mov    ax,ds
2d3c  mov    es,ax
2d3e  mov    al,BYTE PTR es:[bx+0x3]
2d42  mov    ah,0x0
2d44  mov    WORD PTR [bp-0x2],ax                 ; r
                                  ; ---- KOR-SUB.C:307
2d47  mov    di,0x3                               ; di=j
2d4a  jmp    0x2d74
                                  ; ---- KOR-SUB.C:308
2d4c  mov    bx,si                                ; si=i
2d4e  mov    cl,0x4
2d50  shl    bx,cl
2d52  add    bx,0x18ba
2d56  mov    ax,ds
2d58  mov    es,ax
2d5a  add    bx,di                                ; di=j
2d5c  mov    al,BYTE PTR es:[bx+0x1]
2d60  mov    bx,si                                ; si=i
2d62  mov    cl,0x4
2d64  shl    bx,cl
2d66  add    bx,0x18ba
2d6a  push   ax
2d6b  mov    ax,ds
2d6d  mov    es,ax
2d6f  pop    ax
2d70  mov    BYTE PTR es:[bx+di],al               ; di=j
2d73  inc    di                                   ; di=j
2d74  cmp    di,0xd                               ; di=j
2d77  jl     0x2d4c
                                  ; ---- KOR-SUB.C:309
2d79  mov    al,BYTE PTR [bp-0x2]                 ; r
2d7c  mov    bx,si                                ; si=i
2d7e  mov    cl,0x4
2d80  shl    bx,cl
2d82  add    bx,0x18ba
2d86  push   ax
2d87  mov    ax,ds
2d89  mov    es,ax
2d8b  pop    ax
2d8c  mov    BYTE PTR es:[bx+0xc],al
2d90  inc    si                                   ; si=i
2d91  cmp    si,0x17                              ; si=i
2d94  jl     0x2d30
                                  ; ---- KOR-SUB.C:311
2d96  mov    si,0x3e8                             ; si=i | &_information+0x16c?
2d99  jmp    0x2da8
                                  ; ---- KOR-SUB.C:312
2d9b  push   si                                   ; si=i
2d9c  call   _sound
2d9f  inc    sp
2da0  inc    sp
                                  ; ---- KOR-SUB.C:313
2da1  call   _clock_wait
2da4  add    si,0xc8                              ; si=i
2da8  cmp    si,0x7d0                             ; si=i
2dac  jl     0x2d9b
                                  ; ---- KOR-SUB.C:315
2dae  call   _nosound
                                  ; ---- KOR-SUB.C:316
2db1  pop    di                                   ; di=j
2db2  pop    si                                   ; si=i
2db3  mov    sp,bp
2db5  pop    bp
2db6  ret

; ---------------------------------------------------------------
_right_rotate:   ; 0x2db7..0x2e4b  locals: bp-2=r, di=j, si=i
                                  ; ---- KOR-SUB.C:319
2db7  push   bp
2db8  mov    bp,sp
2dba  sub    sp,0x2
2dbd  push   si                                   ; si=i
2dbe  push   di                                   ; di=j
                                  ; ---- KOR-SUB.C:322
2dbf  mov    si,0x3                               ; si=i
2dc2  jmp    0x2e25
                                  ; ---- KOR-SUB.C:323
2dc4  mov    bx,si                                ; si=i
2dc6  mov    cl,0x4
2dc8  shl    bx,cl
2dca  add    bx,0x18ba
2dce  mov    ax,ds
2dd0  mov    es,ax
2dd2  mov    al,BYTE PTR es:[bx+0xc]
2dd6  mov    ah,0x0
2dd8  mov    WORD PTR [bp-0x2],ax                 ; r
                                  ; ---- KOR-SUB.C:324
2ddb  mov    di,0xc                               ; di=j
2dde  jmp    0x2e08
                                  ; ---- KOR-SUB.C:325
2de0  mov    bx,si                                ; si=i
2de2  mov    cl,0x4
2de4  shl    bx,cl
2de6  add    bx,0x18ba
2dea  mov    ax,ds
2dec  mov    es,ax
2dee  add    bx,di                                ; di=j
2df0  dec    bx
2df1  mov    al,BYTE PTR es:[bx]
2df4  mov    bx,si                                ; si=i
2df6  mov    cl,0x4
2df8  shl    bx,cl
2dfa  add    bx,0x18ba
2dfe  push   ax
2dff  mov    ax,ds
2e01  mov    es,ax
2e03  pop    ax
2e04  mov    BYTE PTR es:[bx+di],al               ; di=j
2e07  dec    di                                   ; di=j
2e08  cmp    di,0x3                               ; di=j
2e0b  jg     0x2de0
                                  ; ---- KOR-SUB.C:326
2e0d  mov    al,BYTE PTR [bp-0x2]                 ; r
2e10  mov    bx,si                                ; si=i
2e12  mov    cl,0x4
2e14  shl    bx,cl
2e16  add    bx,0x18ba
2e1a  push   ax
2e1b  mov    ax,ds
2e1d  mov    es,ax
2e1f  pop    ax
2e20  mov    BYTE PTR es:[bx+0x3],al
2e24  inc    si                                   ; si=i
2e25  cmp    si,0x17                              ; si=i
2e28  jl     0x2dc4
                                  ; ---- KOR-SUB.C:328
2e2a  mov    si,0x7d0                             ; si=i | &msg+0x132?
2e2d  jmp    0x2e3c
                                  ; ---- KOR-SUB.C:329
2e2f  push   si                                   ; si=i
2e30  call   _sound
2e33  inc    sp
2e34  inc    sp
                                  ; ---- KOR-SUB.C:330
2e35  call   _clock_wait
2e38  sub    si,0xc8                              ; si=i
2e3c  cmp    si,0x3e8                             ; si=i
2e40  jg     0x2e2f
                                  ; ---- KOR-SUB.C:332
2e42  call   _nosound
                                  ; ---- KOR-SUB.C:333
2e45  pop    di                                   ; di=j
2e46  pop    si                                   ; si=i
2e47  mov    sp,bp
2e49  pop    bp
2e4a  ret

; ---------------------------------------------------------------
_make_point:   ; 0x2e4b..0x2f0a  locals: bp-2=j, di=i, si=n
                                  ; ---- KOR-SUB.C:336
2e4b  push   bp
2e4c  mov    bp,sp
2e4e  sub    sp,0x2
2e51  push   si                                   ; si=n
2e52  push   di                                   ; di=i
2e53  jmp    0x2f01
                                  ; ---- KOR-SUB.C:341
2e56  call   _rand
2e59  mov    bx,0x14
2e5c  cwd
2e5d  idiv   bx
2e5f  mov    di,dx                                ; di=i
2e61  add    di,0x3                               ; di=i
                                  ; ---- KOR-SUB.C:342
2e64  call   _rand
2e67  mov    bx,0xa
2e6a  cwd
2e6b  idiv   bx
2e6d  add    dx,0x3
2e70  mov    WORD PTR [bp-0x2],dx                 ; j
                                  ; ---- KOR-SUB.C:343
2e73  mov    bx,di                                ; di=i
2e75  inc    bx
2e76  mov    cl,0x4
2e78  shl    bx,cl
2e7a  add    bx,0x18ba
2e7e  mov    ax,ds
2e80  mov    es,ax
2e82  add    bx,WORD PTR [bp-0x2]                 ; j
2e85  cmp    BYTE PTR es:[bx],0x0
2e89  je     0x2f01
2e8b  mov    bx,di                                ; di=i
2e8d  mov    cl,0x4
2e8f  shl    bx,cl
2e91  add    bx,0x18ba
2e95  mov    ax,ds
2e97  mov    es,ax
2e99  add    bx,WORD PTR [bp-0x2]                 ; j
2e9c  cmp    BYTE PTR es:[bx],0x0
2ea0  jne    0x2f01
                                  ; ---- KOR-SUB.C:344
2ea2  call   _nosound
                                  ; ---- KOR-SUB.C:345
2ea5  mov    si,0x27                              ; si=n
2ea8  jmp    0x2eda
                                  ; ---- KOR-SUB.C:346
2eaa  push   ds
2eab  mov    ax,si                                ; si=n
2ead  mov    cl,0x5
2eaf  shl    ax,cl
2eb1  add    ax,0x20ae
2eb4  push   ax
2eb5  push   di                                   ; di=i
2eb6  mov    ax,WORD PTR [bp-0x2]                 ; j
2eb9  add    ax,0x8
2ebc  push   ax
2ebd  call   _putptn
2ec0  add    sp,0x8
                                  ; ---- KOR-SUB.C:347
2ec3  mov    ax,si                                ; si=n
2ec5  add    ax,0xffde
2ec8  mov    dx,0x12c                             ; &_play+0x98?
2ecb  mul    dx
2ecd  add    ax,0x1f4
2ed0  push   ax
2ed1  call   _sound
2ed4  inc    sp
2ed5  inc    sp
                                  ; ---- KOR-SUB.C:348
2ed6  call   _clock_wait
2ed9  dec    si                                   ; si=n
2eda  cmp    si,0x21                              ; si=n
2edd  jg     0x2eaa
                                  ; ---- KOR-SUB.C:350
2edf  call   _rand
2ee2  mov    bx,0x7
2ee5  cwd
2ee6  idiv   bx
2ee8  add    dl,0x61
2eeb  mov    bx,di                                ; di=i
2eed  mov    cl,0x4
2eef  shl    bx,cl
2ef1  add    bx,0x18ba
2ef5  mov    ax,ds
2ef7  mov    es,ax
2ef9  add    bx,WORD PTR [bp-0x2]                 ; j
2efc  mov    BYTE PTR es:[bx],dl
2eff  jmp    0x2f04
                                  ; ---- KOR-SUB.C:340
2f01  jmp    0x2e56
                                  ; ---- KOR-SUB.C:354
2f04  pop    di                                   ; di=i
2f05  pop    si                                   ; si=n
2f06  mov    sp,bp
2f08  pop    bp
2f09  ret

; ---------------------------------------------------------------
_erase_point:   ; 0x2f0a..0x2fa6  locals: bp-2=j, di=i, si=n
                                  ; ---- KOR-SUB.C:357
2f0a  push   bp
2f0b  mov    bp,sp
2f0d  sub    sp,0x2
2f10  push   si                                   ; si=n
2f11  push   di                                   ; di=i
2f12  jmp    0x2f9d
                                  ; ---- KOR-SUB.C:362
2f15  call   _rand
2f18  mov    bx,0x14
2f1b  cwd
2f1c  idiv   bx
2f1e  mov    di,dx                                ; di=i
2f20  add    di,0x3                               ; di=i
                                  ; ---- KOR-SUB.C:363
2f23  call   _rand
2f26  mov    bx,0xa
2f29  cwd
2f2a  idiv   bx
2f2c  add    dx,0x3
2f2f  mov    WORD PTR [bp-0x2],dx                 ; j
                                  ; ---- KOR-SUB.C:364
2f32  mov    bx,di                                ; di=i
2f34  mov    cl,0x4
2f36  shl    bx,cl
2f38  add    bx,0x18ba
2f3c  mov    ax,ds
2f3e  mov    es,ax
2f40  add    bx,WORD PTR [bp-0x2]                 ; j
2f43  cmp    BYTE PTR es:[bx],0x0
2f47  je     0x2f9d
                                  ; ---- KOR-SUB.C:365
2f49  call   _nosound
                                  ; ---- KOR-SUB.C:366
2f4c  mov    si,0x22                              ; si=n
2f4f  jmp    0x2f81
                                  ; ---- KOR-SUB.C:367
2f51  push   ds
2f52  mov    ax,si                                ; si=n
2f54  mov    cl,0x5
2f56  shl    ax,cl
2f58  add    ax,0x20ae
2f5b  push   ax
2f5c  push   di                                   ; di=i
2f5d  mov    ax,WORD PTR [bp-0x2]                 ; j
2f60  add    ax,0x8
2f63  push   ax
2f64  call   _putptn
2f67  add    sp,0x8
                                  ; ---- KOR-SUB.C:368
2f6a  mov    ax,si                                ; si=n
2f6c  add    ax,0xffde
2f6f  mov    dx,0x12c                             ; &_play+0x98?
2f72  mul    dx
2f74  add    ax,0x1f4
2f77  push   ax
2f78  call   _sound
2f7b  inc    sp
2f7c  inc    sp
                                  ; ---- KOR-SUB.C:369
2f7d  call   _clock_wait
2f80  inc    si                                   ; si=n
2f81  cmp    si,0x28                              ; si=n
2f84  jl     0x2f51
                                  ; ---- KOR-SUB.C:371
2f86  mov    bx,di                                ; di=i
2f88  mov    cl,0x4
2f8a  shl    bx,cl
2f8c  add    bx,0x18ba
2f90  mov    ax,ds
2f92  mov    es,ax
2f94  add    bx,WORD PTR [bp-0x2]                 ; j
2f97  mov    BYTE PTR es:[bx],0x0
2f9b  jmp    0x2fa0
                                  ; ---- KOR-SUB.C:361
2f9d  jmp    0x2f15
                                  ; ---- KOR-SUB.C:375
2fa0  pop    di                                   ; di=i
2fa1  pop    si                                   ; si=n
2fa2  mov    sp,bp
2fa4  pop    bp
2fa5  ret

; ---------------------------------------------------------------
_up_stage:   ; 0x2fa6..0x3048  locals: bp-2=f, di=j, si=i
                                  ; ---- KOR-SUB.C:378
2fa6  push   bp
2fa7  mov    bp,sp
2fa9  sub    sp,0x2
2fac  push   si                                   ; si=i
2fad  push   di                                   ; di=j
                                  ; ---- KOR-SUB.C:380
2fae  mov    WORD PTR [bp-0x2],0x1                ; f
                                  ; ---- KOR-SUB.C:382
2fb3  mov    ax,0x7d0                             ; &msg+0x132?
2fb6  push   ax
2fb7  call   _sound
2fba  inc    sp
2fbb  inc    sp
                                  ; ---- KOR-SUB.C:383
2fbc  xor    si,si                                ; si=i
2fbe  jmp    0x2ff1
                                  ; ---- KOR-SUB.C:384
2fc0  mov    di,0x3                               ; di=j
2fc3  jmp    0x2feb
                                  ; ---- KOR-SUB.C:385
2fc5  mov    bx,si                                ; si=i
2fc7  inc    bx
2fc8  mov    cl,0x4
2fca  shl    bx,cl
2fcc  add    bx,0x18ba
2fd0  mov    ax,ds
2fd2  mov    es,ax
2fd4  mov    al,BYTE PTR es:[bx+di]               ; di=j
2fd7  mov    bx,si                                ; si=i
2fd9  mov    cl,0x4
2fdb  shl    bx,cl
2fdd  add    bx,0x18ba
2fe1  push   ax
2fe2  mov    ax,ds
2fe4  mov    es,ax
2fe6  pop    ax
2fe7  mov    BYTE PTR es:[bx+di],al               ; di=j
2fea  inc    di                                   ; di=j
2feb  cmp    di,0xd                               ; di=j
2fee  jl     0x2fc5
2ff0  inc    si                                   ; si=i
2ff1  cmp    si,0x16                              ; si=i
2ff4  jl     0x2fc0
                                  ; ---- KOR-SUB.C:387
2ff6  mov    si,0x3                               ; si=i
2ff9  jmp    0x3025
                                  ; ---- KOR-SUB.C:388
2ffb  call   _rand
2ffe  mov    bx,0x3
3001  cwd
3002  idiv   bx
3004  or     dx,dx
3006  je     0x301f
                                  ; ---- KOR-SUB.C:389
3008  call   _rand
300b  mov    bx,0x7
300e  cwd
300f  idiv   bx
3011  add    dl,0x61
3014  mov    BYTE PTR [si+0x1a1a],dl              ; _STAGE+0x160 | si=i
                                  ; ---- KOR-SUB.C:390
3018  mov    WORD PTR [bp-0x2],0x0                ; f
                                  ; ---- KOR-SUB.C:391
301d  jmp    0x3024
301f  mov    BYTE PTR [si+0x1a1a],0x0             ; _STAGE+0x160 | si=i
3024  inc    si                                   ; si=i
3025  cmp    si,0xd                               ; si=i
3028  jl     0x2ffb
                                  ; ---- KOR-SUB.C:392
302a  cmp    WORD PTR [bp-0x2],0x0                ; f
302e  jne    0x2ff6
                                  ; ---- KOR-SUB.C:393
3030  call   _clock_wait
                                  ; ---- KOR-SUB.C:394
3033  mov    ax,0x1f4                             ; &_play+0x160?
3036  push   ax
3037  call   _sound
303a  inc    sp
303b  inc    sp
                                  ; ---- KOR-SUB.C:395
303c  call   _clock_wait
                                  ; ---- KOR-SUB.C:396
303f  call   _nosound
                                  ; ---- KOR-SUB.C:397
3042  pop    di                                   ; di=j
3043  pop    si                                   ; si=i
3044  mov    sp,bp
3046  pop    bp
3047  ret

; ---------------------------------------------------------------
_screen_to_stage:   ; 0x3048..0x30b4  locals: bp-4=chk_stage_adrs, di=i, si=j
                                  ; ---- KOR-SUB.C:400
3048  push   bp
3049  mov    bp,sp
304b  sub    sp,0x4
304e  push   si                                   ; si=j
304f  push   di                                   ; di=i
                                  ; ---- KOR-SUB.C:403
3050  mov    WORD PTR [bp-0x2],ds
3053  mov    WORD PTR [bp-0x4],0x922b             ; chk_stage_adrs
                                  ; ---- KOR-SUB.C:405
3058  xor    di,di                                ; di=i
305a  jmp    0x30a9
                                  ; ---- KOR-SUB.C:406
305c  xor    si,si                                ; si=j
305e  jmp    0x30a3
                                  ; ---- KOR-SUB.C:407
3060  mov    al,[_point]
3063  cbw
3064  mov    dx,0xc8
3067  mul    dx
3069  mov    bx,ax
306b  add    bx,0x43dd
306f  mov    ax,ds
3071  mov    es,ax
3073  mov    ax,di                                ; di=i
3075  mov    dx,0xa
3078  mul    dx
307a  add    bx,ax
307c  mov    al,BYTE PTR es:[bx+si]               ; si=j
307f  mov    bx,di                                ; di=i
3081  add    bx,0x3
3084  mov    cl,0x4
3086  shl    bx,cl
3088  add    bx,0x18ba
308c  push   ax
308d  mov    ax,ds
308f  mov    es,ax
3091  add    bx,si                                ; si=j
3093  pop    ax
3094  mov    BYTE PTR es:[bx+0x3],al
                                  ; ---- KOR-SUB.C:408
3098  les    bx,DWORD PTR [bp-0x4]                ; chk_stage_adrs
309b  mov    BYTE PTR es:[bx],0xff
309f  inc    WORD PTR [bp-0x4]                    ; chk_stage_adrs
30a2  inc    si                                   ; si=j
30a3  cmp    si,0xa                               ; si=j
30a6  jl     0x3060
30a8  inc    di                                   ; di=i
30a9  cmp    di,0x14                              ; di=i
30ac  jl     0x305c
                                  ; ---- KOR-SUB.C:410
30ae  pop    di                                   ; di=i
30af  pop    si                                   ; si=j
30b0  mov    sp,bp
30b2  pop    bp
30b3  ret

; ---------------------------------------------------------------
_stage_to_screen:   ; 0x30b4..0x3109  locals: di=i, si=j
                                  ; ---- KOR-SUB.C:413
30b4  push   bp
30b5  mov    bp,sp
30b7  push   si                                   ; si=j
30b8  push   di                                   ; di=i
                                  ; ---- KOR-SUB.C:416
30b9  xor    di,di                                ; di=i
30bb  jmp    0x3100
                                  ; ---- KOR-SUB.C:417
30bd  xor    si,si                                ; si=j
30bf  jmp    0x30fa
                                  ; ---- KOR-SUB.C:418
30c1  mov    bx,di                                ; di=i
30c3  add    bx,0x3
30c6  mov    cl,0x4
30c8  shl    bx,cl
30ca  add    bx,0x18ba
30ce  mov    ax,ds
30d0  mov    es,ax
30d2  add    bx,si                                ; si=j
30d4  mov    al,BYTE PTR es:[bx+0x3]
30d8  push   ax
30d9  mov    al,[_point]
30dc  cbw
30dd  mov    dx,0xc8
30e0  mul    dx
30e2  mov    bx,ax
30e4  add    bx,0x43dd
30e8  mov    ax,ds
30ea  mov    es,ax
30ec  mov    ax,di                                ; di=i
30ee  mov    dx,0xa
30f1  mul    dx
30f3  add    bx,ax
30f5  pop    ax
30f6  mov    BYTE PTR es:[bx+si],al               ; si=j
30f9  inc    si                                   ; si=j
30fa  cmp    si,0xa                               ; si=j
30fd  jl     0x30c1
30ff  inc    di                                   ; di=i
3100  cmp    di,0x14                              ; di=i
3103  jl     0x30bd
                                  ; ---- KOR-SUB.C:419
3105  pop    di                                   ; di=i
3106  pop    si                                   ; si=j
3107  pop    bp
3108  ret

; ---------------------------------------------------------------
_grp_put_init:   ; 0x3109..0x3126  locals:
                                  ; ---- KOR-SUB.C:422
3109  push   bp
310a  mov    bp,sp
                                  ; ---- KOR-SUB.C:424
310c  call   _put_hi_score
                                  ; ---- KOR-SUB.C:425
310f  call   _put_score
                                  ; ---- KOR-SUB.C:426
3112  call   _put_stage_count
                                  ; ---- KOR-SUB.C:427
3115  call   _put_option
                                  ; ---- KOR-SUB.C:428
3118  call   _put_speed
                                  ; ---- KOR-SUB.C:429
311b  call   _put_bonus
                                  ; ---- KOR-SUB.C:430
311e  call   _put_timer
                                  ; ---- KOR-SUB.C:431
3121  call   _put_life
                                  ; ---- KOR-SUB.C:432
3124  pop    bp
3125  ret

; ---------------------------------------------------------------
_put_hi_score:   ; 0x3126..0x3141  locals:
                                  ; ---- KOR-SUB.C:435
3126  push   bp
3127  mov    bp,sp
                                  ; ---- KOR-SUB.C:437
3129  push   WORD PTR [_hi_score+0x2]
312d  push   WORD PTR [_hi_score]
3131  mov    ax,0x4
3134  push   ax
3135  mov    ax,0x26
3138  push   ax
3139  call   _grp_put2
313c  add    sp,0x8
                                  ; ---- KOR-SUB.C:438
313f  pop    bp
3140  ret

; ---------------------------------------------------------------
_put_score:   ; 0x3141..0x315c  locals:
                                  ; ---- KOR-SUB.C:441
3141  push   bp
3142  mov    bp,sp
                                  ; ---- KOR-SUB.C:443
3144  push   WORD PTR [_score+0x2]
3148  push   WORD PTR [_score]
314c  mov    ax,0x6
314f  push   ax
3150  mov    ax,0x26
3153  push   ax
3154  call   _grp_put2
3157  add    sp,0x8
                                  ; ---- KOR-SUB.C:444
315a  pop    bp
315b  ret

; ---------------------------------------------------------------
_put_stage_count:   ; 0x315c..0x3175  locals:
                                  ; ---- KOR-SUB.C:447
315c  push   bp
315d  mov    bp,sp
                                  ; ---- KOR-SUB.C:449
315f  mov    al,[_point]
3162  cbw
3163  inc    ax
3164  push   ax
3165  mov    ax,0x8
3168  push   ax
3169  mov    ax,0x26
316c  push   ax
316d  call   _grp_put1
3170  add    sp,0x6
                                  ; ---- KOR-SUB.C:450
3173  pop    bp
3174  ret

; ---------------------------------------------------------------
_put_option:   ; 0x3175..0x31a2  locals:
                                  ; ---- KOR-SUB.C:453
3175  push   bp
3176  mov    bp,sp
                                  ; ---- KOR-SUB.C:458
3178  mov    WORD PTR [_locx],0x22
                                  ; ---- KOR-SUB.C:459
317e  mov    WORD PTR [_locy],0xa
                                  ; ---- KOR-SUB.C:460
3184  push   ds
3185  mov    al,[_point]
3188  cbw
3189  mov    bx,ax
318b  shl    bx,1
318d  mov    ax,WORD PTR [bx+0x4315]              ; bx+_option
3191  mov    dx,0x7
3194  mul    dx
3196  add    ax,0xb9e                             ; "!�!!�"
3199  push   ax
319a  call   _lprint
319d  add    sp,0x4
                                  ; ---- KOR-SUB.C:461
31a0  pop    bp
31a1  ret

; ---------------------------------------------------------------
_put_speed:   ; 0x31a2..0x31bd  locals:
                                  ; ---- KOR-SUB.C:463
31a2  push   bp
31a3  mov    bp,sp
                                  ; ---- KOR-SUB.C:465
31a5  mov    ax,0x9
31a8  sub    ax,WORD PTR [_speed_w]
31ac  push   ax
31ad  mov    ax,0xc
31b0  push   ax
31b1  mov    ax,0x26
31b4  push   ax
31b5  call   _grp_put1
31b8  add    sp,0x6
                                  ; ---- KOR-SUB.C:466
31bb  pop    bp
31bc  ret

; ---------------------------------------------------------------
_put_bonus:   ; 0x31bd..0x31d4  locals:
                                  ; ---- KOR-SUB.C:469
31bd  push   bp
31be  mov    bp,sp
                                  ; ---- KOR-SUB.C:471
31c0  push   WORD PTR [_bonus_w]
31c4  mov    ax,0xe
31c7  push   ax
31c8  mov    ax,0x26
31cb  push   ax
31cc  call   _grp_put1
31cf  add    sp,0x6
                                  ; ---- KOR-SUB.C:472
31d2  pop    bp
31d3  ret

; ---------------------------------------------------------------
_put_timer:   ; 0x31d4..0x31eb  locals:
                                  ; ---- KOR-SUB.C:475
31d4  push   bp
31d5  mov    bp,sp
                                  ; ---- KOR-SUB.C:477
31d7  push   WORD PTR [_timer_w]
31db  mov    ax,0x10
31de  push   ax
31df  mov    ax,0x26
31e2  push   ax
31e3  call   _grp_put1
31e6  add    sp,0x6
                                  ; ---- KOR-SUB.C:478
31e9  pop    bp
31ea  ret

; ---------------------------------------------------------------
_put_life:   ; 0x31eb..0x3224  locals: si=x
                                  ; ---- KOR-SUB.C:481
31eb  push   bp
31ec  mov    bp,sp
31ee  push   si                                   ; si=x
                                  ; ---- KOR-SUB.C:484
31ef  xor    si,si                                ; si=x
31f1  jmp    0x321c
                                  ; ---- KOR-SUB.C:485
31f3  push   ds
31f4  mov    ax,[_life]
31f7  cmp    ax,si                                ; si=x
31f9  jle    0x3200
31fb  mov    ax,0x8d
31fe  jmp    0x3203
3200  mov    ax,0x40
3203  mov    cl,0x5
3205  shl    ax,cl
3207  add    ax,0x20ae
320a  push   ax
320b  mov    ax,0x12
320e  push   ax
320f  mov    ax,0x26
3212  sub    ax,si                                ; si=x
3214  push   ax
3215  call   _putptn
3218  add    sp,0x8
321b  inc    si                                   ; si=x
321c  cmp    si,0x8                               ; si=x
321f  jl     0x31f3
                                  ; ---- KOR-SUB.C:486
3221  pop    si                                   ; si=x
3222  pop    bp
3223  ret

; ---------------------------------------------------------------
_grp_put1:   ; 0x3224..0x3272  locals: bp+4=x, bp+6=y, bp+8=n, di=x, si=n
                                  ; ---- KOR-SUB.C:489
3224  push   bp
3225  mov    bp,sp
3227  push   si                                   ; si=n
3228  push   di                                   ; di=x
3229  mov    si,WORD PTR [bp+0x8]                 ; n | si=n
322c  mov    di,WORD PTR [bp+0x4]                 ; x | di=x
                                  ; ---- KOR-SUB.C:492
322f  push   ds
3230  mov    ax,si                                ; si=n
3232  mov    bx,0xa
3235  cwd
3236  idiv   bx
3238  add    dx,0x30
323b  mov    cl,0x5
323d  shl    dx,cl
323f  add    dx,0x20ae
3243  push   dx
3244  push   WORD PTR [bp+0x6]                    ; y
3247  mov    ax,di                                ; di=x
3249  dec    di                                   ; di=x
324a  push   ax
324b  call   _putptn
324e  add    sp,0x8
                                  ; ---- KOR-SUB.C:493
3251  mov    ax,si                                ; si=n
3253  mov    bx,0xa
3256  cwd
3257  idiv   bx
3259  mov    si,ax                                ; si=n
325b  or     ax,ax
325d  jne    0x322f
                                  ; ---- KOR-SUB.C:494
325f  push   ds
3260  mov    ax,0x26ae                            ; &_chr+0x600?
3263  push   ax
3264  push   WORD PTR [bp+0x6]                    ; y
3267  push   di                                   ; di=x
3268  call   _putptn
326b  add    sp,0x8
                                  ; ---- KOR-SUB.C:495
326e  pop    di                                   ; di=x
326f  pop    si                                   ; si=n
3270  pop    bp
3271  ret

; ---------------------------------------------------------------
_grp_put2:   ; 0x3272..0x32c6  locals: bp+4=x, bp+6=y, bp+8=n, di=y, si=x
                                  ; ---- KOR-SUB.C:498
3272  push   bp
3273  mov    bp,sp
3275  push   si                                   ; si=x
3276  push   di                                   ; di=y
3277  mov    di,WORD PTR [bp+0x6]                 ; y | di=y
327a  mov    si,WORD PTR [bp+0x4]                 ; x | si=x
                                  ; ---- KOR-SUB.C:501
327d  push   ds
327e  xor    dx,dx
3280  mov    ax,0xa
3283  push   dx
3284  push   ax
3285  push   WORD PTR [bp+0xa]
3288  push   WORD PTR [bp+0x8]                    ; n
328b  call   0x0:0x59c1
3290  add    ax,0x30
3293  mov    cl,0x5
3295  shl    ax,cl
3297  add    ax,0x20ae
329a  push   ax
329b  push   di                                   ; di=y
329c  mov    ax,si                                ; si=x
329e  dec    si                                   ; si=x
329f  push   ax
32a0  call   _putptn
32a3  add    sp,0x8
                                  ; ---- KOR-SUB.C:502
32a6  xor    dx,dx
32a8  mov    ax,0xa
32ab  push   dx
32ac  push   ax
32ad  push   WORD PTR [bp+0xa]
32b0  push   WORD PTR [bp+0x8]                    ; n
32b3  call   0x0:0x59b8
32b8  mov    WORD PTR [bp+0xa],dx
32bb  mov    WORD PTR [bp+0x8],ax                 ; n
32be  or     dx,ax
32c0  jne    0x327d
                                  ; ---- KOR-SUB.C:503
32c2  pop    di                                   ; di=y
32c3  pop    si                                   ; si=x
32c4  pop    bp
32c5  ret

; ---------------------------------------------------------------
_put_data:   ; 0x32c6..0x3338  locals:
                                  ; ---- KOR-SUB.C:507
32c6  push   bp
32c7  mov    bp,sp
                                  ; ---- KOR-SUB.C:509
32c9  add    WORD PTR [_mili_sec],0x5
                                  ; ---- KOR-SUB.C:510
32ce  cmp    WORD PTR [_mili_sec],0x2d
32d3  jne    0x32e2
32d5  cmp    WORD PTR [_bonus_w],0x0
32da  je     0x32e2
32dc  dec    WORD PTR [_bonus_w]
32e0  jmp    0x332a
                                  ; ---- KOR-SUB.C:512
32e2  cmp    WORD PTR [_mili_sec],0x5a
32e7  jne    0x332a
                                  ; ---- KOR-SUB.C:513
32e9  cmp    WORD PTR [_bonus_w],0x0
32ee  je     0x32f4
32f0  dec    WORD PTR [_bonus_w]
                                  ; ---- KOR-SUB.C:514
32f4  cmp    WORD PTR [_timer_w],0x0
32f9  je     0x32ff
32fb  dec    WORD PTR [_timer_w]
                                  ; ---- KOR-SUB.C:515
32ff  inc    WORD PTR [_speed_sec]
3303  mov    ax,[_speed_sec]
3306  cmp    ax,0x3c
3309  jne    0x3324
                                  ; ---- KOR-SUB.C:516
330b  cmp    WORD PTR [_speed_w],0x0
3310  je     0x3318
3312  mov    ax,[_speed_w]
3315  dec    ax
3316  jmp    0x331b
3318  mov    ax,0x3
331b  mov    [_speed_w],ax
                                  ; ---- KOR-SUB.C:517
331e  mov    WORD PTR [_speed_sec],0x0
                                  ; ---- KOR-SUB.C:519
3324  mov    WORD PTR [_mili_sec],0x0
                                  ; ---- KOR-SUB.C:522
332a  call   _put_bonus
                                  ; ---- KOR-SUB.C:523
332d  call   _put_timer
                                  ; ---- KOR-SUB.C:524
3330  call   _put_speed
                                  ; ---- KOR-SUB.C:525
3333  call   _put_score
                                  ; ---- KOR-SUB.C:526
3336  pop    bp
3337  ret

; ---------------------------------------------------------------
_next_stage_put:   ; 0x3338..0x342f  locals: bp-10=next_img_ptn, bp-14=vad, bp-2=p, bp-38=next_img, bp-4=ii, bp-6=i, di=j, si=k
                                  ; ---- KOR-SUB.C:529
3338  push   bp
3339  mov    bp,sp
333b  sub    sp,0x26
333e  push   si                                   ; si=k
333f  push   di                                   ; di=j
3340  push   ss
3341  lea    ax,[bp-0x26]                         ; next_img
3344  push   ax
3345  push   ds
3346  mov    ax,0xbc8                             ; "�列列蓼"
3349  push   ax
334a  mov    cx,0x18
334d  call   0x0:0x5a94
                                  ; ---- KOR-SUB.C:535
3352  mov    al,[_point]
3355  cbw
3356  mov    bx,0x64
3359  cwd
335a  idiv   bx
335c  inc    dx
335d  mov    WORD PTR [bp-0x2],dx                 ; p
                                  ; ---- KOR-SUB.C:537
3360  mov    WORD PTR [bp-0x6],0x0                ; i
3365  jmp    0x3420
                                  ; ---- KOR-SUB.C:538
3368  mov    ax,WORD PTR [bp-0x6]                 ; i
336b  add    ax,0x1c
336e  shl    ax,1
3370  shl    ax,1
3372  shl    ax,1
3374  mov    WORD PTR [bp-0x4],ax                 ; ii
                                  ; ---- KOR-SUB.C:539
3377  xor    di,di                                ; di=j
3379  jmp    0x3415
                                  ; ---- KOR-SUB.C:540
                                  ; ---- KOR-SUB.C:541
337c  mov    ax,WORD PTR [bp-0x2]                 ; p
337f  mov    dx,0xc8
3382  mul    dx
3384  mov    bx,ax
3386  add    bx,0x43dd
338a  mov    ax,ds
338c  mov    es,ax
338e  mov    ax,WORD PTR [bp-0x6]                 ; i
3391  mov    dx,0xa
3394  mul    dx
3396  add    bx,ax
3398  cmp    BYTE PTR es:[bx+di],0x0              ; di=j
339c  je     0x33c9
339e  mov    ax,WORD PTR [bp-0x2]                 ; p
33a1  mov    dx,0xc8
33a4  mul    dx
33a6  mov    bx,ax
33a8  add    bx,0x43dd
33ac  mov    ax,ds
33ae  mov    es,ax
33b0  mov    ax,WORD PTR [bp-0x6]                 ; i
33b3  mov    dx,0xa
33b6  mul    dx
33b8  add    bx,ax
33ba  cmp    BYTE PTR es:[bx+di],0x6f             ; di=j
33be  jne    0x33c5
33c0  mov    bx,0x1
33c3  jmp    0x33c7
33c5  xor    bx,bx
33c7  jmp    0x33cc
33c9  mov    bx,0x2
33cc  shl    bx,1
33ce  shl    bx,1
33d0  shl    bx,1
33d2  lea    ax,[bp-0x26]                         ; next_img
33d5  add    bx,ax
33d7  mov    ax,ss
33d9  mov    es,ax
33db  mov    WORD PTR [bp-0x8],es
33de  mov    WORD PTR [bp-0xa],bx                 ; next_img_ptn
                                  ; ---- KOR-SUB.C:542
33e1  mov    si,WORD PTR [bp-0x4]                 ; ii | si=k
33e4  jmp    0x340a
                                  ; ---- KOR-SUB.C:543
33e6  mov    bx,si                                ; si=k
33e8  shl    bx,1
33ea  shl    bx,1
33ec  les    bx,DWORD PTR [bx+0x1a6c]             ; bx+_yad
33f0  add    bx,di                                ; di=j
33f2  inc    bx
33f3  inc    bx
33f4  mov    WORD PTR [bp-0xc],es
33f7  mov    WORD PTR [bp-0xe],bx                 ; vad
                                  ; ---- KOR-SUB.C:544
33fa  les    bx,DWORD PTR [bp-0xa]                ; next_img_ptn
33fd  mov    al,BYTE PTR es:[bx]
3400  les    bx,DWORD PTR [bp-0xe]                ; vad
3403  mov    BYTE PTR es:[bx],al
3406  inc    WORD PTR [bp-0xa]                    ; next_img_ptn
3409  inc    si                                   ; si=k
340a  mov    ax,WORD PTR [bp-0x4]                 ; ii
340d  add    ax,0x8
3410  cmp    ax,si                                ; si=k
3412  jg     0x33e6
3414  inc    di                                   ; di=j
3415  cmp    di,0xa                               ; di=j
3418  jge    0x341d
341a  jmp    0x337c
341d  inc    WORD PTR [bp-0x6]                    ; i
3420  cmp    WORD PTR [bp-0x6],0x14               ; i
3424  jge    0x3429
3426  jmp    0x3368
                                  ; ---- KOR-SUB.C:548
3429  pop    di                                   ; di=j
342a  pop    si                                   ; si=k
342b  mov    sp,bp
342d  pop    bp
342e  ret

; ---------------------------------------------------------------
_kor_y_end:   ; 0x342f..0x3454  locals:
                                  ; ---- KOR-SUB.C:551
342f  push   bp
3430  mov    bp,sp
                                  ; ---- KOR-SUB.C:554
3432  cmp    WORD PTR [_kory],0x2
3437  jge    0x343b
3439  jmp    0x3452
343b  jmp    0x3450
                                  ; ---- KOR-SUB.C:556
343d  call   _stage_down_check
3440  or     ax,ax
3442  je     0x3446
3444  jmp    0x3452
                                  ; ---- KOR-SUB.C:557
3446  inc    WORD PTR [_kory]
                                  ; ---- KOR-SUB.C:558
344a  mov    WORD PTR [_d_wait],0x0
                                  ; ---- KOR-SUB.C:555
3450  jmp    0x343d
                                  ; ---- KOR-SUB.C:560
3452  pop    bp
3453  ret

; ---------------------------------------------------------------
_power_rocket_make_set:   ; 0x3454..0x348d  locals:
                                  ; ---- KOR-SUB.C:563
3454  push   bp
3455  mov    bp,sp
                                  ; ---- KOR-SUB.C:565
3457  cmp    WORD PTR [_power_y],0x0
345c  jne    0x348b
345e  mov    bx,WORD PTR [_kory]
3462  inc    bx
3463  mov    cl,0x4
3465  shl    bx,cl
3467  add    bx,0x18ba
346b  mov    ax,ds
346d  mov    es,ax
346f  add    bx,WORD PTR [_korx]
3473  cmp    BYTE PTR es:[bx],0x0
3477  jne    0x348b
                                  ; ---- KOR-SUB.C:566
3479  mov    ax,[_kory]
347c  mov    [_power_y],ax
                                  ; ---- KOR-SUB.C:567
347f  mov    ax,[_korx]
3482  mov    [_power_x],ax
                                  ; ---- KOR-SUB.C:568
3485  mov    WORD PTR [_sub_flag],0x0
                                  ; ---- KOR-SUB.C:570
348b  pop    bp
348c  ret

; ---------------------------------------------------------------
_power_rocket_erase_set:   ; 0x348d..0x34a5  locals:
                                  ; ---- KOR-SUB.C:573
348d  push   bp
348e  mov    bp,sp
                                  ; ---- KOR-SUB.C:575
3490  cmp    WORD PTR [_power_y],0x0
3495  jne    0x34a3
                                  ; ---- KOR-SUB.C:576
3497  mov    ax,[_kory]
349a  mov    [_power_y],ax
                                  ; ---- KOR-SUB.C:577
349d  mov    ax,[_korx]
34a0  mov    [_power_x],ax
                                  ; ---- KOR-SUB.C:579
34a3  pop    bp
34a4  ret

; ---------------------------------------------------------------
_power_bomb_laser_turbo_set:   ; 0x34a5..0x34c3  locals:
                                  ; ---- KOR-SUB.C:582
34a5  push   bp
34a6  mov    bp,sp
                                  ; ---- KOR-SUB.C:584
34a8  cmp    WORD PTR [_sub_flag],0x63
34ad  jne    0x34c1
                                  ; ---- KOR-SUB.C:585
34af  mov    ax,[_kory]
34b2  mov    [_power_y],ax
                                  ; ---- KOR-SUB.C:586
34b5  mov    ax,[_korx]
34b8  mov    [_power_x],ax
                                  ; ---- KOR-SUB.C:587
34bb  mov    WORD PTR [_sub_flag],0x0
                                  ; ---- KOR-SUB.C:589
34c1  pop    bp
34c2  ret

; ---------------------------------------------------------------
_power_proc_set:   ; 0x34c3..0x34e4  locals:
                                  ; ---- KOR-SUB.C:592
34c3  push   bp
34c4  mov    bp,sp
                                  ; ---- KOR-SUB.C:595
34c6  mov    ax,[_STICK+0x4]
34c9  cmp    ax,0x7
34cc  je     0x34d5
34ce  cmp    ax,0x8
34d1  je     0x34da
34d3  jmp    0x34df
                                  ; ---- KOR-SUB.C:596
34d5  call   _power_rocket_make_set
34d8  jmp    0x34e2
                                  ; ---- KOR-SUB.C:597
34da  call   _power_rocket_erase_set
34dd  jmp    0x34e2
                                  ; ---- KOR-SUB.C:598
34df  call   _power_bomb_laser_turbo_set
                                  ; ---- KOR-SUB.C:600
34e2  pop    bp
34e3  ret

; ---------------------------------------------------------------
_put_bomb_pattern_and_store:   ; 0x34e4..0x3555  locals: bp+4=x, bp+6=y, bp+8=d, di=y, si=x
                                  ; ---- KOR-SUB.C:603
34e4  push   bp
34e5  mov    bp,sp
34e7  push   si                                   ; si=x
34e8  push   di                                   ; di=y
34e9  mov    di,WORD PTR [bp+0x6]                 ; y | di=y
34ec  mov    si,WORD PTR [bp+0x4]                 ; x | si=x
                                  ; ---- KOR-SUB.C:605
34ef  cmp    si,0x3                               ; si=x
34f2  jl     0x3503
34f4  cmp    si,0xc                               ; si=x
34f7  jg     0x3503
34f9  cmp    di,0x3                               ; di=y
34fc  jl     0x3503
34fe  cmp    di,0x16                              ; di=y
3501  jle    0x3505
3503  jmp    0x3551
                                  ; ---- KOR-SUB.C:606
3505  push   WORD PTR [bp+0xa]
3508  push   WORD PTR [bp+0x8]                    ; d
350b  push   di                                   ; di=y
350c  mov    ax,si                                ; si=x
350e  add    ax,0x8
3511  push   ax
3512  call   _putptn
3515  add    sp,0x8
                                  ; ---- KOR-SUB.C:607
3518  mov    ax,di                                ; di=y
351a  add    ax,0xfffd
351d  mov    dx,0xa
3520  mul    dx
3522  mov    bx,ax
3524  add    bx,si                                ; si=x
3526  mov    BYTE PTR [bx-0x6dd8],0xff
                                  ; ---- KOR-SUB.C:608
352b  mov    bx,di                                ; di=y
352d  mov    cl,0x4
352f  shl    bx,cl
3531  add    bx,0x18ba
3535  mov    ax,ds
3537  mov    es,ax
3539  cmp    BYTE PTR es:[bx+si],0x6f             ; si=x
353d  jae    0x3551
                                  ; ---- KOR-SUB.C:609
353f  mov    bx,di                                ; di=y
3541  mov    cl,0x4
3543  shl    bx,cl
3545  add    bx,0x18ba
3549  mov    ax,ds
354b  mov    es,ax
354d  mov    BYTE PTR es:[bx+si],0x6e             ; si=x
                                  ; ---- KOR-SUB.C:610
3551  pop    di                                   ; di=y
3552  pop    si                                   ; si=x
3553  pop    bp
3554  ret

; ---------------------------------------------------------------
_power_rocket_make_proc:   ; 0x3555..0x35e5  locals:
                                  ; ---- KOR-SUB.C:614
3555  push   bp
3556  mov    bp,sp
                                  ; ---- KOR-SUB.C:617
3558  mov    bx,WORD PTR [_power_y]
355c  mov    cl,0x4
355e  shl    bx,cl
3560  add    bx,0x18ba
3564  mov    ax,ds
3566  mov    es,ax
3568  add    bx,WORD PTR [_power_x]
356c  mov    BYTE PTR es:[bx],0x0
                                  ; ---- KOR-SUB.C:618
3570  cmp    WORD PTR [_power_y],0x0
3575  je     0x35df
                                  ; ---- KOR-SUB.C:619
3577  mov    bx,WORD PTR [_power_y]
357b  inc    bx
357c  mov    cl,0x4
357e  shl    bx,cl
3580  add    bx,0x18ba
3584  mov    ax,ds
3586  mov    es,ax
3588  add    bx,WORD PTR [_power_x]
358c  cmp    BYTE PTR es:[bx],0x60
3590  jbe    0x35b2
                                  ; ---- KOR-SUB.C:620
3592  mov    bx,WORD PTR [_power_y]
3596  mov    cl,0x4
3598  shl    bx,cl
359a  add    bx,0x18ba
359e  mov    ax,ds
35a0  mov    es,ax
35a2  add    bx,WORD PTR [_power_x]
35a6  mov    BYTE PTR es:[bx],0x6e
                                  ; ---- KOR-SUB.C:621
35aa  mov    WORD PTR [_power_y],0x0
                                  ; ---- KOR-SUB.C:622
35b0  jmp    0x35df
                                  ; ---- KOR-SUB.C:624
35b2  inc    WORD PTR [_power_y]
                                  ; ---- KOR-SUB.C:625
35b6  cmp    WORD PTR [_sub_flag],0x6
35bb  jge    0x35c1
35bd  inc    WORD PTR [_sub_flag]
                                  ; ---- KOR-SUB.C:626
35c1  mov    al,[_sub_flag]
35c4  add    al,0x26
35c6  mov    bx,WORD PTR [_power_y]
35ca  mov    cl,0x4
35cc  shl    bx,cl
35ce  add    bx,0x18ba
35d2  push   ax
35d3  mov    ax,ds
35d5  mov    es,ax
35d7  add    bx,WORD PTR [_power_x]
35db  pop    ax
35dc  mov    BYTE PTR es:[bx],al
                                  ; ---- KOR-SUB.C:628
35df  xor    ax,ax
35e1  jmp    0x35e3
                                  ; ---- KOR-SUB.C:629
35e3  pop    bp
35e4  ret

; ---------------------------------------------------------------
_power_rocket_erase_proc:   ; 0x35e5..0x3688  locals:
                                  ; ---- KOR-SUB.C:632
35e5  push   bp
35e6  mov    bp,sp
                                  ; ---- KOR-SUB.C:635
35e8  mov    bx,WORD PTR [_power_y]
35ec  mov    cl,0x4
35ee  shl    bx,cl
35f0  add    bx,0x18ba
35f4  mov    ax,ds
35f6  mov    es,ax
35f8  add    bx,WORD PTR [_power_x]
35fc  mov    BYTE PTR es:[bx],0x0
                                  ; ---- KOR-SUB.C:636
3600  cmp    WORD PTR [_power_y],0x0
3605  jne    0x360a
3607  jmp    0x3682
                                  ; ---- KOR-SUB.C:637
360a  inc    WORD PTR [_power_y]
                                  ; ---- KOR-SUB.C:638
360e  mov    bx,WORD PTR [_power_y]
3612  mov    cl,0x4
3614  shl    bx,cl
3616  add    bx,0x18ba
361a  mov    ax,ds
361c  mov    es,ax
361e  add    bx,WORD PTR [_power_x]
3622  cmp    BYTE PTR es:[bx],0x60
3626  jbe    0x366a
                                  ; ---- KOR-SUB.C:639
3628  mov    bx,WORD PTR [_power_y]
362c  mov    cl,0x4
362e  shl    bx,cl
3630  add    bx,0x18ba
3634  mov    ax,ds
3636  mov    es,ax
3638  add    bx,WORD PTR [_power_x]
363c  cmp    BYTE PTR es:[bx],0x6f
3640  jae    0x3662
                                  ; ---- KOR-SUB.C:640
3642  mov    bx,WORD PTR [_power_y]
3646  mov    cl,0x4
3648  shl    bx,cl
364a  add    bx,0x18ba
364e  mov    ax,ds
3650  mov    es,ax
3652  add    bx,WORD PTR [_power_x]
3656  mov    BYTE PTR es:[bx],0x0
                                  ; ---- KOR-SUB.C:641
365a  mov    WORD PTR [_power_y],0x0
                                  ; ---- KOR-SUB.C:642
3660  jmp    0x3668
                                  ; ---- KOR-SUB.C:643
3662  mov    WORD PTR [_power_y],0x0
                                  ; ---- KOR-SUB.C:644
3668  jmp    0x3682
                                  ; ---- KOR-SUB.C:646
366a  mov    bx,WORD PTR [_power_y]
366e  mov    cl,0x4
3670  shl    bx,cl
3672  add    bx,0x18ba
3676  mov    ax,ds
3678  mov    es,ax
367a  add    bx,WORD PTR [_power_x]
367e  mov    BYTE PTR es:[bx],0xc
                                  ; ---- KOR-SUB.C:649
3682  xor    ax,ax
3684  jmp    0x3686
                                  ; ---- KOR-SUB.C:651
3686  pop    bp
3687  ret

; ---------------------------------------------------------------
_power_bomb_proc:   ; 0x3688..0x38c3  locals: bp-2=i, di=j, si=k
                                  ; ---- KOR-SUB.C:654
3688  push   bp
3689  mov    bp,sp
368b  sub    sp,0x2
368e  push   si                                   ; si=k
368f  push   di                                   ; di=j
                                  ; ---- KOR-SUB.C:658
3690  cmp    WORD PTR [_sub_flag],0x0
3695  je     0x369c
3697  xor    ax,ax
3699  jmp    0x38bd
                                  ; ---- KOR-SUB.C:659
369c  mov    WORD PTR [_sub_flag],0x1
                                  ; ---- KOR-SUB.C:661
36a2  call   _nosound
                                  ; ---- KOR-SUB.C:662
36a5  mov    WORD PTR [bp-0x2],0x1b               ; i
36aa  jmp    0x38ac
                                  ; ---- KOR-SUB.C:664
36ad  push   ds
36ae  mov    ax,WORD PTR [bp-0x2]                 ; i
36b1  mov    cl,0x5
36b3  shl    ax,cl
36b5  add    ax,0x20ae
36b8  push   ax
36b9  push   WORD PTR [_power_y]
36bd  push   WORD PTR [_power_x]
36c1  call   _put_bomb_pattern_and_store
36c4  add    sp,0x8
                                  ; ---- KOR-SUB.C:665
36c7  call   _clock_wait
                                  ; ---- KOR-SUB.C:667
36ca  push   ds
36cb  mov    ax,WORD PTR [bp-0x2]                 ; i
36ce  mov    cl,0x5
36d0  shl    ax,cl
36d2  add    ax,0x20ae
36d5  push   ax
36d6  push   WORD PTR [_power_y]
36da  mov    ax,[_power_x]
36dd  dec    ax
36de  push   ax
36df  call   _put_bomb_pattern_and_store
36e2  add    sp,0x8
                                  ; ---- KOR-SUB.C:668
36e5  push   ds
36e6  mov    ax,WORD PTR [bp-0x2]                 ; i
36e9  mov    cl,0x5
36eb  shl    ax,cl
36ed  add    ax,0x20ae
36f0  push   ax
36f1  push   WORD PTR [_power_y]
36f5  mov    ax,[_power_x]
36f8  inc    ax
36f9  push   ax
36fa  call   _put_bomb_pattern_and_store
36fd  add    sp,0x8
                                  ; ---- KOR-SUB.C:669
3700  push   ds
3701  mov    ax,WORD PTR [bp-0x2]                 ; i
3704  mov    cl,0x5
3706  shl    ax,cl
3708  add    ax,0x20ae
370b  push   ax
370c  mov    ax,[_power_y]
370f  dec    ax
3710  push   ax
3711  push   WORD PTR [_power_x]
3715  call   _put_bomb_pattern_and_store
3718  add    sp,0x8
                                  ; ---- KOR-SUB.C:670
371b  push   ds
371c  mov    ax,WORD PTR [bp-0x2]                 ; i
371f  mov    cl,0x5
3721  shl    ax,cl
3723  add    ax,0x20ae
3726  push   ax
3727  mov    ax,[_power_y]
372a  inc    ax
372b  push   ax
372c  push   WORD PTR [_power_x]
3730  call   _put_bomb_pattern_and_store
3733  add    sp,0x8
                                  ; ---- KOR-SUB.C:671
3736  call   _clock_wait
                                  ; ---- KOR-SUB.C:673
3739  mov    di,WORD PTR [_power_x]               ; di=j
373d  dec    di                                   ; di=j
373e  jmp    0x3769
                                  ; ---- KOR-SUB.C:674
3740  mov    si,WORD PTR [_power_y]               ; si=k
3744  add    si,0xfffe                            ; si=k
3747  jmp    0x375e
                                  ; ---- KOR-SUB.C:675
3749  push   ds
374a  mov    ax,WORD PTR [bp-0x2]                 ; i
374d  mov    cl,0x5
374f  shl    ax,cl
3751  add    ax,0x20ae
3754  push   ax
3755  push   si                                   ; si=k
3756  push   di                                   ; di=j
3757  call   _put_bomb_pattern_and_store
375a  add    sp,0x8
375d  inc    si                                   ; si=k
375e  mov    ax,[_power_y]
3761  add    ax,0x3
3764  cmp    ax,si                                ; si=k
3766  jg     0x3749
3768  inc    di                                   ; di=j
3769  mov    ax,[_power_x]
376c  inc    ax
376d  inc    ax
376e  cmp    ax,di                                ; di=j
3770  jg     0x3740
                                  ; ---- KOR-SUB.C:676
3772  mov    di,WORD PTR [_power_x]               ; di=j
3776  add    di,0xfffe                            ; di=j
3779  jmp    0x37a3
                                  ; ---- KOR-SUB.C:677
377b  mov    si,WORD PTR [_power_y]               ; si=k
377f  dec    si                                   ; si=k
3780  jmp    0x3797
                                  ; ---- KOR-SUB.C:678
3782  push   ds
3783  mov    ax,WORD PTR [bp-0x2]                 ; i
3786  mov    cl,0x5
3788  shl    ax,cl
378a  add    ax,0x20ae
378d  push   ax
378e  push   si                                   ; si=k
378f  push   di                                   ; di=j
3790  call   _put_bomb_pattern_and_store
3793  add    sp,0x8
3796  inc    si                                   ; si=k
3797  mov    ax,[_power_y]
379a  inc    ax
379b  inc    ax
379c  cmp    ax,si                                ; si=k
379e  jg     0x3782
37a0  add    di,0x4                               ; di=j
37a3  mov    ax,[_power_x]
37a6  add    ax,0x3
37a9  cmp    ax,di                                ; di=j
37ab  jg     0x377b
                                  ; ---- KOR-SUB.C:679
37ad  call   _clock_wait
                                  ; ---- KOR-SUB.C:681
37b0  mov    di,WORD PTR [_power_x]               ; di=j
37b4  add    di,0xfffe                            ; di=j
37b7  jmp    0x37e2
                                  ; ---- KOR-SUB.C:682
37b9  mov    si,WORD PTR [_power_y]               ; si=k
37bd  add    si,0xfffd                            ; si=k
37c0  jmp    0x37d7
                                  ; ---- KOR-SUB.C:683
37c2  push   ds
37c3  mov    ax,WORD PTR [bp-0x2]                 ; i
37c6  mov    cl,0x5
37c8  shl    ax,cl
37ca  add    ax,0x20ae
37cd  push   ax
37ce  push   si                                   ; si=k
37cf  push   di                                   ; di=j
37d0  call   _put_bomb_pattern_and_store
37d3  add    sp,0x8
37d6  inc    si                                   ; si=k
37d7  mov    ax,[_power_y]
37da  add    ax,0x4
37dd  cmp    ax,si                                ; si=k
37df  jg     0x37c2
37e1  inc    di                                   ; di=j
37e2  mov    ax,[_power_x]
37e5  add    ax,0x3
37e8  cmp    ax,di                                ; di=j
37ea  jg     0x37b9
                                  ; ---- KOR-SUB.C:684
37ec  mov    di,WORD PTR [_power_x]               ; di=j
37f0  add    di,0xfffd                            ; di=j
37f3  jmp    0x3820
                                  ; ---- KOR-SUB.C:685
37f5  mov    si,WORD PTR [_power_y]               ; si=k
37f9  add    si,0xfffe                            ; si=k
37fc  jmp    0x3813
                                  ; ---- KOR-SUB.C:686
37fe  push   ds
37ff  mov    ax,WORD PTR [bp-0x2]                 ; i
3802  mov    cl,0x5
3804  shl    ax,cl
3806  add    ax,0x20ae
3809  push   ax
380a  push   si                                   ; si=k
380b  push   di                                   ; di=j
380c  call   _put_bomb_pattern_and_store
380f  add    sp,0x8
3812  inc    si                                   ; si=k
3813  mov    ax,[_power_y]
3816  add    ax,0x3
3819  cmp    ax,si                                ; si=k
381b  jg     0x37fe
381d  add    di,0x6                               ; di=j
3820  mov    ax,[_power_x]
3823  add    ax,0x4
3826  cmp    ax,di                                ; di=j
3828  jg     0x37f5
                                  ; ---- KOR-SUB.C:687
382a  push   ds
382b  mov    ax,WORD PTR [bp-0x2]                 ; i
382e  mov    cl,0x5
3830  shl    ax,cl
3832  add    ax,0x20ae
3835  push   ax
3836  mov    ax,[_power_y]
3839  add    ax,0xfffe
383c  push   ax
383d  mov    ax,[_power_x]
3840  add    ax,0xfffe
3843  push   ax
3844  call   _put_bomb_pattern_and_store
3847  add    sp,0x8
                                  ; ---- KOR-SUB.C:688
384a  push   ds
384b  mov    ax,WORD PTR [bp-0x2]                 ; i
384e  mov    cl,0x5
3850  shl    ax,cl
3852  add    ax,0x20ae
3855  push   ax
3856  mov    ax,[_power_y]
3859  inc    ax
385a  inc    ax
385b  push   ax
385c  mov    ax,[_power_x]
385f  add    ax,0xfffe
3862  push   ax
3863  call   _put_bomb_pattern_and_store
3866  add    sp,0x8
                                  ; ---- KOR-SUB.C:689
3869  push   ds
386a  mov    ax,WORD PTR [bp-0x2]                 ; i
386d  mov    cl,0x5
386f  shl    ax,cl
3871  add    ax,0x20ae
3874  push   ax
3875  mov    ax,[_power_y]
3878  add    ax,0xfffe
387b  push   ax
387c  mov    ax,[_power_x]
387f  inc    ax
3880  inc    ax
3881  push   ax
3882  call   _put_bomb_pattern_and_store
3885  add    sp,0x8
                                  ; ---- KOR-SUB.C:690
3888  push   ds
3889  mov    ax,WORD PTR [bp-0x2]                 ; i
388c  mov    cl,0x5
388e  shl    ax,cl
3890  add    ax,0x20ae
3893  push   ax
3894  mov    ax,[_power_y]
3897  inc    ax
3898  inc    ax
3899  push   ax
389a  mov    ax,[_power_x]
389d  inc    ax
389e  inc    ax
389f  push   ax
38a0  call   _put_bomb_pattern_and_store
38a3  add    sp,0x8
                                  ; ---- KOR-SUB.C:691
38a6  call   _clock_wait
38a9  inc    WORD PTR [bp-0x2]                    ; i
38ac  cmp    WORD PTR [bp-0x2],0x20               ; i
38b0  jge    0x38b5
38b2  jmp    0x36ad
                                  ; ---- KOR-SUB.C:693
38b5  call   _put_stage
                                  ; ---- KOR-SUB.C:694
38b8  mov    ax,0x1
38bb  jmp    0x38bd
                                  ; ---- KOR-SUB.C:695
38bd  pop    di                                   ; di=j
38be  pop    si                                   ; si=k
38bf  mov    sp,bp
38c1  pop    bp
38c2  ret

; ---------------------------------------------------------------
_power_laser_proc:   ; 0x38c3..0x3930  locals: si=i
                                  ; ---- KOR-SUB.C:698
38c3  push   bp
38c4  mov    bp,sp
38c6  push   si                                   ; si=i
                                  ; ---- KOR-SUB.C:702
38c7  cmp    WORD PTR [_sub_flag],0x0
38cc  je     0x38d2
38ce  xor    ax,ax
38d0  jmp    0x392d
                                  ; ---- KOR-SUB.C:703
38d2  mov    WORD PTR [_sub_flag],0x1
                                  ; ---- KOR-SUB.C:705
38d8  call   _nosound
                                  ; ---- KOR-SUB.C:706
38db  push   ds
38dc  mov    ax,0x220e                            ; &_chr+0x160?
38df  push   ax
38e0  push   WORD PTR [_power_y]
38e4  push   WORD PTR [_power_x]
38e8  call   _put_bomb_pattern_and_store
38eb  add    sp,0x8
                                  ; ---- KOR-SUB.C:707
38ee  call   _clock_wait
                                  ; ---- KOR-SUB.C:708
38f1  xor    si,si                                ; si=i
38f3  jmp    0x3923
                                  ; ---- KOR-SUB.C:709
38f5  push   ds
38f6  mov    ax,0x23ee                            ; &_chr+0x340?
38f9  push   ax
38fa  push   WORD PTR [_power_y]
38fe  mov    ax,[_power_x]
3901  sub    ax,si                                ; si=i
3903  push   ax
3904  call   _put_bomb_pattern_and_store
3907  add    sp,0x8
                                  ; ---- KOR-SUB.C:710
390a  push   ds
390b  mov    ax,0x23ee                            ; &_chr+0x340?
390e  push   ax
390f  push   WORD PTR [_power_y]
3913  mov    ax,[_power_x]
3916  add    ax,si                                ; si=i
3918  push   ax
3919  call   _put_bomb_pattern_and_store
391c  add    sp,0x8
                                  ; ---- KOR-SUB.C:711
391f  call   _clock_wait
3922  inc    si                                   ; si=i
3923  cmp    si,0xa                               ; si=i
3926  jl     0x38f5
                                  ; ---- KOR-SUB.C:713
3928  mov    ax,0x1
392b  jmp    0x392d
                                  ; ---- KOR-SUB.C:714
392d  pop    si                                   ; si=i
392e  pop    bp
392f  ret

; ---------------------------------------------------------------
_power_turbo_proc:   ; 0x3930..0x3a1c  locals: bp-10=vad, bp-2=p2, bp-4=p1, bp-6=k, di=j, si=i
                                  ; ---- KOR-SUB.C:717
3930  push   bp
3931  mov    bp,sp
3933  sub    sp,0xa
3936  push   si                                   ; si=i
3937  push   di                                   ; di=j
                                  ; ---- KOR-SUB.C:722
3938  cmp    WORD PTR [_sub_flag],0x0
393d  je     0x3944
393f  xor    ax,ax
3941  jmp    0x3a16
                                  ; ---- KOR-SUB.C:723
3944  mov    WORD PTR [_sub_flag],0x1
                                  ; ---- KOR-SUB.C:725
394a  mov    WORD PTR [bp-0x6],0x0                ; k
394f  jmp    0x398c
                                  ; ---- KOR-SUB.C:726
3951  mov    si,0x30                              ; si=i
3954  jmp    0x3980
                                  ; ---- KOR-SUB.C:727
3956  mov    bx,si                                ; si=i
3958  shl    bx,1
395a  shl    bx,1
395c  les    bx,DWORD PTR [bx+0x1a6c]             ; bx+_yad
3960  add    bx,0x16
3963  mov    WORD PTR [bp-0x8],es
3966  mov    WORD PTR [bp-0xa],bx                 ; vad
                                  ; ---- KOR-SUB.C:728
3969  xor    di,di                                ; di=j
396b  jmp    0x397a
                                  ; ---- KOR-SUB.C:729
396d  les    bx,DWORD PTR [bp-0xa]                ; vad
3970  xor    WORD PTR es:[bx],0xffff
3975  add    WORD PTR [bp-0xa],0x2                ; vad
3979  inc    di                                   ; di=j
397a  cmp    di,0xa                               ; di=j
397d  jl     0x396d
397f  inc    si                                   ; si=i
3980  cmp    si,0x170                             ; si=i
3984  jl     0x3956
                                  ; ---- KOR-SUB.C:731
3986  call   _clock_wait
3989  inc    WORD PTR [bp-0x6]                    ; k
398c  cmp    WORD PTR [bp-0x6],0x2                ; k
3990  jl     0x3951
                                  ; ---- KOR-SUB.C:734
3992  mov    si,0x3                               ; si=i
3995  jmp    0x3a09
                                  ; ---- KOR-SUB.C:735
3997  mov    WORD PTR [bp-0x4],0x16               ; p1
                                  ; ---- KOR-SUB.C:736
399c  mov    WORD PTR [bp-0x2],0x16               ; p2
39a1  jmp    0x39e4
                                  ; ---- KOR-SUB.C:737
39a3  mov    bx,WORD PTR [bp-0x2]                 ; p2
39a6  mov    cl,0x4
39a8  shl    bx,cl
39aa  add    bx,0x18ba
39ae  mov    ax,ds
39b0  mov    es,ax
39b2  cmp    BYTE PTR es:[bx+si],0x60             ; si=i
39b6  jbe    0x39e1
39b8  mov    bx,WORD PTR [bp-0x2]                 ; p2
39bb  mov    cl,0x4
39bd  shl    bx,cl
39bf  add    bx,0x18ba
39c3  mov    ax,ds
39c5  mov    es,ax
39c7  mov    al,BYTE PTR es:[bx+si]               ; si=i
39ca  mov    bx,WORD PTR [bp-0x4]                 ; p1
39cd  mov    cl,0x4
39cf  shl    bx,cl
39d1  add    bx,0x18ba
39d5  push   ax
39d6  mov    ax,ds
39d8  mov    es,ax
39da  pop    ax
39db  mov    BYTE PTR es:[bx+si],al               ; si=i
39de  dec    WORD PTR [bp-0x4]                    ; p1
39e1  dec    WORD PTR [bp-0x2]                    ; p2
39e4  cmp    WORD PTR [bp-0x2],0x0                ; p2
39e8  jge    0x39a3
39ea  jmp    0x3a02
                                  ; ---- KOR-SUB.C:739
39ec  mov    bx,WORD PTR [bp-0x4]                 ; p1
39ef  mov    cl,0x4
39f1  shl    bx,cl
39f3  add    bx,0x18ba
39f7  mov    ax,ds
39f9  mov    es,ax
39fb  mov    BYTE PTR es:[bx+si],0x0              ; si=i
                                  ; ---- KOR-SUB.C:738
39ff  dec    WORD PTR [bp-0x4]                    ; p1
3a02  cmp    WORD PTR [bp-0x4],0x2                ; p1
3a06  jg     0x39ec
3a08  inc    si                                   ; si=i
3a09  cmp    si,0xd                               ; si=i
3a0c  jge    0x3a11
3a0e  jmp    0x3997
                                  ; ---- KOR-SUB.C:741
3a11  mov    ax,0x1
3a14  jmp    0x3a16
                                  ; ---- KOR-SUB.C:742
3a16  pop    di                                   ; di=j
3a17  pop    si                                   ; si=i
3a18  mov    sp,bp
3a1a  pop    bp
3a1b  ret

; ---------------------------------------------------------------
_power_process:   ; 0x3a1c..0x3a58  locals:
                                  ; ---- KOR-SUB.C:746
3a1c  push   bp
3a1d  mov    bp,sp
                                  ; ---- KOR-SUB.C:749
3a1f  mov    ax,[_STICK+0x4]
3a22  sub    ax,0x7
3a25  cmp    ax,0x4
3a28  ja     0x3a56
3a2a  mov    bx,ax
3a2c  shl    bx,1
3a2e  jmp    WORD PTR cs:[bx+0x3a33]              ; bx+_chr+0x1985
3a33  dw case_0 -> 0x3a3d
3a35  dw case_1 -> 0x3a42
3a37  dw case_2 -> 0x3a47
3a39  dw case_3 -> 0x3a4c
3a3b  dw case_4 -> 0x3a51
                                  ; ---- KOR-SUB.C:750
3a3d  call   _power_rocket_make_proc
3a40  jmp    0x3a56
                                  ; ---- KOR-SUB.C:751
3a42  call   _power_rocket_erase_proc
3a45  jmp    0x3a56
                                  ; ---- KOR-SUB.C:752
3a47  call   _power_bomb_proc
3a4a  jmp    0x3a56
                                  ; ---- KOR-SUB.C:753
3a4c  call   _power_laser_proc
3a4f  jmp    0x3a56
                                  ; ---- KOR-SUB.C:754
3a51  call   _power_turbo_proc
3a54  jmp    0x3a56
                                  ; ---- KOR-SUB.C:756
3a56  pop    bp
3a57  ret

;======================================================================
; MODULE KOREA.C
;======================================================================

; ---------------------------------------------------------------
_main:   ; 0x3a58..0x3ba5  locals:
                                  ; ---- KOREA.C:121
3a58  push   bp
3a59  mov    bp,sp
                                  ; ---- KOREA.C:124
3a5b  call   _chrinit
3a5e  or     ax,ax
3a60  je     0x3a76
                                  ; ---- KOREA.C:125
3a62  push   ds
3a63  mov    ax,0x1356                            ; "Not found "KOREA.PTN" image data file.
"
3a66  push   ax
3a67  call   _printf
3a6a  add    sp,0x4
                                  ; ---- KOREA.C:126
3a6d  mov    ax,0x1
3a70  push   ax
3a71  call   _exit
3a74  inc    sp
3a75  inc    sp
                                  ; ---- KOREA.C:128
3a76  call   _stage_load
3a79  or     ax,ax
3a7b  je     0x3a91
                                  ; ---- KOREA.C:129
3a7d  push   ds
3a7e  mov    ax,0x137e                            ; "Not found "KOREA.STG" stage data file.
"
3a81  push   ax
3a82  call   _printf
3a85  add    sp,0x4
                                  ; ---- KOREA.C:130
3a88  mov    ax,0x1
3a8b  push   ax
3a8c  call   _exit
3a8f  inc    sp
3a90  inc    sp
                                  ; ---- KOREA.C:133
3a91  call   _grset
                                  ; ---- KOREA.C:135
3a94  mov    WORD PTR [_flag],0x64
                                  ; ---- KOREA.C:136
3a9a  xor    ax,ax
3a9c  mov    [_windowy1],ax
3a9f  mov    [_windowx1],ax
3aa2  mov    WORD PTR [_windowx2],0x28
3aa8  mov    WORD PTR [_windowy2],0x1a
                                  ; ---- KOREA.C:139
3aae  mov    ax,[_flag]
3ab1  cmp    ax,0x21
3ab4  jne    0x3ab9
3ab6  jmp    0x3b6a
3ab9  jg     0x3b08
3abb  cmp    ax,0x17
3abe  jne    0x3ac3
3ac0  jmp    0x3b56
3ac3  jg     0x3aed
3ac5  cmp    ax,0x6
3ac8  jne    0x3acd
3aca  jmp    0x3b4c
3acd  jg     0x3ae2
3acf  cmp    ax,0x2
3ad2  jne    0x3ad7
3ad4  jmp    0x3b42
3ad7  cmp    ax,0x3
3ada  jne    0x3adf
3adc  jmp    0x3b47
3adf  jmp    0x3b97
3ae2  cmp    ax,0x14
3ae5  jne    0x3aea
3ae7  jmp    0x3b51
3aea  jmp    0x3b97
3aed  cmp    ax,0x1a
3af0  jne    0x3af5
3af2  jmp    0x3b5b
3af5  cmp    ax,0x1e
3af8  jne    0x3afd
3afa  jmp    0x3b60
3afd  cmp    ax,0x1f
3b00  jne    0x3b05
3b02  jmp    0x3b65
3b05  jmp    0x3b97
3b08  cmp    ax,0x50
3b0b  jne    0x3b10
3b0d  jmp    0x3b83
3b10  jg     0x3b31
3b12  cmp    ax,0x3c
3b15  jne    0x3b1a
3b17  jmp    0x3b79
3b1a  jg     0x3b29
3b1c  cmp    ax,0x28
3b1f  je     0x3b6f
3b21  cmp    ax,0x32
3b24  je     0x3b74
3b26  jmp    0x3b97
3b29  cmp    ax,0x42
3b2c  je     0x3b7e
3b2e  jmp    0x3b97
3b31  cmp    ax,0x53
3b34  je     0x3b88
3b36  cmp    ax,0x64
3b39  je     0x3b8d
3b3b  cmp    ax,0xc8
3b3e  je     0x3b92
3b40  jmp    0x3b97
                                  ; ---- KOREA.C:140
3b42  call   _game_start_init
3b45  jmp    0x3b97
                                  ; ---- KOREA.C:141
3b47  call   _stage_init
3b4a  jmp    0x3b97
                                  ; ---- KOREA.C:142
3b4c  call   _get_stick
3b4f  jmp    0x3b97
                                  ; ---- KOREA.C:143
3b51  call   _run_stick
3b54  jmp    0x3b97
                                  ; ---- KOREA.C:144
3b56  call   _run_power
3b59  jmp    0x3b97
                                  ; ---- KOREA.C:145
3b5b  call   _stage_stick_set
3b5e  jmp    0x3b97
                                  ; ---- KOREA.C:146
3b60  call   _stick_clear_check
3b63  jmp    0x3b97
                                  ; ---- KOREA.C:147
3b65  call   _stick_clear_sub1
3b68  jmp    0x3b97
                                  ; ---- KOREA.C:148
3b6a  call   _stick_clear_sub2
3b6d  jmp    0x3b97
                                  ; ---- KOREA.C:149
3b6f  call   _screen_up_check
3b72  jmp    0x3b97
                                  ; ---- KOREA.C:150
3b74  call   _run_option
3b77  jmp    0x3b97
                                  ; ---- KOREA.C:151
3b79  call   _subtract_stick
3b7c  jmp    0x3b97
                                  ; ---- KOREA.C:152
3b7e  call   _game_over
3b81  jmp    0x3b97
                                  ; ---- KOREA.C:153
3b83  call   _screen_clear_up
3b86  jmp    0x3b97
                                  ; ---- KOREA.C:154
3b88  call   _screen_up_sub
3b8b  jmp    0x3b97
                                  ; ---- KOREA.C:156
3b8d  call   _game_title
3b90  jmp    0x3ba0
                                  ; ---- KOREA.C:157
3b92  call   _user_stage
3b95  jmp    0x3ba0
                                  ; ---- KOREA.C:160
3b97  call   _put_stage
                                  ; ---- KOREA.C:161
3b9a  call   _put_data
                                  ; ---- KOREA.C:163
3b9d  call   _clock_wait
                                  ; ---- KOREA.C:164
3ba0  jmp    0x3aae
                                  ; ---- KOREA.C:165
3ba3  pop    bp
3ba4  ret
