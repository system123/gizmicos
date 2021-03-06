{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by the Free Pascal development team.

    Processor independent implementation for the system unit
    (based on libc)

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}


{****************************************************************************
                               Primitives
****************************************************************************}

{$ifndef FPC_SYSTEM_HAS_MOVE}
{$define FPC_SYSTEM_HAS_MOVE}
procedure bcopy(const source;var dest;count:size_t); cdecl; external 'c' name 'bcopy';

{ we need this separate move declaration because we can't add a "public, alias" to the above }
procedure Move(const source;var dest;count:sizeint); [public, alias: 'FPC_MOVE'];{$ifdef SYSTEMINLINE}inline;{$endif}
begin
  if count <= 0 then
    exit;
  bcopy(source,dest,count);
end;
{$endif not FPC_SYSTEM_HAS_MOVE}


{$ifndef FPC_SYSTEM_HAS_FILLCHAR}
{$define FPC_SYSTEM_HAS_FILLCHAR}
procedure memset(var x; value: byte; count: size_t); cdecl; external 'c';

Procedure FillChar(var x;count: sizeint;value:byte);{$ifdef SYSTEMINLINE}inline;{$endif}
begin
  if count <= 0 then
    exit;
  memset(x,value,count);
end;
{$endif FPC_SYSTEM_HAS_FILLCHAR}


{$ifndef FPC_SYSTEM_HAS_INDEXBYTE}
{$define FPC_SYSTEM_HAS_INDEXBYTE}

function memchr(const buf; b: cint; len: size_t): pointer; cdecl; external 'c';

function IndexByte(Const buf;len:sizeint;b:byte):sizeint;{$ifdef SYSTEMINLINE}inline;{$endif}
var
  res: pointer;
begin
  if len = 0 then
    exit(-1);
  { simulate assembler implementations behaviour, which is expected }
  { fpc_pchar_to_ansistr in astrings.inc (interpret values < 0 as   }
  { unsigned)                                                       }
  res := memchr(buf,cint(b),size_t(sizeuint(len)));
  if (res <> nil) then
    IndexByte := SizeInt(res-@buf)
  else
    IndexByte := -1;
end;
{$endif not FPC_SYSTEM_HAS_INDEXBYTE}


{$ifndef FPC_SYSTEM_HAS_COMPAREBYTE}
{$define FPC_SYSTEM_HAS_COMPAREBYTE}
function memcmp_comparechar(Const buf1,buf2;len:size_t):cint; cdecl; external 'c' name 'memcmp';

function CompareByte(Const buf1,buf2;len:sizeint):sizeint;{$ifdef SYSTEMINLINE}inline;{$endif}
var
  res: longint;
begin
  if len <= 0 then
    exit(0);
  res := memcmp_comparechar(buf1,buf2,len);
  if res < 0 then
    CompareByte := -1
  else if res > 0 then
    CompareByte := 1
  else
    CompareByte := 0;
end;
{$endif not FPC_SYSTEM_HAS_COMPAREBYTE}


{$ifndef FPC_SYSTEM_HAS_COMPARECHAR0}
{$define FPC_SYSTEM_HAS_COMPARECHAR0}
function strncmp_comparechar0(Const buf1,buf2;len:size_t):longint; cdecl; external 'c' name 'strncmp';

function CompareChar0(Const buf1,buf2;len:sizeint):sizeint;{$ifdef SYSTEMINLINE}inline;{$endif}
begin
  if len <= 0 then
    exit(0);
  CompareChar0:=strncmp_comparechar0(buf1,buf2,len);
end;

{$endif not FPC_SYSTEM_HAS_COMPARECHAR0}



{$ifndef FPC_SYSTEM_HAS_FPC_PCHAR_LENGTH}
{$define FPC_SYSTEM_HAS_FPC_PCHAR_LENGTH}

function libc_pchar_length(p:pchar):size_t; cdecl; external 'c' name 'strlen';

function fpc_pchar_length(p:pchar):longint;[public,alias:'FPC_PCHAR_LENGTH']; compilerproc;
begin
  fpc_pchar_length:=libc_pchar_length(p);
end;

{$endif ndef FPC_SYSTEM_HAS_FPC_PCHAR_LENGTH}


