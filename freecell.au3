
Opt("SendKeyDelay", 20)
Opt("WinTitleMatchMode", 1) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
Opt("MouseCoordMode", 2) ;1=absolute, 0=relative, 2=client
Opt("PixelCoordMode", 2) ;1=absolute, 0=relative, 2=client

Global $cardnames[52]=['Ac','Ad','Ah','As','2c','2d','2h','2s','3c','3d','3h','3s','4c','4d','4h','4s','5c','5d','5h','5s','6c','6d','6h','6s','7c','7d','7h','7s','8c','8d','8h','8s','9c','9d','9h','9s','Tc','Td','Th','Ts','Jc','Jd','Jh','Js','Qc','Qd','Qh','Qs','Kc','Kd','Kh','Ks']
Global $cardnumbers[52]=[1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8,9,9,9,9,10,10,10,10,11,11,11,11,12,12,12,12,13,13,13,13]
Global $foundations[4]=[0,0,0,0] ;keeps track of the current number on the foundations, cdhs

Global $stacklens[8]=[7,7,7,7,6,6,6,6]
Global $freecells[4]=[-1,-1,-1,-1]
Global $board[12][25]
for $i=0 to 11
   for $j=0 to 24
      $board[$i][$j]=-1
   Next
Next


$xoffset=20
$yoffset=5

$stackhorizoffset=83
$stackvertoffset=17
$fchorizoffset=80

;inner width, ie. clickable area starting at offset
$cwidth=30
$cheight=70


; A-K,CDHS
Global $cardpixels[52]
$file = FileOpen("worldwinner/cards.txt")
for $i=0 to 51
   $cardpixels[$i]=FileReadLine($file)
Next
FileClose($file)

winactivate('http://www.worldwinner.com/')


; top of cards 360,178
; cards 17 pixels apart vertically
; 83 pixels apart horizontally
; first card starts at 114, 112
; foundation piles start at ~470,7
; foundations are 80 apart horizontally
; freecells start at 99,7
; they are 80 apart horizontally

ConsoleWrite('Reading card layout...'&@CRLF)
Global $cards[52][4]
$file=FileOpen('worldwinner/fc.txt',2)
$cnt=0
for $i=0 to 7
   $m=6
   if $i>3 then
      $m=5
   EndIf
   for $j=0 to $m
      $s=''
      $x=124+($i*$stackhorizoffset)
      $y=112+($j*$stackvertoffset)
      for $k=9 to 14
         $s=$s&pixelgetcolor($x,$y+$k)
      Next
      $s=$s&pixelgetcolor($x+7,$y+12)&pixelgetcolor($x+15,$y+14)

      for $l=0 to 51
         if $cardpixels[$l]==$s then
            $board[$i][$j]=$cnt
            ;$cards[$cnt][0]=$cardnames[$l]
            ;$cards[$cnt][1]=$x-10+$xoffset
            ;$cards[$cnt][2]=$y+$yoffset
            $cards[$cnt][0]=$cardnames[$l]
            $cards[$cnt][1]=$s
            $cards[$cnt][2]=$cardnumbers[$l]
            $cards[$cnt][3]=StringRight($cardnames[$l],1) ;cardsuit

            if $j=0 Then
               $line=$cardnames[$l]
            Else
               $line&=' '&$cardnames[$l]
            EndIf
            $cnt+=1
            ExitLoop
         EndIf
      Next
   Next
   FileWrite($file,$line&@CRLF)
   ConsoleWrite($line&@CRLF)
Next
FileClose($file)


ConsoleWrite('Getting solution from fc-solve...'&@CRLF)
;start fc-solve to solve the game
Run('cmd')
WinWaitActive('C:\Windows\system32\cmd.exe')
Send('fc-solve -m C:\Users\Dan\Dropbox\autoitPrograms\worldwinner\fc.txt > C:\Users\Dan\Dropbox\autoitPrograms\worldwinner\fcsol.txt{enter}')
Sleep(1000)
WinClose('C:\Windows\system32\cmd.exe')

