/*****************************************************************************
* 2k 0x8000 ROM for CoCo3
******************************************************************************/
  sprom #(
  	.init_file		("../../../../src/platform/coco3-becker/roms/rs232_c8.hex"),
  	.numwords_a		(2048),
  	.widthad_a		(11)
  ) RAMB16_S9_RC8 (
  	.address			(ADDRESS[10:0]),
  	.clock				(PH_2),
  	.q						(DOA_RC8)
  );
