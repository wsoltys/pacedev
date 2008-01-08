/*****************************************************************************
* 2k Character Generator ROM for CoCo3
******************************************************************************/
   // RAMB16_S9: Virtex-II/II-Pro, Spartan-3/3E 2k x 8 + 1 Parity bit Single-Port RAM
   // Xilinx HDL Language Template version 7.1i

	sprom #(
		.init_file		("../../../../src/platform/coco3-becker/roms/coco3gen.hex"),
		.numwords_a		(2048),
		.widthad_a		(11)
	) RAMB16_S9_CG1 (
		.address			(ROM_ADDRESS[10:0]),
		.clock				(PIX_CLK),
		.q						(ROM_DATA1)
	);

   // End of RAMB16_S9_inst instantiation
