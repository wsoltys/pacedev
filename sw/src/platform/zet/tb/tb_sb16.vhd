library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dummy_mem is
	port (
		clk				: in std_logic;
    addr			: in std_logic_vector(15 downto 0);
    data			: out std_logic_vector(15 downto 0)
	);
end dummy_mem;

architecture SIM of dummy_mem is
begin
	process (addr)
	begin
	  data <= addr(15 downto 0) after 12 ns; -- 12ns SRAM
	end process;
end SIM;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sb16 is
	port (
		fail:				out  boolean := false
	);
end entity tb_sb16;

architecture SYN of tb_sb16 is

	signal clk						: std_logic := '0';
	signal reset					: std_logic	:= '1';

  signal wb_adr_i       : std_logic_vector(15 downto 1) := (others => '0');
  signal wb_dat_i       : std_logic_vector(15 downto 0) := (others => '0');
  signal wb_dat_o       : std_logic_vector(15 downto 0) := (others => '0');
  signal wb_sel_i       : std_logic_vector(1 downto 0) := (others => '0');
  signal wb_cyc_i       : std_logic := '0';
  signal wb_stb_i       : std_logic := '0';
  signal wb_we_i        : std_logic := '0';
  signal wb_ack_o       : std_logic := '0';
	signal sb16_io_arena	: std_logic := '0';
  signal audio_l    		: std_logic_vector(15 downto 0) := (others => '0');
  signal audio_r    		: std_logic_vector(15 downto 0) := (others => '0');

begin

	-- Generate CLK and reset
  clk <= not clk after 40 ns; -- 12.5MHz
	reset <= '0' after 125 ns;

  TEST_P : process

    procedure wb_rd ( adr : in std_logic_vector(4 downto 0); 
                      dat : out std_logic_vector(7 downto 0)) is
    begin
      wait until falling_edge(clk);
      wb_adr_i(4 downto 1) <= adr(4 downto 1);
      wb_sel_i(0) <= not adr(0);
      wb_cyc_i <= '1';
      wb_stb_i <= sb16_io_arena;
      wb_we_i <= '0';
      wait until falling_edge(clk);
      wb_cyc_i <= '0';
      wb_stb_i <= '0';
			dat := wb_dat_o(7 downto 0);
    end procedure wb_rd;

    procedure wb_wr ( adr : in std_logic_vector(4 downto 0); 
                      dat : in std_logic_vector(7 downto 0)) is
    begin
      wait until falling_edge(clk);
      wb_adr_i(4 downto 1) <= adr(4 downto 1);
      wb_sel_i(0) <= not adr(0);
      wb_cyc_i <= '1';
      wb_stb_i <= sb16_io_arena;
      wb_we_i <= '1';
      wb_dat_i <= dat & dat;
      wait until falling_edge(clk);
      wb_cyc_i <= '0';
      wb_stb_i <= '0';
      wb_we_i <= '0';
    end procedure wb_wr;

		procedure wait_dsp_rd is
			variable dat : std_logic_vector(7 downto 0) := (others => '0');
		begin
			wait for 100 ns;
			loop
				wb_rd ("01110", dat);
				exit when dat(7) = '1';
			end loop;
		end procedure wait_dsp_rd;

		procedure wait_dsp_wr is
			variable dat : std_logic_vector(7 downto 0) := (others => '0');
		begin
			wait for 100 ns;
			loop
				wb_rd ("01100", dat);
				exit when dat(7) = '0';
			end loop;
		end procedure wait_dsp_wr;

		variable dat : std_logic_vector(15 downto 0) := (others => '0');

  begin
		-- $022X
		wb_adr_i(15 downto 5) <= X"02" & "001";
    wait until reset = '0';

    -- reset dsp
    wb_wr ("00110", X"01");
		wait for 100 ns;
    wb_wr ("00110", X"00");
		wait_dsp_rd;
		-- read data register
		wb_rd ("01010", dat(7 downto 0));

		-- get dsp version
		wait_dsp_wr;
    wb_wr ("01100", X"E1");
		wait_dsp_rd;
		wb_rd ("01010", dat(7 downto 0));
		wait_dsp_rd;
		wb_rd ("01010", dat(7 downto 0));

		-- 8-bit direct output
		wait_dsp_wr;
    wb_wr ("01100", X"10");
		wait_dsp_wr;
    wb_wr ("01100", X"11");
		wait_dsp_wr;
    wb_wr ("01100", X"10");
		wait_dsp_wr;
    wb_wr ("01100", X"22");
		wait_dsp_wr;
    wb_wr ("01100", X"10");
		wait_dsp_wr;
    wb_wr ("01100", X"33");

  end process TEST_P;

  sb16_hw : entity work.sound_blaster_16
		generic map
		(
			IO_BASE_ADDR	=> X"0220"
		)
    port map
    (
    	wb_clk_i      => clk,
    	wb_rst_i      => reset,
    	
    	wb_adr_i      => wb_adr_i,
    	wb_dat_i      => wb_dat_i,
    	wb_dat_o      => wb_dat_o,
    	wb_sel_i      => wb_sel_i,
    	wb_cyc_i      => wb_cyc_i,
    	wb_stb_i      => wb_stb_i,
    	wb_we_i       => wb_we_i,
    	wb_ack_o      => wb_ack_o,

			sb16_io_arena	=> sb16_io_arena,
    
    	audio_l				=> audio_l,
    	audio_r				=> audio_r
    );

end architecture SYN;
