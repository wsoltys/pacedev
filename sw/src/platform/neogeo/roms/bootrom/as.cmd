set TARGET=bootrom
asw -cpu 68000 -L %TARGET%.lst %TARGET%.asm
p2hex -a -r $f00000-$f00fff -F intel32 %TARGET%.p ..\%TARGET%.hex
