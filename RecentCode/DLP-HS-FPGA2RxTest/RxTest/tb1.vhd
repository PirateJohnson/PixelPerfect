--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:36:04 01/22/2013
-- Design Name:   
-- Module Name:   C:/Users/Kyle/Development/Senior Design/DLP-HS-FPGA2RxTest/RxTest/tb1.vhd
-- Project Name:  RxTest
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RxTest
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
 
ENTITY tb1 IS
END tb1;
 
ARCHITECTURE behavior OF tb1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RxTest
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         rx_sck : OUT  std_logic;
         rx_mosi : OUT  std_logic;
         rx_miso : IN  std_logic;
         rx_csn : OUT  std_logic;
         rx_ce : OUT  std_logic;
         wr : OUT  std_logic;
         rd : OUT  std_logic;
         txe : IN  std_logic;
         rxf : IN  std_logic;
         ftdi_data : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal rx_miso : std_logic := '0';
   signal txe : std_logic := '0';
   signal rxf : std_logic := '0';

	--BiDirs
   signal ftdi_data : std_logic_vector(7 downto 0);

 	--Outputs
   signal rx_sck : std_logic;
   signal rx_mosi : std_logic;
   signal rx_csn : std_logic;
   signal rx_ce : std_logic;
   signal wr : std_logic;
   signal rd : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RxTest PORT MAP (
          clk => clk,
          rst => rst,
          rx_sck => rx_sck,
          rx_mosi => rx_mosi,
          rx_miso => rx_miso,
          rx_csn => rx_csn,
          rx_ce => rx_ce,
          wr => wr,
          rd => rd,
          txe => txe,
          rxf => rxf,
          ftdi_data => ftdi_data
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      rst <= '0';
      wait for 100 ns;	
		rst <= '1';
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
