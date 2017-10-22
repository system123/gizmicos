cd G:\[Borland Pascal]\FPC OS\rtl\fpos
fpc -Aelf -CX -n -O3 -Os -Sg -OpPentiumm -OoREGVAR -OoSTACKFRAME -RIntel -uLINUX -Xd -XX -Tlinux -Fi../i386 -Fi../inc -FU../units/i386-fpos system.pas
pause
cd C:\Tasm_5\FPC OS\rtl\i386
fpc -Aelf -CX -n -O3 -Os -Sg -OpPentiumm -OoREGVAR -OoSTACKFRAME -RIntel -uLINUX -Xd -XX -Tlinux -Fu../units/i386-fpos -FU../units/i386-fpos cpu.pp
fpc -Aelf -CX -n -O3 -Os -Sg -OpPentiumm -OoREGVAR -OoSTACKFRAME -RIntel -uLINUX -Xd -XX -Tlinux -Fu../units/i386-fpos -FU../units/i386-fpos mmx.pp
pause
cd C:\Tasm_5\FPC OS\rtl\inc
fpc -Aelf -CX -n -O3 -Os -Sg -OpPentiumm -OoREGVAR -OoSTACKFRAME -RIntel -uLINUX -Xd -XX -Tlinux -Fu../units/i386-fpos -FU../units/i386-fpos ctypes.pp
pause