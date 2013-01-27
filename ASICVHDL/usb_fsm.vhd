----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:26:33 10/18/2012 
-- Design Name: 
-- Module Name:    usb_fsm - Behavioral 
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

entity usb_fsm is
	port 
	(
			clk 	  		: in  STD_LOGIC;	
			rst 	  		: in  STD_LOGIC;
			pdac_data	: OUT STD_LOGIC_VECTOR(23 downto 0);
			pdac_busy	:	IN STD_LOGIC;
			idac_busy	:	IN STD_LOGIC;
			pdac_update_en	:	OUT STD_LOGIC;
			idac_update_en	:	OUT STD_LOGIC;
			usb_go		: OUT STD_LOGIC;
			usb_done		: IN STD_LOGIC;
			usb_busy		: IN STD_LOGIC;
			usb_dir		: OUT STD_LOGIC;
			usb_dout		: IN	STD_LOGIC_VECTOR ( 7 downto 0);
			usb_din		:	OUT STD_LOGIC_VECTOR(7 downto 0);
			frame_data	: IN STD_LOGIC_VECTOR(7 downto 0);
			frame_data_ready	: IN STD_LOGIC;
			frame_beginning	: IN STD_LOGIC;
			frame_end			: IN STD_LOGIC;
			reg_p1  		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p2  		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p3  		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p4  		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p5  		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p6  		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p7  		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p8  		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p9  		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p10 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p11 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p12 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p13 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p14 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p15 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p16 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p17 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p18 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p19 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p20 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p21 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p22 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p23 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p24 		: OUT STD_LOGIC_VECTOR(7 downto 0);
			reg_p25 		: OUT STD_LOGIC_VECTOR(7 downto 0)
	);

end usb_fsm;

architecture Behavioral of usb_fsm is
signal ustate : integer range 0 to 31;
signal reg_ptr : integer range 0 to 127;

signal int_reg_p1  		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p2  		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p3  		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p4  		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p5  		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p6  		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p7  		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p8  		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p9  		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p10 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p11 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p12 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p13 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p14 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p15 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p16 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p17 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p18 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p19 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p20 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p21 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p22 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p23 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p24 		: STD_LOGIC_VECTOR(7 downto 0);
signal int_reg_p25 		: STD_LOGIC_VECTOR(7 downto 0);

begin
reg_p1 <= int_reg_p1;
reg_p2 <= int_reg_p2;
reg_p3 <= int_reg_p3;
reg_p4 <= int_reg_p4;
reg_p5 <= int_reg_p5;
reg_p6 <= int_reg_p6;
reg_p7 <= int_reg_p7;
reg_p8 <= int_reg_p8;
reg_p9 <= int_reg_p9;
reg_p10 <= int_reg_p10;
reg_p11 <= int_reg_p11;
reg_p12 <= int_reg_p12;
reg_p13 <= int_reg_p13;
reg_p14 <= int_reg_p14;
reg_p15 <= int_reg_p15;
reg_p16 <= int_reg_p16;
reg_p17 <= int_reg_p17;
reg_p18 <= int_reg_p18;
reg_p19 <= int_reg_p19;
reg_p20 <= int_reg_p20;
reg_p21 <= int_reg_p21;
reg_p22 <= int_reg_p22;
reg_p23 <= int_reg_p23;
reg_p24 <= int_reg_p24;
reg_p25 <= int_reg_p25;

