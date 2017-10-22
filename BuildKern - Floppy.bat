@echo off
cd H:\[Borland Pascal]\FPC OS\Kernel

echo ***Building 3rd Stage entry stub
nasm -f elf Stage3.asm -o obj/stage3.o
nasm -f elf Int.asm -o obj/Int.o

echo ***Building Main kernel
echo ***Please be patient this may take a while...
fpc -Aelf -CX -n -O3 -Os -OpPENTIUMM -OoREGVAR -OoUNCERTAIN -OoNOSTACKFRAME -OoPEEPHOLE -OoASMCSE -OoLOOPUNROLL -OoTAILREC -Rintel -Sagic -Tlinux -uUNIX -uLINUX -vnhw -Xd -XX -Fu../rtl/units/i386-fpos -FUobj Kernel.pas

echo ***Linking files...
LD2 -T min.ld -o ../Release/kernel obj/stage3.o obj/kernel.o obj/multiboot.o obj/console.o obj/ports.o obj/idt.o obj/gdt.o obj/isr.o obj/irq.o obj/pit.o obj/keyboard.o obj/paging.o obj/heap.o obj/Sound.o obj/floppy.o obj/Int.o obj/Interrupts.o obj/Multitasking.o ../rtl/units/i386-fpos/system.o
echo ****Done****
echo Please insert a floppy disk into the A: drive then

pause
cd H:\[Borland Pascal]\FPC OS

echo Installing GRUB bootloader to floppy driver
.\bin\rawwritewin --write ".\floppy\grub.img"

echo Installing configuration files for GRUB
copy ".\floppy\menu.cfg" "a:\boot\menu.cfg"

echo Installing the Kernel
Copy Release\Kernel A:\system\Kernel

echo ****Done****
pause
