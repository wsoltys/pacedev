cls
asz80 -l -o -s loderun_z80.asm
aslink -i loderun_z80.rel
hex2bin loderun_z80.ihx
REM * TRS-80 .CMD file format
bin2cmd -o5200 -x5200 loderun_z80
