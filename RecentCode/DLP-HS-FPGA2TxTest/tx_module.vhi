
-- VHDL Instantiation Created from source file tx_module.vhd -- 07:06:39 01/22/2013
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT tx_module
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		payload : IN std_logic_vector(255 downto 0);
		spi_miso : IN std_logic;
		tx_go : IN std_logic;          
		spi_mosi : OUT std_logic;
		spi_cs : OUT std_logic;
		Tx_ce : OUT std_logic;
		spi_sck : OUT std_logic;
		tx_ready : OUT std_logic
		);
	END COMPONENT;

	Inst_tx_module: tx_module PORT MAP(
		clk => ,
		rst => ,
		payload => ,
		spi_mosi => ,
		spi_miso => ,
		spi_cs => ,
		Tx_ce => ,
		spi_sck => ,
		tx_ready => ,
		tx_go => 
	);


