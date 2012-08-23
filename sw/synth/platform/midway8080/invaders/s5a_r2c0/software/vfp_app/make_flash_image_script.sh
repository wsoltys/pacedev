#!/bin/sh

# This script will take the <nios_application>.elf file created by the Nios II
# IDE and process it into a binary image that can be programmed into flash.
# This script adds a header to the applciation image that contains a number of
# useful elements that an intelligent boot loader is intened to interpret before
# it loads the image into execution memory.  The elements that make up the
# attached header are as follows:
#
#   signature = 32-bit word, user assigned, intended to hold a signature used
#               to locate the header in flash memory
#     version = 32-bit word, user assigned, inteneded to hold a binary encoded
#               version identifier for the application
#   timestamp = 32-bit word, script generated, assigns the current time value,
#               the standard C time integer value, seconds since JAN 01, 1970
# data length = 32-bit word, script generated, assigns the byte length of the
#               application data contained in the file
#    data crc = 32-bit word, script generated, assigns the crc32 calculated
#               across the entire application data
#        res1 = 32-bit word, user assigned, use is unspecified
#        res2 = 32-bit word, user assigned, use is unspecified
#  header crc = 32-bit word, script generated, assigns the crc32 calculated
#               across the other 28-bytes of the header data
#
# The current usage for the script is as follows:
#
#   ./make_flash_image_script <application_name.elf>
#     <application_name.elf> = elf file containing the Nios II application
#
              # These indented sections are just going to contain error checking
              # and other script overhead stuff, but don't really have anything
              # to do with the meat of the processing that needs to be done.
              #
              # Before we get started, we'll simply check the input arguments to
              # make sure everything seems in order.
              #
              
              # Check the number of arguments passed into the script
              #
              if [ $# -ne 1 ] ; then
                echo ""
                echo "ERROR: There must be only one argument input to this script."
                echo ""
                echo "USAGE: ./make_flash_image_script <application_name.elf>"
                echo "       <application_name.elf> = elf file containing the Nios II application"
                echo ""
                exit 1;
              fi

              # Check that the input file actually exists before we proceed
              #
              if [ ! -e $1 ] ; then
                echo ""
                echo "ERROR: The file $1 doesn't seem to exist."
                echo ""
                echo "USAGE: ./make_flash_image_script <application_name.elf>"
                echo "       <application_name.elf> = elf file containing the Nios II application"
                echo ""
                exit 1;
              fi
        
# These variables are created to hold the user supplied data required by this
# script.  You could modify this script to pass these values in as arguments
# instead of having to modify these variables each time you change version
# numbers.
#
signature=0xA5A5A5A5;
version=0x01010101;
res1=0x00000000;
res2=0x00000000;

# Like the variables above, these values are required by the script. These
# values are more associated with the hardware project assigned values and are
# unlikely to change from application build to build.  You could modify this 
# script to pass these values in as arguments.
#
flash_base=0x01000000;
flash_end=0x01FFFFFF;

# These are variables for all of the temporary file names used in this script.
# They should all be deleted by the script when it completes.
#
infile="$1";
fake_copier="fake_flash_copier.srec";
tmp0_outfile_elf="$1.tmp.elf";
tmp1_outfile_srec="$1.tmp.srec";
tmp2_outfile_bin="$1.tmp.bin";
final_bin="$1.flash.bin";
final_srec="$1.flash.srec";
flash_file="$1.flash.bin.flash";
hex_file="$1.flash.bin.flash.hex";


# The first order of business is to make a working copy of the input ELF file.
# So the original ELF input file should be unmodified by this process.
#
cp $infile $tmp0_outfile_elf ;

                # check for errors
                #
                if [ $? -ne 0 ] ; then
                  echo ""
                  echo "ERROR: trying to make a copy of file $infile to file $tmp0_outfile_elf"
                  echo ""
                  echo "Deleting file $tmp0_outfile_elf and exiting!"
                  echo ""
                  rm -f $tmp0_outfile_elf;
                  exit 1;
                fi

# We take our copy of the elf file, and we remove the ".entry" section.  This
# section is where the reset code is typically linked, and since this
# application is really not responsible for handling reset activity, we'll
# remove it so we don't accidentally overwrite the intended reset code.
#
nios2-elf-strip --remove-section=.entry $tmp0_outfile_elf ;

                # check for errors
                #
                if [ $? -ne 0 ] ; then
                  echo ""
                  echo "ERROR: trying to strip entry section from elf file $tmp0_outfile_elf"
                  echo ""
                  echo "Deleting file $tmp0_outfile_elf and exiting!"
                  echo ""
                  rm -f $tmp0_outfile_elf;
                  exit 1;
                fi

# Now we create a fake srecord file to imitate a boot copier, so that we can run
# the elf2flash utility to process the application elf.  elf2flash requires a
# boot copier image to be passed into it, so we create something that we
# understand, so we can take it off later.
#
cat <<EOF > $fake_copier
S0030000FC
S113000000000000000000000000000000000000EC
S113001000000000000000000000000000000000DC
S9030000FC
EOF

                # check for errors
                #
                if [ $? -ne 0 ] ; then
                  echo ""
                  echo "ERROR: trying to create fake srecord file $fake_copier"
                  echo ""
                  echo "Deleting file $fake_copier, and $tmp0_outfile_elf and exiting!"
                  echo ""
                  rm -f $fake_copier;
                  rm -f $tmp0_outfile_elf;
                  exit 1;
                fi

# Convert the fake srecord file to a DOS formated text file.  I've had problems
# with elf2flash when this srecord file doesn't have DOS line terminations.
#
conv -D $fake_copier ;

                # check for errors
                #
                if [ $? -ne 0 ] ; then
                  echo ""
                  echo "ERROR: trying to convert the file $fake_copier to DOS format."
                  echo ""
                  echo "Deleting file $fake_copier, and $tmp0_outfile_elf and exiting!"
                  echo ""
                  rm -f $fake_copier;
                  rm -f $tmp0_outfile_elf;
                  exit 1;
                fi

# Run the elf2flash utility with our fake boot copier, and the ELF file that we
# ripped the entry section out of.  The other options for this command are
# obtained from the variables declared at the top of this script.
#
elf2flash --base=$flash_base --end=$flash_end --boot=$fake_copier --input=$tmp0_outfile_elf --output=$tmp1_outfile_srec --reset=$flash_base ;

                # check for errors
                #
                if [ $? -ne 0 ] ; then
                  echo ""
                  echo "ERROR: while running elf2flash."
                  echo ""
                  echo "Deleting file $tmp1_outfile_srec, $fake_copier, and $tmp0_outfile_elf and exiting!"
                  echo ""
                  rm -f $tmp1_outfile_srec;
                  rm -f $fake_copier;
                  rm -f $tmp0_outfile_elf;
                  exit 1;
                fi

# Convert the resultant srec file to a binary file so we can work with it a bit
# easier.
#
nios2-elf-objcopy -I srec -O binary $tmp1_outfile_srec $tmp2_outfile_bin ;

                # check for errors
                #
                if [ $? -ne 0 ] ; then
                  echo ""
                  echo "ERROR: converting srec file $tmp1_outfile_srec to binary."
                  echo ""
                  echo "Deleting file $tmp2_outfile_bin, $tmp1_outfile_srec, $fake_copier, and $tmp0_outfile_elf and exiting!"
                  echo ""
                  rm -f $tmp2_outfile_bin;
                  rm -f $tmp1_outfile_srec;
                  rm -f $fake_copier;
                  rm -f $tmp0_outfile_elf;
                  exit 1;
                fi

# Run the binary file thru the "make_header.pl" perl script.  This script
# computes and constructs the header, then writes a binary output file
# containing this header followed by the data from the binary input file.
#
./make_header.pl $tmp2_outfile_bin $final_bin $signature $version $res1 $res2 ;

                # check for errors
                #
                if [ $? -ne 0 ] ; then
                  echo ""
                  echo "ERROR: Running perl script, make_header.pl."
                  echo ""
                  echo "Deleting file $final_bin, $tmp2_outfile_bin, $tmp1_outfile_srec, $fake_copier, and $tmp0_outfile_elf and exiting!"
                  echo ""
                  rm -f $final_bin;
                  rm -f $tmp2_outfile_bin;
                  rm -f $tmp1_outfile_srec;
                  rm -f $fake_copier;
                  rm -f $tmp0_outfile_elf;
                  exit 1;
                fi

# Make an srec version of the binary flash file.  This will just be a zero based
# srecord file.
#
nios2-elf-objcopy -I binary -O srec $final_bin $final_srec ;

                # check for errors
                #
                if [ $? -ne 0 ] ; then
                  echo ""
                  echo "ERROR: Converting binary file $final_bin to srec."
                  echo ""
                  echo "Deleting file $final_srec, $final_bin, $tmp2_outfile_bin, $tmp1_outfile_srec, $fake_copier, and $tmp0_outfile_elf and exiting!"
                  echo ""
                  rm -f $final_srec;
                  rm -f $final_bin;
                  rm -f $tmp2_outfile_bin;
                  rm -f $tmp1_outfile_srec;
                  rm -f $fake_copier;
                  rm -f $tmp0_outfile_elf;
                  exit 1;
                fi

# Clean up all the temporary files that we created.
#
rm -f $fake_copier;
rm -f $tmp0_outfile_elf;
rm -f $tmp1_outfile_srec;
rm -f $tmp2_outfile_bin;

# create a flash file
bin2flash --input=$final_bin --output=$flash_file --location=0x400000

# create a hex file
nios2-elf-objcopy --input-target srec --output-target ihex $flash_file $hex_file

echo ""
echo "Script completed successfully."
echo ""
