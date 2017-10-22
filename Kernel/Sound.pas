unit Sound;

interface

procedure StartSound(Hz : LongWord);
procedure StopSound;
procedure Beep(Hz, Duration : LongWord);

implementation

uses pit;

procedure StartSound(Hz : LongWord);
var
Divisor : LongWord;
L, H : byte;
begin
Divisor := 1193180 Div Hz;

L := Divisor and $FF;
H := (Divisor shr 8);

WritePort($43,$B6);
WritePort($42,L);
WritePort($42,H);
WritePort($61, (ReadPort($61) or 3));
end;

procedure StopSound;
begin
WritePort($61, (ReadPort($61) xor 3));
end;

procedure Beep(Hz, Duration : LongWord);
begin
StartSound(Hz);
Delay(Duration);
StopSound;
end;

end.
 