USB_FSM : process (clk) is
begin
	if (clk='1' and clk'event) then
		if (rst='0') then	
			ustate	<=0;
			reg_ptr  <=0;
			int_reg_p1   <=X"99";
			int_reg_p2   <=X"93";
			int_reg_p3   <=X"C0";
			int_reg_p4   <=X"16";
			int_reg_p5   <=X"67";
			int_reg_p6   <=X"AB";
			int_reg_p7   <=X"67";
			int_reg_p8   <=X"AB";
			int_reg_p9   <=X"01";
			int_reg_p10  <=X"00";
			int_reg_p11  <=X"00";
			int_reg_p12  <=X"00";
			int_reg_p13  <=X"00";
			int_reg_p14  <=X"00";
			int_reg_p15  <=X"00";	
			int_reg_p16  <=X"02";	
			int_reg_p17  <=X"1E";
			int_reg_p18  <=X"02";
			int_reg_p19  <=X"30";
			int_reg_p20  <=X"00";
			int_reg_p21  <=X"08";
			int_reg_p22  <=X"00";
			int_reg_p23  <=X"26";
			int_reg_p24  <=X"05";
			int_reg_p25  <=X"08";
						---
			pdac_data		<="000000000000000000000000";
			pdac_update_en	<='0';
			--
			idac_update_en	<='0';
			usb_go <= '0';
			usb_dir <= '1';
		else
			case ustate is  
				-------------------------------------------------------
				--- main listening rutine
				-------------------------------------------------------
				when 0 => --wait for a read command	
					ustate <= ustate + 1; 
					usb_dir <= '1'; 
					usb_go <= '0';
				when 1 =>					
					usb_go <= '1';
					usb_dir <= '1';				
					ustate<=ustate+1;	
				when 2 => 
					usb_go<= '0';
					reg_ptr<=0;		
					if(usb_busy = '0' or usb_done = '1') then							
						if(usb_dout = "11111111") then 
							ustate <= 8; 
							usb_dir <= '1';
						elsif ( usb_dout = "00001111") then 
							ustate <= 18;
							usb_dir <= '0';
						else 
							ustate <= 0;
						end if;
					end if; 
				-------------------------------------------------------	
				---- PDAC and IDAC update rutine	for data=FF
				-------------------------------------------------------
				when 8 => 
					usb_go <= '1';								
					usb_dir <= '1';
					pdac_update_en<='0'; 
					idac_update_en<='0';
					ustate <= ustate + 1;	
				when 9=> 
					ustate <= ustate + 1;
				when 10=>
					ustate <= ustate + 1;									
				when 11 =>
					if(usb_done = '1') then							
						ustate <= ustate + 1;
					end if;
				when 13=> 	
					ustate<=ustate+1;							
				when 14 => 	
					case reg_ptr is--- get 25 program  data
						--Update PDAC Channel A
						when 0=>	
							int_reg_p1 <= usb_dout;
							reg_ptr <= reg_ptr + 1;
							usb_go <= '0';
							ustate <= 8;
						when 1=>
							int_reg_p2 <= usb_dout;
							reg_ptr <= reg_ptr + 1;
							ustate <= 8;
							usb_go <= '0';	
						when 2=>		
							pdac_data(15 downto 8)	<=int_reg_p1(7 downto 0);
							pdac_data(7 downto 0) 	<=int_reg_p2(7 downto 0);
							pdac_data(23 downto 16)	<="10011000"; 
							pdac_update_en<='1';-- request PDAC update, ChA
							reg_ptr<=reg_ptr+1;
						when 3=>		
							reg_ptr<=reg_ptr+1; --wait one clk cycle for PDAC routine to respond
						when 4=>		
							if pdac_busy='1' then 
								reg_ptr<=reg_ptr+1; 
							end if;
						when 5=>	--Update PDAC Channel B	
							if pdac_busy='0' then 
								pdac_update_en<='0';
								reg_ptr<=reg_ptr+1; 	
								ustate<=8;
							end if;								
						
						when 6=>	
							int_reg_p3 <= usb_dout;
							reg_ptr <= reg_ptr + 1;
							ustate <= 8;
							usb_go <= '0';
						when 7=>
							int_reg_p4 <= usb_dout;
							reg_ptr <= reg_ptr + 1;
							ustate <= 8;
							usb_go <= '0';
						when 8=>	
							pdac_data(15 downto 8)	<=int_reg_p3(7 downto 0);
							pdac_data(7 downto 0) 	<=int_reg_p4(7 downto 0);
							pdac_data(23 downto 16)	<="10011001"; 
							pdac_update_en<='1';-- request PDAC update, ChB
							reg_ptr<=reg_ptr+1;
						when 9=>	
							reg_ptr<=reg_ptr+1; --wait one clk cycle for PDAC routine to respond
						when 10=>	
							if pdac_busy='1' then 
								reg_ptr<=reg_ptr+1; 
							end if;
						when 11=>--Update PDAC Channel C	
							if pdac_busy='0' then 
								pdac_update_en<='0';
								reg_ptr<=reg_ptr+1; 	
								ustate<=8;
							end if;									
						when 12=>
							int_reg_p5 <= usb_dout;
							reg_ptr <= reg_ptr + 1;
							ustate <= 8;
							usb_go <= '0';
						when 13=>
							int_reg_p6 <= usb_dout;
							reg_ptr <= reg_ptr + 1;
							ustate <= 8;
							usb_go <= '0';
						when 14=> 	
							pdac_data(15 downto 8)	<=int_reg_p5(7 downto 0);
							pdac_data(7 downto 0) 	<=int_reg_p6(7 downto 0);
							pdac_data(23 downto 16)	<="10011010";
							pdac_update_en<='1';-- request PDAC update, ChC
							reg_ptr<=reg_ptr+1;
					when 15=>	
							reg_ptr<=reg_ptr+1; --wait one clk cycle for PDAC routine to respond
						when 16=>	
							if pdac_busy='1' then 
								reg_ptr<=reg_ptr+1; 
							end if;
						when 17=>	
							if pdac_busy='0' then 
								pdac_update_en<='0';
								reg_ptr<=reg_ptr+1; 	
								ustate<=8;
							end if;
						--Update PDAC Channel D
						when 18=>
								int_reg_p7 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 19=>
								int_reg_p8 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 20=> 	
								pdac_data(15 downto 8)	<=int_reg_p7(7 downto 0); 
								pdac_data(7 downto 0) 	<=int_reg_p8(7 downto 0);
								pdac_data(23 downto 16)	<="10011011";
								pdac_update_en<='1'; -- request PDAC update, ChD
								reg_ptr<=reg_ptr+1;
						when 21=>	
								reg_ptr<=reg_ptr+1; --wait one clk cycle for PDAC routine to respond
						when 22=>	
								if (pdac_busy='1') then 
									reg_ptr<=reg_ptr+1; 
								end if;
						when 23=>
								if (pdac_busy='0') then 
									pdac_update_en<='0';
									reg_ptr<=reg_ptr+1;
									ustate<=8; 
								end if;							
						---- get rest of the program registers
						when 24=>
								int_reg_p9 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 25=>
								int_reg_p10 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 26=>
								int_reg_p11 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 27=>
								int_reg_p12 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 28=>
								int_reg_p13 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 29=>
								int_reg_p14 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 30=>
								int_reg_p15 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 31=>
								int_reg_p16 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 32=>
								int_reg_p17 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 33=>
								int_reg_p18 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 34=>
								int_reg_p19 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 35=>
								int_reg_p20 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 36=>
								int_reg_p21 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 37=>
								int_reg_p22 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 38=>
								int_reg_p23 <=usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 39=>
								int_reg_p24 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								ustate <= 8;
								usb_go <= '0';
						when 40=>
								int_reg_p25 <= usb_dout;
								reg_ptr <= reg_ptr + 1;
								idac_update_en<='1';	-- Assume idac_update rutine will responded in one clock
								ustate<=15;
								usb_go <= '0';
										
						when others=> reg_ptr<=reg_ptr+1;
					end case;	
				when 15 => 	ustate<=ustate+1;
				when 16 => 	if (idac_busy='0') then 
									idac_update_en<='0';	
									ustate<=0; 
								else 
									idac_update_en<='1'; 
								end if;
				---------------------------------------------------------------------------	
				-- frame read rutine for first data=0F
				---------------------------------------------------------------------------
				when 18 	=> 
								usb_go <= '0';
								if(frame_beginning = '1') then	
									ustate <= ustate + 1;	
								end if;
				when 19=>
							usb_go <= '0';
							if( frame_data_ready = '1') then
								usb_dir <= '0';
								usb_go <= '1';
								usb_din <= frame_data;
							elsif(frame_end='1') then	
									ustate<=0;  -- end frame read, go listening mode	
							end if;	
				---------------------------------------------------------------------------
				when others=>	ustate<=ustate+1;
			end case;
		end if;
	else
		null;
	end if;
end process USB_FSM;

end Behavioral;

