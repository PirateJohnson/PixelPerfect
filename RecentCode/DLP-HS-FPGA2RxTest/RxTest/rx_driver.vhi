
-- VHDL Instantiation Created from source file rx_driver.vhd -- 12:55:35 01/22/2013
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT rx_driver
	PORT(
		clk : IN std_logic;
		rx_miso : IN std_logic;
		rst : IN std_logic;          
		rx_mosi : OUT std_logic;
		rx_cs : OUT std_logic;
		rx_ce : OUT std_logic;
		rx_sck : OUT std_logic
		);
	END COMPONENT;

	Inst_rx_driver: rx_driver PORT MAP(
		clk => ,
		rx_mosi => ,
		rx_miso => ,
		rx_cs => ,
		rx_ce => ,
		rx_sck => ,
		rst => 
	);


