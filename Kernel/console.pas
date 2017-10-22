unit console;

interface

const
    clBlack = $0;
    clBlue = $1;
    clGreen = $2;
    clCyan = $3;
    clRed = $4;
    clMagenta = $5;
    clBrown = $6;
    clLightGray = $7;
    clDarkGray = $8;
    clLightBlue = $9;
    clLightGreen = $A;
    clLightCyan = $B;
    clLightRed = $C;
    clLightMagenta = $D;
    clLightBrown = $E;
    clWhite = $F;


const
  ControlReg : word = $03D4;
  DataReg : word = $03D5;
  VidMem : PChar = PChar($B8000);

var
  CursorPosX: Word;
  CursorPosY: Word;
  // Color attribute
  Attrib: Word;
  // Blank (space) character for current color
  Blank: Word;
  Offset : word;
  bHeader : Boolean = false;
  YMax : byte = 24;
  XMax : byte = 80;
  BlinkState : boolean;

procedure GoToXY(const X,Y: Word);
procedure ClearScreen;
procedure PrintString(const Data : string);
procedure SetTextColor(const Bg,Fg: byte);
procedure PrintChar(const c : char);
procedure Panic(const Data : string);
procedure SetHeader(Header : Boolean);
procedure InitScreen;

implementation

uses Ports, Sound;

procedure SetHeader(Header : Boolean);
begin
bHeader := Header;

if bHeader = true then
  begin
  YMax := 23;
  XMax := 80;
  end
else
  begin
  YMax := 24;
  XMax := 80;
  end;
end;

procedure GoToXY(const X,Y: Word);
begin
if X < 80 then CursorPosX := X;
if Y < 25 then CursorPosY := Y;
end; 

procedure Scroll;
var
i, x, YVal : byte;
begin
if bHeader = true then
  YVal := 1
else
  YVal := 0;
  
  if CursorPosY >= 24 then begin
    { // line index starts from 0
      for n:=0 to 23 do
        line[n]:=line[n+1] }
    //Move((VidMem+2*80)^,VidMem^,23*2*80);
    Move(((VidMem+2*80)+(160*YVal))^,(VidMem+(160*YVal))^,23*2*80);
    // Empty last line
    FillWord((VidMem+23*2*80)^,80,Blank);
    CursorPosX:=0;
    CursorPosY:=23;
  end;
end;

procedure Blink;
var
  Temp: LongWord;
begin
  // X,Y mapped to VidMem ( 1-dim array )
  Temp:=CursorPosY*80+CursorPosX;
  WritePort($3D4,14);
  WritePort($3D5,Temp shr 8);
  WritePort($3D4,15);
  WritePort($3D5,Temp);
end;

procedure BlinkOff;
begin
  if BlinkState = True then
  begin
    WritePort(ControlReg,$14);
    WritePort(DataReg, $FF);
    WritePort(ControlReg,$15);
    WritePort(DataReg, $FF);
  end;
  BlinkState := False;
end;

procedure DoChar(const c: Char);

  procedure Print(const c: Char);
  begin
    // First byte = character to print
    Offset := (CursorPosY*80*2) + (CursorPosX shl 1);
    VidMem[Offset]:=c;
    // Second byte = color attributes
    Inc(Offset);
    VidMem[Offset]:=Char(Attrib);
  end;

begin
  // Blank character based on current color attributes
  Blank:=$20 or (Attrib shl 8);
  case c of
    // Backspaces
    #08 : if CursorPosX > 0 then
          begin
          Dec(CursorPosX);
          Print(' ');
          end
          else
            begin
            CursorPosX := 79;
            Dec(CursorPosY);
            Print(' ');
            end;
    // Tabs, only to a position which is divisible by 8
    #09 : CursorPosX := (CursorPosX+8) and not 7;
    { Newlines, DOS and BIOS way ( consider as if a carriage
      return is also there) }
    #10: begin
      CursorPosX:=0;
      Inc(CursorPosY);
      end;
    // Carriage return
    #13: CursorPosX:=0;
    // Printable characters, starting from space
    #32..#255: begin
      Print(c);
      Inc(CursorPosX);
    end;
  end;
  // Whoops! Line limit, move on to the next line
  if CursorPosX >= XMax then begin
    CursorPosX:=0;
    Inc(CursorPosY);
  end;
  if CursorPosY >= YMax then
  Scroll;
end;

procedure PrintChar(const c : char);
begin
DoChar(c);
Blink;
end;

procedure PrintString(const Data : string);
var
i : integer;
begin
BlinkOff;
for i := 1 to Length(Data) do
  DoChar(Data[i]);
Blink;
end;

procedure Panic(const Data : string);
var
i : integer;
Fin : string;
begin
BlinkOff;
SetTextColor(clBlack, clRed);
Fin := #10'***PANIC: ' + Data;
for i := 1 to Length(Fin) do
  DoChar(Fin[i]);
Blink;
Beep(750,50);
SetTextColor(clBlack, clLightGreen);
While true do ;
end;

procedure SetTextColor(const Bg,Fg : byte);
begin
Attrib := (Bg shl 4) or (Fg and $0F);
Blank := $20 or (Attrib shl 8);
end;

procedure ClearScreen;
var
  i: Byte;
begin
  BlinkOff;
  Blank:=$0 or (Attrib shl 8);
  for i:=0 to 24 do
    FillWord((VidMem+(i*2*80))^,80,Blank);
  CursorPosX:=0;
  CursorPosY:=0;
  Blink;
end;

procedure InitScreen;
begin
CursorPosX := 0;
CursorPosY := 0;
SetTextColor(clBlack, clWhite);
ClearScreen;
end;

end.
