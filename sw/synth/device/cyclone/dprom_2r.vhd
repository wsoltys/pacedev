LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY dprom_2r IS
	GENERIC
	(
		init_file		: string := "";
		numwords_a	: natural;
		widthad_a		: natural;
		width_a			: natural := 8;
		numwords_b	: natural;
		widthad_b		: natural;
		width_b			: natural := 8
	);
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q_a		: OUT STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0)
	);
END dprom_2r;

ARCHITECTURE SYN OF dprom_2r IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
	SIGNAL sub_wire2	: STD_LOGIC ;
	SIGNAL sub_wire3_bv	: BIT_VECTOR (width_a-1 DOWNTO 0);
	SIGNAL sub_wire3	: STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
	SIGNAL sub_wire4_bv	: BIT_VECTOR (width_b-1 DOWNTO 0);
	SIGNAL sub_wire4	: STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);

	COMPONENT altsyncram
	GENERIC (
		address_aclr_a		: STRING;
		address_aclr_b		: STRING;
		address_reg_b		: STRING;
		indata_aclr_a		: STRING;
		indata_aclr_b		: STRING;
		indata_reg_b		: STRING;
		init_file		: STRING;
		init_file_layout		: STRING;
		intended_device_family		: STRING;
		lpm_type		: STRING;
		numwords_a		: NATURAL;
		numwords_b		: NATURAL;
		operation_mode		: STRING;
		outdata_aclr_a		: STRING;
		outdata_aclr_b		: STRING;
		outdata_reg_a		: STRING;
		outdata_reg_b		: STRING;
		power_up_uninitialized		: STRING;
		ram_block_type		: STRING;
		read_during_write_mode_mixed_ports		: STRING;
		widthad_a		: NATURAL;
		widthad_b		: NATURAL;
		width_a		: NATURAL;
		width_b		: NATURAL;
		width_byteena_a		: NATURAL;
		width_byteena_b		: NATURAL;
		wrcontrol_aclr_a		: STRING;
		wrcontrol_aclr_b		: STRING;
		wrcontrol_wraddress_reg_b		: STRING
	);
	PORT (
			wren_a	: IN STD_LOGIC ;
			wren_b	: IN STD_LOGIC ;
			clock0	: IN STD_LOGIC ;
			address_a	: IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
			address_b	: IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0);
			q_a	: OUT STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
			q_b	: OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
			data_a	: IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
			data_b	: IN STD_LOGIC_VECTOR (width_b-1 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	sub_wire2    <= '0';
	sub_wire3_bv(width_a-1 DOWNTO 0) <= (others => '0');
	sub_wire3    <= To_stdlogicvector(sub_wire3_bv);
	sub_wire4_bv(width_b-1 DOWNTO 0) <= (others => '0');
	sub_wire4    <= To_stdlogicvector(sub_wire4_bv);
	q_a    <= sub_wire0(width_a-1 DOWNTO 0);
	q_b    <= sub_wire1(width_b-1 DOWNTO 0);

	altsyncram_component : altsyncram
	GENERIC MAP (
		address_aclr_a => "NONE",
		address_aclr_b => "NONE",
		address_reg_b => "CLOCK0",
		indata_aclr_a => "NONE",
		indata_aclr_b => "NONE",
		indata_reg_b => "CLOCK0",
		init_file => init_file,
		init_file_layout => "PORT_A",
		intended_device_family => "Cyclone",
		lpm_type => "altsyncram",
		numwords_a => numwords_a,
		numwords_b => numwords_b,
		operation_mode => "BIDIR_DUAL_PORT",
		outdata_aclr_a => "NONE",
		outdata_aclr_b => "NONE",
		outdata_reg_a => "UNREGISTERED",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		ram_block_type => "M4K",
		read_during_write_mode_mixed_ports => "DONT_CARE",
		widthad_a => widthad_a,
		widthad_b => widthad_b,
		width_a => width_a,
		width_b => width_b,
		width_byteena_a => 1,
		width_byteena_b => 1,
		wrcontrol_aclr_a => "NONE",
		wrcontrol_aclr_b => "NONE",
		wrcontrol_wraddress_reg_b => "CLOCK0"
	)
	PORT MAP (
		wren_a => sub_wire2,
		wren_b => sub_wire2,
		clock0 => clock,
		address_a => address_a,
		address_b => address_b,
		data_a => sub_wire3,
		data_b => sub_wire4,
		q_a => sub_wire0,
		q_b => sub_wire1
	);

END SYN;
