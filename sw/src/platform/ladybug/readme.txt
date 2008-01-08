unzip the ladybug archive from fpgaarcade.com here
and rename the directory to "fpgaarcade"

unzip the game roms into their respective subdirectories under "roms"
run cygwin
run copy_roms.sh in each subdirectory - copies to "hex"
run the makefile in the "hex" directory
* the cpu rom files aren't the right size/split, create manually
* manually (re)create the char, sprite split .hex files from the .bins
copy the required files to the PACE src platform "roms" directory

*NOTE*
the perl script that creates the dummy decrypt roms is broken under win32
- it adds CR to LF within the file
- PACE sw dev platform ladybug has a program to use instead

last tested with v2.1
