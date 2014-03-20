asz80 -l -o -s ti ti.asm
aslink -i ti.rel
hex2bin ti.ihx
bin2cmd -o4310 -x4535 ti

