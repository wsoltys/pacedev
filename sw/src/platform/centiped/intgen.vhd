library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity intGen is
	port
	(
    clk       : in std_logic;
    reset     : in std_logic;

    -- inputs
    vsync_n   : in std_logic;
    intack    : in std_logic;

    -- outputs
    vblank    : out std_logic;
    irq_n     : out std_logic
	);
end intGen;

architecture SYN of intGen is

	signal vsync_pulse : std_logic;
	
begin

	-- produce a 1-clock vsync pulse on falling edge of vsync_n/vblank_n input
	-- - this allows us to use sync/vblank generate by video controller of any length
	
	process (clk, reset)
		variable vsync_r : std_logic := '0';
	begin
		if reset = '1' then
			vsync_r := '1';				-- video controller comes out of reset in vblank
			vsync_pulse <= '0';
		elsif rising_edge(clk) then
			vsync_pulse <= '0';
			if vsync_n = '0' and vsync_r = '1' then
				vsync_pulse <= '1';
			end if;
			vsync_r := vsync_n;
		end if;
	end process;

	--
	-- We need to produce 2 signals in this module
	-- - vblank every 60Hz
	-- - irq_n every 32 scanlines
	-- The numbers need to be pretty spot-on,
	-- because the centipede code actually counts them
	-- and will lock up if they're wrong!
	--
	
  process (clk, reset)
    variable vb_count : integer range 0 to 49199;
    variable irq_count : integer range 0 to 30000;
    variable toggle_r : std_logic;
    variable irq_r : std_logic;
    variable vblank_r : std_logic;
  begin
  	if reset = '1' then
    	vb_count := 0;
      irq_count := 0;
      vblank_r := '0';
      irq_r := '0';
      toggle_r := '0';
    elsif rising_edge (clk) then
			-- centipede vblank = 60Hz (17ms)
      -- vblank period = 1640us, which leaves 15.2ms
      if vsync_pulse = '1' then
       	vb_count := 0;
        vblank_r := '1';
     	elsif vb_count = 49199 then
       	vblank_r := '0';
				irq_count := 0;		-- re-sync with vblank
				toggle_r := '1';	-- re-sync with vblank
      else
       	vb_count := vb_count + 1;
      end if;

      -- do irq
      if intack = '1' then
       	-- turn off IRQ line
        irq_r := '0';
      else
       	-- irq gets toggled every 16(from 256) scanlines
        -- ie. 15.2ms / (256/16) = 950us
        -- @30Mhz, 28500 = 950us
        --if irq_count = 30000 then
        if irq_count = 28500 then
        	irq_count := 0;
          irq_r := toggle_r;
          toggle_r := not toggle_r;
          end if;
      end if;

			irq_count := irq_count + 1;

    end if;

    vblank <= vblank_r;
    irq_n <= not irq_r; -- or vblank_r; 	-- no irq during vblank

	end process;

end SYN;
