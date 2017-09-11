
Readme.txt for matread.exe

Frank Palazzolo
palazzol@tir.com
7/28/97

Matread.exe is a quick and dirty disassembler for the
Atari "Star Wars" and "Empire Strikes Back" Matrix processors.

It's a DOS executable which reads four files
and dumps a disassembly to the standard output.
I've compiled it under DJGPP, but it also
compiles as a win32 command line exec under VC++ 5.0.

If you can't understand the disassembly then I suggest you refer
to the schematics.  The mnemonics are based on them.

Right now the files that are expected are hard-coded to:

starwars.mc0    (136021.110 at 7H, most significant nibble)    
starwars.mc1    (136021.111 at 7J)
starwars.mc2    (136021.112 at 7K)
starwars.mc3    (136021.113 at 7L, least significant nibble)

These images are 1024 x 4 bits (lower nibble is used only)
and come from the 82S137 PROMS on the main board.

It will work on ESB with the appropriate changes to filenames.



