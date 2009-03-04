/*****************************************************************************
* 2k 0x8000 ROM for CoCo3
******************************************************************************/
  sprom #(
  	.init_file		("../../../../src/platform/coco3-becker/roms/cart_c0.hex"),
  	.numwords_a		(2048),
  	.widthad_a		(11)
  ) RAMB16_S9_C0S2 (
  	.address			(ADDRESS[10:0]),
  	.clock				(PH_2),
  	.q						(DOA_C0_S2)
  );
