#include<stdio.h>
#include<stdlib.h>

//#define SWAP32(x) (((x<<24)&0xFF000000)|((x<<16)&0xFF0000)|((x>>16)&0xFF00)|((x>>24)&0xFF))
#define SWAP32(x) (((x<<16)&0xFFFF0000)|((x>>16)&0xFFFF))
//#define SWAP32(x) (((x<<8)&0xFF00FF00)|((x>>8)&0x00FF00FF))
#define SWAP16(x) (((x<<8)&0xFF00)|((x>>8)&0xFF))

int main( int argc, char *argv[ ]) 
{
	FILE *infile, *outfile;
	char prefix[4];
	char fileFormat[8];
	unsigned char ch;
	float byteValue;
	unsigned int i;
	char ckID[4];
	unsigned long nChunkSize;
	short int wFormatTag;
	short int nChannels;
	unsigned long nSamplesPerSecond;
	unsigned long nAvgBytesPerSecond;
	short int nBlockAlign;
	short int nBitsPerSample;
	
	/* Print a copyright. */
	fprintf(stderr, "WAV to Raw ASCII file Conversion Utility\n");
	fprintf(stderr, " Copyright: Dan Kennedy. All are free to use this.\n\n");
	
	/* Test for two files as arguments */
	if (argc != 3) {
	  fprintf(stderr, "Usage: wav2raw sourceWavFile destRawFile\n");
	  fprintf(stderr, "Success returns errorlevel 0. Error return greater than zero.\n");
	  exit(1);
	}
	
	/* Open source for binary read (will fail if file does not exist) */
	if( (infile = fopen( argv[1], "rb" )) == NULL ) {
	  fprintf(stderr, "The source file %s was not opened\n",argv[1] );
	  exit(2);
	}
	else 
	  fprintf(stderr,  "The source file %s was opened\n",argv[1] );
	
	/* Open output for write */
	if( (outfile = fopen( argv[2], "w" )) == NULL ) {
	  fprintf(stderr, "The output file %s was not opened\n",argv[2] );
	  exit(3);
	}
	else
	  fprintf(stderr, "The output file %s was opened\n",argv[2] );
	
	/* Read the header bytes. */
	fscanf( infile, "%4c", prefix );
	fscanf( infile, "%4c", &nChunkSize );
	fprintf (stderr, "nChunkSize = %d\n", nChunkSize);
	fscanf( infile, "%8c", fileFormat );
	fprintf (stderr, "Format = %4.4s\n", fileFormat);
	fprintf (stderr, "Subchunk1ID = %4.4s\n", fileFormat+4);
	fscanf( infile, "%4c", &nChunkSize );
	fprintf (stderr, "nChunkSize = %d\n", nChunkSize);
	fscanf( infile, "%2c", &wFormatTag );
	fscanf( infile, "%2c", &nChannels );
	fscanf( infile, "%4c", &nSamplesPerSecond );
	fscanf( infile, "%4c", &nAvgBytesPerSecond );
	fscanf( infile, "%2c", &nBlockAlign );
	fscanf( infile, "%2c", &nBitsPerSample );
	fseek ( infile, 0x3E, SEEK_SET);
	fscanf( infile, "%4c", ckID );
	fscanf( infile, "%4c", &nChunkSize );
	
	/* Testing on the file format variables would go here. */
	//nChannels = SWAP16(nChannels);
	fprintf (stderr, "nChannels = %d\n", nChannels);
	fprintf (stderr, "nSamplesPerSecond = %d\n", nSamplesPerSecond);
	fprintf (stderr, "nBitsPerSample = %d\n", nBitsPerSample);
	fprintf (stderr, "ckID = %4.4s\n", ckID);
	fprintf (stderr, "nChunkSize = %d\n", nChunkSize);
	exit (0);

	/* Scan and convert the bytes. */
	for( i = 0; (i < nChunkSize);i++ ) {
	  fscanf( infile, "%1c", &ch );
	  //byteValue = ((float)ch-128)/128;
	  //fprintf(outfile,"%g\n",byteValue);
		printf ("0x%02x, ", ch);
		if ((nChunkSize % 16) == 15)
			printf ("\n");
	}
	
	/* All files are closed: */
	_fcloseall( );
	
	exit(0);
}
