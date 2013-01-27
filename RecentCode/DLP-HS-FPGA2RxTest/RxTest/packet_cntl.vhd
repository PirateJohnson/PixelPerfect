----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:35:42 01/23/2013 
-- Design Name: 
-- Module Name:    packet_cntl - Behavioral 
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

entity packet_cntl is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           payload : in  STD_LOGIC_VECTOR (255 downto 0);
           dout : out  STD_LOGIC_VECTOR (7 downto 0);
           payload_ready : in  STD_LOGIC;
           ftdi_go : out  STD_LOGIC;
           ftdi_done : in  STD_LOGIC);
end packet_cntl;

architecture Behavioral of packet_cntl is
signal pstate : integer range 0 to 80;
signal payload_buffer		: STD_LOGIC_VECTOR(255 downto 0);
begin

process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
			pstate <= 0;
			ftdi_go <= '0';
			dout <= (others=> '0');
		else
			case pstate is
				when 0=>
					if(payload_ready= '1') then
						pstate <= pstate + 1;
						payload_buffer <= payload;
					else
						payload_buffer <= (others=>'0');
					end if;
				when 1=>
					dout <= payload_buffer(255 downto 250) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 2=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 3=>
					dout <= payload_buffer(249 downto 244) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 4=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 5=>
					dout <= payload_buffer(243 downto 238) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 6=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 7=>
					dout <= payload_buffer(237 downto 232) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 8=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 9=>
					dout <= payload_buffer(231 downto 226) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 10=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 11=>
					dout <= payload_buffer(225 downto 220) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 12=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 13=>
					dout <= payload_buffer(219 downto 214) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 14=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 15=>
					dout <= payload_buffer(213 downto 208) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 16=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 17=>
					dout <= payload_buffer(207 downto 202) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 18=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 19=>
					dout <= payload_buffer(201 downto 196) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 20=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 21=>
					dout <= payload_buffer(195 downto 190) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 22=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 23=>
					dout <= payload_buffer(189 downto 184) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 24=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 25=>
					dout <= payload_buffer(183 downto 178) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 26=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 27=>
					dout <= payload_buffer(177 downto 172) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 28=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 29=>
					dout <= payload_buffer(171 downto 166) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 30=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 31=>
					dout <= payload_buffer(165 downto 160) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 32=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 33=>
					dout <= payload_buffer(159 downto 154) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 34=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 35=>
					dout <= payload_buffer(153 downto 148) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 36=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 37=>
					dout <= payload_buffer(147 downto 142) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 38=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 39=>
					dout <= payload_buffer(141 downto 136) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 40=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 41=>
					dout <= payload_buffer(135 downto 130) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 42=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 43=>
					dout <= payload_buffer(129 downto 124) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 44=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 45=>
					dout <= payload_buffer(123 downto 118) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 46=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 47=>
					dout <= payload_buffer(117 downto 112) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 48=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 49=>
					dout <= payload_buffer(111 downto 106) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 50=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 51=>
					dout <= payload_buffer(105 downto 100) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 52=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 53=>
					dout <= payload_buffer(99 downto 94) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 54=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
					--------------------------------------
				when 55=>
					dout <= payload_buffer(93 downto 88) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 56=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 57=>
					dout <= payload_buffer(87 downto 82) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 58=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 59=>
					dout <= payload_buffer(81 downto 76) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 60=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 61=>
					dout <= payload_buffer(75 downto 70) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 62=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 63=>
					dout <= payload_buffer(69 downto 64) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 64=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 65=>
					dout <= payload_buffer(63 downto 58) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 66=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 67=>
					dout <= payload_buffer(57 downto 52) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 68=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 69=>
					dout <= payload_buffer(51 downto 46) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 70=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 71=>
					dout <= payload_buffer(45 downto 40) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 72=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 73=>
					dout <= payload_buffer(39 downto 34) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 74=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 75=>
					dout <= payload_buffer(33 downto 28) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 76=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 77=>
					dout <= payload_buffer(27 downto 22) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 78=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= pstate + 1;
					end if;
				when 79=>
					dout <= payload_buffer(21 downto 16) & "00";
					ftdi_go <= '1';
					pstate <= pstate + 1;
				when 80=>
					ftdi_go <= '0';
					if(ftdi_done = '1') then
						pstate <= 0;
					end if;

				
					
				when others=>
			end case;
		
		end if;
	
	end if;

end process;
end Behavioral;

