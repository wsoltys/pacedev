/***************************************************************************
* MBDISS.C
*
* Atari mathbox disassembler.
*
* Copyright (c) Zonn Moore, 1996  All rights reserved.
***************************************************************************/
#include <stdio.h>
#include <stdlib.h>

#define  SUBR     1        // Subtract R from S instruction
#define  NOTRS    5        // Not R and S instruction

#define  r_ZERO   16
#define  r_DATA   17
#define  r_QREG   18

#define  LDAB     0x08
#define  STOP     0x08

#define  Sb       0x08
#define  Jb       0x04
#define  Mb       0x02
#define  Cb       0x01

int cnvReg( int reg, int index);

/* source indexis */

int   RopVal[8] =
{  1, 1, 0, 0, 0, 3, 3, 3};

int   SopVal[8] =
{  4, 2, 4, 2, 1, 1, 4, 0};

/* mnemonic names */

char  *SourceName[5] =
{  "0", "A", "B", "D", "Q"};

char  *RegName[19] =
{  "r00", "r01", "r02", "r03", "r04", "r05", "r06", "r07",
   "r08", "r09", "r10", "r11", "r12", "r13", "r14", "r15",
   "#00", "Dre", "Qre"
};

char  *FuncName[8][2] =
{  "add", "adc",
   "sbc", "sub",     // SUBR
   "sbc", "sub",     // SUBS
   "ior", "ior",
   "and", "and",
   "and", "and",     // NOTRS
   "xor", "xor",
   "xnr", "xnr"
};

#if 0
char  *DestName[8] =
{  "qreg",
   "nop",
   "rama",
   "ramf",
   "ramqd",
   "ramd",
   "ramqu",
   "ramu"
};
#endif

unsigned char  Prom[6][256];

