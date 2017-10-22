unit Ports;

interface 

function ReadPort(Port: Word): Byte;
procedure WritePort(Port: Word; Value: Byte);
procedure Move(const source;var dest;count:SizeInt);
procedure FillWord(var x;count : SizeInt;value : word);

const
  SMALLMOVESIZE = 36;

var
temp : byte;

implementation

//procedure fpc_shortstr_assign(len:longint;sstr,dstr:pointer);[public,alias:'FPC_SHORTSTR_ASSIGN']; {$ifdef HAS_COMPILER_PROC} compilerproc; {$endif}
{var
  slen : byte;
type
  pstring = ^string;
begin
  slen:=length(pstring(sstr)^);
  if slen<len then
    len:=slen;
  move(sstr^,dstr^,len+1);
  if slen>len then
    pchar(dstr)^:=chr(len);
end;      }


{$asmmode intel}
procedure WritePort(Port: Word; Value: Byte);
begin
  asm
    mov dx,Port
    mov al,Value
    out dx,al
  end ['EAX','EDX'];
end;

function ReadPort(Port: Word): Byte;
var
  Value: Byte;
begin
  asm
    mov dx,Port
    in  al,dx
    mov @Result, al;
  end ['EAX','EDX'];
end;

procedure fillword(var x;count : SizeInt;value : word);
var
  aligncount : sizeint;
  pdest,pend : pword;
  v : ptruint;
begin
  if count <= 0 then
    exit;
  pdest:=@x;
  if Count>4*sizeof(ptruint)-1 then
    begin
      v:=(value shl 16) or value;
      { Align on native pointer size }
      aligncount:=(PtrUInt(pdest) and (sizeof(PtrUInt)-1)) shr 1;
      dec(count,aligncount);
      pend:=pdest+aligncount;
      while pdest<pend do
        begin
          pdest^:=value;
          inc(pdest);
        end;
      { use sizeuint typecast to force shr optimization }
      pptruint(pend):=pptruint(pdest)+((sizeuint(count)*2) div sizeof(ptruint));
      while pdest<pend do
        begin
          pptruint(pdest)^:=v;
          inc(pptruint(pdest));
        end;
      count:=((count*2) and (sizeof(ptruint)-1)) shr 1;
    end;
  pend:=pdest+count;
  while pdest<pend do
    begin
      pdest^:=value;
      inc(pdest);
    end;
end;

procedure SmallForwardMove_3;assembler;nostackframe;
asm
  jmp     dword ptr @@FwdJumpTable[ecx*4]
  align   16
@@FwdJumpTable:
  dd      @@Done {Removes need to test for zero size move}
  dd      @@Fwd01,@@Fwd02,@@Fwd03,@@Fwd04,@@Fwd05,@@Fwd06,@@Fwd07,@@Fwd08
  dd      @@Fwd09,@@Fwd10,@@Fwd11,@@Fwd12,@@Fwd13,@@Fwd14,@@Fwd15,@@Fwd16
  dd      @@Fwd17,@@Fwd18,@@Fwd19,@@Fwd20,@@Fwd21,@@Fwd22,@@Fwd23,@@Fwd24
  dd      @@Fwd25,@@Fwd26,@@Fwd27,@@Fwd28,@@Fwd29,@@Fwd30,@@Fwd31,@@Fwd32
  dd      @@Fwd33,@@Fwd34,@@Fwd35,@@Fwd36
@@Fwd36:
  mov     ecx,[eax-36]
  mov     [edx-36],ecx
@@Fwd32:
  mov     ecx,[eax-32]
  mov     [edx-32],ecx
@@Fwd28:
  mov     ecx,[eax-28]
  mov     [edx-28],ecx
@@Fwd24:
  mov     ecx,[eax-24]
  mov     [edx-24],ecx
@@Fwd20:
  mov     ecx,[eax-20]
  mov     [edx-20],ecx
@@Fwd16:
  mov     ecx,[eax-16]
  mov     [edx-16],ecx
@@Fwd12:
  mov     ecx,[eax-12]
  mov     [edx-12],ecx
@@Fwd08:
  mov     ecx,[eax-8]
  mov     [edx-8],ecx
@@Fwd04:
  mov     ecx,[eax-4]
  mov     [edx-4],ecx
  ret
@@Fwd35:
  mov     ecx,[eax-35]
  mov     [edx-35],ecx
@@Fwd31:
  mov     ecx,[eax-31]
  mov     [edx-31],ecx
@@Fwd27:
  mov     ecx,[eax-27]
  mov     [edx-27],ecx
@@Fwd23:
  mov     ecx,[eax-23]
  mov     [edx-23],ecx
@@Fwd19:
  mov     ecx,[eax-19]
  mov     [edx-19],ecx
@@Fwd15:
  mov     ecx,[eax-15]
  mov     [edx-15],ecx
@@Fwd11:
  mov     ecx,[eax-11]
  mov     [edx-11],ecx
