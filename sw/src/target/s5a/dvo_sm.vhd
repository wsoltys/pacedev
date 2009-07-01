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
  generic
  (
    clock_speed	: integer;	          -- Input clock speed (Hz)
    i2c_speed		: integer := 400000		-- I2C toggle rate (Hz)
  );
	port
	(
		clk					: in std_logic;
		clk_ena     : in std_logic;
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
  		clock_speed	: integer := clock_speed;	  -- Input clock speed (Hz)
  		i2c_speed		: integer := i2c_speed      -- I2C toggle rate (Hz)
  	);
  	port
  	(
  		reset				: in std_logic;
  		clk					: in std_logic;
  		clk_ena		  : in std_logic;
  		timeout_err	: out std_logic;
  
      -- interface to i2c_sm		
  		is_idle     : out std_logic;
  		is_ready    : out std_logic;
  		last_byte   : in std_logic;
  		do_tx       : in std_logic;
  		txbyte      : in std_logic_vector(7 downto 0);
		  do_rx       : in std_logic;
		  rxbyte      : out std_logic_vector(7 downto 0);

      -- I2C physical interface
  		vo_scl			: inout std_logic;
  		vo_sda			: inout std_logic
  	);
  end component i2c_sm;

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
  signal rxbyte         : std_logic_vector(7 downto 0);
	signal do_rx          : std_logic;
  
begin

	BLK_SM : block
	
		type state_t is 
		(
		  init, wait_rdy,
		  cfg_tx1a, cfg_tx1d0, cfg_tx1d1,
		  cfg_done
		);

		signal state : state_t;
		
		type state_a_t is array (natural range <>) of state_t;
		constant next_state : state_a_t(0 to 4) := 
		( 
		  init,
		  cfg_tx1a, cfg_tx1d0, cfg_tx1d1,
		  cfg_done
	  );
    
	begin

		PROC_SM : process(clk, reset)
		  variable ready_r : std_logic := '0';
		  variable state_v : integer range 0 to next_state'high := 0;
		begin
      if reset = '1' then
        ready_r := '0';
        state_v := 0;
  			do_tx <= '0';
  			do_rx <= '0';
  			last_byte <= '0';
        state <= init;
      elsif rising_edge(clk) and clk_ena = '1' then

        -- assign defaults
  			do_tx <= '0';
  			do_rx <= '0';
        last_byte <= '0';
        
  			case state is

          when init =>
            null;
                          
    			when cfg_tx1a =>
    				txbyte <= DEV_ADDR_WR;
    				do_tx <= '1';
                
    			when cfg_tx1d0 =>
            -- setup - Ref=Vdd, int.clk, unipolar, no RST
    				txbyte <= TFP410_CTL_1_MODE;
    				do_tx <= '1';
    
    			when cfg_tx1d1 =>
            -- TDIS=0(PD#),VEN=1(orig),HEN=1(orig),DSEL=1,BSEL=1(24-bit),EDGE=1(rising),PD#=1(normal)
    				txbyte <= X"3F";
    				last_byte <= '1';
    				do_tx <= '1';
    
    			when others =>
            null;
          
  			end case;

        -- - 'ready' transitions to next state,
        --    else state transitions to waiting
        --    (allows us to pulse signals to the i2c core)
        if state /= cfg_done then
    			if ready_r = '0' and ready = '1' then
    			  state_v := state_v + 1;
    			  state <= next_state(state_v);
  			  else
    			  if state /= wait_rdy then
    			    state <= wait_rdy;
        	  end if;
    			end if;
    		end if;
  			ready_r := ready;
  			
  	  end if;
		end process PROC_SM;

	end block BLK_SM;

  i2c_sm_inst : i2c_sm
  	port map
  	(
  		clk					  => clk,
  		reset				  => reset,
  		clk_ena		    => clk_ena,
  		timeout_err	  => open,
  
      -- interface to i2c_sm		
  		is_idle       => is_idle,
  		is_ready      => ready,
  		last_byte     => last_byte,
  		do_tx         => do_tx,
  		txbyte        => txbyte,
      do_rx         => do_rx,
      rxbyte        => rxbyte,
  		vo_scl			  => i2c_scl,
  		vo_sda			  => i2c_sda
  	);

end SYN;
