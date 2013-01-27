----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:23:07 01/21/2013 
-- Design Name: 
-- Module Name:    fifo_reader - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fifo_reader is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           dout : in  STD_LOGIC_VECTOR (7 downto 0);
			  get_data : in STD_LOGIC;
           fifo_dout : out  STD_LOGIC_VECTOR (7 downto 0);
			  data_sent		: out STD_LOGIC;
           data_available : out  STD_LOGIC;
			  rd_en : out STD_LOGIC;
           rd_clk : out  STD_LOGIC;
           empty : in  STD_LOGIC);
end fifo_reader;

architecture Behavioral of fifo_reader is
signal rstate : integer range 0 to 50;
begin

process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
			rstate <= 0;
			data_available <= '0';
			rd_clk <= '0';
			data_sent <= '0';
		else
			case rstate is
				when 0=>
					rd_clk <= '1';
					rstate <= rstate + 1;
				when 1=>
					rd_clk <= '0';
					rstate <= rstate + 1;
				when 2=>
					rd_clk <= '1';
					rstate <= rstate + 1;
				when 3=>
					rd_clk <= '0';
					rstate <= rstate + 1;
				when 4=>
					rd_clk <= '1';
					rstate <= rstate + 1;
				when 5=>
					rd_clk <= '0';
					rstate <= rstate + 1;
				when 6=>
					rd_clk <= '1';
					rstate <= rstate + 1;
				when 7=>
					rd_clk <= '0';
					rstate <= rstate + 1;
				when 8=>
					rd_clk <= '1';
					rstate <= rstate + 1;
				when 9=>
					rd_clk <= '0';
					rstate <= rstate + 1;
				when 10=>
					rd_clk <= '1';
					rstate <= rstate + 1;
				when 11=>
					rd_clk <= '0';
					rstate <= rstate + 1;
				when 12=>
					rd_clk <= '1';
					rstate <= rstate + 1;
				when 13=>
					rd_clk <= '0';
					data_sent <= '0';
					rstate <= rstate + 1;
				when 14=>
					data_sent <= '0';
					rd_clk <= '1';
					rstate <= rstate + 1;
				when 15=>
					rd_clk <= '0';
					rstate <= rstate + 1;
				when 16=>
					data_sent <= '0';
					if(empty = '1') then
						data_available <= '0';
						rstate <= 14;
					else
						data_available <= '1';
						rstate <= rstate + 1;
					end if;
				when 17=>
					
					if( get_data = '1') then
						rd_en <= '1';
						rstate <= rstate + 1;
					end if;
				when 18=>
					rd_clk <= '1';
					fifo_dout <= dout;
					rstate <= rstate + 1;
				when 19=>
					rd_clk <= '0';
					rstate <= rstate + 1;
				when 20=>
					rd_clk <= '1';
					rd_en <= '0';
				--	fifo_dout <= dout;
					data_sent <= '1';
					rstate <= 13;
				when others=>
			end case;
	end if;
end if;
end process;
end Behavioral;

