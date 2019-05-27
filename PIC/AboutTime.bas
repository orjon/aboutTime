'****************************************************************
'*  Name    : AboutTime.BAS                                     *
'*  Author  : orjon.com                                         *
'*  Date    : 17-07-2010                                        *
'*  Version : 1.0                                               *
'****************************************************************

TiltSet var portc.0     ' low is pressed
TiltInc var portc.1     ' low is pressed
Reset var portc.2

A var portb.7
D var portb.6
C var portb.5
B var portb.4
SEG4 var portc.7  ' low is open, high latches
SEG3 var portc.6
SEG2 var portc.5
SEG1 var portc.4
SecBlink var portb.3

gosub blank     'display 0 on all displays with open latch (ie "0000")
low seg1
low seg2
low seg3
low seg4 'open all segemtn latches
gosub blank     'display 0 on all displays with open latch (ie "0000")
high seg1
high seg2
high seg3
high seg4 'open all segemtn latches

'-------------------------- Clock Variables ---------------------------------
DS1302_RST var porta.5 ' DS1302 Reset Pin
DS1302_CLK var porta.3 ' DS1302 Clock Pin
DS1302_DQ var porta.4 ' DS1302 Data Pin
'----------------------- Write Commands For DS1302 --------------------------
writectrl con $8E ' Control byte
writeram con $80 ' Write to RAM
writeprotect con $00 ' Write-protect DS1302
writesec con $80 ' Write seconds
writemin con $82 ' Write minutes
writehour con $84 ' Write hour
writedate con $86 ' Write date
writemonth con $88 ' Write month
writeyear con $8C ' Write year
'------------------------- Read Commands For DS1302 -------------------------
readsec con $81 ' Read seconds from DS1302
readmin con $83 ' Read minutes from DS1302
readhour con $85 ' Read hours from DS1302
readdate con $87 ' Read date from DS1302
readyear con $8D ' Read year from DS1302
readmonth con $89 ' Read month from DS1302
'------------------------------ Time Variables ------------------------------
mem var byte ' Temporary data holder
outbyte var byte ' Second byte to ds1302
reg_adr var byte ' First byte to DS1302
date var byte ' Date variable

mo var byte ' Month variable
yr var byte ' Year variable
xx var byte  ' temp hold of above possible bytes

Seconds var byte
Minutes Var Byte
Hours var byte

VarSeconds var byte
VarMinutes Var Byte
VarHours var byte

SecondsLSB VAR byte
MinutesLSB VAR byte
HoursLSB VAR byte
SecondsMSB VAR byte
MinutesMSB VAR byte
HoursMSB VAR byte

VarMinutesLSB VAR byte
VarHoursLSB VAR byte
VarMinutesMSB VAR byte
VarHoursMSB VAR byte

BCDSeconds var byte
BCDMinutes VAR Byte
BCDHours Var byte

VarBCDMinutes VAR Byte
VarBCDHours Var byte

Blinker var byte
TensCounter VAR byte

ControlSeconds Var Byte

Variance var byte
RandomVariance VAR Byte
RandomNumber VAR WORD

temp var byte

'------------------------ Initial Settings For Ports ------------------------
low DS1302_RST ' Set reset pin low
low DS1302_CLK ' Set clock pin low
'----------------------------------------------------------------------------
adcon1 = 7  'analouge to digital pls!
'set clock values
'-------------------------------------------------------------------------------
RandomNumber =  23'Random seed
low SecBlink
low seg1
low seg2
low seg3
low seg4 'open all segement latches
IF PCON.0=0 then goto dirtystart

TheBeginning:
PCON.0=1
low SecBlink
low seg1
low seg2
low seg3
low seg4 'open all segement latches
gosub blank

SetHours:
repeat
gosub blank       'clear (unlight) 7 segment (in this case all of them)
pause 100         'pause with segments unlit
If TiltSet=1 THEN Goto ExitSetHours
pause 100         'pause with segments unlit
If TiltSet=1 THEN Goto ExitSetHours
pause 100         'pause with segments unlit
If TiltSet=1 THEN Goto ExitSetHours
pause 100         'pause with segments unlit
If TiltSet=1 THEN Goto ExitSetHours
pause 100         'pause with segments unlit
If TiltSet=1 THEN Goto ExitSetHours

gosub number0     'set number 0 on all segments'
pause 100         'pause with 0 on segments    = segments flashing on / off
If TiltSet=1 THEN Goto ExitSetHours
pause 100         'pause with 0 on segments    = segments flashing on / off
If TiltSet=1 THEN Goto ExitSetHours
pause 100         'pause with 0 on segments    = segments flashing on / off
If TiltSet=1 THEN Goto ExitSetHours
pause 100         'pause with 0 on segments    = segments flashing on / off
If TiltSet=1 THEN Goto ExitSetHours
pause 100         'pause with 0 on segments    = segments flashing on / off
If TiltSet=1 THEN Goto ExitSetHours
until TiltSet=1 'wait for TiltSet pressed

