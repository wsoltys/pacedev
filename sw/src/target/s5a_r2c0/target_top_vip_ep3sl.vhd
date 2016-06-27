library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_syn_attributes.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity target_top_vip_ep3sl is
	port
	(
		ddr64_odt             : out std_logic_vector(0 downto 0);
		ddr64_clk             : inout std_logic_vector(0 downto 0);
		ddr64_clk_n           : inout std_logic_vector(0 downto 0);
		ddr64_cs_n            : out std_logic_vector(0 downto 0);
		ddr64_cke             : out std_logic_vector(0 downto 0);
		ddr64_a               : out std_logic_vector(12 downto 0);
		ddr64_ba              : out std_logic_vector(2 downto 0);
		ddr64_ras_n           : out std_logic;
		ddr64_cas_n           : out std_logic;
		ddr64_we_n            : out std_logic;
		ddr64_dq              : inout std_logic_vector(63 downto 0);
		ddr64_dqs             : inout std_logic_vector(7 downto 0);
		ddr64_dqsn            : inout std_logic_vector(7 downto 0);
		ddr64_dm              : out std_logic_vector(7 downto 0);
		ddr64_reset_n         : out std_logic;

    -- DVI output, 1V5 I/O 1 pix/clk, 24-bit mode
		vdo_red			          : out std_logic_vector(7 downto 0);
		vdo_green		          : out std_logic_vector(7 downto 0);
		vdo_blue		          : out std_logic_vector(7 downto 0);
		vdo_idck		          : out std_logic;
		vdo_hsync		          : out std_logic;
		vdo_vsync		          : out std_logic;
		vdo_de			          : out std_logic;

    -- DVI input, 1 pix/clk, 24-bit mode
		vdi_odck			        : in std_logic;
		vdi_red				        : in std_logic_vector(7 downto 0);
		vdi_green			        : in std_logic_vector(7 downto 0);
		vdi_blue			        : in std_logic_vector(7 downto 0);
		vdi_de				        : in std_logic;
		vdi_vsync			        : in std_logic;
		vdi_hsync			        : in std_logic;
		vdi_scdt			        : in std_logic;
		--vdi_pdn			        	: out std_logic;

    -- VGA input, 1 pix/clk, 30-bit mode
		vai_dataclk		        : in std_logic;
		vai_extclk		        : out std_logic;
		vai_red				        : in std_logic_vector(9 downto 0);
		vai_green			        : in std_logic_vector(9 downto 0);
		vai_blue			        : in std_logic_vector(9 downto 0);
		vai_vsout			        : in std_logic;
		vai_hsout			        : in std_logic;
		vai_sogout		        : in std_logic;
		vai_fidout		        : in std_logic;
		--vai_pwdn		        	: out std_logic;
		vai_resetb_n	        : out std_logic;
		vai_coast			        : in std_logic;
		--vai_scl			        	: inout std_logic;
		--vai_sda			        	: inout std_logic;

		-- LVDS video from the Cyclone
		vli_red               : in std_logic_vector(7 downto 0); -- 7..0
		vli_green             : in std_logic_vector(7 downto 0); -- 15..8
		vli_blue              : in std_logic_vector(7 downto 0); -- 23..16
		vli_hsync             : in std_logic;  -- 24
		vli_vsync             : in std_logic;  -- 25
		vli_de                : in std_logic;  -- 26
		vli_locked            : in std_logic;  -- 27
		vli_clk			  	      : in std_logic;

    -- I2C to the Cyclone
		vid_scl			          : inout std_logic;
		vid_sda			          : inout std_logic;
                          
    -- SDVO to LVDS input, dual 4 channel x 7 
		vsi_clk			          : in std_logic_vector(1 downto 0);
		vsi_data		          : in std_logic_vector(7 downto 0);
		vsi_enavdd	          : in std_logic;
		vsi_enabkl	          : in std_logic;
		                      
		vlo_clk			          : out std_logic;
		vlo_data		          : out std_logic_vector(2 downto 0);

    -- VGA output, 1 pix/clk, 30-bit mode
		vao_clk	  	          : out std_logic;
		vao_red			          : out std_logic_vector(9 downto 0);
		vao_green		          : out std_logic_vector(9 downto 0);
		vao_blue		          : out std_logic_vector(9 downto 0);
		vao_hsync             : out std_logic;
		vao_vsync             : out std_logic;
		vao_blank_n           : out std_logic;
		vao_sync_n	          : out std_logic;
		vao_sync_t	          : out std_logic;
		vao_m1			          : out std_logic;
		vao_m2			          : out std_logic;

    -- Connection to video FPGA
		vid_address			      : in std_logic_vector(10 downto 0);
		vid_data				      : inout std_logic_vector(15 downto 0);
		vid_write_n			      : in std_logic;
		vid_read_n			      : in std_logic;
		vid_waitrequest_n	    : out std_logic;
		vid_irq_n				      : out std_logic;
		vid_clk					      : in std_logic;
    vid_reset_core_n      : in std_logic;
    vid_reset_n           : in std_logic;
    
		vid_spare		          : in std_logic_vector(29 downto 28);
                          
		clk24_b			          : in std_logic;
		veb_ck_b		          : in std_logic;
                          
		clk24_c			          : in std_logic;
		veb_ck_c		          : in std_logic;
                          
		clk24_d			          : in std_logic;
		veb_ck_d		          : in std_logic
                          
--		ddr_clk			          : in std_logic;
	);

