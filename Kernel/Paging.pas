unit Paging;

interface

// These 4 functions come from JamesM's tutorial
procedure AllocFrame(var Page : LongWord; IsKernel,IsWritable : Boolean);
procedure FreeFrame(var Page : LongWord);
function GetPage(Addr : LongWord; Make : Boolean; PageDir : PLongWord): PLongWord;
procedure SwitchPageDir(PageDir : PLongWord);

procedure InitPaging(MemSizeInKB : LongWord);
procedure PageFaultHandler(var r: TRegisters);

var
  PageDir : PLongWord;
  PageTable : array [0..1023] of PLongWord;
  MemorySize,FrameCount : LongWord;
  KernelEnd : LongWord; external name 'end'; // End of kernel
  iPages : byte;
                       
implementation

uses console, heap, idt;

const
  PageSize = 4096;

var
  CurrentDirectory,Frames: PLongWord;

// These 7 functions come from JamesM's tutorial
function IndexFromBit(a: LongWord): LongWord;
begin
  IndexFromBit:=a div 32;
end;

function OffsetFromBit(a: LongWord): LongWord; 
begin
  OffsetFromBit:=a mod 32;
end;

procedure GetFrameIdxOff(var Frame,Idx,Off: LongWord; FrameAddr: LongWord);
begin
  Frame:=FrameAddr div $1000;
  Idx:=IndexFromBit(Frame);
  Off:=OffsetFromBit(Frame);
end;

procedure SetFrame(FrameAddr: LongWord);
var
  Frame,Idx,Off: LongWord;
begin
  GetFrameIdxOff(Frame,Idx,Off,FrameAddr);
  Frames[Idx]:=Frames[Idx] or ($1 shl Off);
end;

procedure ClearFrame(FrameAddr: LongWord);
var
  Frame,Idx,Off: LongWord;
begin
  GetFrameIdxOff(Frame,Idx,Off,FrameAddr);
  Frames[Idx]:=Frames[Idx] and not($1 shl Off);
end;

function TestFrame(FrameAddr: LongWord): LongWord;
var
  Frame,Idx,Off: LongWord;
begin
  GetFrameIdxOff(Frame,Idx,Off,FrameAddr);
  TestFrame:=Frames[Idx] and ($1 shl Off);
end;

function FirstFrame: LongWord;
var
  i,j,ToTest: LongWord;
begin
  for i:=0 to IndexFromBit(FrameCount)-1 do
    if Frames[i]<>$FFFFFFFF then // nothing free, exit early.
      // at least one bit is free here.
      for j:=0 to 31 do begin
        ToTest:=$1 shl j;
        if Frames[i] and ToTest=0 then begin
          FirstFrame:=i*4*8+j;
          Exit;
        end;
      end;
end;

procedure AllocFrame(var Page : LongWord; IsKernel,IsWritable: Boolean);
var
ind : LongWord;
begin
if Page shr 12 <> 0 then
  Exit
else
begin

ind := FirstFrame;

  if ind = High(LongWord) then
    begin
      Panic('NO FREE FRAMES');
    end;

SetFrame(ind*$1000);
Page := Page and 1;   //Present

if isWritable then
  Page := Page and 2  //Writable
else
  Page := Page and $FFFFFFFD;

if isKernel then
  Page := Page and $FFFFFFFB
else
  Page := Page and 4; //User Mode

Page := Page or (Ind shl 12);
end;
end;

procedure FreeFrame(var Page : LongWord);
var
Frame : LongWord;
begin
Frame := Page shr 12;

if Frame = 0 then
  Exit
else
  begin
  ClearFrame(Frame);
  Page := Page and $FFF;
  end;
end;

function GetPage(Addr : LongWord; Make : Boolean; PageDir : PLongWord): PLongWord;
var
TableIdx, Temp : LongWord;
begin
Addr := Addr div $1000;
TableIdx := Addr div 1024;

if PageDir[TableIdx] <> 2 then // If the table is assigned already
  GetPage := PLongWord(PLongWord(PageDir[TableIdx])[Addr mod 1024])