@@Fwd07:
  mov     ecx,[eax-7]
  mov     [edx-7],ecx
  mov     ecx,[eax-4]
  mov     [edx-4],ecx
  ret
@@Fwd03:
  movzx   ecx, word ptr [eax-3]
  mov     [edx-3],cx
  movzx   ecx, byte ptr [eax-1]
  mov     [edx-1],cl
  ret
@@Fwd34:
  mov     ecx,[eax-34]
  mov     [edx-34],ecx
@@Fwd30:
  mov     ecx,[eax-30]
  mov     [edx-30],ecx
@@Fwd26:
  mov     ecx,[eax-26]
  mov     [edx-26],ecx
@@Fwd22:
  mov     ecx,[eax-22]
  mov     [edx-22],ecx
@@Fwd18:
  mov     ecx,[eax-18]
  mov     [edx-18],ecx
@@Fwd14:
  mov     ecx,[eax-14]
  mov     [edx-14],ecx
@@Fwd10:
  mov     ecx,[eax-10]
  mov     [edx-10],ecx
@@Fwd06:
  mov     ecx,[eax-6]
  mov     [edx-6],ecx
@@Fwd02:
  movzx   ecx, word ptr [eax-2]
  mov     [edx-2],cx
  ret
@@Fwd33:
  mov     ecx,[eax-33]
  mov     [edx-33],ecx
@@Fwd29:
  mov     ecx,[eax-29]
  mov     [edx-29],ecx
@@Fwd25:
  mov     ecx,[eax-25]
  mov     [edx-25],ecx
@@Fwd21:
  mov     ecx,[eax-21]
  mov     [edx-21],ecx
@@Fwd17:
  mov     ecx,[eax-17]
  mov     [edx-17],ecx
@@Fwd13:
  mov     ecx,[eax-13]
  mov     [edx-13],ecx
@@Fwd09:
  mov     ecx,[eax-9]
  mov     [edx-9],ecx
@@Fwd05:
  mov     ecx,[eax-5]
  mov     [edx-5],ecx
@@Fwd01:
  movzx   ecx, byte ptr [eax-1]
  mov     [edx-1],cl
@@Done:
end; {SmallForwardMove}

{-------------------------------------------------------------------------}
{Perform Backward Move of 0..36 Bytes}
{On Entry, ECX = Count, EAX = Source, EDX = Dest.  Destroys ECX}
procedure SmallBackwardMove_3;assembler;nostackframe;
asm
  jmp     dword ptr @@BwdJumpTable[ecx*4]
  align   16
@@BwdJumpTable:
  dd      @@Done {Removes need to test for zero size move}
  dd      @@Bwd01,@@Bwd02,@@Bwd03,@@Bwd04,@@Bwd05,@@Bwd06,@@Bwd07,@@Bwd08
  dd      @@Bwd09,@@Bwd10,@@Bwd11,@@Bwd12,@@Bwd13,@@Bwd14,@@Bwd15,@@Bwd16
  dd      @@Bwd17,@@Bwd18,@@Bwd19,@@Bwd20,@@Bwd21,@@Bwd22,@@Bwd23,@@Bwd24
  dd      @@Bwd25,@@Bwd26,@@Bwd27,@@Bwd28,@@Bwd29,@@Bwd30,@@Bwd31,@@Bwd32
  dd      @@Bwd33,@@Bwd34,@@Bwd35,@@Bwd36
@@Bwd36:
  mov     ecx,[eax+32]
  mov     [edx+32],ecx
@@Bwd32:
  mov     ecx,[eax+28]
  mov     [edx+28],ecx
@@Bwd28:
  mov     ecx,[eax+24]
  mov     [edx+24],ecx
@@Bwd24:
  mov     ecx,[eax+20]
  mov     [edx+20],ecx
@@Bwd20:
  mov     ecx,[eax+16]
  mov     [edx+16],ecx
@@Bwd16:
  mov     ecx,[eax+12]
  mov     [edx+12],ecx
@@Bwd12:
  mov     ecx,[eax+8]
  mov     [edx+8],ecx
@@Bwd08:
  mov     ecx,[eax+4]
  mov     [edx+4],ecx
@@Bwd04:
  mov     ecx,[eax]
  mov     [edx],ecx
  ret
@@Bwd35:
  mov     ecx,[eax+31]
  mov     [edx+31],ecx
@@Bwd31:
  mov     ecx,[eax+27]
  mov     [edx+27],ecx
@@Bwd27:
  mov     ecx,[eax+23]
  mov     [edx+23],ecx
@@Bwd23:
  mov     ecx,[eax+19]
  mov     [edx+19],ecx
@@Bwd19:
  mov     ecx,[eax+15]
  mov     [edx+15],ecx
@@Bwd15:
  mov     ecx,[eax+11]
  mov     [edx+11],ecx
@@Bwd11:
  mov     ecx,[eax+7]
  mov     [edx+7],ecx
@@Bwd07:
  mov     ecx,[eax+3]
  mov     [edx+3],ecx
  mov     ecx,[eax]
  mov     [edx],ecx
  ret
