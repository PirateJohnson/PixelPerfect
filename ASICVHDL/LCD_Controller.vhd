----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:54:59 10/04/2012 
-- Design Name: 
-- Module Name:    LCD_Controller - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity LCD_Controller is
    Port ( 	rst : in  STD_LOGIC;
				clk : in  STD_LOGIC;
				sda : out  STD_LOGIC;
				scl : out  STD_LOGIC;	  
				cs : out  STD_LOGIC;
				lcd_go : in STD_LOGIC;
				frame_data : in STD_LOGIC_VECTOR(7 downto 0);
				frame_begin : in STD_LOGIC;
				frame_end : in STD_LOGIC);
end LCD_Controller;

architecture Behavioral of LCD_Controller is
	COMPONENT Generic_SPI_FSM
	PORT(
			MOSI : out  STD_LOGIC;
			CS : out  STD_LOGIC;
			SCL : out  STD_LOGIC;
			Din : in  STD_LOGIC_VECTOR (8 downto 0);
			SCL_Pulses : in  STD_LOGIC_VECTOR (4 downto 0);
			go : in  STD_LOGIC;
			spi_lcd_go : in STD_LOGIC;
			rst : in STD_LOGIC;
			dis_cs : in STD_LOGIC;
			clk : in STD_LOGIC;
			done : out  STD_LOGIC
		);
	END COMPONENT;
	
	signal lcd_dir : STD_LOGIC;
	signal dout_pad, din_pad : STD_LOGIC;
	signal dout: STD_LOGIC_VECTOR(8 downto 0);
	signal spi_go, spi_done, spi_lcd_go_sig : STD_LOGIC;
	signal lstate : integer range 0 to 63 := 0;
	signal lcd_cnt_en, lcd_cnt_rst : STD_LOGIC;
	signal lcd_cnt : STD_LOGIC_VECTOR(17 downto 0);
	signal spi_rst : STD_LOGIC;
	signal parameter : STD_LOGIC;
	signal dis_cs_sig : STD_LOGIC;
	
begin
	Inst_Generic_SPI_FSM: Generic_SPI_FSM PORT MAP(
		MOSI => dout_pad,
		CS => cs,
		SCL => scl,
		Din => dout,
		SCL_Pulses => "01001" ,
		go => spi_go,
		spi_lcd_go => spi_lcd_go_sig,
		rst => spi_rst,
		dis_cs => dis_cs_sig,
		clk => clk,
		done => spi_done
	);

sda <= dout_pad;
spi_lcd_go_sig <= lcd_go;

process(clk) is
begin
	if(rising_edge(clk)) then
		if(lcd_cnt_rst = '0' OR rst = '0') then
			lcd_cnt <= (others => '0');
		else
			if(lcd_cnt_en = '1') then
				lcd_cnt <= lcd_cnt + "01";
			else
				lcd_cnt <= lcd_cnt;
			end if;
		end if;
	end if;
end process;

process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
			lstate <= 0;
			dis_cs_sig <= '0';
			lcd_cnt_rst <= '0';
			spi_go <= '0';
			spi_rst <= '0';
			lcd_cnt_en <= '0';
			parameter <= '1';
		else
			case lstate is 
				when 0=>
					lcd_cnt_rst <= '1';
					spi_rst <= '1';
					lcd_cnt_en <= '1';
					if(lcd_cnt = "111101000010010000") then --Wait 5 ms
						lcd_cnt_rst <= '0';
						dout <= "000010001"; --Sleep Out
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 1=>
					spi_go <= '1';
					lcd_cnt_rst <= '1';
					lcd_cnt_en <= '0';
					lstate <= lstate + 1;
				when 2=>
					spi_go <= '0';  
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 3=>
					lcd_cnt_en <= '1';
					if(lcd_cnt = "111101000010010000") then --Wait 5 ms
						dout <= "000101001";  --Display On command
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 4=>
					lcd_cnt_en <= '0';
					lcd_cnt_rst <= '0';
					spi_go <= '1';
					lstate <= lstate + 1;
				when 5=>
					spi_go <= '0';
					lcd_cnt_rst <= '1';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 6=>
					dout <= "000101100";  --Write Command
			    		lstate <= lstate + 1;
				when 7=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 8=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;					
				when 9=>
					lcd_cnt_en <= '0';
					dout <= "100000000";  -- Write Black (give a background for partial area)
					lstate <= lstate + 1;
				when 10=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 11=>
					spi_go <= '0';
					if(spi_done = '1') then
					    if (lcd_cnt = "011100010110111111") then
						lstate <= lstate + 1;
					    else
						lcd_cnt_en <= '1';
						lstate <= 9;
						end if;
					else
						null;
					end if;	
				when 12=>
					dout <= "000110110"; --Memory Access Control
					lstate <= lstate + 1;
				when 13=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 14=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 15=>
					dout <= "110110000"; --Set Parameter
					lstate <= lstate + 1;
				when 16=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 17=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 18=>
					dout <= "000101010"; --Column Address Set
					lstate <= lstate + 1;
				when 19=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 20=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 21=>
					dout <= "100000000"; --Set Parameter 1 - SC[15:8]
					lstate <= lstate + 1;
				when 22=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 23=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 24=>
					dout <= "100001010"; --Set Parameter 2 - SC[7:0]
					lstate <= lstate + 1;
				when 25=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 26=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 27=>
					dout <= "100000000"; --Set Parameter 3 - EC[15:8]
					lstate <= lstate + 1;
				when 28=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 29=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 30=>
					dout <= "111010001"; --Set Parameter 4 - EC[7:0]
					lstate <= lstate + 1;
				when 31=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 32=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 33=>
					dout <= "000101011"; --Page Address Set
					lstate <= lstate + 1;
				when 34=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 35=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 36=>
					dout <= "100000000"; --Parameter 1 - SP[15:8]
					lstate <= lstate + 1;
				when 37=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 38=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 39=>
					dout <= "100001101"; --Parameter 2 - SP[7:0]
					lstate <= lstate + 1;
				when 40=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 41=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 42=>
					dout <= "100000000"; --Parameter 3 - EP[15:8]
					lstate <= lstate + 1;
				when 43=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 44=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 45=>
					dout <= "110100010"; --Parameter 4 - EP[7:0]
					lstate <= lstate + 1;
				when 46=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 47=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 48=>
					dout <= "000101100";  --Write Command
			    	lstate <= lstate + 1;
				when 49=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 50=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 51=>
					if(frame_begin = '1') then
						lstate <= lstate + 1;
						dis_cs_sig <= '1';
					else
						null;
					end if;
				when 52=>
					if(lcd_go = '1') then
						dout <= parameter & frame_data(7 downto 0);
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 53=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 54=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 55=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 56=>
					spi_go <= '0';
					if(spi_done = '1') then
						lstate <= lstate + 1;
					else
						null;
					end if;
				when 57=>
					spi_go <= '1';
					lstate <= lstate + 1;
				when 58=>
					spi_go <= '0';
					if(spi_done = '1') then
					   if (frame_end = '1') then
							lstate <= 51;
					   else
							lstate <= 52;
						end if;
					else
					    null;
					end if;
				when others=>
					lstate <= 0;
				end case;		
		end if;	
	end if;
end process;
end Behavioral;

