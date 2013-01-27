
-- VHDL Instantiation Created from source file packet_control.vhd -- 06:50:34 01/22/2013
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT packet_control
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		data_available : IN std_logic;
		frame_data : IN std_logic_vector(7 downto 0);
		row_ptr : IN std_logic_vector(7 downto 0);
		col_ptr : IN std_logic_vector(7 downto 0);
		ack_data : IN std_logic;          
		inc_ptr : OUT std_logic_vector(7 downto 0);
		req_data : OUT std_logic;
		tx_go : OUT std_logic;
		data : OUT std_logic_vector(255 downto 0)
		);
	END COMPONENT;

	Inst_packet_control: packet_control PORT MAP(
		clk => ,
		rst => ,
		data_available => ,
		frame_data => ,
		row_ptr => ,
		col_ptr => ,
		inc_ptr => ,
		req_data => ,
		ack_data => ,
		tx_go => ,
		data => 
	);


