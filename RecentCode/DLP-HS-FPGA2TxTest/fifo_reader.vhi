
-- VHDL Instantiation Created from source file fifo_reader.vhd -- 12:38:34 01/21/2013
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT fifo_reader
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		dout : IN std_logic_vector(7 downto 0);
		get_data : IN std_logic;
		empty : IN std_logic;          
		fifo_dout : OUT std_logic_vector(7 downto 0);
		data_sent : OUT std_logic;
		data_available : OUT std_logic;
		rd_clk : OUT std_logic
		);
	END COMPONENT;

	Inst_fifo_reader: fifo_reader PORT MAP(
		clk => ,
		rst => ,
		dout => ,
		get_data => ,
		fifo_dout => ,
		data_sent => ,
		data_available => ,
		rd_clk => ,
		empty => 
	);


