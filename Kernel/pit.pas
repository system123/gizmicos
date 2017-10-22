unit pit;

interface

const
  ClockHz : LongWord = 1193180;

var
  TimerTicks : LongWord = 0;
  ETicks : LongWord = 0;

procedure InitTimer(Hz : LongWord);
procedure TimerHz(Hz : LongWord);
procedure Delay(Ticks : LongWord);

implementation

uses irq, console;

procedure TimerHz(Hz : LongWord);
var
Divisor : LongWord;
L, H : byte;
begin
Divisor := ClockHz Div Hz;

L := Divisor and $FF;
H := (Divisor shr 8) and $FF;

WritePort($43,$36);
WritePort($40,L);
WritePort($40,H);
end;

procedure TimerHandler(var r : TRegisters);
var
s : string;
begin
Inc(TimerTicks);

if TimerTicks mod 100 = 0 then
  {begin
  //Timer 1sec Event do something
  str(Timerticks div 100, s);
  // 26 > 25 therefore the Y position will not change
  GoToXY(0,3);
  PrintString(s);
  end; }   
end;

procedure Delay(Ticks : LongWord);
var
s : string;
begin
  ETicks := Ticks + TimerTicks;

  While ETicks > TimerTicks do ;
end;

procedure InitTimer(Hz : LongWord);
begin
PrintString(#10'Enabling the system timer');
InstallIRQHandler(0,@TimerHandler);
TimerHz(Hz);   // 100Hz is standard. Then TimerTicks mod 100 = 0 is used for 1 second results
PrintString(#10'Done');
end;

end.
