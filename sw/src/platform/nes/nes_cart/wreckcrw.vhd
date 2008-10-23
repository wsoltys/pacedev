library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.nes_cart_pkg.all;

architecture WRECKCRW of nes_cart is

begin

	prg_rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/nes/carts/wreckcrw_prg.hex",
			numwords_a	=> 32768,
			widthad_a		=> 15
		)
		port map
		(
			clock			=> clk,
			address		=> prg_a(14 downto 0),
			q					=> prg_d_o
		);
	
	chr_rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/nes/carts/wreckcrw_chr.hex",
			numwords_a	=> 8192,
			widthad_a		=> 13
		)
		port map
		(
			clock			=> clk,
			address		=> chr_a(12 downto 0),
			q					=> chr_d_o
		);

	prg_d_oe <= '1';
	chr_d_oe <= '1';
	vram_ce_n <= '0';
	irq_oe <= '0';
	
end WRECKCRW;
