
-- VHDL Instantiation Created from source file fifo_writer.vhd -- 11:43:21 01/21/2013
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT fifo_writer
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		write_fifo : IN std_logic;
		fifo_full : IN std_logic;
		fifo_din : IN std_logic_vector(7 downto 0);          
		wr_clk : OUT std_logic;
		wr_en : OUT std_logic;
		write_fifo_busy : OUT std_logic;
		din : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	Inst_fifo_writer: fifo_writer PORT MAP(
		clk => ,
		rst => ,
		wr_clk => ,
		wr_en => ,
		write_fifo_busy => ,
		write_fifo => ,
		fifo_full => ,
		fifo_din => ,
		din => 
	);


