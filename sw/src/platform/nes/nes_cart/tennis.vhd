library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.STD_MATCH;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.nes_cart_pkg.all;
use work.target_pkg.all;

architecture TENNIS of nes_cart is

	component xilinx_tennis_prg_ntsc is
		port
		(
			clk		: in std_logic;
			addr	: in std_logic_vector(13 downto 0);
			dout	: out std_logic_vector(7 downto 0)
		);
	end component xilinx_tennis_prg_ntsc;

	component xilinx_tennis_chr is
		port
		(
			clk		: in std_logic;
			addr	: in std_logic_vector(12 downto 0);
			dout	: out std_logic_vector(7 downto 0)
		);
	end component xilinx_tennis_chr;

begin

	GEN_ALTERA : if PACE_FPGA_VENDOR = PACE_FPGA_VENDOR_ALTERA generate

		GEN_NTSC_PRG : if NTSC generate
			prg_rom_inst : entity work.sprom
				generic map
				(
					init_file		=> "../../../../src/platform/nes/carts/tennis_prg_ntsc.hex",
					numwords_a	=> 16384,
					widthad_a		=> 14
				)
				port map
				(
					clock			=> clk,
					address		=> prg_a(13 downto 0),
					q					=> prg_d_o
				);
		end generate GEN_NTSC_PRG;
		
		GEN_PAL_PRG : if not NTSC generate
			prg_rom_inst : entity work.sprom
				generic map
				(
					init_file		=> "../../../../src/platform/nes/carts/tennis_prg_pal.hex",
					numwords_a	=> 16384,
					widthad_a		=> 14
				)
				port map
				(
					clock			=> clk,
					address		=> prg_a(13 downto 0),
					q					=> prg_d_o
				);
		end generate GEN_PAL_PRG;
		
		chr_rom_inst : entity work.sprom
			generic map
			(
				init_file		=> "../../../../src/platform/nes/carts/tennis_chr.hex",
				numwords_a	=> 8192,
				widthad_a		=> 13
			)
			port map
			(
				clock			=> clk,
				address		=> chr_a(12 downto 0),
				q					=> chr_d_o
			);

	end generate GEN_ALTERA;

	GEN_XILINX_SPARTAN3 : if PACE_FPGA_FAMILY	= PACE_FPGA_FAMILY_SPARTAN3 generate

		prg_rom_inst : xilinx_tennis_prg_ntsc
			port map
			(
				clk		=> clk,
				addr	=> prg_a(13 downto 0),
				dout	=> prg_d_o
			);

		chr_rom_inst : xilinx_tennis_chr
			port map
			(
				clk		=> clk,
				addr	=> chr_a(12 downto 0),
				dout	=> chr_d_o
			);

	end generate GEN_XILINX_SPARTAN3;

	prg_d_oe <= '1';
	chr_d_oe <= '1';
	vram_ce_n <= '0';
	irq_oe <= '0';
	
end TENNIS;
