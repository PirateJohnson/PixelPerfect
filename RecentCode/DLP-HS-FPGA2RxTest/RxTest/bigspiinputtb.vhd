--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:43:02 01/22/2013
-- Design Name:   
-- Module Name:   C:/Users/Kyle/Development/Senior Design/DLP-HS-FPGA2RxTest/RxTest/bigspiinputtb.vhd
-- Project Name:  RxTest
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Generic_SPI_FSM
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY bigspiinputtb IS
END bigspiinputtb;
 
ARCHITECTURE behavior OF bigspiinputtb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Generic_SPI_FSM
    PORT(
         MOSI : OUT  std_logic;
         MISO : IN  std_logic;
         CS_out : OUT  std_logic;
         SCL : OUT  std_logic;
         Din : IN  std_logic_vector(7 downto 0);
         Din_big : IN  std_logic_vector(255 downto 0);
			Dout_big : OUT STD_LOGIC_VECTOR(255 downto 0);
         Dout : OUT  std_logic_vector(7 downto 0);
         SCL_Pulses : IN  std_logic_vector(8 downto 0);
         SCL_width : IN  std_logic_vector(3 downto 0);
         CS_width : IN  std_logic_vector(3 downto 0);
         CS_enable : IN  std_logic;
         go : IN  std_logic;
         dir : IN  std_logic;
         rst : IN  std_logic;
         clk : IN  std_logic;
         done : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal MISO : std_logic := '0';
   signal Din : std_logic_vector(7 downto 0) := (others => '0');
   signal Din_big : std_logic_vector(255 downto 0) := (others => '0');
	signal Dout_big	: std_logic_vector(255 downto 0) := (others=>'0');
   signal SCL_Pulses : std_logic_vector(8 downto 0) := (others => '0');
   signal SCL_width : std_logic_vector(3 downto 0) := (others => '0');
   signal CS_width : std_logic_vector(3 downto 0) := (others => '0');
   signal CS_enable : std_logic := '0';
   signal go : std_logic := '0';
   signal dir : std_logic := '0';
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal MOSI : std_logic;
   signal CS_out : std_logic;
   signal SCL : std_logic;
   signal Dout : std_logic_vector(7 downto 0);
   signal done : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Generic_SPI_FSM PORT MAP (
          MOSI => MOSI,
          MISO => MISO,
          CS_out => CS_out,
          SCL => SCL,
          Din => Din,
          Din_big => Din_big,
			 Dout_big => Dout_big,
          Dout => Dout,
          SCL_Pulses => SCL_Pulses,
          SCL_width => SCL_width,
          CS_width => CS_width,
          CS_enable => CS_enable,
          go => go,
          dir => dir,
          rst => rst,
          clk => clk,
          done => done
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	CS_width <= "0010";
	SCL_width <= "0011";

   -- Stimulus process
	
	MISO_proc: process
	begin
		--MISO <= '0';
		wait until SCL= '0';
		MISO <= '1';
		wait until SCL = '1';
		wait until SCL = '0';
		MISO <= '0';
		wait until SCL = '1';
		
		
	
	end process;
   stim_proc: process
   begin		
      rst <= '0';
		wait for clk_period*5;
		rst <= '1';
		dir <= '1'; -- read some shit 
		SCL_pulses <= "100000000";
		wait for clk_period;
		go <= '1';
      -- insert stimulus here 

      wait;
   end process;

END;