else if Make then
  begin
  PageDir[TableIdx] := LongWord(kmalloc(SizeOf(LongWord), true,@Temp));
  FillByte(PageDir[TableIdx],$1000,0);
  PageDir[TableIdx] := Temp or $7; //Present, ReadWrite, UserMode
  GetPage:=PLongWord(PLongWord(PageDir[TableIdx])[Addr mod 1024]);
  end
else
  GetPage := nil;
end;

procedure SetupPaging(const Value : LongWord);assembler;nostackframe;
asm
mov cr3, Value
mov eax, cr0
or eax, $80000000
mov cr0, eax
end;

procedure SwitchPageDir(PageDir: PLongWord);
begin
  CurrentDirectory := PageDir;
  SetupPaging(PtrUInt(PageDir));
end;

procedure PageFaultHandler(var r: TRegisters);
var
  FaultingAddress: LongWord;
  Present,ReadOnly,UserMode,Reserved,Id: Boolean;
begin
  asm
    mov eax,cr2
    mov FaultingAddress,eax
  end;
  with r do begin
    Present:=  (ErrorCode and $1)=0;
    ReadOnly:= (ErrorCode and $2)<>0;
    UserMode:= (ErrorCode and $4)<>0;
    Reserved:= (ErrorCode and $8)<>0;
    Id:= (ErrorCode and $10)<>0;
  end;
  PrintString(#10'Faulting address: $'+HexStr(FaultingAddress,8));
  PrintString(#10'Page status: ( ');
  if Present then PrintString('present ');
  if ReadOnly then PrintString('read-only ');
  if UserMode then PrintString('user-mode ');
  if Reserved then PrintString('reserved ');
  PrintString(#10')');
  Panic('Page Fault');
  while true do;
end;

procedure FillPageTable(var PageTable: PLongWord; const Phys: LongWord);
var
  i: Word;
begin
  for i := 0 to 1023 do
    PageTable[i] := ((i*PageSize)+Phys) or 3; // 011 (supervisor, read/write, present)
end;

procedure InitPageDirectory;
var
  i: Word;
begin
  for i:=0 to 1023 do
    PageDir[i] := 2; // 010 (supervisor, read/write, not present)
end;

procedure InitPaging(MemSizeInKB : LongWord);
var
i, Mem : LongWord;

 procedure DetectMemory;
  var
    S,SizeSuffix, sTmp : String;
  begin
    PrintString(#10'Detecting Memory... ');
    Str(MemSizeInKB,S);
    case Length(S) of
      1..3: SizeSuffix:=' KB';
      4..6: begin
        MemSizeInKB := (MemSizeInKB shr 10)+1;
        SizeSuffix:=' MB';
      end;
      else begin
        MemSizeInKB := (MemSizeInKB shr 20)+1;
        SizeSuffix :=' GB';
      end;
    end;
    MemorySize := MemSizeInKB shl 10; // Turns KB into Bytes
    FrameCount := MemorySize div PageSize;
    Str(MemSizeInKB,sTmp);
    PrintString(#10'You have : ' + sTmp);
    PrintString(SizeSuffix + ' of memory availabe');
  end;

begin
  DetectMemory;
  PrintString(#10'Initialising Paging');

  // Create our page directory
  PageDir := PLongWord((PtrUInt(@KernelEnd) and $FFFFF000) + PageSize);

  //Create our identity map to map virtual memory to physical memory

  PageTable[0] := PageDir + PageSize;
  PageTable[768] := PageTable[0] + PageSize;

  FillPageTable(PageTable[0],0); // Identity Map
  FillPageTable(PageTable[768],$100000);

  // The next 3 instructions MUST be kept ordered!!!
  InitPageDirectory;
  PageDir[0] := PtrUInt(PageTable[0]) or 3;
  PageDir[768] := PtrUInt(PageTable[768]) or 3;

  Frames := PLongWord(kmalloc(IndexFromBit(FrameCount),false,nil));
  FillByte(Frames,IndexFromBit(FrameCount),0);

  SetIDTGate(14,PtrUInt(@PageFaultHandler),$08,$8E);
  SwitchPageDir(PageDir);

  PrintString(#10'Done');
end;

end.
