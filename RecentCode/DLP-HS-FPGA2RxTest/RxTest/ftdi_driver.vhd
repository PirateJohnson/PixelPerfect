----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:42:33 01/21/2013 
-- Design Name: 
-- Module Name:    ftdi_driver - Behavioral 
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

entity ftdi_driver is
    Port ( 	clk : in STD_LOGIC;
				rst: in STD_LOGIC;
				go : in  STD_LOGIC;
				done : out  STD_LOGIC;
				data_in : in STD_LOGIC_VECTOR(7 downto 0);
				data_out : out STD_LOGIC_VECTOR(7 downto 0);
				dir : in  STD_LOGIC;
				busy : out STD_LOGIC;
				rd : out STD_LOGIC;
				wr : out STD_LOGIC;
				txe : in STD_LOGIC;
				rxf : in STD_LOGIC;
				--ftdi_data : inout STD_LOGIC_VECTOR(7 downto 0) --Data to ftdi chip		
				ftdi_dout : out STD_LOGIC_VECTOR(7 downto 0);
				ftdi_din	 : in STD_LOGIC_VECTOR(7 downto 0);
				dbg		: out STD_LOGIC_VECTOR(2 downto 0)
			  
			  );
end ftdi_driver;

architecture Behavioral of ftdi_driver is
	signal ustate : integer range 0 to 31;
	signal int_dir: STD_LOGIC;
	signal int_data : STD_LOGIC_VECTOR(7 downto 0);
begin
data_out <= int_data when int_dir = '1' else "00000000";

process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
			ustate<= 0;
			rd <= '1';
			wr <= '1';
			done <= '0';
			busy <= '0';
			dbg <= "000";
			int_data <= "00000000";
		else
			case ustate is
				when 0=>
					int_data <= "00000000";
					rd <= '1';
					wr <= '1';
					done <= '1';	
					busy <= '0';
					if(go = '1') then
						busy <= '1';
						done <= '0';
						int_dir <= dir;
						int_data <= data_in;
						ustate <= ustate + 1;
					else
						null;
					end if;
				when 1=>
					done <= '0';
					if(int_dir = '1') then --read
						ustate <= ustate + 1;
					else
					--	int_data <= data_in;
						ustate <= ustate + 7;
					end if;
				when 2=>
					if(rxf = '0') then
						ustate <= ustate + 1;
						dbg <= "010";
					else
					--dbg <= "100";
						null;
					end if;
				when 3=> --rxf == 0
					rd <= '0'; --drop read line low
					ustate <= ustate + 1; -- delay 20 ns (assuming 50 ns clk)
				when 4=>
					int_data <= ftdi_din;
					ustate <= ustate + 1; --delay 30 more ns
				when 5=>
					rd <= '1';
					done <= '1';
					ustate <= ustate + 1;	--delay 50 ns
				when 7=>		
					if(go = '0') then
						dbg <= "001";
						ustate <= 0;
						done <= '0';
					end if;
					busy <= '0';
				when 8=> -- write sequence
					if(txe = '0') then
						ustate <= ustate + 1;
					else
						null;
					end if;
				when 9=>
					ftdi_dout <= int_data;
					ustate <= ustate + 1;
				when 10=>
					wr <= '0';
					ustate <= ustate + 1;
				when 11=>
					wr <= '1';
				--	done <= '1';
				--	ustate <= ustate + 1;
					ustate <= 0;
				when 12=>
				--	if(go = '0') then -- if go still equals 1, then stay in the current state, otherwise reset
				--		ustate <= 0;
				--	end if;
				--	busy <= '0';
				when others=>
					ustate <= ustate + 1;
			end case;
					
		end if;
	end if;
end process;

end Behavioral;

