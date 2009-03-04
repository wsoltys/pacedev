/*****************************************************************************
* 2k 0xB000 ROM for CoCo3
******************************************************************************/
  sprom #(
  	.init_file		("../../../../src/platform/coco3-becker/roms/cc3_B0_nodsk.hex"),
  	.numwords_a		(2048),
  	.widthad_a		(11)
  ) RAMB16_S9_B0 (
  	.address			(ADDRESS[10:0]),
  	.clock				(PH_2),
  	.q						(DOA_B0)
  );
