--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   06:29:58 01/22/2013
-- Design Name:   
-- Module Name:   C:/Users/Kyle/Development/Senior Design/DLP-HS-FPGA2TxTest/ptrcntltb.vhd
-- Project Name:  DLP-HS-FPGA2TxTest
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: pointer_control
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
 
ENTITY ptrcntltb IS
END ptrcntltb;
 
ARCHITECTURE behavior OF ptrcntltb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pointer_control
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         inc_ptr : IN  std_logic;
         colptr : OUT  std_logic_vector(7 downto 0);
         rowptr : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal inc_ptr : std_logic := '0';

 	--Outputs
   signal colptr : std_logic_vector(7 downto 0);
   signal rowptr : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pointer_control PORT MAP (
          clk => clk,
          rst => rst,
          inc_ptr => inc_ptr,
          colptr => colptr,
          rowptr => rowptr
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
	rst_proc: process
	begin
		rst <= '0';
		wait for 50 ns;
		rst <= '1';
		wait;
	end process;
   -- Stimulus process
   stim_proc: process
   begin	
		inc_ptr <= '0';
		wait for clk_period*10;
		inc_ptr <= '1';
		wait for clk_period;
   end process;

END;
