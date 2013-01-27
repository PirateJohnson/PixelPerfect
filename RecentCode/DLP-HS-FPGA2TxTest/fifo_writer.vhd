----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:42:10 01/21/2013 
-- Design Name: 
-- Module Name:    fifo_writer - Behavioral 
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

entity fifo_writer is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           wr_clk : out  STD_LOGIC;
           wr_en : out  STD_LOGIC;
           write_fifo_busy : out  STD_LOGIC;
           write_fifo : in  STD_LOGIC;
           fifo_full : in  STD_LOGIC;
           fifo_din : in  STD_LOGIC_VECTOR (7 downto 0);
           din : out  STD_LOGIC_VECTOR (7 downto 0));
end fifo_writer;

architecture Behavioral of fifo_writer is
	signal wfs : integer range 0 to 10;
begin

wr_fifo_proc: process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
			wfs <= 0;
			wr_clk <= '0';
			wr_en <= '0';
		else
			case wfs is
				when 0=>
					wr_clk <= '0';
					wr_en <= '0';
					write_fifo_busy <= '0';
					if(write_fifo = '1') then
						din <= fifo_din;
						write_fifo_busy <= '1';
						wfs <= wfs + 1;
					end if;
				when 1=>
					wr_clk <= '1';
					wfs <= wfs + 1;
				when 2=>
					wr_clk <= '0';					
					wfs <= wfs + 1;
				when 3=>
					wr_clk <= '1';
					wfs <= wfs + 1;
				when 4=>
					wr_clk <= '0';					
					wfs <= wfs + 1;
				when 5=>
					wr_clk <= '1';
					wr_en <= '1';
					wfs <= wfs + 1;
				when 6=>
					wr_clk <= '0';
					
					wfs <= wfs + 1;
				when 7=>
					wr_clk <= '1';
					wr_en <= '0';
					wfs <= wfs + 1;
				when 8=>
					wr_clk <= '0';
					wfs <= wfs + 1;
				when 9=>
					wr_clk <= '1';
					wfs <= 0;
					write_fifo_busy <= '0';
				when others=>
					
			end case;
		end if;
	end if;

end process;

end Behavioral;

