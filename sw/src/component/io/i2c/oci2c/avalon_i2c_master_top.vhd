-- Top-level wrapper for I2C compatible with SOPC Builder
-- - removed generic
-- - all ports std_logic_vector

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avalon_i2c_master_top is
	port 
	(
		csi_clockreset_clk		  : in std_logic;
		csi_clockreset_reset    : in std_logic;
		coe_arst_arst_i         : in  std_logic := '0';             -- asynchronous reset

		-- wishbone signals     
		avs_s1_address          : in  std_logic_vector(2 downto 0);         -- lower address bits
		avs_s1_writedata        : in  std_logic_vector(7 downto 0); -- Databus input
		avs_s1_readdata         : out std_logic_vector(7 downto 0); -- Databus output
		avs_s1_write            : in  std_logic;	              -- Write enable input
		avs_s1_chipselect       : in  std_logic;                    -- Strobe signals / core select signal
		avs_s1_waitrequest_n    : out std_logic;                    -- Bus cycle acknowledge output
		ins_irq1_irq            : out std_logic;                    -- interrupt request output signal

		-- i2c lines
		coe_i2c_scl_pad_i       : in  std_logic;                -- i2c clock line input
		coe_i2c_scl_pad_o       : out std_logic;                -- i2c clock line output
		coe_i2c_scl_padoen_o    : out std_logic;                -- i2c clock line output enable, active low
		coe_i2c_sda_pad_i       : in  std_logic;                -- i2c data line input
		coe_i2c_sda_pad_o       : out std_logic;                -- i2c data line output
		coe_i2c_sda_padoen_o    : out std_logic                 -- i2c data line output enable, active low
	);
end entity avalon_i2c_master_top;

architecture structural of avalon_i2c_master_top is

  component i2c_master_top is
  	generic(
  		ARST_LVL : std_logic := '0'                   -- asynchronous reset level
  	);
  	port (
  		-- wishbone signals
  		wb_clk_i  : in  std_logic;                    -- master clock input
  		wb_rst_i  : in  std_logic := '0';             -- synchronous active high reset
  		arst_i    : in  std_logic := not ARST_LVL;    -- asynchronous reset
  		wb_adr_i  : in  std_logic_vector(2 downto 0); -- lower address bits
  		wb_dat_i  : in  std_logic_vector(7 downto 0); -- Databus input
  		wb_dat_o  : out std_logic_vector(7 downto 0); -- Databus output
  		wb_we_i   : in  std_logic;	              -- Write enable input
  		wb_stb_i  : in  std_logic;                    -- Strobe signals / core select signal
  		wb_cyc_i  : in  std_logic;	              -- Valid bus cycle input
  		wb_ack_o  : out std_logic;                    -- Bus cycle acknowledge output
  		wb_inta_o : out std_logic;                    -- interrupt request output signal
  
  		-- i2c lines
  		scl_pad_i     : in  std_logic;                -- i2c clock line input
  		scl_pad_o     : out std_logic;                -- i2c clock line output
  		scl_padoen_o  : out std_logic;                -- i2c clock line output enable, active low
  		sda_pad_i     : in  std_logic;                -- i2c data line input
  		sda_pad_o     : out std_logic;                -- i2c data line output
  		sda_padoen_o  : out std_logic                 -- i2c data line output enable, active low
  	);
  end component;

begin

  i2c_master_top_inst : i2c_master_top
  	generic map
      (
    		ARST_LVL => '1'   -- actual is active HI
    	)
  	port map
      (
    		-- wishbone signals
    		wb_clk_i  => csi_clockreset_clk,
    		wb_rst_i  => csi_clockreset_reset,
    		arst_i    => coe_arst_arst_i,
    		wb_adr_i  => avs_s1_address,
    		wb_dat_i  => avs_s1_writedata,
    		wb_dat_o  => avs_s1_readdata,
    		wb_we_i   => avs_s1_write,
    		wb_stb_i  => avs_s1_chipselect,
    		wb_cyc_i  => avs_s1_chipselect,
    		wb_ack_o  => avs_s1_waitrequest_n,
    		wb_inta_o => ins_irq1_irq,
    
    		-- i2c lines
    		scl_pad_i     => coe_i2c_scl_pad_i,
    		scl_pad_o     => coe_i2c_scl_pad_o,
    		scl_padoen_o  => coe_i2c_scl_padoen_o,
    		sda_pad_i     => coe_i2c_sda_pad_i,
    		sda_pad_o     => coe_i2c_sda_pad_o,
    		sda_padoen_o  => coe_i2c_sda_padoen_o
    	);

end architecture structural;