ConsoleWrite('Solving game...'&@CRLF)
$cnt=0
$file=FileOpen('worldwinner/fcsol.txt')
while True
   #cs
   if WinExists('FreeCell:') Then
      ConsoleWrite('Found the winning window!'&@CRLF)
      Exit
   EndIf
   #ce

   $line=FileReadLine($file)
   if @error=-1 then exitloop
   if StringInStr($line,'Move') Then
      winactivate('http://www.worldwinner.com/')
      $split=StringSplit($line,' ',2)
      if $split[4]=='stack' Then ;from stack
         if $split[7]=='stack' Then
            movecards(int($split[1]),int($split[5]),int($split[8]))
         ElseIf $split[7]=='freecell' Then
            movecards(1,int($split[5]),int($split[8])+8)
         Else
            movecards(1,int($split[5]),99)
         EndIf
      Else ;from freecell
         if $split[7]=='stack' Then
            movecards(1,int($split[5])+8,int($split[8]))
         Else
            movecards(1,int($split[5])+8,99)
         EndIf
      EndIf

      if $cnt=0 Then
         For $i=0 to 3
            ConsoleWrite($foundations[$i]&' ')
         Next
         ConsoleWrite(@crlf)
         MsgBox(0,'','First move. Move ace if need to')
      EndIf

      $cnt+=1
      if mod($cnt,5)=0 then ;if $cnt>40 and mod($cnt,10)=0 then
         printboard()
         MsgBox(0,'','keep going?')
      EndIf
   EndIf
WEnd
FileClose($file)

Func printboard()
   ConsoleWrite('Board:'&@crlf)
   for $i=0 to 7
      for $j=0 to 19
         if $board[$i][$j]>-1 Then
            ConsoleWrite($cards[$board[$i][$j]][0]&' ')
         Else
            ;ConsoleWrite('-1 ')
            ExitLoop
         EndIf
      Next
      ConsoleWrite(@crlf)
   Next
   For $i=0 to 3
      ConsoleWrite($foundations[$i]&' ')
   Next
   ConsoleWrite(@crlf)
EndFunc

