/*****************************************************************************
* 2k Character Generator ROM for APPLE 2E Initialized with GLB Apple set
******************************************************************************/
  sprom #(
  	.init_file		("../../../../src/platform/appleii-becker/roms/chargen.hex"),
  	.numwords_a		(2048),
  	.widthad_a		(11)
  ) RAMB16_S9_CG (
  	.address			(VROM_ADDRESS),
  	.clock				(CLK[0]),
  	.q						(VRAM_DATA0)
  );
