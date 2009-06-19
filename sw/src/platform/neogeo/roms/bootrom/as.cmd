set TARGET=bootrom
asw -cpu 68000 -L %TARGET%.lst %TARGET%.asm
p2hex -a -r $ff0000-$ff0fff -F intel32 %TARGET%.p %TARGET%.hex
c:\bin\hex2bin %TARGET%.hex
bin2hex16 -s %TARGET%.bin >%TARGET%.hex
copy /y %TARGET%.hex ..