ExitSetHours:
gosub number0

repeat
until TiltSet=0 'wait for TiltSet back to normal angle
pause 250

high seg1     ' latches seg 1 and 2, thus wont change from existing 0
high seg2
gosub blank
HIGH seg3     ' latches seg 3 and 4 at blank, ie off.
HIGH seg4

temp=0
Hours=Temp

SetHoursLoop:
repeat
until TiltInc=0  OR TiltSet=1

if TiltSet=1 then SetMinTens   'Exit Loop if TitltSet active

temp = temp + 1  'increment Temp if TiltInc pressed
if temp=24 then temp=0                    'reset temp to 0 if over 23

Hours=Temp
gosub Decimal_SB_and_BCD
xx=HoursMSB
low seg1                    'display Hours MSB on segment 1
gosub DisplayNumber
high seg1                   'latch Hours MSB when done
xx=HoursLSB
low seg2                    'display Hours LSB on segment 2
gosub DisplayNumber
high seg2                   'latch Hours LSB when done

Pause 500

goto SetHoursLoop
'-------------------------------------------------------------------------------
SetMinTens:
low seg3               'turn on tens minutes display to 0
gosub number0
HIGH seg3

repeat
until TiltSet=0  'Wait for ButtonSet release
Pause 250

temp=0
MinutesMSB=Temp

SetMinTensLoop:
repeat
until TiltInc=0  OR TiltSet=1

if TiltSet=1 then SetMinUnits   'Exit Loop if TiltSet Pressed

temp = temp + 1  'increment Temp if TiltInc pressed
if temp=6 then temp=0                    'reset temp to 0 if over 23

MinutesMSB=Temp
xx=MinutesMSB
low seg3                       ; display Hours MSB on segment 3
gosub DisplayNumber
high seg3

Pause 500

goto SetMinTensLoop
'-------------------------------------------------------------------------------
SetMinUnits:
low seg4               'turn on minutes unit display to 0
gosub number0
HIGH seg4

repeat
until TiltSet=0  'Wait for TiltSet release
Pause 250

temp=0
MinutesLSB=Temp

SetMinUnitsLoop:
repeat
until TiltInc=0  OR TiltSet=1

if TiltSet=1 then SetVariance   'Exit Loop if TiltSet Pressed

temp = temp + 1  'increment Temp if TiltInc pressed
if temp=10 then temp=0                    'reset temp to 0 if over 23

MinutesLSB=Temp

xx=MinutesLSB
low seg4                       ; display Hours MSB on segment 4
gosub DisplayNumber
high seg4

Pause 500

goto SetMinUnitsLoop
'-------------------------------------------------------------------------------
SetVariance:      'currently limited to 0-9
low seg1
low seg2
low seg3          'open seg 1-2 latches.
gosub Blank
high seg1
high seg2
high seg3         'close seg 1-2 latches with blank on them.

low seg4               'turn seg 3-4 display to 0
gosub number0
HIGH seg4

repeat
until TiltSet=0  'Wait for ButtonSet release
Pause 250

Variance=0

SetVarianceLoop:
write 1, Variance 'store variance in eeprom location1
repeat
until TiltInc=0  OR TiltSet=1

if TiltSet=1 then SetClock   'Exit Loop if TiltSet Pressed

Variance = Variance + 1  'increment Temp if TiltInc pressed
if Variance=10 then vAriance=0                    'reset temp to 0 if over 9
                 'latch Hours MSB when done
xx=Variance
low seg4                    'display Hours LSB on segment 2
gosub DisplayNumber
high seg4                   'latch Hours LSB when done

Pause 500

goto SetVarianceLoop
'-------------------------------------------------------------------------------
setclock:
Minutes=(MinutesMSB*10)+MinutesLSB   'add ten and untis together
Seconds=0

GoSUB Decimal_SB_and_BCD

reg_adr = writectrl ' Set to control byte
outbyte = writeprotect ' Set turn off protection
gosub w_out ' Send both bytes
reg_adr = writesec ' Set to write seconds register
outbyte = $00 ' Set to write 00 to seconds register
gosub w_out
reg_adr = writemin
outbyte = BCDMinutes
gosub w_out
reg_adr = writehour
outbyte = BCDHours
gosub w_out
reg_adr = writedate
outbyte = $01
gosub w_out
reg_adr = writemonth
outbyte = $01
gosub w_out
reg_adr = writeyear
outbyte = $00
gosub w_out
reg_adr = writectrl
outbyte = writeprotect
gosub w_out
'-------------------------------------------------------------------------------
gosub blank
GOSUB GenerateRandom
blinker = 0
TensCounter = 0
PCON.0=0

