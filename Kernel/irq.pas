unit irq;

interface

type
  TIRQHandler = procedure (var r : TRegisters);

const
 IRQRoutines : array[0..15] of TIRQHandler = (
    nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
    );

procedure InitIRQ;stdcall;
procedure InstallIRQHandler(const IRQNo : byte; Handler : TIRQHandler);
procedure UninstallIRQHandler(const IRQNo : byte);
procedure IRQWait(IRQNo : byte);
procedure EnableIRQ(IRQNo : byte);

var
  IRQWaiting : boolean = false;
  IRQWaiter : byte;

implementation

uses IDT, console;

procedure irq0; external name 'irq0';
procedure irq1; external name 'irq1';
procedure irq2; external name 'irq2';
procedure irq3; external name 'irq3';
procedure irq4; external name 'irq4';
procedure irq5; external name 'irq5';
procedure irq6; external name 'irq6';
procedure irq7; external name 'irq7';
procedure irq8; external name 'irq8';
procedure irq9; external name 'irq9';
procedure irq10; external name 'irq10';
procedure irq11; external name 'irq11';
procedure irq12; external name 'irq12';
procedure irq13; external name 'irq13';
procedure irq14; external name 'irq14';
procedure irq15; external name 'irq15';

procedure InstallIRQHandler(const IRQNo : byte; Handler : TIRQHandler);
begin
IRQRoutines[IRQNo] := Handler;
EnableIRQ(IRQNO);
end;

procedure UninstallIRQHandler(const IRQNo : byte);
begin
IRQRoutines[IRQNo] := nil;
end;

procedure EnableIRQ(IRQNo : byte);
var
IMR : byte;
begin
if IRQNo <= 7 then
  begin
     IMR := ReadPort($21);
     asm
     mov ecx, IRQNo
     and ecx, 7
     mov eax, 1
     shl eax, cl
     xor al, $FF
     xor ecx, ecx
     mov ecx, eax
     mov al, IMR
     and al, cl
     mov IMR, al
     end;
     WritePort($21,IMR);
  end
else

if (IRQNo > 7) and (IRQNo <= 15) then
  begin
     IMR := ReadPort($A1);
     asm
     mov ecx, IRQNo
     and ecx, 7
     mov eax, 1
     shl eax, cl
     xor al, $FF
     xor ecx, ecx
     mov ecx, eax
     mov al, IMR
     and al, cl
     mov IMR, al
     end;
     WritePort($A1,IMR);
  end;
end;

procedure DisableIRQ(IRQNo : byte);
var
IMR : byte;
begin
if IRQNo <= 7 then
  begin
     IMR := ReadPort($21);
     asm
     mov ecx, IRQNo
     and ecx, 7
     mov eax, 1
     shl eax, cl
     xor ecx, ecx
     mov ecx, eax
     mov al, IMR
     or al, cl
     mov IMR, al
     end;
     WritePort($21,IMR);
  end
else

if (IRQNo > 7) and (IRQNo <= 15) then
  begin
     IMR := ReadPort($A1);
     asm
     mov ecx, IRQNo
     and ecx, 7
     mov eax, 1
     shl eax, cl
     xor ecx, ecx
     mov ecx, eax
     mov al, IMR
     or al, cl
     mov IMR, al
     end;
     WritePort($A1,IMR);
  end; 
end;

procedure RemapIRQ;
begin
  WritePort($20,$11);
  WritePort($A0,$11);
  WritePort($21,$20);
  WritePort($A1,$28);
  WritePort($21,$04);
  WritePort($A1,$02);
  WritePort($21,$01);
  WritePort($A1,$01);
  WritePort($21,$FF);
  WritePort($A1,$FF);
end;

procedure InitIRQ;stdcall;[public, alias : 'initIRQ'];
begin
PrintString(#10'Remapping the Interupt Requests (IRQ)');
RemapIRQ;
PrintString(#10'Done'#10'Initialising IRQs 0 - 15');
SetIDTGate(32,PtrUInt(@irq0),$08,$8E); //timer
SetIDTGate(33,PtrUInt(@irq1),$08,$8E); //keyboard
SetIDTGate(34,PtrUInt(@irq2),$08,$8E); //reserved
SetIDTGate(35,PtrUInt(@irq3),$08,$8E);
SetIDTGate(36,PtrUInt(@irq4),$08,$8E);
SetIDTGate(37,PtrUInt(@irq5),$08,$8E);
SetIDTGate(38,PtrUInt(@irq6),$08,$8E);
SetIDTGate(39,PtrUInt(@irq7),$08,$8E);
SetIDTGate(40,PtrUInt(@irq8),$08,$8E);
SetIDTGate(41,PtrUInt(@irq9),$08,$8E);
SetIDTGate(42,PtrUInt(@irq10),$08,$8E);
SetIDTGate(43,PtrUInt(@irq11),$08,$8E);
SetIDTGate(44,PtrUInt(@irq12),$08,$8E);
SetIDTGate(45,PtrUInt(@irq13),$08,$8E);
SetIDTGate(46,PtrUInt(@irq14),$08,$8E);
SetIDTGate(47,PtrUInt(@irq15),$08,$8E);
PrintString(#10'Done');
end;

procedure IRQWait(IRQNo : byte);
begin
IRQWaiter := IRQNo;
IRQWaiting := true;
while IRQWaiting = true do;
end;

procedure IrqHandler(var r : TRegisters); cdecl; [public, alias: 'irq_handler'];
var
  Handler : TIrqHandler;
  s : string; 
begin

if IrqRoutines[r.InterruptNumber-32] <> nil then
  begin
     Handler := IrqRoutines[r.InterruptNumber-32];
     Handler(r);
  end;

if r.InterruptNumber >= 40 then
  WritePort($A0,$20);

  WritePort($20,$20);
end;

end.
