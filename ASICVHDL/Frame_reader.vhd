library IEEE;
library UNISIM;
use UNISIM.VComponents.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.ALL;
entity Frame_reader is
    Port ( 	clk 	: in  STD_LOGIC;	
				rst 	: in  STD_LOGIC;		
				frame_end : out std_logic;
				frame_ready: out std_logic;
				data_available : out STD_LOGIC;
				---- USB ports
				dout 		: out  STD_LOGIC_VECTOR (7 downto 0);
				--END USB stuff
				col_ptr		:out STD_LOGIC_VECTOR(7 downto 0);
				row_ptr		: out STD_LOGIC_VECTOR(7 downto 0);
				rdec_clk		:out  STD_LOGIC;
				rdec_rst		:out  STD_LOGIC;
				row_rst		:out  STD_LOGIC;
				row_sel		:out  STD_LOGIC;
				row_boost	:out  STD_LOGIC;
				--
				cdec_clk		:out  STD_LOGIC;
				cdec_rst		:out  STD_LOGIC;
				col_vln_casc:out  STD_LOGIC;
				col_sh		:out  STD_LOGIC;
				amp_rst		:out  STD_LOGIC;
				comp_rst1	:out  STD_LOGIC;
				comp_rst2	:out  STD_LOGIC;
				coldata 		:in   STD_LOGIC_VECTOR (7 downto 0);
				---	
				i2c_in1		:out  STD_LOGIC;

				--
				adc_clk	:out  STD_LOGIC;
			--	adc_jump	:out  STD_LOGIC;
			--	adc_done	:in   STD_LOGIC;
				ramp_rst	:out  STD_LOGIC;
				ramp_set	:out  STD_LOGIC;
				frame_beginning : OUT STD_LOGIC;
				disable_frame_reader : IN STD_LOGIC
				);
end Frame_reader;

	

architecture Behavioral of Frame_reader is

	
	-------- Frame reader signals
	signal fstate  : integer range 0 to 4095:=0;
--	signal rowptr,colptr : integer range 0 to 255:=0;
	signal rowptr,colptr : STD_LOGIC_VECTOR(7 downto 0);
	--signal fdout:STD_LOGIC_VECTOR (7 downto 0);
	signal cycle_cnt,cdata:STD_LOGIC_VECTOR (9 downto 0);
	constant pstep : integer := 1;
	constant rstep : integer := 1;
	signal cntr : STD_LOGIC_VECTOR(15 downto 0);
	signal cnt_en 	:STD_LOGIC;
	signal rp, cp : STD_LOGIC_VECTOR(7 downto 0);
	
begin

row_ptr <= rowptr;
col_ptr <= colptr;
--adc_jump <= '0';

cntr_proc : process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
			cntr <= (others => '0');
		else
			if(cnt_en = '1') then
				cntr <= cntr + "01";
			else
				cntr <= (others => '0');
			end if;
		end if;
	end if;
