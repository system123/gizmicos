unit Floppy;

interface

const
  StatusRegA : word = $0000;  // Read Only
  StatusRegB : word = $0001;  // Read Only
  DOReg : word = $0002;
  TapeDrvReg : word = $0003;
  MSReg : word = $0004; // Read Only - Main Status Reg
  FIFOReg : word = $0005; // Write-only
  DIReg : word = $0007;      // Read Only
  CCReg : word = $0007; // Write-only

  MotorOnDelay : integer = 50;
  MotorOffDelay : integer = 300;
  DMAChan : byte = 2;
  DMABufLen : word = $4800;

DriveBase : array[0..1] of word = (
    $03F0, //DriveA base
    $0370  //DriveB base
    );

DriveTypes : array[0..7] of string =(
    'none',
    '360kB 5.25\',
    '1.2MB 5.25\',
    '720kB 3.5\',
    '1.44MB 3.5\',
    '2.88MB 3.5\',
    'unknown type',
    'unknown type'
    );

DriveStatus : array[0..3] of string = (
              '0','error','invalid','drive');

FloppyCmd : array[1..19] of byte = (
  $02, // READ_TRACK          1
  $03, // SPECIFY             2
  $04, // SENSE_DRIVE_STATUS  3
  $05, // WRITE_DATA          4
  $06, // READ_DATA           5
  $07, // RECALIBRATE         6
  $08, // SENSE_INTERRUPT     7
  $09, // WRITE_DELETED_DATA  8
  $0A, // READ_ID             9
  $0C, // READ_DELETED_DATA   10
  $0D, // FORMAT_TRACK        11
  $0F, // SEEK                12
  $10, // VERSION             13
  $11, // SCAN_EQUAL          14
  $12, // PERPENDICULAR_MODE  15
  $13, // CONFIGURE           16
  $16, // VERIFY              17
  $19, // SCAN_LOW_OR_EQUAL   18
  $1D  // SCAN_HIGH_OR_EQUAL  19
   );

procedure initFloppy;
procedure DetectDrives;
procedure LBA2CHS(LBA:LongWord; var cyl,head,sec : byte);
{procedure FloppyWriteCmd(Drive : byte; cmd : byte);
function FloppyReadCmd(Drive : byte) : byte; }
procedure SenseInt(Drive : byte; var st0, cyl : byte);
function Calibrate(Drive : byte) : byte;
function Seek(Drive : byte; cyli, head : byte) : byte;
function FloppyReset(Drive : byte) : byte;
{procedure Motor(Drive : byte; State : byte);}
function FloppyDoTrack(Drive : byte; cyl : byte; dir : byte) : byte;
function FloppyDoTrackLBA(Drive : byte; LBA : byte; dir : byte; NoSectors : byte) : byte;

var
  MotorState : byte = 0;
  Ticks : byte;
  Waiting : boolean;
  Size : LongWord;
  {$Align 32}
  Buffer : array[1..$4800] of byte;

implementation

uses console, ports, pit, irq, heap;

procedure LBA2CHS(LBA:LongWord; var cyl,head,sec : byte);
begin
sec := (LBA mod 18) + 1;
cyl := LBA Div 36;
head := (LBA Div 18) mod 2;
end;

procedure DetectDrives;
var
drive : byte;
begin
WritePort($70, $10);
drive := ReadPort($71);