void main( void)
{
   FILE  *inFile;
   int   ii, mm, pp, tt;
   int   ropH, ropL, sopL, sopH, func, dest;
   int   regH1, regH2, regL1, regL2, notf, jmpf, A10inv;

   // print header

   fputs( "              132              131              130              129
128              127\n\n", stdout);

   fputs( "    A   A   A   A    A   A   A   A    A   A   A   A    A   A   A   A
A   A   A   A\n", stdout);
   fputs( "    0   1   2   3    4   5   6   7    8   9  10  11   12  13  14  15
16  17  18  19    S   J   M   C\n\n", stdout);

   fputs( "   D3  D2  D1  D0   D3  D2  D1  D0   D3  D2  D1  D0   D3  D2  D1  D0
D3  D2  D1  D0   D3  D2  D1  D0\n\n", stdout);

   fputs( "    1   2   3   4   20  19  18  17   14H 14L 13* 12   ST  27  28  26
LD   6   7   5    S   J   M  29\n\n", stdout);

   fputs( "   A3  A2  A1  A0   B3  B2  B1  B0   I2  I2  I1  I0       I5  I4  I3
I8  I7  I6               Cn\n\n", stdout);

   fputs( "Miscellaneous notes:\n", stdout);
   fputs( " C = Cin to Acc\n\n", stdout);

   fputs( " if ST high, STOP\n\n", stdout);

   fputs( " if LD high, Load latch with AB (A0-A7)\n\n", stdout);

   fputs( " if J low, never JMP\n", stdout);
   fputs( " if J high and S low, JMP to latched value\n", stdout);
   fputs( " if J high and S high, JMP if (pos and no OVF) or (neg and OVF)\n\n",
stdout);

   fputs( " if M low,                                            A10= A10\n",
stdout);
   fputs( " if M high and prev A18 high,                         A10=~A10\n",
stdout);
   fputs( " if M high and prev A18 low and prev RRQ shift out 0, A10=~A10\n",
stdout);
   fputs( " if M high and prev A18 low and prev RRQ shift out 1, A10= A10\n\n",
stdout);

   fputs( " if A18 high,
R15=1\n", stdout);
   fputs( " if S low and A18 low,
R15=0\n", stdout);
   fputs( " if S high and A18 low and (pos and no OVF) or (neg and OVF),
R15=0\n", stdout);
   fputs( " if S high and A18 low and (pos and OVF) or (neg and no OVF),
R15=1\n\n", stdout);

   fputs( " Note that R0 of LSB goes to Q3 of MSB, making all RRQs an extension
of the ALU.\n\n", stdout);

   fputs( " In lines that display two opcodes with no asterisk preceeding\n",
stdout);
   fputs( " the first opcode, the two opcodes are both executed
simultaneously.\n\n", stdout);

   fputs( " The lines proceeded by an asterisk indicates instructions
modified\n", stdout);
   fputs( " by the S flag.  The instructions marked with a '*' are executed if
the\n", stdout);
   fputs( " shift of the prvious instruction shifts out a 0.  Otherwise the
alternative\n", stdout);
   fputs( " instruction is executed.\n\n", stdout);

   fputs( "Jump table:\n", stdout);
   fputs( " 00: 20 21 22 23  24 25 26 27  28 29 2A 41  2C 34 35 36\n", stdout);
   fputs( " 10: 37 42 7E B8  BD 2E 2F 17  19 18 30 31  D9 EB F4 00\n\n",
stdout);

   fputs( "Microcode:", stdout);

   // Read in PROMS

   inFile = fopen( "136002.132", "rb");

   if (inFile == 0)
   {  perror( "136002.132");
      exit( 0);
   }

   fread( Prom[0], 1, 256, inFile);    // read buffer
   fclose( inFile);                    // close file

   inFile = fopen( "136002.131", "rb");

   if (inFile == 0)
   {  perror( "136002.131");
      exit( 0);
   }

   fread( Prom[1], 1, 256, inFile);    // read buffer
   fclose( inFile);              // close file


   inFile = fopen( "136002.130", "rb");

   if (inFile == 0)
   {  perror( "136002.130");
      exit( 0);
   }

   fread( Prom[2], 1, 256, inFile);    // read buffer
   fclose( inFile);              // close file


   inFile = fopen( "136002.129", "rb");

   if (inFile == 0)
   {  perror( "136002.129");
      exit( 0);
   }

   fread( Prom[3], 1, 256, inFile);    // read buffer
   fclose( inFile);              // close file


   inFile = fopen( "136002.128", "rb");

   if (inFile == 0)
   {  perror( "136002.128");
      exit( 0);
   }

   fread( Prom[4], 1, 256, inFile);    // read buffer
   fclose( inFile);              // close file


   inFile = fopen( "136002.127", "rb");

   if (inFile == 0)
   {  perror( "136002.127");
      exit( 0);
   }

   fread( Prom[5], 1, 256, inFile);    // read buffer
   fclose( inFile);              // close file

   // display PROMS

   for (ii = 0; ii < 256; ii++)
   {
      printf( "\n %02X: ", ii);  // print address

      /* Print microcode */

      for (pp = 0; pp < 6; pp++)
      {
         for (mm = 0x08; mm != 0; mm >>= 1)
            printf( "%c", (Prom[pp][ii] & mm) ? '1' : '0');

         putchar( ' ');

      }

      /* Point to mnemonics */

      if (!(Prom[5][ii] & Mb))
         A10inv = 0x00;       // src doesn't change

      else
         A10inv = 0x02;       // src based on OV and Sign

      ropL = RopVal[Prom[2][ii] & 0x07];
      ropH = RopVal[(Prom[2][ii] & 0x03) | ((Prom[2][ii] & 0x08) >> 1) ^
A10inv];

      sopL = SopVal[Prom[2][ii] & 0x07];
      sopH = SopVal[(Prom[2][ii] & 0x03) | ((Prom[2][ii] & 0x08) >> 1) ^
A10inv];

      func = Prom[3][ii] & 0x07;
      dest = Prom[4][ii] & 0x07;

      notf = (func == NOTRS);

      /* check if sources reversed */

      if (func == SUBR)
      {  regH1 = sopH;
         regH2 = ropH;

         regL1 = sopL;
         regL2 = ropL;
      }

      else
      {  regH1 = ropH;
         regH2 = sopH;

         regL1 = ropL;
         regL2 = sopL;
      }

      /* convert to values */

      regH1 = cnvReg( regH1, ii);
      regH2 = cnvReg( regH2, ii);
      regL1 = cnvReg( regL1, ii);
      regL2 = cnvReg( regL2, ii);

      /* Print mnemonics */

      if (A10inv)
         fputc( '*', stdout);

      else
         fputc( ' ', stdout);

      fprintf( stdout, "%s(%c%s, %s)",
         FuncName[func][Prom[5][ii] & Cb], (notf) ? '~' : ' ', RegName[regH1],
RegName[regH2]);

      if ((((Prom[2][ii] >> 1) ^ Prom[2][ii]) & 0x04) && A10inv)
      {  fprintf( stdout, "\nError: Different sources from A14 and A10.\n");
         exit( 0);
      }

      /* Check if High and Low sources differ, if so, print low */

      if ((((Prom[2][ii] >> 1) ^ Prom[2][ii]) & 0x04) || A10inv)
         fprintf( stdout, " %s( %s, %s)",
               FuncName[func][Prom[5][ii] & Cb], RegName[regL1],
RegName[regL2]);

      else
         fputs( "               ", stdout);

      /* print destination */

      fputc( ' ', stdout);

      switch (dest)
      {
      case 0:                                      // QREG
         fprintf( stdout, "        Qre=ALU OUT=ALU");
         break;

      case 1:                                      // NOP
         fprintf( stdout, "                OUT=ALU");
         break;

      case 2:                                      // RAMA
         fprintf( stdout, "%3s=ALU         OUT=%3s",
               RegName[cnvReg( 2, ii)], RegName[cnvReg( 1, ii)]);

         break;

      case 3:                                      // RAMF
         fprintf( stdout, "%3s=ALU         OUT=ALU", RegName[cnvReg( 2, ii)]);
         break;

      case 4:                                      // RAMQD

         /* normal shift with zero */

         if (!(Prom[5][ii] & Sb))
            fprintf( stdout, "%3s=SRA Qre=RRQ OUT=ALU", RegName[cnvReg( 2,
ii)]);


         /* modified shift with overflow */

         else
            fprintf( stdout, "%3s=OSR Qre=RRQ OUT=ALU", RegName[cnvReg( 2,
ii)]);

         break;

      case 5:                                      // RAMD

         /* normal shift with zero */

         if (!(Prom[5][ii] & Sb))
            fprintf( stdout, "%3s=SRA         OUT=ALU", RegName[cnvReg( 2,
ii)]);

         /* modified shift with overflow */

         else
            fprintf( stdout, "%3s=OSR         OUT=ALU", RegName[cnvReg( 2,
ii)]);

         break;

      case 6:                                      // RAMQU
         fprintf( stdout, "%3s=RLA Qre=SLQ OUT=ALU", RegName[cnvReg( 2, ii)]);
         break;

      case 7:                                      // RAMU
         fprintf( stdout, "%3s=RLA         OUT=ALU", RegName[cnvReg( 2, ii)]);
         break;
      }

      fputc( ' ', stdout);

      /* Print PC control information */

      jmpf = 0;

      /* check for jumps */

      if (Prom[5][ii] & Jb)      // if J high, check for jumps
      {
         if (Prom[5][ii] & Sb)   // is S high, JNO
            fputs( "JNO ", stdout);

         else                    // if S low, always jmp
         {  fputs( "JMP ", stdout);
            jmpf = 1;
         }
      }
      else
         fputs( "    ", stdout);

      /* check if latch loaded */

      if (Prom[4][ii] & LDAB)
         fprintf( stdout, "L%1X%1X ", Prom[0][ii], Prom[1][ii]);

      else
         fputs( "    ", stdout);
      
      /* check for STOP instruction */

      if (Prom[3][ii] & STOP)
      {  fputs( "HLT", stdout);
         jmpf = 1;
      }
/*    else */
/*       fputs( "   ", stdout); */

      if (jmpf)
         putchar( '\n');
   }
}

int cnvReg( int reg, int index)
{
   int   newReg;

   switch (reg)
   {
   case 0:
      newReg = r_ZERO;           // abs zero
      break;

   case 1:
      newReg = Prom[0][index];   // 0-15 = register numbers
      break;

   case 2:
      newReg = Prom[1][index];   // 0-15 = register numbers
      break;

   case 3:
      newReg = r_DATA;           // data port
      break;

   case 4:
      newReg = r_QREG;           // Q register
      break;
   }
   return (newReg);
}

