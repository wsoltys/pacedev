DE1
===

On the DE1 the cpu (program) roms must be programmed into flash.
The easiest way is to convert the jbugrom<n>.hex files in the 
rom sub-directory to binary and concatenate them into a single .bin file.
Program the flash at address $0000 and that's it!