end entity target_top_vip_ep3sl;

architecture SYN of target_top_vip_ep3sl is

  signal init           : std_logic := '0';
  alias reset           : std_logic is init;
  signal reset_n        : std_logic := '1';
  
  signal clk_65M        : std_logic;
  signal clk_120M       : std_logic;

  signal system_interrupts		: std_logic_vector(15 downto 0) := (others => '0');

  signal vdo_idck_s     : std_logic;
  signal vdo_red_s      : std_logic_vector(7 downto 0);
  signal vdo_green_s    : std_logic_vector(7 downto 0);
  signal vdo_blue_s     : std_logic_vector(7 downto 0);
  signal vdo_hsync_s    : std_logic;
  signal vdo_vsync_s    : std_logic;
  signal vdo_de_s       : std_logic;
  
begin

  target_top_ep3sl_inst : entity work.target_top_ep3sl
  	port map
  	(
--  		ddr64_odt           => ddr64_odt,    
----  		ddr64_clk         => ddr64_clk,  
----  		ddr64_clk_n       => ddr64_clk_n,
--  		ddr64_cs_n          => ddr64_cs_n,   
--  		ddr64_cke           => ddr64_cke,    
--  		ddr64_a             => ddr64_a,      
--  		ddr64_ba            => ddr64_ba,     
--  		ddr64_ras_n         => ddr64_ras_n,  
--  		ddr64_cas_n         => ddr64_cas_n,  
--  		ddr64_we_n          => ddr64_we_n,   
--  		ddr64_dq            => ddr64_dq,     
----  		ddr64_dqs         => ddr64_dqs,  
----  		ddr64_dqsn        => ddr64_dqsn, 
--  		ddr64_dm            => ddr64_dm,     
--  		ddr64_reset_n       => ddr64_reset_n,
  
      -- DVI output, 1V5 I/O 1 pix/clk, 24-bit mode
  		vdo_red			        => vdo_red_s,		
  		vdo_green		        => vdo_green_s,	
  		vdo_blue		        => vdo_blue_s,	  
  		vdo_idck		        => vdo_idck_s,	  
  		vdo_hsync		        => vdo_hsync_s,	
  		vdo_vsync		        => vdo_vsync_s,	
  		vdo_de			        => vdo_de_s,		  
  
      -- DVI input, 1 pix/clk, 24-bit mode
  		vdi_odck			      => vdi_odck,		  
  		vdi_red				      => vdi_red,			
  		vdi_green			      => vdi_green,		
  		vdi_blue			      => vdi_blue,		  
  		vdi_de				      => vdi_de,			  
  		vdi_vsync			      => vdi_vsync,		
  		vdi_hsync			      => vdi_hsync,		
  		vdi_scdt			      => vdi_scdt,		  
--  		vdi_pdn			      => vdi_pdn,		
  
      -- VGA input, 1 pix/clk, 30-bit mode
  		vai_dataclk		      => vai_dataclk,		
  		vai_extclk		      => vai_extclk,		  
  		vai_red				      => vai_red,				
  		vai_green			      => vai_green,			
  		vai_blue			      => vai_blue,			  
  		vai_vsout			      => vai_vsout,			
  		vai_hsout			      => vai_hsout,			
  		vai_sogout		      => vai_sogout,		  
  		vai_fidout		      => vai_fidout,		  
--  		vai_pwdn		      => vai_pwdn,		  
  		vai_resetb_n	      => vai_resetb_n,	  
  		vai_coast			      => vai_coast,			
--  		vai_scl			      => vai_scl,			
--  		vai_sda			      => vai_sda,			
  
  		-- LVDS video from the Cyclone
  		vli_red             => vli_red,      
  		vli_green           => vli_green,    
  		vli_blue            => vli_blue,     
  		vli_hsync           => vli_hsync,    
  		vli_vsync           => vli_vsync,    
  		vli_de              => vli_de,       
  		vli_locked          => vli_locked,   
  		vli_clk			        => vli_clk,			

      -- I2C to the Cyclone
  		vid_scl			        => vid_scl,
  		vid_sda			        => vid_sda,
  
      -- SDVO to LVDS input, dual 4 channel x 7 
  		vsi_clk			        => vsi_clk,
  		vsi_data		        => vsi_data,		  
  		vsi_enavdd	        => vsi_enavdd,	  
  		vsi_enabkl	        => vsi_enabkl,	  
  		                                    
  		vlo_clk			        => vlo_clk,
  		vlo_data		        => vlo_data,		  
  
      -- VGA output, 1 pix/clk, 30-bit mode
  		vao_clk	  	        => vao_clk,	  	
  		vao_red			        => vao_red,			
  		vao_green		        => vao_green,		
  		vao_blue		        => vao_blue,		  
  		vao_hsync           => vao_hsync,    
  		vao_vsync           => vao_vsync,    
  		vao_blank_n         => vao_blank_n,  
  		vao_sync_n	        => vao_sync_n,	  
  		vao_sync_t	        => vao_sync_t,	  
  		vao_m1			        => vao_m1,			  
  		vao_m2			        => vao_m2,			  
  
      -- Connection to video FPGA
  		vid_address			    => (others => '0'),
  		vid_data				    => open,				   
  		vid_write_n			    => vid_write_n,
  		vid_read_n			    => vid_read_n,
  		vid_waitrequest_n	  => open, 
  		vid_irq_n				    => open,
  		vid_clk					    => vid_clk,
      vid_reset_core_n    => vid_reset_core_n,
      vid_reset_n         => vid_reset_n,
                                               
  		vid_spare		        => vid_spare,		     
                                               
  		clk24_b			        => clk24_b,			     
  		veb_ck_b		        => veb_ck_b,		       
                                               
  		clk24_c			        => clk24_c,			     
  		veb_ck_c		        => veb_ck_c,		       
                                               
  		clk24_d			        => clk24_d,			     
  		veb_ck_d		        => veb_ck_d		       
  
--      ddr_clk			        => ddr_clk
  	);

	reset_gen : process (clk24_d)
		variable reset_cnt : integer := 999999;
	begin
		if rising_edge(clk24_d) then
			if reset_cnt > 0 then
				init <= '1';
				reset_cnt := reset_cnt - 1;
			else
				init <= '0';
			end if;
		end if;
	end process reset_gen;

  reset <= init;
  reset_n <= not init;
  
  vip_pll_inst : entity work.vip_pll
    port map
    (
      inclk0		=> clk24_d,
      c0		    => clk_120M,
      c1		    => clk_65M,
      c2		    => vdo_idck
    );

  vip_sopc_inst : entity work.vip_sopc
    port map
    (
      clk_24M                                         => clk24_c,
      clk_slave_if                                    => vid_clk,
      vip_clk                                         => clk_120M,
      reset_n                                         => reset_n,

      altmemddr_0_aux_full_rate_clk_out               => open,
      altmemddr_0_aux_half_rate_clk_out               => open,
      altmemddr_0_phy_clk_out                         => open,

      -- the_flave_interface_0
      access_n_to_the_flave_interface_0               => vid_write_n,
      address_to_the_flave_interface_0                => vid_address,
      data_to_and_from_the_flave_interface_0          => vid_data,
      interrupts_from_the_flave_interface_0				    => system_interrupts,
      irq_n_from_the_flave_interface_0                => vid_irq_n,
      read_n_to_the_flave_interface_0                 => vid_read_n,
      reset_n_to_the_flave_interface_0                => '1',
      waitrequest_n_from_the_flave_interface_0        => vid_waitrequest_n,
		
      vid_clk_to_the_alt_vip_cti_0                    => vdo_idck_s,
      vid_data_to_the_alt_vip_cti_0(23 downto 16)     => vdo_red_s,
      vid_data_to_the_alt_vip_cti_0(15 downto 8)      => vdo_green_s,
      vid_data_to_the_alt_vip_cti_0(7 downto 0)       => vdo_blue_s,
      vid_datavalid_to_the_alt_vip_cti_0              => vdo_de_s,
      vid_f_to_the_alt_vip_cti_0                      => '0',
      vid_h_sync_to_the_alt_vip_cti_0                 => vdo_hsync_s,
      vid_locked_to_the_alt_vip_cti_0                 => '1',
      vid_v_sync_to_the_alt_vip_cti_0                 => vdo_vsync_s,

      -- the_altmemddr_0
      aux_scan_clk_from_the_altmemddr_0               => open,
      aux_scan_clk_reset_n_from_the_altmemddr_0       => open,
      dll_reference_clk_from_the_altmemddr_0          => open,
      dqs_delay_ctrl_export_from_the_altmemddr_0      => open,
      global_reset_n_to_the_altmemddr_0               => reset_n,
      local_init_done_from_the_altmemddr_0            => open,
      local_refresh_ack_from_the_altmemddr_0          => open,
      local_wdata_req_from_the_altmemddr_0            => open,
      mem_addr_from_the_altmemddr_0                   => ddr64_a,
      mem_ba_from_the_altmemddr_0                     => ddr64_ba,
      mem_cas_n_from_the_altmemddr_0                  => ddr64_cas_n,
      mem_cke_from_the_altmemddr_0                    => ddr64_cke(0),
      mem_clk_n_to_and_from_the_altmemddr_0           => ddr64_clk_n(0),
      mem_clk_to_and_from_the_altmemddr_0             => ddr64_clk(0),
      mem_cs_n_from_the_altmemddr_0                   => ddr64_cs_n(0),
      mem_dm_from_the_altmemddr_0                     => ddr64_dm,
      mem_dq_to_and_from_the_altmemddr_0              => ddr64_dq,
      mem_dqs_to_and_from_the_altmemddr_0             => ddr64_dqs,
      mem_dqsn_to_and_from_the_altmemddr_0            => ddr64_dqsn,
      mem_odt_from_the_altmemddr_0                    => ddr64_odt(0),
      mem_ras_n_from_the_altmemddr_0                  => ddr64_ras_n,
      mem_reset_n_from_the_altmemddr_0                => ddr64_reset_n,
      mem_we_n_from_the_altmemddr_0                   => ddr64_we_n,
      oct_ctl_rs_value_to_the_altmemddr_0             => (others =>'0'),
      oct_ctl_rt_value_to_the_altmemddr_0             => (others =>'0'),
      reset_phy_clk_n_from_the_altmemddr_0            => open,
      
      underflow_from_the_alt_vip_itc_0                => open,
      vid_data_from_the_alt_vip_itc_0(23 downto 16)   => vdo_red,
      vid_data_from_the_alt_vip_itc_0(15 downto 8)    => vdo_green,
      vid_data_from_the_alt_vip_itc_0(7 downto 0)     => vdo_blue,
      vid_datavalid_from_the_alt_vip_itc_0            => vdo_de,
      vid_f_from_the_alt_vip_itc_0                    => open,
      vid_h_from_the_alt_vip_itc_0                    => open,
      vid_h_sync_from_the_alt_vip_itc_0               => vdo_hsync,
      vid_v_from_the_alt_vip_itc_0                    => open,
      vid_v_sync_from_the_alt_vip_itc_0               => vdo_vsync,
      vid_clk_to_the_alt_vip_itc_0                    => clk_65M
  );
  
end;
