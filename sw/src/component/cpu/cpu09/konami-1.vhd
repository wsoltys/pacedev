library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity konami_1 is
  generic
  (
    ENABLE_OPCODE_ENCRYPTION  : boolean := true
  );
	port 
  (	
		clk      :	in std_logic;                     -- E clock input (falling edge)
		rst      :  in std_logic;                     -- reset input (active high)
		vma      : out std_logic;                     -- valid memory address (active high)
    ba       : out std_logic;                     -- bus available (high on sync wait or DMA grant)
    bs       : out std_logic;                     -- bus status (high on interrupt or reset vector fetch or DMA grant)
		addr     : out std_logic_vector(15 downto 0); -- address bus output
		rw       : out std_logic;                     -- read not write output
	  data_out : out std_logic_vector(7 downto 0);  -- data bus output
	  data_in  :  in std_logic_vector(7 downto 0);  -- data bus input
		irq      :  in std_logic;                     -- interrupt request input (active high)
		firq     :  in std_logic;                     -- fast interrupt request input (active high)
		nmi      :  in std_logic;                     -- non maskable interrupt request input (active high)
		halt     :  in std_logic;                     -- halt input (active high) grants DMA
		hold     :  in std_logic                      -- hold input (active high) extend bus cycle
	);
end entity konami_1;

architecture SYN of konami_1 is
  signal addr_s             : std_logic_vector(addr'range);
  signal opfetch            : std_logic;
  signal decrypted_data_in  : std_logic_vector(data_in'range);
begin

  GEN_STOCK_6809 : if not ENABLE_OPCODE_ENCRYPTION generate
    decrypted_data_in <= data_in;
  end generate GEN_STOCK_6809;
  
  GEN_KONAMI_1 : if ENABLE_OPCODE_ENCRYPTION generate
  
    decrypted_data_in(7) <= ((data_in(7) and not addr_s(1)) or (not data_in(7) and addr_s(1))) 
                              when opfetch = '1' else
                            data_in(7);
    decrypted_data_in(6) <= data_in(6);
    decrypted_data_in(5) <= ((data_in(5) and addr_s(1)) or (not data_in(5) and not addr_s(1))) 
                              when opfetch = '1' else
                            data_in(5);
    decrypted_data_in(4) <= data_in(4);
    decrypted_data_in(3) <= ((data_in(3) and not addr_s(3)) or (not data_in(3) and addr_s(3))) 
                              when opfetch = '1' else
                            data_in(3);
    decrypted_data_in(2) <= data_in(2);
    decrypted_data_in(1) <= ((data_in(1) and addr_s(3)) or (not data_in(1) and not addr_s(3))) 
                              when opfetch = '1' else
                            data_in(1);
    decrypted_data_in(0) <= data_in(0);

  end generate GEN_KONAMI_1;
  
  addr <= addr_s;
  
  cpu_inst : entity work.cpu09
    port map
    (	
      clk				=> clk,
      rst				=> rst,
      rw				=> rw,
      vma				=> vma,
      lic       => open,
      ifetch    => open,
      opfetch   => opfetch,
      ba        => ba,
      bs        => bs,
      addr		  => addr_s,
      data_in		=> decrypted_data_in,
      data_out	=> data_out,
      halt			=> halt,
      hold			=> hold,
      irq				=> irq,
      firq			=> firq,
      nmi				=> nmi
    );
    
end architecture SYN;

