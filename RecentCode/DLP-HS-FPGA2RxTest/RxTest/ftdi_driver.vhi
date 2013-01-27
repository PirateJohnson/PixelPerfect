
-- VHDL Instantiation Created from source file ftdi_driver.vhd -- 11:36:12 01/22/2013
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT ftdi_driver
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		go : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);
		dir : IN std_logic;
		txe : IN std_logic;
		rxf : IN std_logic;
		ftdi_din : IN std_logic_vector(7 downto 0);          
		done : OUT std_logic;
		data_out : OUT std_logic_vector(7 downto 0);
		busy : OUT std_logic;
		rd : OUT std_logic;
		wr : OUT std_logic;
		ftdi_dout : OUT std_logic_vector(7 downto 0);
		dbg : OUT std_logic_vector(2 downto 0)
		);
	END COMPONENT;

	Inst_ftdi_driver: ftdi_driver PORT MAP(
		clk => ,
		rst => ,
		go => ,
		done => ,
		data_in => ,
		data_out => ,
		dir => ,
		busy => ,
		rd => ,
		wr => ,
		txe => ,
		rxf => ,
		ftdi_dout => ,
		ftdi_din => ,
		dbg => 
	);