PrintString(#10'Floppy Drive 0: ' + DriveTypes[drive shr 4]);
PrintString(#10'Floppy Drive 1: ' + DriveTypes[drive and $F]);
end;

procedure FloppyHandler(var r : TRegisters);
var
s : string;
begin
Waiting := false;
end;

procedure FloppyWriteCmd(Drive : byte; cmd : byte);
var
base : word;
i : integer;
begin
base := DriveBase[Drive];
{
repeat
Delay(1);
until(($C0 and ReadPort(base + MSReg)) <> $C0);}

for i := 1 to 300 do
  begin
  if (($C0 and ReadPort(base + MSReg)) = $80) then
        begin
          WritePort((Base + FIFOReg), cmd);
          Exit;
        end;
    Delay(1);
  end;
Panic('Floppy drive write command : Timeout');
end;

function FloppyReadCmd(Drive : byte) : byte;
var
base : word;
i : integer;
begin
base := DriveBase[Drive];

{repeat
Delay(1);
until(($C0 and ReadPort(base + MSReg)) <> $80);   }

for i := 1 to 300 do
  begin
      if (($80 and ReadPort(base + MSReg)) = $80) then
        begin
        FloppyReadCmd := ReadPort(base + FIFOReg);
        Exit;
        end;
      Delay(1);
  end;
Panic('Floppy drive read command : Timeout');
FloppyReadCmd := 0;
end;

procedure IRQwait(no : byte);
begin
while Waiting = true do
end;

procedure IODelay;
var
i : integer;
begin
for i := 1 to 500 do ;
end;

procedure SenseInt(Drive : byte; var st0, cyl : byte);
var
base : word;
begin
base := DriveBase[Drive];

FloppyWriteCmd(Drive, FloppyCmd[7]);
IODelay;

st0 := FloppyReadCmd(Drive);
cyl := FloppyReadCmd(Drive);
end;

procedure Motor(Drive : byte; State : byte);
var
base : word;
begin
base := DriveBase[Drive];
// 0 - Off; 1 - On; 2 - Wait

if State = 1 then
  begin
// If requested on
if MotorState = 0 then
  begin
    //Turn motor on
    WritePort(base + DOReg, $1C);
    Delay(MotorOnDelay);
    MotorState := 1;
  end
else
  begin
    if MotorState = 2 then
      PrintString(#10'Floppy Motor: Strange, motor already waiting');
      
    Ticks := 300;
    MotorState := 2;
  end;
end;

if State = 0 then
if MotorState = 1 then
  begin
    WritePort(base + DOReg, $0C);
    MotorState := 0;
    Delay(MotorOffDelay);
  end;
end;   

function Calibrate(Drive : byte) : byte;
var
i, st0, cyl : byte ;
s : string;
begin
st0 := -1;
cyl := -1;

PrintString(#10'Calibrating floppy drive...');

Motor(Drive, 1);

for i:= 0 to 10 do
  begin
    Waiting := True;
    FloppyWriteCmd(Drive, FloppyCmd[6]);
    FloppyWriteCmd(Drive, Drive);
    IrqWait(6);
    SenseInt(Drive, st0, cyl);

    if (st0 and $C0) = $C0 then
      PrintString(#10'Floppy Calibrate : Status =' + DriveStatus[st0 shr 6]);   //Calibration error

    if cyl = 0 then
      begin
      Motor(Drive, 0);
      Calibrate := 0;
      PrintString(#10'Floppy calibration done');
      Exit;
      end;
  end;
Panic('Floppy calibrate : Timeout');
Motor(Drive, 0);
Calibrate := 1;
end;

function FloppyReset(Drive : byte) : byte;
var
base : word;
st0, cyl : byte;
begin
st0 := -1;
cyl := -1;

Waiting := True;

base := DriveBase[Drive];

WritePort(base + DOReg, $00);
WritePort(base + DOReg, $0C);

IrqWait(6);
SenseInt(Drive, st0, cyl);

//Set transfer speed
WritePort(base + CCReg, $00);

FloppyWriteCmd(Drive, FloppyCmd[2]);
FloppyWriteCmd(Drive, $DF);
FloppyWriteCmd(Drive, $02);

if Calibrate(Drive) = 1 then
  FloppyReset := 1
else
  FloppyReset := 0;
end;

function Seek(Drive : byte; cyli, head : byte):byte;
var
st0, cyl, i : byte;
s : string;
begin
st0 := -1;
cyl := -1;

Motor(Drive, 1);

for i := 0 to 10 do
  begin
  Waiting := True;
  FloppyWriteCmd(Drive, FloppyCmd[12]);
  FloppyWriteCmd(Drive, (head shl 2));
  FloppyWriteCmd(Drive, cyli);
  IRQWait(6);
  SenseInt(Drive, st0, cyl);
  
  if (st0 and $C0) = $C0 then
      PrintString(#10'Floppy Seek: Status = ' + DriveStatus[st0 shr 6]);   //Calibration error

  if cyl = cyli then
    begin
      Motor(Drive,0);
      PrintString(#10'Cylinder Found');
      Seek := 0;
      Exit;
    end;
  end;
Seek := -1;
Motor(Drive, 0);
Panic('Floppy Seek : Timeout');
end;

procedure FloppyDMAInit(dir : byte; Size : LongWord);
var
Addr, Count : Longword;
mode : byte;
begin

Addr := PtrUInt(@Buffer);
Count := Size - 1;

if (Addr and $ff000000) or (Count and $ffff0000) or ((Addr + Count) and $ffff0000) <> (Addr and $ffff0000) then
    Panic('Floppy DMA: Static buffer problem');

mode := $40;
mode := mode or $02;

case dir of
1  : mode := mode or $04; //Read to mem
2  : mode := mode or $08; //Write from mem
end;

WritePort($0A,$06); //Mask DMA 2
WritePort($0C,$FF); //Reset Flip-Flop

WritePort($04,(Addr and $000000FF));         //Address Low byte
WritePort($04,((Addr shr 8) and $000000FF)); //Address High byte

WritePort($81,((Addr shr 16) and $000000FF)); //External Page Register

WritePort($0C,$FF); //Reset Flip-Flop
WritePort($05,(Count and $000000FF));         //Count low byte
WritePort($05,((Count shr 8) and $000000FF)); //Count High byte

WritePort($0B,Mode); //Set Mode -see above
WritePort($0A,$02);  //Unmask DMA 2
end;

function FloppyDoTrackLBA(Drive : byte; LBA : byte; dir : byte; NoSectors : byte) : byte;
var
cmd, i, st0, st1, st2, rcy, rhe, rse, bps, error : byte;
cyl, head, sec : byte;
begin
error := 0;

case dir of
1  : cmd := FloppyCmd[5] or $C0; //Read
2  : cmd := FloppyCmd[4] or $C0; //Write
end;

LBA2CHS(LBA, cyl, head, sec);
Size := NoSectors * 512;

if (Seek(Drive, cyl, head)) = -1 then
  begin
  FloppyDoTrackLBA := -1;
  Exit;
  end;

for i := 1 to 20 do
 begin
   Motor(Drive, 1);
   FloppyDMAInit(dir, Size);

   Delay(10);

   FloppyWriteCmd(Drive, cmd);
   FloppyWriteCmd(Drive, ((head shl 2) or Drive));
   FloppyWriteCmd(Drive, cyl);
   FloppyWriteCmd(Drive, head);
   FloppyWriteCmd(Drive, sec);
   FloppyWriteCmd(Drive, 2);
   FloppyWriteCmd(Drive, 0);
   FloppyWriteCmd(Drive, 0);
   FloppyWriteCmd(Drive, $FF);

   IRQWait(6);

   st0 := FloppyReadCmd(Drive);
   st1 := FloppyReadCmd(Drive);
   st2 := FloppyReadCmd(Drive);

   //Read Cylinder, Head, Sector
   rcy := FloppyReadCmd(Drive);
   rhe := FloppyReadCmd(Drive);
   rse := FloppyReadCmd(Drive);

   bps := FloppyReadCmd(Drive);

   if error = 0  then
    begin
      Motor(Drive, 0);
      FloppyDoTrackLBA := 0;
      Exit;
    end;

   if error >= 1 then
    begin
      PrintString(#10'Floppy Read Write Fail.. Quiiting');
      Motor(Drive, 0);
      FloppyDoTrackLBA := -2;
      Exit;
    end;
 end;
 
PrintString(#10'Floppy Read Write Timeout');
Motor(Drive, 0);
FloppyDoTrackLBA := -1;
end;

function FloppyDoTrack(Drive : byte; cyl : byte; dir : byte) : byte;
var
cmd, i, st0, st1, st2, rcy, rhe, rse, bps, error : byte;
begin
error := 0;

case dir of
1  : cmd := FloppyCmd[5] or $C0; //Read
2  : cmd := FloppyCmd[4] or $C0; //Write
end;

Size := DMABufLen;

if (Seek(Drive, cyl, 0)) or (Seek(Drive, cyl, 1)) = -1 then
  begin
  FloppyDoTrack := -1;
  Exit;
  end;

for i := 1 to 20 do
 begin
   Motor(Drive, 1);
   FloppyDMAInit(dir, Size);

   Delay(10);

   FloppyWriteCmd(Drive, cmd);
   FloppyWriteCmd(Drive, 0);
   FloppyWriteCmd(Drive, cyl);
   FloppyWriteCmd(Drive, 0);
   FloppyWriteCmd(Drive, 1);
   FloppyWriteCmd(Drive, 2);
   FloppyWriteCmd(Drive, 18);
   FloppyWriteCmd(Drive, $1B);
   FloppyWriteCmd(Drive, $FF);

   IRQWait(6);

   st0 := FloppyReadCmd(Drive);
   st1 := FloppyReadCmd(Drive);
   st2 := FloppyReadCmd(Drive);

   //Read Cylinder, Head, Sector
   rcy := FloppyReadCmd(Drive);
   rhe := FloppyReadCmd(Drive);
   rse := FloppyReadCmd(Drive);

   bps := FloppyReadCmd(Drive);

   if error = 0  then
    begin
      Motor(Drive, 0);
      FloppyDoTrack := 0;
      Exit;
    end;

   if error >= 1 then
    begin
      PrintString(#10'Floppy Read Write Fail.. Quiiting');
      Motor(Drive, 0);
      FloppyDoTrack := -2;
      Exit;
    end;
 end;
 
PrintString(#10'Floppy Read Write Timeout');
Motor(Drive, 0);
FloppyDoTrack := -1;
end;

function FloppyRead(Drive : byte; Data : byte; LBA : boolean; NoSec : byte) : byte;
begin
if LBA = false then
  FloppyRead := FloppyDoTrack(Drive, Data, 1);

if LBA = true then
  FloppyRead := FloppyDoTrackLBA(Drive, Data, 1, NoSec);
end;

function FloppyWrite(Drive : byte; Data : byte; LBA : boolean; NoSec : byte) : byte;
begin
if LBA = false then
  FloppyWrite := FloppyDoTrack(Drive, Data, 2);

if LBA = true then
  FloppyWrite := FloppyDoTrackLBA(Drive, Data, 2, NoSec);
end;

procedure initFloppy;
var
s : string;
b : Byte;
begin
PrintString(#10'Locating floppy drives...');

DetectDrives;

PrintString(#10'Installing floppy driver');

InstallIRQHandler(6,@FloppyHandler);
FloppyReset(0);

PrintString(#10'Floppy driver install done');
{FloppyRead(0, 1, false, 0);
MemCopy(PLongWord(@Buffer),PLongWord($B8000),(Size-1));   }
{FloppyWrite(0, 1, true, 2);
MemCopy(PLongWord(@Buffer),PLongWord($B8000),(Size-1)); }
end;

end.
