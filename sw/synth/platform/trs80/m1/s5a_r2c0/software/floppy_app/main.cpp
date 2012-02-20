#include <stdio.h>
#include <stdlib.h>

#include <altera_avalon_pio_regs.h>
#include <system.h>

int main (int argc, char *argv[])
{
	printf ("S5AR2_C0 Floppy Emulator v0.1!\n");

  alt_u32 track = IORD_ALTERA_AVALON_PIO_DATA (TRACK_PIO_BASE);
	printf ("track = %ld\n", track);
}
