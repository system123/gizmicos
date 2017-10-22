unit gdt;

interface

type

  TGDTEntry = packed record
    LowLimit: Word;     //u16int
    LowBase: Word;
    MiddleBase: Byte;    //u8int
    Access: Byte;
    Granularity: Byte;
    HighBase: Byte;
  end;

  TGDTPtr = packed record
    Limit: Word;
    Base: LongWord;   //u32int
  end;

var
  GDTList: array [0..4] of TGDTEntry;
  GDTPtr: TGDTPtr;

procedure SetGDTGate(num : byte; base,limit: LongWord; acc,gran: Byte);
procedure InitGDT; stdcall;

implementation

uses
  console;

//procedure GDTInit; external name 'GDTInit';

procedure FlushGDT; assembler; nostackframe;
label
  flush;
asm
  lgdt [GDTPtr]
  mov  ax,$10
  mov  ds,ax
  mov  es,ax
  mov  fs,ax
  mov  gs,ax
  mov  ss,ax
  //jmp $08:flush   // don't know the correct syntax in FPC inline assembler
flush:
end;

procedure SetGDTGate(num : byte; base,limit: LongWord; acc,gran: Byte);
begin
    GDTList[num].LowBase := (base and $FFFF);
    GDTList[num].MiddleBase := (base shr 16) and $FF;
    GDTList[num].HighBase := (base shr 24) and $FF;

    GDTList[num].LowLimit := (limit and $FFFF);

    GDTList[num].Granularity := ((limit shr 16) and $0F);
    GDTList[num].Granularity := GDTList[num].Granularity or (gran and $F0);

    GDTList[num].Access := acc;
end;

procedure InitGDT;stdcall;[public, alias: 'InitGDT'];
begin
  PrintString(#10'Initialising the Global Descriptor Table (GDT)');

  GDTPtr.Limit := (SizeOf(TGDTEntry)*5) -1;
  GDTPtr.Base := PtrUInt(@GDTList);

  SetGDTGate(0,0,0,0,0); // nil descriptor
  SetGDTGate(1,0,$FFFFFFFF,$9A,$CF); // Kernel space code
  SetGDTGate(2,0,$FFFFFFFF,$92,$CF); // Kernel space data
  SetGDTGate(3,0,$FFFFFFFF,$FA,$CF); // User space code
  SetGDTGate(4,0,$FFFFFFFF,$F2,$CF); // User space data

  FlushGDT;
  PrintString(#10'Done.');
end;

end.