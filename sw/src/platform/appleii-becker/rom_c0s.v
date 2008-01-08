/*****************************************************************************
* 2k C1 Slot ROM for APPLE 2E Initialized ALL 0XFF
******************************************************************************/
  sprom #(
  	.init_file		("../../../../src/platform/appleii-becker/roms/c0s.hex"),
  	.numwords_a		(2048),
  	.widthad_a		(11)
  ) RAMB16_S9_C0S (
  	.address			(ADDRESS[10:0]),
  	.clock				(PH_2),
  	.q						(DOA_C0S)
  );
