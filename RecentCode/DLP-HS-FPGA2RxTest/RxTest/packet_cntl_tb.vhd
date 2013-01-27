--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:30:03 01/23/2013
-- Design Name:   
-- Module Name:   C:/Users/Kyle/Development/Senior Design/DLP-HS-FPGA2RxTest/RxTest/packet_cntl_tb.vhd
-- Project Name:  RxTest
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: packet_cntl
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
 
ENTITY packet_cntl_tb IS
END packet_cntl_tb;
 
ARCHITECTURE behavior OF packet_cntl_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT packet_cntl
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         payload : IN  std_logic_vector(255 downto 0);
         dout : OUT  std_logic_vector(7 downto 0);
         payload_ready : IN  std_logic;
         ftdi_go : OUT  std_logic;
         ftdi_done : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal payload : std_logic_vector(255 downto 0) := (others => '0');
   signal payload_ready : std_logic := '0';
   signal ftdi_done : std_logic := '0';

 	--Outputs
   signal dout : std_logic_vector(7 downto 0);
   signal ftdi_go : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: packet_cntl PORT MAP (
          clk => clk,
          rst => rst,
          payload => payload,
          dout => dout,
          payload_ready => payload_ready,
          ftdi_go => ftdi_go,
          ftdi_done => ftdi_done
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
	ftdi_proc:process
	begin
		ftdi_done <= '1';
		wait for clk_period;
		ftdi_done <= '0';
		wait until ftdi_go = '1';
		wait for 6*clk_period;
		
		
	end process;
   -- Stimulus process
   stim_proc: process
   begin		
      rst <= '0';
		payload <= (others=>'0');
		wait for 3* clk_period;
		rst <= '1';
		wait for clk_period;
		payload_ready <= '1';
		payload <= (others=>'1');
		wait for clk_period;
		payload_ready <= '0';
		payload <= (others=>'0');
      -- insert stimulus here 

      wait;
   end process;

END;
