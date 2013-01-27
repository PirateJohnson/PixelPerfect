
-- VHDL Instantiation Created from source file Generic_SPI_FSM.vhd -- 12:10:24 01/22/2013
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT Generic_SPI_FSM
	PORT(
		MISO : IN std_logic;
		Din : IN std_logic_vector(7 downto 0);
		Din_big : IN std_logic_vector(255 downto 0);
		SCL_Pulses : IN std_logic_vector(8 downto 0);
		SCL_width : IN std_logic_vector(3 downto 0);
		CS_width : IN std_logic_vector(3 downto 0);
		CS_enable : IN std_logic;
		go : IN std_logic;
		dir : IN std_logic;
		rst : IN std_logic;
		clk : IN std_logic;          
		MOSI : OUT std_logic;
		CS_out : OUT std_logic;
		SCL : OUT std_logic;
		Dout : OUT std_logic_vector(7 downto 0);
		done : OUT std_logic
		);
	END COMPONENT;

	Inst_Generic_SPI_FSM: Generic_SPI_FSM PORT MAP(
		MOSI => ,
		MISO => ,
		CS_out => ,
		SCL => ,
		Din => ,
		Din_big => ,
		Dout => ,
		SCL_Pulses => ,
		SCL_width => ,
		CS_width => ,
		CS_enable => ,
		go => ,
		dir => ,
		rst => ,
		clk => ,
		done => 
	);


