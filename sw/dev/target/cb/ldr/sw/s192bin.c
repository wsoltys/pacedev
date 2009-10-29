#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

static int ahtoi( char *buffer, int n );
static void usage( void );

int main( int argc, char *argv[] )
{
    FILE    *fp, *fpBin;
    char    buffer[256];
    char    fname[64];
    int     addr;

    if( --argc != 1 )
        usage();

    strcpy( fname, argv[1] );
    if( !strchr( fname, '.' ) )
        strcat( fname, ".S19" );

    // construct binary filename
    strcpy( buffer, fname );
    *strchr( buffer, '.' ) = '\0';
    strcat( buffer, ".bin" ); 

    fp = fopen( fname, "rt" );
    if( !fp )
    {
        printf( "error: unable to open %s for input!\n", fname );
        exit( 0 );
    }

    fpBin = fopen( buffer, "wb" );

    addr = 0x0000;
    fgets( buffer, 256, fp );
    while( !feof( fp ) )
    {
        if( buffer[0] == 'S' )
        {
            static unsigned char    zero = 0;

            char            *p = &buffer[2];
            unsigned char   byte;
            int             a, n;

            switch( buffer[1] )
            {
                case '1' :
                    
                    // extract number of bytes
                    n = ahtoi( p, 2 );
                    p += 2;

                    // extract address
                    a = ahtoi( p, 4 );
                    p += 4;

                    // pad binary with zeroes
                    for( ; addr<a; addr++ )
                        fwrite( &zero, 1, 1, fpBin );
  
                    // write bytes to file
                    a += ( n - 3 );
                    for( ; addr<a; addr++, p+=2 )
                    {
                        byte = (unsigned char)ahtoi( p, 2 );
                        fwrite( &byte, 1, 1, fpBin );
                    }
                    break;

                case '9' :
                    break;
            }
        }
        
        fgets( buffer, 256, fp );
    }

    fclose( fp );
    fclose( fpBin );

    return( 0 );
}

int ahtoi( char *buffer, int n )
{
    int i;
    int val = 0;

    for( i=0; i<n; i++, buffer++ )
    {
        val <<= 4;
        if( isdigit( *buffer ) )
            val += *buffer - '0';
        else
            val += toupper( *buffer ) - 'A' + 10;
    }

    return( val );
}

void usage( void )
{
    printf( "usage: s192bin <file>[.S19]\n" );
    exit( 0 );
}

