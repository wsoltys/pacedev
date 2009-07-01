library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.project_pkg.all;
use work.platform_pkg.all;

entity Pacman_Interrupts is
  generic
  (
    USE_VIDEO_VBLANK    : boolean := true
  );
  port
  (
    clk               : in std_logic;	-- 30MHz
    clk_ena           : in std_logic;
    reset             : in std_logic;

    z80_data          : in std_logic_vector(7 downto 0);
		Z80_addr					: in std_logic_vector(1 downto 0);
		io_wr							: in std_logic;
    intena_wr         : in std_logic;

		vblank						: in std_logic;

    -- interrupt status & request lines
		int_ack						: in std_logic;
    int_req           : out std_logic;
		int_vec						: out std_logic_vector(7 downto 0)
  );

end Pacman_Interrupts;

architecture SYN of Pacman_Interrupts is

  signal vblank_int     : std_logic;
  signal intena_s       : std_logic;

begin

  -- latch interrupt enables
  process (clk, clk_ena, reset)
  begin
    if reset = '1' then
      intena_s <= '0';
    elsif rising_edge (clk) and clk_ena = '1' then
      if intena_wr = '1' then
        intena_s <= z80_data(0);
      end if;
    end if;
  end process;

	-- latch interrupt vector
	process (clk, clk_ena, reset)
	begin
		if reset = '1' then
			int_vec <= (others => '0');
		elsif rising_edge(clk) and clk_ena = '1' then
			if io_wr = '1' and z80_addr(1 downto 0) = "00" then
				int_vec <= z80_data;
			end if;
		end if;
	end process;

	GEN_FAKE_VBLANK_INT : if not USE_VIDEO_VBLANK generate
    FAKE_VBLANK_BLOCK : block

      signal slow_clk_ena   : std_logic; -- 1MHz

    begin

      -- generate 1MHz (1us) clock enable
      process (clk, reset)
        variable count_v      : natural range 0 to CLK0_FREQ_MHz-1;
      begin
        if reset = '1' then
          count_v := 0;
          slow_clk_ena <= '0';
        elsif rising_edge(clk) then
          if count_v = CLK0_FREQ_MHz-1 then
            count_v := 0;
            slow_clk_ena <= '1';
          else
            count_v := count_v + 1;
            slow_clk_ena <= '0';
          end if;
        end if;
      end process;

      -- VBLANK interrupt
      process (clk, reset)
        variable count : natural range 0 to 16665;
      begin
        if reset = '1' then
          count := 0;
          vblank_int <= '0';
        elsif rising_edge (clk) then
          if slow_clk_ena = '1' then
            if count = 16665 then
              count := 0;
              vblank_int <= '1';
            else
              count := count + 1;
            end if;
          end if;
          -- priority for the ack
          if int_ack = '1' then
            vblank_int <= '0';
          end if;
        end if;
      end process;
    end block FAKE_VBLANK_BLOCK;
	end generate GEN_FAKE_VBLANK_INT;
	
	GEN_REAL_VBLANK_INT : if USE_VIDEO_VBLANK generate
	
		process (clk, reset)
			variable vblank_v : std_logic_vector(3 downto 0);
			alias vblank_r : std_logic is vblank_v(vblank_v'left);
			alias vblank_s : std_logic is vblank_v(vblank_v'left-1);
		begin
			if reset = '1' then
				vblank_int <= '0';
				vblank_v := (others => '0');
			elsif rising_edge(clk) then
				-- unmeta the vblank signal
				vblank_v := vblank_v(vblank_v'left-1 downto 0) & vblank;
				-- rising edge vblank only
				if vblank_r = '0' and vblank_s = '1' then
					vblank_int <= '1';
				end if;
				-- priority for the ack
				if int_ack = '1' then
					vblank_int <= '0';
				end if;
				vblank_r := vblank_v(vblank_v'left);
			end if;
		end process;
	
	end generate GEN_REAL_VBLANK_INT;

  -- generate INT
  int_req <= '1' when (vblank_int and intena_s) /= '0' else '0';
  
end SYN;
