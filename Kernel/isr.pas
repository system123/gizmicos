unit isr;

interface

procedure InitISR;stdcall;

implementation

uses idt, console, paging;

const
  ExceptionMessages: array [0..31] of String = (
    'Division By Zero',
    'Debug',
    'Non Maskable Interrupt',
    'Breakpoint',
    'Into Detected Overflow',
    'Out of Bounds',
    'Invalid Opcode',
    'No Coprocessor',
    'Double Fault',
    'Coprocessor Segment Overrun',
    'Bad TSS',
    'Segment Not Present',
    'Stack Fault',
    'General Protection Fault',
    'Page Fault',
    'Unknown Interrupt',
    'Coprocessor Fault',
    'Alignment Check',
    'Machine Check',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved',
    'Reserved'
  );

procedure isr0; external name 'isr0';
procedure isr1; external name 'isr1';
procedure isr2; external name 'isr2';
procedure isr3; external name 'isr3';
procedure isr4; external name 'isr4';
procedure isr5; external name 'isr5';
procedure isr6; external name 'isr6';
procedure isr7; external name 'isr7';
procedure isr8; external name 'isr8';
procedure isr9; external name 'isr9';
procedure isr10; external name 'isr10';
procedure isr11; external name 'isr11';
procedure isr12; external name 'isr12';
procedure isr13; external name 'isr13';
procedure isr14; external name 'isr14';
procedure isr15; external name 'isr15';
procedure isr16; external name 'isr16';
procedure isr17; external name 'isr17';
procedure isr18; external name 'isr18';
procedure isr19; external name 'isr19';
procedure isr20; external name 'isr20';
procedure isr21; external name 'isr21';
procedure isr22; external name 'isr22';
procedure isr23; external name 'isr23';
procedure isr24; external name 'isr24';
procedure isr25; external name 'isr25';
procedure isr26; external name 'isr26';
procedure isr27; external name 'isr27';
procedure isr28; external name 'isr28';
procedure isr29; external name 'isr29';
procedure isr30; external name 'isr30';
procedure isr31; external name 'isr31';

procedure InitISR; stdcall;[public, alias: 'initISR'];
begin
  PrintString(#10'Initalising Interupt Service Requests (ISR)');
  SetIDTGate(0,PtrUInt(@isr0),$08,$8E);
  SetIDTGate(1,PtrUInt(@isr1),$08,$8E);
  SetIDTGate(2,PtrUInt(@isr2),$08,$8E);
  SetIDTGate(3,PtrUInt(@isr3),$08,$8E);
  SetIDTGate(4,PtrUInt(@isr4),$08,$8E);
  SetIDTGate(5,PtrUInt(@isr5),$08,$8E);
  SetIDTGate(6,PtrUInt(@isr6),$08,$8E);
  SetIDTGate(7,PtrUInt(@isr7),$08,$8E);
  SetIDTGate(8,PtrUInt(@isr8),$08,$8E);
  SetIDTGate(9,PtrUInt(@isr9),$08,$8E);
  SetIDTGate(10,PtrUInt(@isr10),$08,$8E);
  SetIDTGate(11,PtrUInt(@isr11),$08,$8E);
  SetIDTGate(12,PtrUInt(@isr12),$08,$8E);
  SetIDTGate(13,PtrUInt(@isr13),$08,$8E);
  SetIDTGate(14,PtrUInt(@isr14),$08,$8E);
  SetIDTGate(15,PtrUInt(@isr15),$08,$8E);
  SetIDTGate(16,PtrUInt(@isr16),$08,$8E);
  SetIDTGate(17,PtrUInt(@isr17),$08,$8E);
  SetIDTGate(18,PtrUInt(@isr18),$08,$8E);
  SetIDTGate(19,PtrUInt(@isr19),$08,$8E);
  SetIDTGate(20,PtrUInt(@isr20),$08,$8E);
  SetIDTGate(21,PtrUInt(@isr21),$08,$8E);
  SetIDTGate(22,PtrUInt(@isr22),$08,$8E);
  SetIDTGate(23,PtrUInt(@isr23),$08,$8E);
  SetIDTGate(24,PtrUInt(@isr24),$08,$8E);
  SetIDTGate(25,PtrUInt(@isr25),$08,$8E);
  SetIDTGate(26,PtrUInt(@isr26),$08,$8E);
  SetIDTGate(27,PtrUInt(@isr27),$08,$8E);
  SetIDTGate(28,PtrUInt(@isr28),$08,$8E);
  SetIDTGate(29,PtrUInt(@isr29),$08,$8E);
  SetIDTGate(30,PtrUInt(@isr30),$08,$8E);
  SetIDTGate(31,PtrUInt(@isr31),$08,$8E);
  PrintString(#10'Done');
end;

procedure ISR_Handler(var r : TRegisters); cdecl; [public, alias: 'isr_handler'];
var
s : string;
begin
  if r.InterruptNumber < 32 then
   begin
    SetTextColor(clBlack,clRed);
    PrintChar(#10);
    PrintString(ExceptionMessages[r.InterruptNumber]);
    PrintString(' Exception');

    with r do begin
      Str(ErrorCode, s);
      PrintString(#10'Error code = ');PrintString(s);
      PrintString(#10'EAX'#9'= $');PrintString(HexStr(eax,8));
      PrintString(#10'EBX'#9'= $');PrintString(HexStr(ebx,8));
      PrintString(#10'ECX'#9'= $');PrintString(HexStr(ecx,8));
      PrintString(#10'EDX'#9'= $');PrintString(HexStr(edx,8));
      PrintString(#10'ESI'#9'= $');PrintString(HexStr(esi,8));
      PrintString(#10'EDI'#9'= $');PrintString(HexStr(edi,8));
      PrintString(#10'ESP'#9'= $');PrintString(HexStr(esp,8));
      PrintString(#10'EBP'#9'= $');PrintString(HexStr(ebp,8));
      PrintString(#10'CS'#9'= $');PrintString(HexStr(cs,8));
      PrintString(#10'DS'#9'= $');PrintString(HexStr(ds,8));
      PrintString(#10'ES'#9'= $');PrintString(HexStr(es,8));
      PrintString(#10'FS'#9'= $');PrintString(HexStr(fs,8));
      PrintString(#10'GS'#9'= $');PrintString(HexStr(gs,8));
      PrintString(#10'SS'#9'= $');PrintString(HexStr(ss,8));
      PrintString(#10'EIP'#9'= $');PrintString(HexStr(eip,8));
      PrintString(#10'EFLAGS'#9'= $');PrintString(HexStr(eflags,8));
      PrintString(#10'User ESP'#9'= $');PrintString(HexStr(UserESP,8));
    end;
    PrintChar(#10);
   { if r.InterruptNumber = 14 then
      PageFaultHandler(r);   }
    while true do ;
  end;   
end;

end.
