asz80 -l -o -s ti ti.asm
aslink -i ti.rel
hex2bin ti.ihx
REM * TRS-80 .CMD file format
bin2cmd -o5210 -x5435 ti
REM * Microbee CP/M .COM file format
copy ti.bin ti.com
REM * Microbee TAP(e) format
bin2tap ti.bin ti.tap --loadaddr:0x900 --startaddr:0x900
