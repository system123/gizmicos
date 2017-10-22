unit heap;

interface

function kmalloc(size : Longword; align : boolean; Phys : PLongWord):LongWord;
function MemAlloc(Size : LongWord):LongWord;
procedure MemCopy(Src : PLongWord; Dest : PLongWord; Size : LongWord);
procedure MemMove(Src : PLongWord; Dest : PLongWord; Size : LongWord);

var
  PlacementAdd : LongWord;

implementation

function kmalloc(size : Longword; align : boolean; Phys : PLongWord):LongWord;
var
Temp: LongWord;
Addr : Pointer;
begin

if align and (PlacementAdd and $FFFFF000 <> 0) then
  PlacementAdd := (PlacementAdd and ($FFFFF000)) + $1000;

if Assigned(Phys) then
  Phys^ := PlacementAdd;

kmalloc := PlacementAdd;
Inc(PlacementAdd,Size);
end;

function MemAlloc(Size : LongWord):LongWord;
begin
kmalloc(Size, false, nil);
end;

procedure MemCopy(Src : PLongWord; Dest : PLongWord; Size : LongWord);
var
i : integer;
begin
kmalloc(Size,false,Dest);

for i := 0 to Size do
  begin
  Dest[i] := Src[i];
  end;
end;

procedure MemMove(Src : PLongWord; Dest : PLongWord; Size : LongWord);
var
i : integer;
DEnd, SEnd : PLongWord;
k, S : LongWord;
begin
DEnd := Dest + Size;
SEnd := Src + Size;

 for i := 0 to Size do
    Dest[i] := Src[i];

if (Src < DEnd) and (Src > Dest) then
begin
   k := LongWord(SEnd);
   S := SEnd - DEnd;
   for i := S to k do
    Src[i] := LongWord(char($0));
end
else
 for i := 0 to Size do
    Src[i] := LongWord(char($0));
end;

end.
