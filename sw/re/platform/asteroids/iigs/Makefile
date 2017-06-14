
all:
	ca65 -t apple2 hello.s -o compile/hello.o
	ld65 -o compile/hello.bin compile/hello.o -C donttouch/apple2.cfg
	cp donttouch/cc65.dsk test.dsk
#	java -jar ../ac.jar -dos140 test.dsk
	tokenize_asoft <loader.txt > compile/apple_loader
	dos33 test.dsk SAVE A compile/apple_loader HELLO
	java -jar ../ac.jar -cc65 test.dsk TEST B < compile/hello.bin

clean:
	rm -f compile/hello.o compile/hello.bin test.dsk compile/apple_loader
#test:
#	ca65 -t apple2 hello.s
#	ld65 -o hello.bin hello.o -C ./apple2.cfg
##	mkdos33fs mog.dsk
#	cp cc65.dsk mog.dsk
#	tokenize_asoft <loader.txt > apple_loader
#	dos33 mog.dsk SAVE A apple_loader HELLO
#	dd if=hello.bin of=goodbye.bin bs=1 skip=4
#	dos33 mog.dsk SAVE B goodbye.bin TEST
