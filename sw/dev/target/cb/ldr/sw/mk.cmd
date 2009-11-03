as -l -o ldr.asm
ln -f ldr.lnk
s192bin ldr
bin2hex ldr.bin >ldr.hex
copy ldr.hex ..\..\..\de2\ldr\src\roms\trs80_m3_rom.hex
bin2coe ldr.bin >ldr.coe
copy ldr.coe ..\src\roms\trs80_m3_rom.coe
