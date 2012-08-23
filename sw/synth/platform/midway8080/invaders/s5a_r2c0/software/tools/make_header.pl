#!/bin/perl

# this subroutine will be called if there are any issues detected with the input
# parameters for  the script.
sub usage
{
  # this subroutine can accept an error string as input
  my $err_str = shift @_;
  
  # if we get an error string passed in, then print it
  if(defined($err_str))
  {
    printf("\n%s\n", $err_str);
  }

  # print the usage requirements for this script
  printf("\

USAGE: make_header.pl <in_file> <out_file> <signature> <version> <res1> <res2>
   in_file = name of input file to process
  out_file = name of header file to output
  signature = 32-bit signature value, placed in the header signature location
    version = 32-bit version value, placed in the header version location
       res1 = 32-bit value, placed in the header res1 location
       res2 = 32-bit value, placed in the header res2 location
  
");

  # exit with a non-zero value indicating an error occurred during processing
  exit 1;
}

# this subroutine calculates a reflected crc32 and adds it to the crc value
# input operand and returns the new crc value.
sub rfc2823_crc32_relected
{
  # get the input operands, assume they are proper
  my ( $crcval, $cval ) = (@_);
  my $i;

  # perform the reflected crc32 algorithm
  $crcval ^= $cval;
  for ($i = 8; $i--; )
  {
    $crcval = ($crcval & 0x00000001) ? (( $crcval >> 1 ) ^ 0xEDB88320 ) : ($crcval >> 1);
  }

  # return the new crc value
  return $crcval;
}

# Script Begins Here

# get the script input operands
my ($in_file, $out_file, $signature, $version, $res1, $res2) = @ARGV;

# convert the numeric input values to decimal numbers
$signature = oct $signature if $signature =~ /^0/;
$version = oct $version if $version =~ /^0/;
$res1 = oct $res1 if $res1 =~ /^0/;
$res2 = oct $res2 if $res2 =~ /^0/;

# test for the right number of operands
defined $res2 or usage("ERROR: Not enough input arguments passed into script.");

# make sure the input file exists
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

# open the output file
my $out_FH;
open($out_FH, ">$out_file") or usage("ERROR: Cannot open output file $out_file.");
binmode($out_FH);

# we need to skip the header bytes allocated in the input file.
seek($in_FH, 32, 0);

# read the input file and compute the crc32 and data length
my $in_char;
my $length = 0;
my $data_crc = 0xffffffff;
while(read($in_FH, $in_char, 1))
{
  $in_char = unpack C, $in_char;
  $data_crc = rfc2823_crc32_relected($data_crc, $in_char);
  $length++;
}

# get the current time value for a timestamp = seconds since 01/01/1970 UTC
my $timestamp = time;

# calculate the header crc32
my $bin_header = pack L7, ($signature, $version, $timestamp, $length, $data_crc, $res1, $res2);
my @unpacked = unpack C28, $bin_header;
my $header_crc = 0xffffffff;
foreach $next_item (@unpacked)
{
  $header_crc = rfc2823_crc32_relected($header_crc, $next_item);
}

# pack the entire header together
$bin_header = pack L8, ($signature, $version, $timestamp, $length, $data_crc, $res1, $res2, $header_crc);

# write the header out to the output file
print { $out_FH } $bin_header;

# now write the rest of the data to the output file
# we need to skip the header bytes allocated in the input file.
seek($in_FH, 32, 0);
while(read($in_FH, $in_char, 1))
{
  print { $out_FH } $in_char;
}

# return with value 0, indicating no errors
exit 0;

