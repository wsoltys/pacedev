/*****************************************************************************
* 2k 0xC800 DISK ROM for CoCo3
******************************************************************************/
  sprom #(
  	.init_file		("../roms/dsk_C8.hex"),
  	.numwords_a		(2048),
  	.widthad_a		(11)
  ) RAMB16_S9_DC8 (
  	.address			(ADDRESS[10:0]),
  	.clock				(PH_2),
  	.q						(DOA_DC8)
  );
