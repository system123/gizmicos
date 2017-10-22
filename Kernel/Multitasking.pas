unit Multitasking;

interface

type
  PageDir = PLongWord;

implementation

uses heap, paging, ports;

function ClonePageDir(src : PageDir) : PageDir;
var
Phys : LongWord;
Dir : PageDir;
begin
Dir := PLongWord(kmalloc(SizeOf(LongWord), true, @Phys));
FillByte(Dir,SizeOf(LongWord),0);


end;

end.
