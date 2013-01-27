----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:18:48 10/04/2012 
-- Design Name: 
-- Module Name:    Generic_SPI_FSM - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
LIBRARY XilinxCoreLib;
use XilinxCoreLib.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Generic_SPI_FSM is
    Port ( MOSI : out  STD_LOGIC;
           MISO : in  STD_LOGIC;
           CS_out : out  STD_LOGIC;
           SCL : out  STD_LOGIC;
           Din : in  STD_LOGIC_VECTOR (7 downto 0);
			  Din_big : in STD_LOGIC_VECTOR(255 downto 0);
			  Dout : out STD_LOGIC_VECTOR ( 7 downto 0);
			  Dout_big	: out STD_LOGIC_VECTOR(255 downto 0);
           SCL_Pulses : in  STD_LOGIC_VECTOR (8 downto 0);
			  SCL_width : in STD_LOGIC_VECTOR(3 downto 0);
			  CS_width : in STD_LOGIC_VECTOR(3 downto 0);
			  CS_enable	: IN STD_LOGIC;
--			  CS_override : in STD_LOGIC;
           go : in  STD_LOGIC;
			  dir : in STD_LOGIC; --0 Write out mosi, 1 read in MISO
			  rst : in STD_LOGIC;
			  clk : in STD_LOGIC;
           done : out  STD_LOGIC);
end Generic_SPI_FSM;

architecture Behavioral of Generic_SPI_FSM is
signal sstate : integer range 0 to 31 := 0;
signal MOSI_sreg : STD_LOGIC_VECTOR (7 downto 0);
signal MOSI_big_sreg	: STD_LOGIC_VECTOR(255 downto 0);
signal MISO_sreg : STD_LOGIC_VECTOR(7 downto 0);
signal MISO_big_sreg : STD_LOGIC_VECTOR(255 downto 0);
signal shift_mosi : STD_LOGIC;
signal shift_miso : STD_LOGIC;
signal sck_cnt_inc : STD_LOGIC; --change to right dimension
signal sck_cnt_rst : STD_LOGIC;
signal sck_cnt : STD_LOGIC_VECTOR(8 downto 0);
signal load_sreg : STD_LOGIC;
signal cw_cnt : STD_LOGIC_VECTOR(4 downto 0);
signal cw_cnt_en : STD_LOGIC;
signal int_dir, int_CS_Enable :STD_LOGIC;
signal CS : STD_LOGIC;
signal lMosi, bMosi : STD_LOGIC;
begin
lMosi <= MOSI_sreg(7) when (dir = '0') else '0';
bMosi <= MOSI_big_sreg(255) when ( dir = '0') else '0';
		
MOSI <= bMosi when SCL_Pulses = "100000000" else lMosi;
--sreg(8) <= MISO when dir = '1' else '0';
CS_out <= CS;
sck_cnt_proc: process(clk) is
begin
	if(rising_edge(clk)) then	
		if(rst = '0' or sck_cnt_rst= '1') then
			sck_cnt <= (others=>'0');
		else
			if(sck_cnt_inc = '1') then
				sck_cnt <= sck_cnt + "01";
			else
				null;
			end if;		
		end if;
	end if;
end process;

miso_sreg_proc : process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
			MISO_sreg <= (others=>'0');
		else
			if(shift_miso = '1') then
				MISO_sreg <= MISO_sreg(6 downto 0) & MISO;
				MISO_big_sreg <= MISO_big_sreg(254 downto 0) & MISO;
			end if;
		end if;
	
	end if;
end process;

mosi_sreg_proc: process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
	--		MISO_sreg <= (others=>'0');
			MOSI_sreg <= (others=>'0');
			MOSI_big_sreg <= (others=>'0');
		else
			if(load_sreg = '1') then
			--	if(dir = '0') then
				
					MOSI_sreg <= din;
					MOSI_big_sreg <= din_big;
			--	end if;
			else
				if( shift_mosi = '1') then
				--	if( dir = '0') then -- update MOSI
						MOSI_sreg <= MOSI_sreg(6 downto 0) & '0';
						MOSI_big_sreg <= MOSI_big_sreg(254 downto 0) & '0';
			--		else -- update MISO
				--		MISO_sreg <= MISO & MISO_sreg(7 downto 1);			
			--		end if;
				else
					null;
				end if;
		end if;
		end if;
	end if;
