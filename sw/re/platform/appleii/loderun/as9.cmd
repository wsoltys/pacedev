cls
as6809 -l -o -s loderun_6809.asm
@if ERRORLEVEL 1 goto end
REM * cartridge image
REM aslink -i loderun_6809.rel
REM hex2bin loderun_6809.ihx
REM * disk basic
aslink -t loderun_6809.rel
REM * create DSK image
del loderun_6809.dsk
copy loderun_6809.bin lr.bin
file2dsk loderun_6809.dsk lr.bin
:end
