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


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Generic_SPI_FSM is
    Port ( MOSI : out  STD_LOGIC;
           CS : out  STD_LOGIC;
			  dis_cs : in STD_LOGIC; ---
           SCL : out  STD_LOGIC;
           Din : in  STD_LOGIC_VECTOR (8 downto 0);
           SCL_Pulses : in  STD_LOGIC_VECTOR (4 downto 0);
           go : in  STD_LOGIC;
			  spi_lcd_go : in STD_LOGIC;
			  rst : in STD_LOGIC;
			  clk : in STD_LOGIC;
           done : out  STD_LOGIC);
end Generic_SPI_FSM;

architecture Behavioral of Generic_SPI_FSM is

signal sstate : integer range 0 to 31 := 0;
signal sreg : STD_LOGIC_VECTOR (8 downto 0);
signal shift : STD_LOGIC;
signal sck_cnt_inc : STD_LOGIC;
signal sck_cnt_rst : STD_LOGIC;
signal sck_cnt : STD_LOGIC_VECTOR(4 downto 0);
signal load_sreg : STD_LOGIC;
signal cnt3 : STD_LOGIC_VECTOR(1 downto 0);

begin

MOSI <= sreg(8);

sck_cnt_proc: process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0' or sck_cnt_rst= '0') then
			sck_cnt <= "00000";
		else
			if(sck_cnt_inc = '1') then
				sck_cnt <= sck_cnt + "00001";
			else
				null;
			end if;		
		end if;
	end if;
end process;

sreg_proc: process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
			sreg <= "000000000";
		else
			if(load_sreg = '1') then
				sreg <= din;
			else
			if( shift = '1') then
					sreg <= sreg(7 downto 0) & sreg(8);					
			else
				null;
			end if;
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
			shift <= '0';
			sck_cnt_rst <= '0';
			sck_cnt_inc <= '0';
			load_sreg <= '0';
			cnt3 <= "00";
		else
			case sstate is
				when 0 =>
					done <= '0';
					if(go = '1') then
						load_sreg <= '1';
						sck_cnt_rst <= '1';
						sstate <= sstate + 1;
					else
						CS <= '1';
						SCL <= '0';
						sck_cnt_rst <= '0';
					end if;
				when 1=> -- start shiftin!
					load_sreg <= '0';
					CS <= '0';
					SCL <= '0';
					shift <= '0';
					sstate <= sstate + 1;
				when 2=>
					done <= '0'; 
					shift <= '0';
					load_sreg <= '0';
					sck_cnt_rst <= '1';
					sck_cnt_inc <= '1';
					SCL <= '0';
					sstate <= sstate + 1;
				when 3=>
					sck_cnt_inc <= '0';
					shift <= '1';
					SCL <= '1';
					if(sck_cnt = "01000") then --9 pulses
						sstate <= sstate + 1; --finish up
					else
						sstate <= 2;
					end if;
				when 4=>
					done <= '1';
					shift <= '0';
					sck_cnt_rst <= '0';
					SCL <= '0';
					if (dis_cs = '0') then 
						sstate <= sstate + 1;
					else 
						if(cnt3 = "10") then
							if(spi_lcd_go = '1') then
								load_sreg <= '1';
								cnt3 <= "00";
								sstate <= 2;
							else
								sstate <= sstate;
							end if;
						else
							cnt3 <= cnt3 + "01";
							sstate <= 2;
						end if;
					end if;
				when 5=>
					CS <= '1';	
					sstate <= sstate + 1;
				when 6=>
					done <= '1';
					sstate <= 0;
				when others=>
					sstate <= sstate + 1;
			end case;
		end if;
	end if;
end process;
end Behavioral;
