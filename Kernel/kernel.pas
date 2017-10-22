unit kernel;

interface

uses multiboot, console, idt, gdt, isr, irq, pit, keyboard, paging, heap, Sound, Floppy, Interrupts, Multitasking;
{$I Header.inc}

procedure kmain(var MB: TMultiBootInfo; MagicNumber: LongWord); stdcall;

implementation

Const
  kHeader = 'GIZMIC OS v0.02';
  kHeaderBg = clBlue;
  kHeaderFg = clWhite;

procedure TempAssert(const Msg,FName: ShortString; LineNo: LongInt; ErrorAddr: Pointer);
var
  Line: String;
begin
  SetTextColor(clBlack,clRed);
  Str(LineNo,Line);
  if Msg='' then
    PrintString(#10'Assertion failed')
  else
    PrintString(Msg);
    PrintString(#10' at line '+Line+' of '+FName+' at address $'+HexStr(LongWord(ErrorAddr),8)+'!');
    SetTextColor(clBlack,clLightGreen);
end;

procedure kmain(var MB: TMultiBootInfo; MagicNumber: LongWord); stdcall;[public, alias: 'kmain'];
var
i : integer;
p : PLongWord;
s : string;
begin
AssertErrorProc:=@TempAssert;
initScreen;

  if MagicNumber <> MultiBootBootloaderMagic then begin
    SetTextColor(clBlack,clRed);
    PrintString(#10'ERROR: a multiboot-compliant boot loader is needed!'#10);
    asm
      cli
      hlt
    end;
  end;

SetTextColor(clBlack,clLightGreen);
initGDT;
initIDT;
InitInt;
initISR;
initIRQ;
initKeyboard;
initTimer(100);
initPaging(MB.UpperMemory+1000);

asm
  sti
end;

initFloppy;

{ClearScreen;
GoToXY(5,7);
SetTextColor(clBlack,clRed);
for i := 1 to 5 do
     PrintString(arrHeader3[i]);
Delay(250);

ClearScreen;  }
GoToXY(0,0);
SetTextColor(clBlue,clWhite);
PrintString(kHeader + #10);
SetTextColor(clBlack,clWhite);
SetHeader(true);

{i := 0;
i := 12321 div i; }

while true do;  
end;
end.