end process;

scl_cycle_time_proc: process(clk) is
begin
	if(rising_edge(clk)) then
	if(rst = '0') then
		cw_cnt <= (others => '0');
	else
		if(cw_cnt_en = '1') then
			cw_cnt <= cw_cnt + 1;
		else
			cw_cnt <= (others => '0');
		end if;
	
	end if;
	end if;
end process;

process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
			sstate <= 0;
			done <= '0';
			SCL <= '0';
			CS <= '1';
			shift_mosi <= '0';
			shift_miso <= '0';
			sck_cnt_rst <= '1';
			sck_cnt_inc <= '0';
			load_sreg <= '0';
			cw_cnt_en <= '0';
			int_CS_enable <= '0';
			int_dir <= '0';
		else
			case sstate is
				when 0 =>
					done <= '0';
				
					cw_cnt_en <= '0';
					if(go = '1') then
						int_dir <= dir;
						int_CS_Enable <= CS_Enable;
					--	if(dir = '0') then 
							load_sreg <= '1';
					--	else
					--		load_sreg <= '0';
					--	end if;
							CS <= '0';
						sck_cnt_rst <= '0';
						sstate <= sstate + 1;
					else
						null;
					end if;
				when 1=> -- start shiftin!
					load_sreg <= '0';
					CS <= '0';
					SCL <= '0';
					shift_mosi <= '0';

					sstate <= sstate + 1;
				when 2=>
					shift_mosi <= '0';
					shift_miso <= '0';
				--	SCL <= '0';
					sck_cnt_inc <= '1';
					sstate <= sstate + 1;
					cw_cnt_en <= '0';
				when 3=>
					shift_mosi <= '0';
					shift_miso <= '0';
					sck_cnt_inc <= '0';
					SCL <= '0';
					cw_cnt_en <= '1';
					if(cw_cnt = SCL_width -1 ) then
						sstate <= sstate + 1;
						cw_cnt_en <= '0';
					end if;
				when 4=>
					sck_cnt_inc <= '0';					
					cw_cnt_en <= '0';
					sstate <= sstate + 1;
			--		if(sck_cnt < SCL_Pulses) then
						shift_miso <= '1';
			--	end if;
				when 5=>
					shift_mosi <= '0';
					shift_miso <= '0';
					SCL <= '1';
					cw_cnt_en <= '1';

					if(cw_cnt = SCL_width -1) then
						if(sck_cnt = SCL_Pulses) then --9 pulses
							sstate <= sstate + 1; --finish up						
						else
		
							sstate <= 2;
							shift_mosi <= '1';
					--		shift_miso <= '1';
						end if;
					--	shift_miso <= '0';
					else
					--	shift_miso <= '0';
					end if;
				when 6=> 
					shift_miso <= '0';
			--		SCL <= '0';
					if(int_dir = '1') then 
						shift_mosi <= '1';
					end if;
					sstate <= sstate + 1;
			when 7=>
					cw_cnt_en <= '0';
					shift_mosi <= '0';
					sck_cnt_rst <= '1';
					SCL <= '0';	
					sstate <= sstate + 1;
				when 8=>
				--	if(dir = '1') then
						dout <= MISO_sreg;
						dout_big <= MISO_big_sreg;
				--	else
				--		null;
				--	end if;
					
					sstate <= sstate + 1;
				when 9=>
					
					if(int_CS_enable = '1') then
						CS <= '1';
						cw_cnt_en <= '1';
						if(cw_cnt = CS_width) then
							sstate <= 0;
						end if;
					else
						sstate <= 0;
					end if;
					done <= '1';
					
				when others=>
					sstate <= sstate + 1;
			end case;
		end if;
	
	end if;

end process;



end Behavioral;

