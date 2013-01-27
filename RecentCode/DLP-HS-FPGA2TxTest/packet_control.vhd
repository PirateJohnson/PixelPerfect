----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:47:58 11/09/2012 
-- Design Name: 
-- Module Name:    packet_cntl_r2 - Behavioral 
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

entity packet_control is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           data_available : in  STD_LOGIC;
           frame_data: in  STD_LOGIC_VECTOR (7 downto 0);
				row_ptr	: in STD_LOGIC_VECTOR(7 downto 0);
				col_ptr 	: in STD_LOGIC_VECTOR(7 downto 0);
				inc_ptr	: out STD_LOGIC;
				req_data : out STD_LOGIC;
				ack_data	: in STD_LOGIC;
				tx_ready	: in STD_LOGIC;
        --   FE : in  STD_LOGIC;
           tx_go : out  STD_LOGIC;
           data : out  STD_LOGIC_VECTOR (255 downto 0));
end packet_control;

architecture Behavioral of packet_control is
signal pl_reg		: STD_LOGIC_VECTOR(255 downto 0);
signal pl_cnt		: integer range 0 to 41;
signal da_cnt		: integer range 0 to 30000;
signal pstate					: integer range 0 to 20;
--signal rc_state	: integer range 0 to 10;
--signal inc_ptr		: STD_LOGIC;
--signal row_ptr, col_ptr		: STD_LOGIC_VECTOR(7 downto 0);
begin

data<= pl_reg;




process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
			pl_reg <= (others => '0');
			pl_cnt <= 0;
			da_cnt <= 0;
			pstate <= 0;
			tx_go <= '0';
			req_data <= '0';
			inc_ptr <= '0';
		else
			case pstate is
				when 0=>
					da_cnt <= 0;
					pl_cnt <= 0;
					tx_go <= '0';
					req_data <= '0';
					inc_ptr <= '0';
					pl_reg <= (others => '0');
					pstate <= pstate + 1;
				when 1=>
					tx_go <= '0';
					if(data_available = '1') then
						pstate <= pstate + 1;
						req_data <= '1';
					end if;
				when 2=>					
					if(ack_data = '1') then
						req_data <= '0';
						da_cnt <= da_cnt + 1;
						pstate <= pstate + 1;
					end if;					
				when 3=>
					inc_ptr <= '1';
					case pl_cnt is
						when 0=>
							pl_reg(239 downto 234) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 1=>
							pl_reg(233 downto 228) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 2=>
							pl_reg(227 downto 222) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 3=>
							pl_reg(221 downto 216) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 4=>
							pl_reg(215 downto 210) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 5=>
							pl_reg(209 downto 204) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 6=>
							pl_reg(203 downto 198) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 7=>
							pl_reg(197 downto 192) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 8=>
							pl_reg(191 downto 186) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 9=>
							pl_reg(185 downto 180) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 10=>
							pl_reg(179 downto 174) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 11=>
							pl_reg(173 downto 168) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 12=>
							pl_reg(167 downto 162) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 13=>
							pl_reg(161 downto 156) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 14=>	
							pl_reg(155 downto 150) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 15=>
							pl_reg(149 downto 144) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 16=>
							pl_reg(143 downto 138) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 17=>
							pl_reg(137 downto 132) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 18=>
							pl_reg(131 downto 126) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 19=>
							pl_reg(125 downto 120) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 20=>
							pl_reg(119 downto 114) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 21=>
							pl_reg(113 downto 108) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 22=>
							pl_reg(107 downto 102) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 23=>
							pl_reg(101 downto 96) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 24=>
							pl_reg(95 downto 90) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 25=>
							pl_reg(89 downto 84) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 26=>
							pl_reg(83 downto 78) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 27=>
							pl_reg(77 downto 72) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 28=>
							pl_reg(71 downto 66) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 29=>
							pl_reg(65 downto 60) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 30=>
							pl_reg(59 downto 54) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 31=>
							pl_reg(53 downto 48) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 32=>
							pl_reg(47 downto 42) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 33=>
							pl_reg(41 downto 36) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 34=>
							pl_reg(35 downto 30) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 35=>
							pl_reg(29 downto 24) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 36=>
							pl_reg(23 downto 18) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 37=>
							pl_reg(17 downto 12) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 38=>
							pl_reg(11 downto 6) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 39=>
							pl_reg(5 downto 0) <= frame_data(7 downto 2);
							pl_cnt <= pl_cnt + 1;
						when 40=>
							pl_reg(247 downto 240) <= row_ptr;
							pl_reg(255 downto 248) <= col_ptr;
							pl_cnt <= pl_cnt + 1;
						when others=>
							
						end case;
						pstate <= pstate + 1;
				when 4=>
					inc_ptr <= '0';
					if(pl_cnt = 41) then
						if(tx_ready ='1') then
							tx_go <= '1';	--Wait until tx module is done
							pl_cnt <= 0;
							pstate <= pstate + 1;
						end if;
					else
						pstate <= 1;
					end if;					
--				when 5=>
--					if(pl_cnt = 41) then
--						pstate <= pstate + 1;
--						pl_cnt <= 0;
--					else
--						pstate <= 1;
--					end if;
				when 5=>					
					if(da_cnt = 30000) then
						pstate <= 0;
						da_cnt <= 0;
					else
						pstate <= 1;
					end if;
				when others=> pstate <= pstate +1;
			end case;
		end if;
	
	end if;

end process;

end Behavioral;

