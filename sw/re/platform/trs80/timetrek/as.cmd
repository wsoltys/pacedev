asz80 -l -o -s timetrek timetrek.asm
aslink -i timetrek.rel
hex2bin timetrek.ihx
REM * TRS-80 .CMD file format
bin2cmd -o5210 -x5435 timetrek
REM * Microbee CP/M .COM file format
copy timetrek.bin timetrek.com
REM * Microbee .BEE file format
copy timetrek.bin timetrek.bee
REM * Microbee TAP(e) format
bin2tap timetrek.bin timetrek.tap --loadaddr:0x900 --startaddr:0x900