@@Bwd03:
  movzx   ecx, word ptr [eax+1]
  mov     [edx+1],cx
  movzx   ecx, byte ptr [eax]
  mov     [edx],cl
  ret
@@Bwd34:
  mov     ecx,[eax+30]
  mov     [edx+30],ecx
@@Bwd30:
  mov     ecx,[eax+26]
  mov     [edx+26],ecx
@@Bwd26:
  mov     ecx,[eax+22]
  mov     [edx+22],ecx
@@Bwd22:
  mov     ecx,[eax+18]
  mov     [edx+18],ecx
@@Bwd18:
  mov     ecx,[eax+14]
  mov     [edx+14],ecx
@@Bwd14:
  mov     ecx,[eax+10]
  mov     [edx+10],ecx
@@Bwd10:
  mov     ecx,[eax+6]
  mov     [edx+6],ecx
@@Bwd06:
  mov     ecx,[eax+2]
  mov     [edx+2],ecx
@@Bwd02:
  movzx   ecx, word ptr [eax]
  mov     [edx],cx
  ret
@@Bwd33:
  mov     ecx,[eax+29]
  mov     [edx+29],ecx
@@Bwd29:
  mov     ecx,[eax+25]
  mov     [edx+25],ecx
@@Bwd25:
  mov     ecx,[eax+21]
  mov     [edx+21],ecx
@@Bwd21:
  mov     ecx,[eax+17]
  mov     [edx+17],ecx
@@Bwd17:
  mov     ecx,[eax+13]
  mov     [edx+13],ecx
@@Bwd13:
  mov     ecx,[eax+9]
  mov     [edx+9],ecx
@@Bwd09:
  mov     ecx,[eax+5]
  mov     [edx+5],ecx
@@Bwd05:
  mov     ecx,[eax+1]
  mov     [edx+1],ecx
@@Bwd01:
  movzx   ecx, byte ptr[eax]
  mov     [edx],cl
@@Done:
end; {SmallBackwardMove}

procedure Forwards_IA32_3;assembler;nostackframe;
asm
  push    ebx
  mov     ebx,edx
  fild    qword ptr [eax]
  add     eax,ecx {QWORD Align Writes}
  add     ecx,edx
  add     edx,7
  and     edx,-8
  sub     ecx,edx
  add     edx,ecx {Now QWORD Aligned}
  sub     ecx,16
  neg     ecx
@FwdLoop:
  fild    qword ptr [eax+ecx-16]
  fistp   qword ptr [edx+ecx-16]
  fild    qword ptr [eax+ecx-8]
  fistp   qword ptr [edx+ecx-8]
  add     ecx,16
  jle     @FwdLoop
  fistp   qword ptr [ebx]
  neg     ecx
  add     ecx,16
  pop     ebx
  jmp     SmallForwardMove_3
end; {Forwards_IA32}

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX < EDX and ECX > 36 (SMALLMOVESIZE)}
procedure Backwards_IA32_3;assembler;nostackframe;
asm
  push    ebx
  fild    qword ptr [eax+ecx-8]
  lea     ebx,[edx+ecx] {QWORD Align Writes}
  and     ebx,7
  sub     ecx,ebx
  add     ebx,ecx {Now QWORD Aligned, EBX = Original Length}
  sub     ecx,16
@BwdLoop:
  fild    qword ptr [eax+ecx]
  fild    qword ptr [eax+ecx+8]
  fistp   qword ptr [edx+ecx+8]
  fistp   qword ptr [edx+ecx]
  sub     ecx,16
  jge     @BwdLoop
  fistp   qword ptr [edx+ebx-8]
  add     ecx,16
  pop     ebx
  jmp     SmallBackwardMove_3
end; {Backwards_IA32}

const
   fastmoveproc_forward : pointer = @Forwards_IA32_3;
   fastmoveproc_backward : pointer = @Backwards_IA32_3;

procedure Move(const source;var dest;count:SizeInt);[public, alias: 'MOVE'];assembler;nostackframe;
asm
  cmp     ecx,SMALLMOVESIZE
  ja      @Large
  cmp     eax,edx
  lea     eax,[eax+ecx]
  jle     @SmallCheck
@SmallForward:
  add     edx,ecx
  jmp     SmallForwardMove_3
@SmallCheck:
  je      @Done {For Compatibility with Delphi's move for Source = Dest}
  sub     eax,ecx
  jmp     SmallBackwardMove_3
@Large:
  jng     @Done {For Compatibility with Delphi's move for Count < 0}
  cmp     eax,edx
  jg      @moveforward
  je      @Done {For Compatibility with Delphi's move for Source = Dest}
  push    eax
  add     eax,ecx
  cmp     eax,edx
  pop     eax
  jg      @movebackward
@moveforward:
  jmp     dword ptr fastmoveproc_forward
@movebackward:
  jmp     dword ptr fastmoveproc_backward {Source/Dest Overlap}
@Done:
end;

end.
