unit dma;

interface

uses ports;

const
        DMAPage:array [0..7] of byte=($87,$83,$81,$82,$8f,$8b,$89,$8a);
        DMAAddr:array [0..7] of byte=(0,2,4,6,$c0,$c4,$c8,$cc);
        DMALen:array [0..7] of byte=(1,3,5,7,$c2,$c6,$ca,$ce);
        DMAMaskL=$a;
        DMAMaskH=$d4;
        DMAModeL=$b;
        DMAModeH=$d6;
        DMAClearL=$c;
        DMAClearH=$d8;

procedure SetupDMARead(chan,length:cardinal; buffer:pointer);
procedure SetupDMAWrite(chan,length:cardinal; buffer:pointer);
function getdmaremaining(chan:cardinal):cardinal;
procedure enabledma(chan:cardinal);
procedure disabledma(chan:cardinal);
procedure initdma;

implementation

var
        dmainuse:array [0..7] of boolean;

procedure initdma;
var
        i:cardinal;
begin
        for i:=0 to 7 do dmainuse[i]:=false;
        dmainuse[4]:=true;//cascade channel
end;

procedure enabledma(chan:cardinal);
begin
        if chan<4 then begin
                WritePort(DMAMaskL,chan);
        end else if ((chan>3) and (chan<8)) then begin
                WritePort(DMAMaskH,chan-4);
        end;
end;
procedure disabledma(chan:cardinal);
begin
        if chan<4 then begin
                WritePort(DMAMaskL,4+chan);
        end else if ((chan>3) and (chan<8)) then begin
                WritePort(DMAMaskH,chan);
        end;
end;

function getdmaremaining(chan:cardinal):cardinal;
var
count:word;
begin
        count:=0;
        if chan<7 then begin
                disabledma(chan);
                count:= ReadPort(DMALen[chan])+1;
                count:= count + (ReadPort(DMALen[chan]) shl 8);
                if count<>0 then
                  enabledma(chan)
                else
                  dmainuse[chan] := false;
        end;
        getdmaremaining:=count;
end;

{These 2 routines program the dma controler ready for dma
both will lock and yeild in the testandset routine if the channel is unavailable
and will stay yeilded until the channel becomes available again}

procedure SetupDMARead(chan,length:cardinal; buffer:pointer);
var
        ad,page:cardinal;
begin
        if chan<4 then begin
                ad:= PtrUInt(buffer);
                page:=(ad shr 16) and $ff;
                ad:=ad and $ffff;
        end else begin
                ad:= PtrUInt(buffer);
                page:=(ad shr 16) and $fe;
                ad:=(ad shr 1) and $ffff
        end;
        if ((chan>7) or (chan=4)) then begin
              //  writeln('Cannot do DMA on a channel that doesnt exist');
               // dodmaread:=-(KERROR);
                exit;
        end else begin
                dmainuse[chan] := true;
                disabledma(chan);
                if chan<4 then begin
                        WritePort(DMAClearL,0);
                        WritePort(DMAModeL,$44);
                        WritePort(DMAaddr[chan],(ad and $ff));
                        WritePort(DMAaddr[chan],((ad and $ff00) div $100));
                        WritePort(DMAlen[chan],(length and $ff));
                        WritePort(DMAlen[chan],((length shr 8) and $ff));
                        WritePort(DMAPage[chan],(page and $ff));
                end else begin
                        WritePort(DMAClearH,0);
                        WritePort(DMAModeH,$44);
                        WritePort(DMAaddr[chan],(ad and $ff));
                        WritePort(DMAaddr[chan],((ad and $ff00) div $100));
                        WritePort(DMAlen[chan],((length shr 1) and $ff));
                        WritePort(DMAlen[chan],((length shr 9) and $ff));
                        WritePort(DMAPage[chan],(page and $ff));

                end;
        end;
end;

procedure SetupDMAWrite(chan,length:cardinal; buffer:pointer);
var
        ad,page:cardinal;
begin
        if chan<4 then begin
                ad:= PtrUInt(buffer);
                page:=(ad shr 16) and $ff;
                ad:=ad and $ffff;
        end else begin
                ad:= PtrUInt(buffer);
                page:=(ad shr 16) and $fe;
                ad:=(ad shr 1) and $ffff
        end;
        if ((chan>7) or (chan=4)) then begin
               // writeln('Cannot do DMA on a channel that doesnt exist');
                //dodmaread:=-(KERROR);
                exit;
        end else begin
                dmainuse[chan] := true;
                disabledma(chan);
                if chan<4 then begin
                        WritePort(DMAClearL,0);
                        WritePort(DMAModeL,$48);
                        WritePort(DMAaddr[chan],(ad and $ff));
                        WritePort(DMAaddr[chan],((ad and $ff00) div $100));
                        WritePort(DMAlen[chan],(length and $ff));
                        WritePort(DMAlen[chan],((length shr 8) and $ff));
                        WritePort(DMAPage[chan],(page and $ff));
                end else begin
                        WritePort(DMAClearH,0);
                        WritePort(DMAModeH,$48);
                        WritePort(DMAaddr[chan],(ad and $ff));
                        WritePort(DMAaddr[chan],((ad and $ff00) div $100));
                        WritePort(DMAlen[chan],((length shr 1) and $ff));
                        WritePort(DMAlen[chan],((length shr 9) and $ff));
                        WritePort(DMAPage[chan],(page and $ff));

                end;
        end;
end;
end.
