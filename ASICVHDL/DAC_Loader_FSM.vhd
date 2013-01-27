----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:51:22 10/18/2012 
-- Design Name: 
-- Module Name:    DAC_Loader_FSM - Behavioral 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DAC_Loader_FSM is
	PORT
	(
		clk	: IN STD_LOGIC;
		rst	: IN STD_LOGIC;
		pdac_clk	: OUT STD_LOGIC;
		pdac_sin	: OUT STD_LOGIC;
		pdac_sync	: OUT STD_LOGIC;
		pdac_update_en	: IN STD_LOGIC;
		pdac_data	: IN STD_LOGIC_VECTOR(23 downto 0);
		pdac_busy	: OUT STD_LOGIC
	
	);
end DAC_Loader_FSM;

architecture Behavioral of DAC_Loader_FSM is
signal dacstate : integer range 0 to 127;
begin
DAC_Loader_FSM: process (clk,rst,pdac_update_en,pdac_data)
begin
	if (clk='1' and clk'event) then
		if (rst='0') then
			pdac_busy<='0';
			dacstate<=0;
			pdac_clk<='1';
			pdac_sin<='0';
			pdac_sync<='1';
		elsif (pdac_update_en='1') then
				case dacstate is
					when  0=>	pdac_sync<='0'; 
									pdac_busy<='1';	pdac_sin<=pdac_data(23);	dacstate<=dacstate+1;
					when  1=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when  2=>	pdac_clk<='1';		pdac_sin<=pdac_data(22);	dacstate<=dacstate+1;
					when  3=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when  4=>	pdac_clk<='1';		pdac_sin<=pdac_data(21);	dacstate<=dacstate+1;
					when  5=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when  6=>	pdac_clk<='1';		pdac_sin<=pdac_data(20);	dacstate<=dacstate+1;
					when  7=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when  8=>	pdac_clk<='1';		pdac_sin<=pdac_data(19);	dacstate<=dacstate+1;
					when  9=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 10=>	pdac_clk<='1';		pdac_sin<=pdac_data(18);	dacstate<=dacstate+1;
					when 11=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 12=>	pdac_clk<='1';		pdac_sin<=pdac_data(17);	dacstate<=dacstate+1;
					when 13=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 14=>	pdac_clk<='1';		pdac_sin<=pdac_data(16);	dacstate<=dacstate+1;
					when 15=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 16=>	pdac_clk<='1';		pdac_sin<=pdac_data(15);	dacstate<=dacstate+1;
					when 17=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 18=>	pdac_clk<='1';		pdac_sin<=pdac_data(14);	dacstate<=dacstate+1;
					when 19=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 20=>	pdac_clk<='1';		pdac_sin<=pdac_data(13);	dacstate<=dacstate+1;
					when 21=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 22=>	pdac_clk<='1';		pdac_sin<=pdac_data(12);	dacstate<=dacstate+1;
					when 23=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 24=>	pdac_clk<='1';		pdac_sin<=pdac_data(11);	dacstate<=dacstate+1;
					when 25=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 26=>	pdac_clk<='1';		pdac_sin<=pdac_data(10);	dacstate<=dacstate+1;
					when 27=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 28=>	pdac_clk<='1';		pdac_sin<=pdac_data(9);	dacstate<=dacstate+1;
					when 29=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 30=>	pdac_clk<='1';		pdac_sin<=pdac_data(8);	dacstate<=dacstate+1;
					when 31=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 32=>	pdac_clk<='1';		pdac_sin<=pdac_data(7);	dacstate<=dacstate+1;
					when 33=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 34=>	pdac_clk<='1';		pdac_sin<=pdac_data(6);	dacstate<=dacstate+1;
					when 35=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 36=>	pdac_clk<='1';		pdac_sin<=pdac_data(5);	dacstate<=dacstate+1;
					when 37=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 38=>	pdac_clk<='1';		pdac_sin<=pdac_data(4);	dacstate<=dacstate+1;
					when 39=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 40=>	pdac_clk<='1';		pdac_sin<=pdac_data(3);	dacstate<=dacstate+1;
					when 41=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 42=>	pdac_clk<='1';		pdac_sin<=pdac_data(2);	dacstate<=dacstate+1;
					when 43=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 44=>	pdac_clk<='1';		pdac_sin<=pdac_data(1);	dacstate<=dacstate+1;
					when 45=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 46=>	pdac_clk<='1';		pdac_sin<=pdac_data(0);	dacstate<=dacstate+1;
					when 47=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 48=>	pdac_clk<='1';	
									pdac_sync<='1';
									pdac_busy<='0';
									dacstate<=dacstate+1;
					when others=> dacstate<=dacstate+1;
				end case;
		else	dacstate<=0; 
		end if;
	else	null;	end if;
end process DAC_Loader_FSM;

end Behavioral;

