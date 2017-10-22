unit idt;

interface

type
  TIDTEntry = packed record
  BaseLow : word;
  SegSel : word;
  Always0 : byte;
  Flags : byte;
  BaseHigh : word;
  end;

  TIDTPtr = packed record
  limit : word;
  base : LongWord;
  end;

var
IDTPtr : TIDTPtr;
IDTTables : array[0..255] of TIDTEntry;

procedure SetIDTGate(idx: Byte; base: LongWord; SSelect: Word; flg: Byte);
procedure initIDT;stdcall;

implementation

uses console;

procedure FlushIDT; assembler; nostackframe;
asm
  lidt [IDTPtr]
end;

procedure SetIDTGate(idx: Byte; base: LongWord; SSelect: Word; flg: Byte);
begin
  IDTTables[idx].BaseLow := (base and $FFFF);
  IDTTables[idx].BaseHigh := (base shr 16) and $FFFF;

  IDTTables[idx].SegSel := SSelect;
  IDTTables[idx].Always0 := 0;

  IDTTables[idx].Flags := flg;    
end;

procedure initIDT;stdcall;[public, alias: 'initIDT'];
var
i : byte;
begin
PrintString(#10'Initialising the Interupt Descriptor Table (IDT)');
IDTPtr.limit := (SizeOf(TIDTEntry)*256)-1;
IDTPtr.base := PtrUInt(@IDTTables);

FillByte(IDTTables,(SizeOf(TIDTEntry)*256),0);

FlushIDT;
PrintString(#10'Done');
end;

end.
