#!/bin/perl

# This script reads a binary input file that is expected to be formatted with
# the header created by the make_header.pl script, along with the data used to
# create the header.

# if an error occurs, we'll just drop thru this sub routine to print any error
# messages along with the script usage.
sub usage
{
  my $err_str = shift @_;
  
  if(defined($err_str))
  {
    printf("\n%s\n", $err_str);
  }

  printf("\
  
USAGE: read_flash_image.pl <in_file>
   in_file = name of input file to process, this should be a binary file.
  
");

exit 1;
}

# this subroutine is used to calculate reflected crc32 sums used in the input
# file
sub rfc2823_crc32_relected
{
  my ( $crcval, $cval ) = (@_);
  my $i;

  $crcval ^= $cval;
  for ($i = 8; $i--; )
  {
    $crcval = ($crcval & 0x00000001) ? (($crcval >> 1) ^ 0xEDB88320) : ($crcval >> 1);
  }

  return $crcval;
}

# Script Begins Here

# get the input argument
my ($in_file) = @ARGV;
defined $in_file or usage("ERROR: Not enough input arguments passed into script.");

# open the input file
my $in_FH;
if(-e $in_file)
{
  open($in_FH, "<$in_file") or usage("ERROR: Cannot open input file $in_file.");
  binmode($in_FH);
}
else
{
  usage("ERROR: Input file does not exist.");
}

# read the header data from the input file
my $header_bytes;
read($in_FH, $header_bytes, 32) or die("\nError reading header from file $in_file.\n\nExiting!!!\n\n");

# print the header data as bytes
printf("\nHeader Bytes\n");
@unpacked_header_bytes = unpack C32, $header_bytes;
my $next_item;
my $i = 0;
foreach $next_item (@unpacked_header_bytes)
{
  printf("%02X ", $next_item);
  $i++;
  if( $i >= 16 )
  {
    $i = 0;
    printf("\n");
  }
}
printf("\n");

# print the header data as words
printf("\nHeader Words\n");
@unpacked_header_words = unpack L8, $header_bytes;
$i = 0;
foreach $next_item (@unpacked_header_words)
{
  printf("%08X ", $next_item);
  $i++;
  if( $i >= 4 )
  {
    $i = 0;
    printf("\n");
  }
}
printf("\n");

# check the header crc, if we crc the whole header, the resultant crc value
# will equal ZERO if the data and crc are correct.
my $header_test = 0xffffffff;
foreach $next_item (@unpacked_header_bytes)
{
  $header_test = rfc2823_crc32_relected($header_test, $next_item);
}

printf("\nHeader CRC Check = 0x%08X\n", $header_test);

if( $header_test == 0 )
{
  printf("Header CRC Validation: PASSED\n");
}
else
{
  printf("Header CRC Validation: FAILED\n");
}

# extract the header fields into a more managable form
my $signature =  $unpacked_header_words[0];
my $version =    $unpacked_header_words[1];
my $timestamp =  $unpacked_header_words[2];
my $length =     $unpacked_header_words[3];
my $data_crc =   $unpacked_header_words[4];
my $res1 =       $unpacked_header_words[5];
my $res2 =       $unpacked_header_words[6];
my $header_crc = $unpacked_header_words[7];

# print the header data
printf("\nHeader Elements:\
 signature = 0x%08X\
   version = 0x%08X\
 timestamp = 0x%08X\
    length = 0x%08X\
  data_crc = 0x%08X\
      res1 = 0x%08X\
      res2 = 0x%08X\
header_crc = 0x%08X\
",
$signature,
$version,
$timestamp,
$length,
$data_crc,
$res1,
$res2,
$header_crc
);

# print the timestamp as the actual time it represents
($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime($timestamp);
printf("\ntimestamp value = 0x%08X - %d_d is %4d/%02d/%02d %02d:%02d:%02d UTC\n", $timestamp, $timestamp, $year + 1900,  $mon + 1, $mday, $hour, $min, $sec);

# calculate the crc for the data section of the input file
my $check_data_crc = 0xffffffff;
my $check_length = 0;
my $in_char;
while(read($in_FH, $in_char, 1))
{
  $in_char = unpack C, $in_char;
  $check_data_crc = rfc2823_crc32_relected( $check_data_crc, $in_char );
  $check_length++;
}

printf("\nCalcuated Data CRC = 0x%08X\n", $check_data_crc);

if( $check_data_crc == $data_crc )
{
  printf("Data CRC Validation: PASSED\n");
}
else
{
  printf("Data CRC Validation: FAILED\n");
}

if( $check_length == $length )
{
  printf("Data length Validation: PASSED\n");
}
else
{
  printf("Data length Validation: FAILED\n");
  printf("Calculated length = %d\nHeader length = %d\n", $check_length, $length);
}

# read the records in the data section of the input file

# first move back to the begining of the data section
seek($in_FH, 32, 0) or die("\nERROR: Could not seek to byte 32 in file.\n\n");

# format of data section records:
#  data record : <32-bit length> <32-bit address> <length bytes of data>
# entry record : <0x00000000> <32-bit entry address>
#  halt record : <0xFFFFFFFF>
#

my $next_data;
my @data_addr;
my @data_len;
do {
  if( read($in_FH, $next_data, 4) != 4 )
  {
    die("\nERROR: Unable to read 4 bytes of anticipated length field.\n")
  }
  else
  {
    @data_len = unpack L, $next_data;
  }

  if( $data_len == 0xFFFFFFFF )
  {
    printf("\nHalt Record Detected -- 0x%08X\n", $data_len[0]);
  }
  else
  {
    if( read($in_FH, $next_data, 4) != 4 )
    {
      die("\nERROR: Unable to 4 bytes of anticipated address field.\n")
    }
    else
    {
      @data_addr = unpack L, $next_data;
    }
    if( $data_len[0] == 0 )
    {
      printf("\nEntry Record Detected -- %d\n",$data_len[0]);
      printf("Entry Record address = 0x%08X\n",$data_addr[0]);
    }
    else
    {
      printf("\nData Record Detected\n");
      printf(" Data Record length = 0x%08X - %d_d\n",$data_len[0], $data_len[0]);
      printf("Data Record address = 0x%08X\n",$data_addr[0]);
      seek($in_FH, $data_len[0], 1) or die("\nERROR: Unable to seek over data length - $data_len[0] bytes\n");
    }
  }
} while(!(eof $in_FH));

printf("\nEnd of Processing!\n\n");

