library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.project_pkg.all;
use work.platform_pkg.all;

entity Galaxian_Interrupts is
  generic
  (
    USE_VIDEO_VBLANK  : in boolean := true
  );
  port
  (
    clk               : in std_logic;
    reset             : in std_logic;

    z80_data          : in std_logic_vector(7 downto 0);
    nmiena_wr         : in std_logic;

		vblank						: in std_logic;
		
    -- interrupt status & request lines
    nmi_req           : out std_logic
  );

end Galaxian_Interrupts;

architecture SYN of Galaxian_Interrupts is

  signal slow_clk_ena   : std_logic; -- 1MHz
  signal vblank_int     : std_logic;
  signal nmiena_s       : std_logic;

begin

  -- generate 1MHz (1us) clock enable
  process (clk, reset)
    subtype count_t is natural range 0 to CLK0_FREQ_MHz-1;
    variable count_v  : count_t := 0;
  begin
    if reset = '1' then
      count_v := 0;
      slow_clk_ena <= '0';
    elsif rising_edge(clk) then
      slow_clk_ena <= '0';  -- default
      if count_v = count_t'high then
        slow_clk_ena <= '1';
        count_v := 0;
      else
        count_v := count_v + 1;
      end if;
    end if;
  end process;

  -- latch interrupt enables
  process (clk, reset)
  begin
    if reset = '1' then
      nmiena_s <= '0';
    elsif rising_edge (clk) then
      if nmiena_wr = '1' then
        nmiena_s <= z80_data(0);
      end if;
    end if;
  end process;

	GEN_FAKE_VBLANK_INT : if not USE_VIDEO_VBLANK generate
		
  -- VBLANK interrupt
  process (clk, slow_clk_ena, reset)
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
          vblank_int <= '0';
        end if;
      end if;
    end if;
  end process;

	end generate GEN_FAKE_VBLANK_INT;
	
	GEN_REAL_VBLANK_INT : if USE_VIDEO_VBLANK generate
	
		process (clk, slow_clk_ena, reset)
			variable vblank_v : std_logic_vector(3 downto 0);
			alias vblank_r : std_logic is vblank_v(vblank_v'left);
			alias vblank_s : std_logic is vblank_v(vblank_v'left-1);
		begin
			if reset = '1' then
				vblank_int <= '0';
				vblank_v := (others => '0');
			elsif rising_edge(clk) then
				-- unmeta the vblank signal
				if slow_clk_ena = '1' then
					vblank_v := vblank_v(vblank_v'left-1 downto 0) & vblank;
					-- rising edge vblank only
					if vblank_r = '0' and vblank_s = '1' then
						vblank_int <= '1';
					else
						vblank_int <= '0';
					end if;
					vblank_r := vblank_v(vblank_v'left);
				end if;
			end if;
		end process;
	
	end generate GEN_REAL_VBLANK_INT;

  -- generate INT
  nmi_req <= '1' when (vblank_int and nmiena_s) /= '0' else '0';
  
end SYN;
