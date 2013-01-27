--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:48:23 01/21/2013
-- Design Name:   
-- Module Name:   C:/Users/Kyle/Development/Senior Design/DLP-HS-FPGA2TxTest/txtesttb.vhd
-- Project Name:  DLP-HS-FPGA2TxTest
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TxTest
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
 
ENTITY txtesttb IS
END txtesttb;
 
ARCHITECTURE behavior OF txtesttb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TxTest
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         asic_sck : IN  std_logic;
         asic_miso : IN  std_logic;
         asic_cs : IN  std_logic;
         tx_sck : OUT  std_logic;
         tx_ce : OUT  std_logic;
         tx_csn : OUT  std_logic;
         tx_mosi : OUT  std_logic;
         tx_miso : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal asic_sck : std_logic := '0';
   signal asic_miso : std_logic := '0';
   signal asic_cs : std_logic := '0';
   signal tx_miso : std_logic := '0';

 	--Outputs
   signal tx_sck : std_logic;
   signal tx_ce : std_logic;
   signal tx_csn : std_logic;
   signal tx_mosi : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TxTest PORT MAP (
          clk => clk,
          rst => rst,
          asic_sck => asic_sck,
          asic_miso => asic_miso,
          asic_cs => asic_cs,
          tx_sck => tx_sck,
          tx_ce => tx_ce,
          tx_csn => tx_csn,
          tx_mosi => tx_mosi,
          tx_miso => tx_miso
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
      -- hold reset state for 100 ns.
		rst <= '0';
		asic_cs <= '1';
		asic_sck <= '0';
		asic_miso <= '0';
		
		wait for clk_period * 5;
		rst <= '1';
      wait for 100 ns;	
		asic_cs <= '0';
		asic_miso <= '1'; --b0
		wait for 50 ns;
		asic_sck <= '1';	--b0	
		wait for 50 ns;	
		asic_sck <= '0';
		asic_miso <= '0';		--b1
		wait for 50 ns;
		asic_sck <= '1';		--b1
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '1';  --b2
		wait for 50 ns;
		asic_sck <= '1';		--b2
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0'; --b3
		wait for 50 ns;
		asic_sck <= '1';		--b3
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '1'; --b4
		wait for 50 ns;
		asic_sck <= '1';		--b4
		wait for 50 ns;
		asic_sck <= '0'; 
		asic_miso <= '0';  --b5
		wait for 50 ns;
		asic_sck <= '1';		--b5
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '1'; --b6
		wait for 50 ns;
		asic_sck <= '1';		--b6
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0'; --b7
		wait for 50 ns;
		asic_sck <= '1';		--b7
		wait for 50 ns;		
		--End of frame data
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';	--b8	
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--9
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--10
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--11
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--12
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--13
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--14
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--15
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--16
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--17
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--18
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--19
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--20
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--21
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--22
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--23
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--24
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for clk_period*20;
		asic_cs <= '0';
		asic_miso <= '1'; --b0
		wait for 50 ns;
		asic_sck <= '1';	--b0	
		wait for 50 ns;	
		asic_sck <= '0';
		asic_miso <= '0';		--b1
		wait for 50 ns;
		asic_sck <= '1';		--b1
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '1';  --b2
		wait for 50 ns;
		asic_sck <= '1';		--b2
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0'; --b3
		wait for 50 ns;
		asic_sck <= '1';		--b3
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '1'; --b4
		wait for 50 ns;
		asic_sck <= '1';		--b4
		wait for 50 ns;
		asic_sck <= '0'; 
		asic_miso <= '0';  --b5
		wait for 50 ns;
		asic_sck <= '1';		--b5
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '1'; --b6
		wait for 50 ns;
		asic_sck <= '1';		--b6
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0'; --b7
		wait for 50 ns;
		asic_sck <= '1';		--b7
		wait for 50 ns;		
		--End of frame data
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';	--b8	
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--9
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--10
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--11
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--12
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--13
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--14
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--15
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--16
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--17
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--18
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--19
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--20
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--21
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--22
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--23
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
		wait for 50 ns;
		asic_sck <= '1';		--24
		wait for 50 ns;
		asic_sck <= '0';
		asic_miso <= '0';
      -- insert stimulus here 

      wait;
   end process;

END;
