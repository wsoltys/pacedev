@echo off
set opt=""
if "%2%" == "debug" set opt="-d"
if "%2%" == "-d" set opt="-d"
if "%1%" == "apple" goto apple
if "%1%" == "apple2" goto apple
if "%1%" == "coco" goto coco
if "%1%" == "coco3" goto coco
if "%1%" == "neogeo" goto neogeo
if "%1%" == "trs80" goto trs80
goto bad_sys

:apple
mess64d apple2e %2 -flop1 LODERUNNER.DSK
goto end

:coco
if "%2%" == "video" set opt=-snapsize 320x192 -aviwrite coco.avi
mess64d coco3 %opt% -flop1 LODERUN_6809.DSK
goto end

:neogeo
echo neogeo not supported yet
goto end

:trs80
trs80gp -m4 -na -ee loderun_z80.cmd
goto end

:bad_sys
echo Unknown system. Choose {apple^|coco^|neogeo^|trs80}
goto end

:end
