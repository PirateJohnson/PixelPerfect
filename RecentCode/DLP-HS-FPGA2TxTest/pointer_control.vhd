----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    06:27:32 01/22/2013 
-- Design Name: 
-- Module Name:    pointer_control - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pointer_control is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           inc_ptr : in  STD_LOGIC;
           colptr : out  STD_LOGIC_VECTOR (7 downto 0);
           rowptr : out  STD_LOGIC_VECTOR (7 downto 0));
end pointer_control;

architecture Behavioral of pointer_control is
signal col_ptr, row_ptr : STD_LOGIC_VECTOR(7 downto 0);
begin

colptr <= col_ptr;
rowptr <= row_ptr;
rc_cntr: process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst='0') then
			row_ptr <= (others=>'0');
			col_ptr <= (others=>'0');
		else
			if(inc_ptr = '1') then						
				if(col_ptr = "11000111") then --199
					col_ptr <= (others=>'0');
					if(row_ptr = "10010101") then --149
						row_ptr <= (others=>'0');
					else
						row_ptr <= row_ptr + "01";
					end if;
				else
					col_ptr <= col_ptr + "01";				
				end if;
			end if;
		end if;
	end if;
end process;

end Behavioral;

