@echo off
@if "%1%" == "coco" goto coco
@if "%1%" == "coco3" goto coco
@if "%1%" == "neogeo" goto neogeo
@if "%1%" == "trs80" goto trs80
@goto bad_sys

:coco
cls
@echo on

@if "%2" == "e" goto extract

as6809 -l -o -s lr_gfx.asm
@if ERRORLEVEL 1 goto errcoco
aslink -t lr_gfx.rel

as6809 -l -o -s lr_ldr.asm
@if ERRORLEVEL 1 goto errcoco
aslink -t lr_ldr.rel

as6809 -l -o -s loderun_6809.asm
@if ERRORLEVEL 1 goto errcoco
@REM * cartridge image
@REM aslink -i loderun_6809.rel
@REM hex2bin loderun_6809.ihx
@REM * disk basic
aslink -t loderun_6809.rel

@REM * create DSK image
del loderun_6809.dsk
@REM copy loderun_6809.bin lr.bin
reloc loderun_6809.bin lr.bin
file2dsk loderun_6809.dsk lrm4bpp.bin lr.bin gfxm4bpp.bin gfxc4bpp.bin lr_ldr.bin lr.bas
@REM file2dsk loderun_6809.dsk lr.bin tiles.bin title_rle.bin lr.bas readme.txt
@goto end

:extract
imgtool get coco_jvc_rsdos LODERUN_6809.DSK lr.bas
@goto end

:errcoco
@echo off
echo.
echo *** ERROR building coco ***
goto end

:neogeo
echo.
echo *** neogeo not supported yet ***
goto end

:trs80
cls
@echo on
asz80 -l -o -s loderun_z80.asm
@if ERRORLEVEL 1 goto errtrs80
aslink -i loderun_z80.rel
hex2bin loderun_z80.ihx
@REM * TRS-80 .CMD file format
bin2cmd -o5200 -x5200 loderun_z80
@goto end
:errtrs80
@echo off
echo.
echo *** ERROR building trs80 ***
goto end

:bad_sys
echo.
echo *** Unknown system. Choose {coco^|neogeo^|trs80} ***
goto end

:end