end process;
----------------------------------------------------------------------------------------------------
-- Frame Read routine
----------------------------------------------------------------------------------------------------
Frame_FSM: process (clk,rst) is
begin
	if (clk='1' and clk'event) then
		if (rst='0') then
			fstate<=0;
			cnt_en <= '0';
			---
			dout		<="00000000";
			rowptr	<=(others=>'0');
			colptr	<=(others=>'0');	
			------
			i2c_in1<='0';
			rdec_clk		<='0';
			rdec_rst		<='0';
			row_rst		<='0';
			row_sel		<='0';
			row_boost	<='0';
			cdec_clk		<='0';
			cdec_rst		<='0';
			col_vln_casc<='0';
			col_sh		<='0';
			amp_rst		<='0';
			comp_rst1	<='0';
			comp_rst2	<='0';
			adc_clk	<='0';
			ramp_rst	<='0';
			ramp_set	<='0';
			data_available <= '0';
			frame_beginning <= '0';
			--
		else 
			---------------------------------------------------------------------------------------------
			--- FRAME Reader Operation
			---------------------------------------------------------------------------------------------		
			case fstate is
				when  0=>	
								rowptr		<=(others=> '0');
								colptr		<=(others=>'0');	
								i2c_in1		<='0';
								rdec_clk		<='0';
								rdec_rst		<='1';
								row_rst		<='0';
								row_sel		<='0';
								row_boost	<='0';
								cdec_clk		<='0';
								cdec_rst		<='0';
								col_vln_casc<='1';
								col_sh		<='0';
								amp_rst		<='0';
								comp_rst1	<='0';
								comp_rst2	<='0';
								adc_clk		<='0';
								ramp_rst		<='1';
								ramp_set		<='0';
								frame_beginning <= '1';
								----
								data_available <= '0';
								---
								fstate<=fstate+1;
				when 	 6=>	
								i2c_in1	<='1';
								fstate<=fstate+1;								
				when 	 9=>	
								rdec_rst	<='0'; 
								fstate<=fstate+1;
				-------------------------------------
				--- Row repeat return point
				-------------------------------------	
				when  13=>	
								frame_beginning <= '0';
								ramp_set		<='0';
								rdec_clk		<='1';
								col_vln_casc<='1';
								fstate<=fstate+1;				
				when 	16=>
								i2c_in1	<='0';
								rdec_clk	<='0';
								row_sel	<='1';
								cdec_rst		<='1';
								col_sh		<='1';
								amp_rst		<='1';
								comp_rst1	<='1';
								comp_rst2	<='1';
								ramp_rst		<='1';
								fstate<=fstate+1;	
				when  20=>	
								cdec_rst		<='0';
								fstate<=fstate+1;	
				when 	48=>	
								comp_rst2	<='0';
								fstate<=fstate+1;								
				when 	64=>	
								comp_rst1	<='0';
								fstate<=fstate+1;	
				when  88=>	
								amp_rst		<='0';
								row_rst		<='1';
								fstate<=fstate+1;	
				when  103=>	
								row_boost	<='1';
								fstate<=fstate+1;
				when 120=>	
								row_boost	<='0';				
								fstate<=fstate+1;	
				when 156=>	
								col_sh		<='0';
								fstate<=fstate+1;	
				when 159=>	
								cycle_cnt	<="0000000000";
								fstate<=fstate+1;		
				-------------------------------------
				--- ADC repeat return point
				-------------------------------------															
				when 160=>	
								col_vln_casc<='0';
								row_rst		<='0';
								row_sel		<='0';
								adc_clk 		<='0';
								fstate<=fstate+pstep;	
				when 173=>	
								ramp_rst		<='0';
								fstate<=fstate+pstep;	
				when 176=>	
								adc_clk		<='1';
								fstate<=fstate+pstep;	
				when 191=>	
								adc_clk		<='1';
								if (cycle_cnt="1111111111") then 	
									fstate<=fstate+1;	
								else 	cycle_cnt<=cycle_cnt+1; 
									fstate<=160;	
								end if;
				when 196=>	
								i2c_in1		<='1';
								colptr		<=(others=>'0');
								cdec_clk<='0';
								fstate<=fstate+1;	
				-------------------------------------
				--- Column read return point
				-------------------------------------								
				when 200=>	
								cdec_clk		<='1';
								ramp_set		<='1';
								cnt_en <= '1';
								if(cntr = "101011") then
									cnt_en <= '0';
									fstate <= fstate + 1;
								end if;
				when 203=>	
								dout	<=coldata; --send upper 8bits
								data_available <= '1';
								fstate<=fstate+1;	
				when 205=> 
								fstate <= fstate + 1; 
								data_available <= '0'; 
				when 206=>	
								cdec_clk	<='0';
								i2c_in1<='0';								
								fstate<=fstate+1;
								data_available <= '0';
				when 212=>	
								if (colptr="11000111") then	fstate<=fstate+1;	
								else 	colptr<=colptr+"01";
									fstate<=199;
								end if;
								data_available <= '0';
				-------------------------------------
				--- check frame range
				-------------------------------------								
				when 213=>										
								fstate<=fstate+1;	
								ramp_set		<='1';					
				when 214=>	
								if (rowptr="10010101") then		
									  col_vln_casc<='1';
									  fstate<=fstate+1;
									  frame_end <= '1';
								else
									rowptr<=rowptr+"01";
									fstate<=8;	
								end if;
				-------------------------------------
				--- END OF FRAME - Sent FPS counter/speed to USB2
				-------------------------------------	
				when 233=> 
					--		if(disable_frame_reader = '0') then
								fstate<=fstate+1;	
					--		end if;
								frame_end <= '0';
				when 234=>	
								fstate<=0;
				-------------------------------------
				when others=> 
								fstate<=fstate+1;
			end case;
		end if;
	end if;
end process Frame_FSM;
----------------------------------------------------------------------------------------------------
-- End of Frame Read Routione
----------------------------------------------------------------------------------------------------
	
end Behavioral;