'-------------------------------------------------------------------------------
telltime:
Gosub GetTime
gosub BCD_to_Decimal    'split and convert to Decimal

IF Reset=0 then goto TheBeginning

IF TiltSet = 1 Then GoTO DisplayBlank 'returns BCD format time

IF TensCounter = SecondsMSB then GOSUB GenerateRandom      'every tenth second enter this subroutine


If TiltInc = 0 THEN GOSUB DisplayTime
If TiltInc = 0 THEN GOTO telltime
If Blinker <> SecondsLSB then gosub Blinkseconds 'runs blinker proceedure once per every change in SecondsLSB (ie every second)

If TiltInc = 1 THEN gosub DisplayVarTime

goto telltime
'-------------------------------------------------------------------------------
dirtystart:
read 1,Variance
read 2,Tenscounter
RandomNumber =  23'Random seed
Gosub GetTime
gosub BCD_to_Decimal
GOSUB GenerateRandom
goto telltime
'-------------------------------------------------------------------------------
DisplayBlank:
low seg1
low seg2
low seg3
low seg4     'open all segement latches
gosub blank
high seg1
high seg2
high seg3
high seg4     'open all segement latches
low SecBlink 'turn off blinker
pause 10 'rest a little my friend
'TensCounter = SecondsMSB
GOTO TellTime

'-------------------------------------------------------------------------------
DisplayVarTime:

GOSUB VarDecimal_SB_and_BCD

xx=VarMinutesLSB
low seg4
gosub DisplayNumber
HIGH seg4
pause 20

xx=VarMinutesMSB
low seg3
gosub DisplayNumber
HIGH seg3
pause 20

xx=VarHoursMSB
low seg1
gosub DisplayNumber
HIGH seg1
pause 20

xx=VarHourslSB
low seg2
gosub DisplayNumber
HIGH seg2
pause 20

Return
'-------------------------------------------------------------------------------
DisplayTime:

xx=MinutesLSB
low seg4
gosub DisplayNumber
HIGH seg4
pause 20

xx=MinutesMSB
low seg3
gosub DisplayNumber
HIGH seg3
pause 20

xx=HoursMSB
low seg1
gosub DisplayNumber
HIGH seg1
pause 20

xx=HoursLSB
low seg2
gosub DisplayNumber
HIGH seg2
pause 20


Return
'------------------------------------------------------------------------------------
GenerateRandom:
TensCounter =  TensCounter+3
If TensCounter = 6 then TensCounter = 0   'ensures this loop in only entered once every ten seconds
write 2,tenscounter

VarHours = Hours
VarMinutes=Minutes

