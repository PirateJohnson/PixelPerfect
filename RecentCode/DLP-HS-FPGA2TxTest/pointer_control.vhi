
-- VHDL Instantiation Created from source file pointer_control.vhd -- 06:36:10 01/22/2013
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT pointer_control
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		inc_ptr : IN std_logic;          
		colptr : OUT std_logic_vector(7 downto 0);
		rowptr : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	Inst_pointer_control: pointer_control PORT MAP(
		clk => ,
		rst => ,
		inc_ptr => ,
		colptr => ,
		rowptr => 
	);


