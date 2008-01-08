library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.project_pkg.all;

entity nes_cart is
	generic
	(
		NTSC					: boolean := true
	);
  port
  (
    clk         	: in std_logic;
    reset       	: in std_logic;

    prg_a       	: in std_logic_vector(14 downto 0);
    prg_d_i     	: in std_logic_vector(7 downto 0);
    prg_d_o     	: out std_logic_vector(7 downto 0);
    prg_d_oe    	: out std_logic;
		prg_rom_ce_n	: in std_logic;
		prg_rw_n			: in std_logic;

    chr_a       	: in std_logic_vector(13 downto 0);
    chr_d_i     	: in std_logic_vector(7 downto 0);
    chr_d_o     	: out std_logic_vector(7 downto 0);
    chr_d_oe    	: out std_logic;
		chr_ram_rd_n	: in std_logic;
		chr_ram_wr_n	: in std_logic;
		
		vram_ce_n			: out std_logic;
		chr_a13_n			: in std_logic;

		-- IRQ (open-collector)
		irq_i_n				: in std_logic;
		irq_oe				: out std_logic
  );
end nes_cart;
