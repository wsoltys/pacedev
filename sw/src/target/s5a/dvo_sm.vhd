--
-- Small state machine to read touchscreen ADC
--
-- Loads DVI registers:
-- CTL_1_MODE (0x08) <= 0xFF	-- Enable transceiver
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--library altera;
--use altera.altera_syn_attributes.all;

entity i2c_sm_controller is
	port
	(
		clk					: in std_logic;
		reset				: in std_logic;

    -- I2C physical interface
		i2c_scl			: inout std_logic;
		i2c_sda			: inout std_logic
	);
end i2c_sm_controller;

architecture SYN of i2c_sm_controller is

  component i2c_sm is
  	generic
  	(
  		clock_speed	: integer := 25000000;	-- Input clock speed (Hz)
  		i2c_speed		: integer := 400000			-- I2C toggle rate (Hz)
  	);
  	port
  	(
  		reset				: in std_logic;
  		clk					: in std_logic;
  		clk_ena		  : in std_logic;
  		timeout_err	: out std_logic;
  
      -- interface to i2c_sm		
  		is_idle     : out std_logic;
  		ready       : out std_logic;
  		last_byte   : in std_logic;
  		do_tx       : in std_logic;
  		txbyte      : in std_logic_vector(7 downto 0);
  
      -- I2C physical interface
  		vo_scl			: inout std_logic;
  		vo_sda			: inout std_logic
  	);
  end component i2c_sm;

  constant SIM_DELAY    : time := 2 ns;
  
  constant DEV_ADDR     : std_logic_vector(7 downto 0) := X"70";
  -- derived - don't edit
	constant DEV_ADDR_RD	: std_logic_vector(7 downto 0) := DEV_ADDR(7 downto 1) & '1';
	constant DEV_ADDR_WR	: std_logic_vector(7 downto 0) := DEV_ADDR(7 downto 1) & '0';

	constant TFP410_CTL_1_MODE	: std_logic_vector(7 downto 0) := X"08";

	signal is_idle				: std_logic;	-- I2C state machine is idle (ready for command)
	signal ready					: std_logic;	-- Ready to tx/rx next byte
	signal last_byte			: std_logic;	-- Last byte to tx/rx
	signal do_tx					: std_logic;	-- Initiate a tx
	signal txbyte					: std_logic_vector(7 downto 0);
  
begin

	BLK_SM : block
	
		type state_t is 
		(
		  init, 
		  cfg_tx1a, cfg_tx1d0, cfg_tx1d1, cfg_tx1wait, 
		  cfg_done);

		signal state : state_t;
		
	begin

		-- DVI out IC load state machine combinatorial
		PROC_COMB : process(state)
		begin
			do_tx <= '0';
			last_byte <= '0';
      txbyte <= (others => '0');
			case state is

  			when cfg_tx1a =>
  				txbyte <= DEV_ADDR_WR after SIM_DELAY;
  				do_tx <= '1' after SIM_DELAY;
  
  			when cfg_tx1d0 =>
  				txbyte <= TFP410_CTL_1_MODE after SIM_DELAY;
  				do_tx <= '1' after SIM_DELAY;
  
  			when cfg_tx1d1 =>
          -- TDIS=0(PD#),VEN=1(orig),HEN=1(orig),DSEL=1,BSEL=1(24-bit),EDGE=1(rising),PD#=1(normal)
  				txbyte <= X"3F" after SIM_DELAY;
  				do_tx <= '1' after SIM_DELAY;
  
  			when cfg_tx1wait =>
  				last_byte <= '1' after SIM_DELAY;
  
  			when others =>
          null;
        
			end case;
		end process PROC_COMB;

		-- DVI out IC load state machine registers
		PROC_REG : process(clk, reset)
			variable next_state : state_t;
			variable ready_r : std_logic := '0';
		begin
			if reset = '1' then
				state <= init;
				ready_r := '0';
			elsif rising_edge(clk) then
				next_state := state;
				case state is

  				when init =>
  					if is_idle = '1' then
  						next_state := cfg_tx1a;
  					end if;
  
  				when cfg_tx1a =>
  					if ready_r = '0' and ready = '1' then
  						next_state := cfg_tx1d0;
  					end if;
  
  				when cfg_tx1d0 =>
  					if ready_r = '0' and ready = '1' then
  						next_state := cfg_tx1d1;
  					end if;
  
  				when cfg_tx1d1 =>
  					if ready_r = '0' and ready = '1' then
  						next_state := cfg_tx1wait;
  					end if;
  
  				when cfg_tx1wait =>
  					if ready_r = '0' and ready = '1' then
  						next_state := cfg_done;
  					end if;

  				when cfg_done =>
  				  -- spin forever
  				  null;

          when others =>
            next_state := init;
              				  
				end case;

				case next_state is
					when others =>
					  null;
				end case;
        ready_r := ready;
				state <= next_state;
			end if;
		end process PROC_REG;

	end block BLK_SM;

  i2c_sm_inst : i2c_sm
  	port map
  	(
  		clk					  => clk,
  		reset				  => reset,
  		clk_ena		    => '1',
  		timeout_err	  => open,
  
      -- interface to i2c_sm		
  		is_idle     => is_idle,
  		ready       => ready,
  		last_byte   => last_byte,
  		do_tx       => do_tx,
  		txbyte      => txbyte,

  		vo_scl			  => i2c_scl,
  		vo_sda			  => i2c_sda
  	);

end SYN;
