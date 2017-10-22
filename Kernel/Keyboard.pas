unit Keyboard;

interface

Type
  TKeyMap = array[0..127] of Char;


const
  DataPort = $60;
  CtrlPort = $64;

  USKeyMap : TKeyMap = (
    #00,
    #27, // Esc
    '1','2','3','4','5','6','7','8','9','0','-','=', // Numbers
    #08, //Backspace
    #09, //Tab
    'q','w','e','r','t','y','u','i','o','p','[',']',
    #10, //Enter
    #00, //Ctrl
    'a','s','d','f','g','h','j','k','l',';',
    '''', // '
    '`',
    #00, //Left Shift
    '\','z','x','c','v','b','n','m',',','.','/',
    #00, //Right Shift
    '*',
    #00, //Alt
    ' ', //Space Bar
    #0, //Caps Lock
    #0,#0,#0,#0,#0,#0,#0,#0,#0,#0, //F1 - F10
    #0, //Num Lock
    #0, //Scroll Lock
    #0, //Home Key
    #0, //Up Arrow
    #0, //Page Up
    '-',
    #0, //Left Arrow
    #0,
    #0, //Right Arrow
    '+',
    #0, //End key
    #0, //Down Arrow
    #0, //Page Down
    #0, //Insert Key
    #0, //Delete Key
    #0,#0,#0,
    #0, //F11 Key
    #0, //F12 Key
    #0, //All other keys are undefined
    #0,
    #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
    #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
    #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
    #0,#0,#0,#0,#0,#0,#0
    );

  ShiftedUSKeyMap : TKeyMap = (
    #00,
    #27, // Esc
    '!','@','#','$','%','^','&','*','(',')','_','+', // Numbers
    #08, //Backspace
    #09, //Tab
    'Q','W','E','R','T','Y','U','I','O','P','{','}',
    #10, //Enter
    #00, //Ctrl
    'A','S','D','F','G','H','J','K','L',':',
    '"', // '
    '~',
    #00, //Left Shift
    '|','Z','X','C','V','B','N','M','<','>','?',
    #00, //Right Shift
    '*', //Num Pad *
    #00, //Alt
    ' ', //Space Bar
    #0, //Caps Lock
    #0,#0,#0,#0,#0,#0,#0,#0,#0,#0, //F1 - F10
    #0, //Num Lock
    #0, //Scroll Lock
    #0, //Home Key
    #0, //Up Arrow
    #0, //Page Up
    '-',
    #0, //Left Arrow
    #0,
    #0, //Right Arrow
    '+',
    #0, //End key
    #0, //Down Arrow
    #0, //Page Down
    #0, //Insert Key
    #0, //Delete Key
    #0,#0,#0,
    #0, //F11 Key
    #0, //F12 Key
    #0, //All other keys are undefined
    #0,
    #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
    #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
    #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,
    #0,#0,#0,#0,#0,#0,#0
    );

var
  Buffer : string = '';

procedure InitKeyboard;
procedure LoadKeyMap(const KeyMap, ShiftedKeyMap : TKeyMap);

implementation

uses irq, console;

type
  TKeyStatus = (ksCtrl, ksAlt, ksShift, ksCaps, ksNum, ksScroll);
  TKeyStatusSet = set of TKeyStatus;

var
  KeyStatus : TKeyStatusSet;
  ActiveKeyMap, ActiveShiftedKeyMap : TKeyMap;

procedure LoadKeyMap(const KeyMap, ShiftedKeyMap : TKeyMap);
begin
ActiveKeyMap := KeyMap;
ActiveShiftedKeyMap := ShiftedKeyMap;
end;

procedure SetLED(c,n,s : boolean);
var
        l : byte;
        i : cardinal;
begin
        i:=0;
        l:=2;

        while (i < 250) and ((l and 2)=2) do begin
                l := ReadPort($64);
                inc(i);
        end;
        
        if i >= 250 then
          begin
            PrintString(#10'Trying to set KBD LEDS caused timeout');
            Exit;
          end

        else
          begin
                if s = true then l := 1 else l := 0;
                if n = true then l := l+2;
                if c = true then l := l+4;
                WritePort($60, $ED);
                WritePort($60, l);
          end;
end;

procedure KeyboardHandler(var r : TRegisters);
var
  ScanCode: Byte;
  c: Char;
begin
ScanCode := ReadPort(DataPort);

if (ScanCode and $80) = 0 then
  begin
    case ScanCode of
    42, 54  : if not (ksShift in KeyStatus) then
              Include(KeyStatus, ksShift);

    58      : if not (ksCaps in KeyStatus) then
                begin
                SetLED(true, false, false);
                Include(KeyStatus, ksCaps);
                end
              else
                begin
                SetLED(false, false, false);
                Exclude(KeyStatus, ksCaps);
                end; 
    end;

    if ksShift in KeyStatus then            // Shift Engaged
      c := ActiveShiftedKeyMap[ScanCode]
    else
      if not (ksCaps in KeyStatus) then   // And Caps Lock Off
      c := ActiveKeyMap[ScanCode]
    else
      c := UpCase(ActiveKeyMap[ScanCode]);   // Caps Lock ON

    case c of
    #08  : begin
          PrintChar(c);
          Delete(Buffer, Length(Buffer),1);
          end;

    #10  : begin
          PrintChar(c);
          //ExecCommand(Buffer);
          //Buffer := '';
          end;

    #0  : begin
          // Not Yet Implemented
          end
          
    else // Other characters
        if Length(Buffer) < 255 then begin // ShortString limit
        PrintChar(c);
        //Buffer := Buffer+c;
      end
    else
      begin
        PrintString(#10);
        SetTextColor(clBlack,clRed);
        PrintString('Maximum buffer length is 255!');
        SetTextColor(clBlack, clWhite);
      end;
    end;
  end

else   //Key Released
  begin
    ScanCode := ScanCode and not $80;

    case ScanCode of
      42,54: if ksShift in KeyStatus then
      Exclude(KeyStatus,ksShift);
    end;
  end;
end;

procedure InitKeyboard;
begin
PrintString(#10'Initialising the keyboard');
LoadKeyMap(USKeyMap, ShiftedUSKeyMap);
InstallIRQHandler(1, @KeyboardHandler);
PrintString(#10'Done');
end;

end.
