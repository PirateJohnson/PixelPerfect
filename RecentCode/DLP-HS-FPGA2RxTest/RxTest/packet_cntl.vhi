
-- VHDL Instantiation Created from source file packet_cntl.vhd -- 09:00:51 01/23/2013
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT packet_cntl
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		payload : IN std_logic_vector(255 downto 0);
		payload_ready : IN std_logic;
		ftdi_busy : IN std_logic;          
		dout : OUT std_logic_vector(7 downto 0);
		ftdi_go : OUT std_logic
		);
	END COMPONENT;

	Inst_packet_cntl: packet_cntl PORT MAP(
		clk => ,
		rst => ,
		payload => ,
		dout => ,
		payload_ready => ,
		ftdi_go => ,
		ftdi_busy => 
	);


