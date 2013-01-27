----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:32:43 11/14/2012 
-- Design Name: 
-- Module Name:    spitx - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spitx is
    Port ( frame_data : in  STD_LOGIC_VECTOR (7 downto 0);
           column_data : in  STD_LOGIC_VECTOR (7 downto 0);
           row_data : in  STD_LOGIC_VECTOR (7 downto 0);
			  DA			: in STD_LOGIC;
			  clk	:in STD_LOGIC;
			  rst : in STD_LOGIC;
           MOSI : out  STD_LOGIC;
           CS : out  STD_LOGIC;
           SCK : out  STD_LOGIC);
end spitx;

architecture Behavioral of spitx is

signal fd_buff, cd_buff, rd_buff : STD_LOGIC_VECTOR(7 downto 0);
signal sstate : integer range 0 to 50;
begin


process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then 
			fd_buff <= (others=>'0');
			cd_buff <= (others=>'0');
			rd_buff <= (others=> '0');
			sstate <= 0;		
			CS <= '1';
			SCK <= '0';
			MOSI <= '0';
		else
			case sstate is
				when 0=>
					if(DA = '1') then
						sstate <= sstate + 1;
						fd_buff <= frame_data;
						cd_buff <= column_data;
						rd_buff <= row_data;
					end if;
				when 1=> 
					CS <= '0';
					sstate <= sstate + 1;
				when 2=>
					MOSI <= fd_buff(7);
					SCK <= '0';
					sstate <= sstate + 1;
				when 3=>
					SCK <= '1';					
					sstate <= sstate + 1;
				when 4=>
					MOSI <= fd_buff(6);
					SCK <= '0';
					sstate <= sstate + 1;
				when 5=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 6=>
					MOSI <= fd_buff(5);
					SCK <= '0';
					sstate <= sstate + 1;
				when 7=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 8=>
					MOSI <= fd_buff(4);
					SCK <= '0';
					sstate <= sstate + 1;
				when 9=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 10=>
					MOSI <= fd_buff(3);
					SCK <= '0';
					sstate <= sstate + 1;
				when 11=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 12=>
					MOSI <= fd_buff(2);
					SCK <= '0';
					sstate <= sstate + 1;
				when 13=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 14=>
					MOSI <= fd_buff(1);
					SCK <= '0';
					sstate <= sstate + 1;
				when 15=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 16=>
					MOSI <= fd_buff(0);
					SCK <= '0';
					sstate <= sstate + 1;
				when 17=>
					SCK <= '1';
					sstate <= sstate + 1;
					
--END OF PIXEL DATA

				when 18=>
					MOSI <= cd_buff(7);
					SCK <= '0';
					sstate <= sstate + 1;
				when 19=>
					SCK <= '1';					
					sstate <= sstate + 1;
				when 20=>
					MOSI <= cd_buff(6);
					SCK <= '0';
					sstate <= sstate + 1;
				when 21=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 22=>
					MOSI <= cd_buff(5);
					SCK <= '0';
					sstate <= sstate + 1;
				when 23=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 24=>
					MOSI <= cd_buff(4);
					SCK <= '0';
					sstate <= sstate + 1;
				when 25=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 26=>
					MOSI <= cd_buff(3);
					SCK <= '0';
					sstate <= sstate + 1;
				when 27=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 28=>
					MOSI <= cd_buff(2);
					SCK <= '0';
					sstate <= sstate + 1;
				when 29=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 30=>
					MOSI <= cd_buff(1);
					SCK <= '0';
					sstate <= sstate + 1;
				when 31=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 32=>
					MOSI <= cd_buff(0);
					SCK <= '0';
					sstate <= sstate + 1;
				when 33=>
					SCK <= '1';
					sstate <= sstate + 1;
--END OF COLUMN POINTER
	
				when 34=>
					MOSI <= rd_buff(7);
					SCK <= '0';
					sstate <= sstate + 1;
				when 35=>
					SCK <= '1';					
					sstate <= sstate + 1;
				when 36=>
					MOSI <= rd_buff(6);
					SCK <= '0';
					sstate <= sstate + 1;
				when 37=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 38=>
					MOSI <= rd_buff(5);
					SCK <= '0';
					sstate <= sstate + 1;
				when 39=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 40=>
					MOSI <= rd_buff(4);
					SCK <= '0';
					sstate <= sstate + 1;
				when 41=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 42=>
					MOSI <= rd_buff(3);
					SCK <= '0';
					sstate <= sstate + 1;
				when 43=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 44=>
					MOSI <= rd_buff(2);
					SCK <= '0';
					sstate <= sstate + 1;
				when 45=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 46=>
					MOSI <= rd_buff(1);
					SCK <= '0';
					sstate <= sstate + 1;
				when 47=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 48=>
					MOSI <= rd_buff(0);
					SCK <= '0';
					sstate <= sstate + 1;
				when 49=>
					SCK <= '1';
					sstate <= sstate + 1;
				when 50=>
					SCK <= '0';
					CS <= '1';
					sstate <= 0;

			end case;
			
		
		end if;
	
	end if;
	
end process;


end Behavioral;