Func movecards($n,$from,$to)
   $r1=0
   ;$r2=0

   $rand=Random(0,6,1)
   if $rand<2 Then
      ;$r1=Random(0,100,1)
      $r2=Random(4,5,1)
   elseif $rand<5 Then
      ;$r1=Random(100,200,1)
      $r2=Random(5,7,1)
   Elseif $rand<7 Then
      ;$r1=Random(200,400,1)
      $r2=Random(7,8,1)
   Else
      ;$r1=Random(400,750,1)
      $r2=Random(8,12,1)
   EndIf


   if $from<8 then ;stack to something
      $fromx=114+$from*$stackhorizoffset+$xoffset
      $fromy=112+($stacklens[$from]-$n)*$stackvertoffset+$yoffset
      if $to<8 then ;s to s
         $tox=114+$to*$stackhorizoffset+$xoffset
         $toy=112+$stacklens[$to]*$stackvertoffset+$yoffset

         For $i=$n To 1 Step -1
            $board[$to][$stacklens[$to]]=$board[$from][$stacklens[$from]-$i]
            $board[$from][$stacklens[$from]-$i]=-1
            $stacklens[$to]+=1
         Next
         $stacklens[$from]-=$n
         ;Sleep($r1)
         if $n=1 Then
            MouseClickDrag('primary',$fromx+random(0,$cwidth,1),$fromy+random(0,$cheight,1),$tox+random(0,$cwidth,1),$toy+random(0,$cheight,1),$r2)
         Else
            MouseClickDrag('primary',$fromx+random(0,$cwidth,1),$fromy+random(0,10,1),$tox+random(0,$cwidth,1),$toy+random(0,$cheight,1),$r2)
         EndIf
      ElseIf $to<12  Then ;s to fc
         $actualto=-1
         for $i=0 to UBound($freecells)-1
            if $freecells[$i]=-1 Then
               $actualto=$i
               ExitLoop
            EndIf
         Next
         $freecells[$actualto]=$to-8

         $tox=99+$actualto*$fchorizoffset+$xoffset
         $toy=7+$yoffset

         ;Sleep($r1)

         $clickx=$fromx+random(0,$cwidth,1)
         $clicky=$fromy+random(0,$cheight,1)

         Opt("MouseClickDelay", Random(80,200,1))
         MouseClick('primary', $clickx, $clicky, 2, $r2)

         $board[$to][0]=$board[$from][$stacklens[$from]-1]
         $board[$from][$stacklens[$from]-1]=-1
         $stacklens[$from]-=1
      Else ;s to foundation
         $cardnumber=$cards[$board[$from][$stacklens[$from]-1]][2]
         $cardsuit=$cards[$board[$from][$stacklens[$from]-1]][3]

         #cs
         if $cardsuit=='c' Then
            if $cardnumber>(min($foundations[1],$foundations[2])+1) Then ;manually move it, otherwise it already moved automatically
               ConsoleWrite('manually moving '&$cards[$board[$from][$stacklens[$from]-1]][0]&@CRLF)
               MouseClick('secondary',$fromx+random(0,$cwidth,1),$fromy+random(0,$cheight,1))
            Else
               ConsoleWrite('automatically moved '&$cards[$board[$from][$stacklens[$from]-1]][0]&@CRLF)
            EndIf
            $foundations[0]+=1
         ElseIf $cardsuit=='d' Then
            if $cardnumber>(min($foundations[0],$foundations[3])+1) Then ;manually move it, otherwise it already moved automatically
               ConsoleWrite('manually moving '&$cards[$board[$from][$stacklens[$from]-1]][0]&@CRLF)
               MouseClick('secondary',$fromx+random(0,$cwidth,1),$fromy+random(0,$cheight,1))
            Else
               ConsoleWrite('automatically moved '&$cards[$board[$from][$stacklens[$from]-1]][0]&@CRLF)
            EndIf
            $foundations[1]+=1
         ElseIf $cardsuit=='h' Then
            if $cardnumber>(min($foundations[0],$foundations[3])+1) Then ;manually move it, otherwise it already moved automatically
               ConsoleWrite('manually moving '&$cards[$board[$from][$stacklens[$from]-1]][0]&@CRLF)
               MouseClick('secondary',$fromx+random(0,$cwidth,1),$fromy+random(0,$cheight,1))
            Else
               ConsoleWrite('automatically moved '&$cards[$board[$from][$stacklens[$from]-1]][0]&@CRLF)
            EndIf
            $foundations[2]+=1
         ElseIf $cardsuit=='s' Then
            if $cardnumber>(min($foundations[1],$foundations[2])+1) Then ;manually move it, otherwise it already moved automatically
               ConsoleWrite('manually moving '&$cards[$board[$from][$stacklens[$from]-1]][0]&@CRLF)
               MouseClick('secondary',$fromx+random(0,$cwidth,1),$fromy+random(0,$cheight,1))
            Else
               ConsoleWrite('automatically moved '&$cards[$board[$from][$stacklens[$from]-1]][0]&@CRLF)
            EndIf
            $foundations[3]+=1
         EndIf
         #ce



         #cs
         ;check if card is actually there
         $s=readcard($from,$stacklens[$from]-1)

         if $cards[$board[$from][$stacklens[$from]-1]][1]==$s Then
            ;ConsoleWrite($cards[$board[$from][$stacklens[$from]-1]][0]&'  '&$from&' -> 99'&@TAB&'(right-click)3'&@TAB&'s='&$s&@crlf)
            ;Sleep($r1)
            MouseClick('secondary',$fromx+random(0,$cwidth,1),$fromy+random(0,$cheight,1))
         ;Else
            ;ConsoleWrite($cards[$board[$from][$stacklens[$from]-1]][0]&'  '&$from&' -> 99'&@TAB&'(no right-click)4'&@TAB&'s='&$s&@crlf)
         EndIf
         #ce
         $board[$from][$stacklens[$from]-1]=-1
         $stacklens[$from]-=1

      EndIf

      $found=True
      While $found
         $found=False
         ;check if next one automatically moved to foundation
         $cardnumber=$cards[$board[$from][$stacklens[$from]-1]][2]
         $cardsuit=$cards[$board[$from][$stacklens[$from]-1]][3]

         if $cardsuit=='c' Then
            if $cardnumber-1=min($foundations[1],$foundations[2]) Then ;manually move it, otherwise it already moved automatically
               ConsoleWrite('automatically moved '&$cards[$board[$from][$stacklens[$from]-1]][0]&@CRLF)
               $foundations[0]+=1
               $board[$from][$stacklens[$from]-1]=-1
               $stacklens[$from]-=1
               $found=True
            EndIf
         ElseIf $cardsuit=='d' Then
            if $cardnumber-1=min($foundations[0],$foundations[3]) Then ;manually move it, otherwise it already moved automatically
               ConsoleWrite('manually moving '&$cards[$board[$from][$stacklens[$from]-1]][0]&@CRLF)
               $foundations[1]+=1
               $board[$from][$stacklens[$from]-1]=-1
               $stacklens[$from]-=1
               $found=True
            EndIf
         ElseIf $cardsuit=='h' Then
            if $cardnumber-1=min($foundations[0],$foundations[3]) Then ;manually move it, otherwise it already moved automatically
               ConsoleWrite('manually moving '&$cards[$board[$from][$stacklens[$from]-1]][0]&@CRLF)
               $foundations[2]+=1
               $board[$from][$stacklens[$from]-1]=-1
               $stacklens[$from]-=1
               $found=True
            EndIf
         ElseIf $cardsuit=='s' Then
            if $cardnumber-1=min($foundations[1],$foundations[2]) Then ;manually move it, otherwise it already moved automatically
               ConsoleWrite('manually moving '&$cards[$board[$from][$stacklens[$from]-1]][0]&@CRLF)
               $foundations[3]+=1
               $board[$from][$stacklens[$from]-1]=-1
               $stacklens[$from]-=1
               $found=True
            EndIf
         EndIf
      WEnd

   Else ;fc to something
      $actualfrom=-1
      for $i=0 to UBound($freecells)-1
         if $freecells[$i]=$from-8 Then
            $actualfrom=$i
            $freecells[$i]=-1
            ExitLoop
         EndIf
      Next

      $fromx=99+$actualfrom*$fchorizoffset+$xoffset
      $fromy=7+$yoffset
      if $to<8 then ;fc to s
         $tox=114+$to*$stackhorizoffset+$xoffset
         $toy=112+$stacklens[$to]*$stackvertoffset+$yoffset

         $board[$to][$stacklens[$to]]=$board[$from][0]
         $board[$from][0]=-1

         ;Sleep($r1)
         MouseClickDrag('primary',$fromx+random(0,$cwidth,1),$fromy+random(0,$cheight,1),$tox+random(0,$cwidth,1),$toy+random(0,$cheight,1),$r2)
         $stacklens[$to]+=1
      Else ;fc to foundation
         ;check if card is actually there
         $s=''
         $x=109+$actualfrom*$fchorizoffset
         $y=7
         for $k=9 to 14
            $s=$s&pixelgetcolor($x,$y+$k)
         Next
         $s=$s&pixelgetcolor($x+7,$y+12)&pixelgetcolor($x+15,$y+14)

         if $board[$from][0]>-1 and $cards[$board[$from][0]][1]==$s Then
            ;Sleep($r1)
            MouseClick('secondary',$fromx+random(0,$cwidth,1),$fromy+random(0,$cheight,1))
         EndIf
         $board[$from][0]=-1

      EndIf
   EndIf
EndFunc

Func min($a,$b)
   If $a<$b Then
      return $a
   EndIf
   Return $b
EndFunc

Func readcard($col,$row)
   $st=''
   $xt=124+($col*$stackhorizoffset)
   $yt=112+($row*$stackvertoffset)
   for $kt=9 to 14
      $st=$st&pixelgetcolor($xt,$yt+$kt)
   Next
   $st=$st&pixelgetcolor($xt+7,$yt+12)&pixelgetcolor($xt+15,$yt+14)
   return $st
EndFunc