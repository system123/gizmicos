{ This unit is inspired by JamesM's tutorial, but implemented as object }
unit orderedarray;

interface

type

  TLessThanFunc = function (a,b: Pointer): Boolean;

  TOrderedArray = object
  private
    Data: PPointer;
    Size: LongWord;
    MaxSize: LongWord;
    LessThanFunc: TLessThanFunc;
  public
    procedure Create(InitMaxSize: LongWord; InitLessThanFunc: TLessThanFunc);
    procedure Place(Addr: Pointer; InitMaxSize: LongWord; InitLessThanFunc:
      TLessThanFunc);
    procedure Destroy;
    procedure Insert(Item: Pointer);
    function LookUp(Idx: LongWord): Pointer;
    procedure Remove(Idx: LongWord);
    function GetSize: LongWord;
  end;

function DefaultLessThan(a,b: Pointer): Boolean;

implementation

uses
  heap;

function DefaultLessThan(a,b: Pointer): Boolean;
begin
  DefaultLessThan:=a<b;
end;

{ TOrderedArray }

procedure TOrderedArray.Create(InitMaxSize: LongWord; InitLessThanFunc: TLessThanFunc);
var
  ArraySize: LongWord;
begin
  ArraySize:=InitMaxSize*SizeOf(Pointer);
  Data:=PPointer(MemAlloc(ArraySize));
  FillByte(Data,ArraySize,0);
  Size:=0;
  MaxSize:=InitMaxSize;
  LessThanFunc:=InitLessThanFunc;
end;

procedure TOrderedArray.Place(Addr: Pointer; InitMaxSize: LongWord; InitLessThanFunc:
  TLessThanFunc);
begin
  Data^:=Addr;
  FillByte(Data,InitMaxSize*SizeOf(Pointer),0);
  Size:=0;
  MaxSize:=InitMaxSize;
  LessThanFunc:=InitLessThanFunc;
end;

procedure TOrderedArray.Destroy;
begin
  KernelHeap^.MemFree(Data);
end;

procedure TOrderedArray.Insert(Item: Pointer);
var
  i: LongWord;
  Temp1,Temp2: Pointer;
begin
  Assert(Assigned(LessThanFunc));
  i:=0;
  while (i<Size) and (LessThanFunc(Data[i],Item)) do Inc(i);
  if i=Size then begin// just add at the end of the array.
    Data[Size]:=Item;
    Inc(Size);
  end else begin
    Temp1:=Data[i];
    Data[i]:=Item;
    while i<Size do begin
      Inc(i);
      Temp2:=Data[i];
      Data[i]:=Temp1;
      Temp1:=Temp2;
    end;
    Inc(Size);
  end;
end;

function TOrderedArray.LookUp(Idx: LongWord): Pointer;
begin
  Assert(Idx<Size);
  LookUp:=Data[Idx];
end;

procedure TOrderedArray.Remove(Idx: LongWord);
begin
  while Idx<Size do begin
    Data[Idx]:=Data[Idx+1];
    Inc(Idx);
  end;
  Dec(Size);
end;

function TOrderedArray.GetSize: LongWord;
begin
  GetSize:=Size;
end;

end.