random RandomNumber
RandomVariance = (RandomNumber//(Variance+1))+0 'Value will be between 0 and 'Variance'

If TensCounter = 0 then GOSUB PlusVariance

If TensCounter = 3 then gosub MinusVariance
Return

'------------------------------------------------------------------------------------
PlusVariance:

VarMinutes=Minutes+RandomVariance
If VarMinutes < 60 then return
VarMinutes = VarMinutes - 60
Varhours = VarHours+1
Return

'------------------------------------------------------------------------------------
MinusVariance:
IF VarMinutes < RandomVariance THEN GOSUB MinusVarianceRollover
VarMinutes=VarMinutes-RandomVariance
Return

MinusVarianceRollover:
If VarHours=0 Then VarHours=24
VarHours = VarHours-1
VarMinutes = 60 + VarMinutes
Return


'------------------------------ Blink Seconds  ------------------------------
BlinkSeconds:
Blinker = SecondsLSB
low SecBlink
IF Reset=0 then goto theBeginning
Pause 99
IF Reset=0 then goto theBeginning
Pause 99
IF Reset=0 then goto theBeginning
Pause 99
IF Reset=0 then goto theBeginning
Pause 99
IF Reset=0 then goto theBeginning
Pause 99
high SecBLink
RETURN


'-----creates xDec from xBCD --------------------------------------------------
'Decimal:    0     1     2     3     4     5     6     7     8     9
'BCD:     0000  0001  0010  0011  0100  0101  0110  0111  1000  1001
BCD_to_Decimal:
SecondsMSB=BCDSeconds & $70
SecondsMSB=SecondsMSB>>4
SecondsLSB=BCDSeconds & $0F              '
Seconds=(SecondsMSB*10)+SecondsLSB 'combines DECMinutes MSB and LSB

MinutesMSB=BCDMinutes & $70
MinutesMSB=MinutesMSB>>4
MinutesLSB=BCDMinutes & $0F              '
Minutes=(MinutesMSB*10)+MinutesLSB 'combines DECMinutes MSB and LSB

HoursMSB=BCDHours & $70
HoursMSB=HoursMSB>>4
HoursLSB=BCDHours & $0F
Hours=(HoursMSB*10)+HoursLSB 'combines DECMinutes MSB and LSB
RETURN
'-----creates BCDMinutes, LSB and MSB from Decimal Minutes-----------------------
VarDecimal_SB_and_BCD:
VarBCDMinutes=VarMinutes DIG 1
VarBCDMinutes=VarBCDMinutes<<4
VarBCDMinutes=VarBCDMinutes+(VarMinutes DIG 0)

VarBCDHours=VarHours DIG 1
VarBCDHours=VarBCDHours<<4
VarBCDHOurs=VarBCDHours+(VarHOurs DIG 0)

VarMinutesMSB=VarBCDMinutes & $70
VarMinutesMSB=VarMinutesMSB>>4
VarMinutesLSB=VarBCDMinutes & $0F

VarHoursMSB=VarBCDHours & $70
VarHoursMSB=VarHoursMSB>>4
VarHoursLSB=VarBCDHours & $0F
Return
'-----creates BCDMinutes, LSB and MSB from Decimal Minutes-----------------------
Decimal_SB_and_BCD:
BCDSeconds=Seconds DIG 1
BCDSeconds=BCDSeconds<<4
BCDSeconds=BCDSeconds+(Seconds DIG 0)

BCDMinutes=Minutes DIG 1
BCDMinutes=BCDMinutes<<4
BCDMinutes=BCDMinutes+(Minutes DIG 0)

BCDHours=Hours DIG 1
BCDHours=BCDHours<<4
BCDHours=BCDHours+(Hours DIG 0)

SecondsMSB=BCDSeconds & $70
SecondsMSB=SecondsMSB>>4
SecondsLSB=BCDSeconds & $0F

MinutesMSB=BCDMinutes & $70
MinutesMSB=MinutesMSB>>4
MinutesLSB=BCDMinutes & $0F

HoursMSB=BCDHours & $70
HoursMSB=HoursMSB>>4
HoursLSB=BCDHours & $0F

Return
'---------------------------------------- Get Time --------------------------
GetTime:
reg_adr = readsec ' Read seconds
gosub w_in
BCDSeconds = mem
reg_adr = readmin ' Read minutes
gosub w_in
BCDMinutes = mem
reg_adr = readhour ' Read Hours
gosub w_in
BCDHours = mem
Return

'----------------------- Time Commands Subroutines --------------------------
w_in:
mem = reg_adr ' Set mem variable to reg_adr contents
high DS1302_RST ' Activate the DS1302
shiftout DS1302_DQ,DS1302_CLK,0, [mem] ' Send control byte
shiftin DS1302_DQ,DS1302_CLK,1, [mem] ' Retrieve data in from the DS1302
low DS1302_RST ' Deactivate DS1302
return

w_out:
mem = reg_adr ' Set mem variable to reg_adr contents
high DS1302_RST ' Activate the DS1302
shiftout DS1302_DQ,DS1302_CLK,0, [mem] ' Send control byte
mem = outbyte ' Set mem variable to outbyte contents
shiftout DS1302_DQ,DS1302_CLK,0, [mem] ' Send data stored in mem variable to DS1302
low DS1302_RST ' Deactivate DS1302
return

'------------sub routines------------------------
DisplayNumber:
  IF (xx = 0) then gosub NUMBER0
  IF (xx = 1) then gosub NUMBER1
  IF (xx = 2) then gosub NUMBER2
  IF (xx = 3) then gosub NUMBER3
  IF (xx = 4) then gosub NUMBER4
  IF (xx = 5) then gosub NUMBER5
  IF (xx = 6) then gosub NUMBER6
  IF (xx = 7) then gosub NUMBER7
  IF (xx = 8) then gosub NUMBER8
  IF (xx = 9) then gosub NUMBER9
return

BLANK:
   HIGH D
   LOW  C
   HIGH B
   LOW  A
return


NUMBER0:
   LOW  D
   LOW  C
   LOW  B
   LOW  A
return

NUMBER1:
   LOW  D
   LOW  C
   LOW  B
   HIGH A
return

NUMBER2:
   LOW  D
   LOW  C
   HIGH B
   LOW  A
return

NUMBER3:
   LOW  D
   LOW  C
   HIGH B
   HIGH A
return

NUMBER4:
   LOW  D
   HIGH C
   LOW  B
   LOW  A
return

NUMBER5:
   LOW  D
   HIGH C
   LOW  B
   HIGH A
return

NUMBER6:
   LOW  D
   HIGH C
   HIGH B
   LOW  A
return

NUMBER7:
   LOW  D
   HIGH C
   HIGH B
   HIGH A
return

NUMBER8:
   HIGH D
   LOW  C
   LOW  B
   LOW  A
return

NUMBER9:
   HIGH D
   LOW  C
   LOW  B
   HIGH A
return
