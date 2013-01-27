----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:00:13 10/18/2012 
-- Design Name: 
-- Module Name:    iDAC_Loader_FSM - Behavioral 
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

entity iDAC_Loader_FSM is
	PORT
	(
		clk	:	IN STD_LOGIC;
		rst	: 	IN STD_LOGIC;
		idac_busy	: OUT STD_LOGIC;
		i2c_clk		: OUT STD_LOGIC;
		i2c_in2		: OUT STD_LOGIC;
		i2c_rstb		: OUT STD_LOGIC;
	--	ref_pwron	: OUT STD_LOGIC;
		idac_update_en	: IN STD_LOGIC;		
		reg_p9 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p10 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p11 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p12 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p13 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p14 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p15 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p16 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p17 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p18 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p19 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p20 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p21 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p22 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p23 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p24 		: IN STD_LOGIC_VECTOR(7 downto 0);
		reg_p25 		: IN STD_LOGIC_VECTOR(7 downto 0)
	);
end iDAC_Loader_FSM;

architecture Behavioral of iDAC_Loader_FSM is
signal idacstate 	:	integer range 0 to 511;
begin
iDAC_Loader_FSM: process (clk,rst,idac_update_en) is
begin
	if (clk='1' and clk'event) then
		if (rst='0') then
			idac_busy<='0'; -- IDAC routine is not busy
			idacstate<=0;
			i2c_in2<='0'; 			
			i2c_clk<='0';
			i2c_rstb<='1'; -- active low reset
			--ref_pwron<='0';
		elsif (idac_update_en='1') then 
				case idacstate is
					when    0=>	idac_busy<='1';-- IDAC routine is busy
									i2c_clk<='0';
									i2c_in2<='0';
									i2c_rstb<='0'; -- reset idac
							--		ref_pwron<='0';-- power OFF reference generator during update
									idacstate<=idacstate+1;
					when    2=>	i2c_rstb<='1';	i2c_in2<=reg_p23(1);	idacstate<=idacstate+1;-- sslar_override
					when    4=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when    6=>	i2c_clk<='0';	i2c_in2<=reg_p21(6);	idacstate<=idacstate+1;-- step6
					when    8=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   10=>	i2c_clk<='0';	i2c_in2<=reg_p21(5);	idacstate<=idacstate+1;-- step5
					when   12=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   14=>	i2c_clk<='0';	i2c_in2<=reg_p21(4);	idacstate<=idacstate+1;-- step4
					when   16=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   18=>	i2c_clk<='0';	i2c_in2<=reg_p21(3);	idacstate<=idacstate+1;-- step3
					when   20=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   22=>	i2c_clk<='0';	i2c_in2<=reg_p21(2);	idacstate<=idacstate+1;-- step2
					when   24=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   26=>	i2c_clk<='0';	i2c_in2<=reg_p21(1);	idacstate<=idacstate+1;-- step1
					when   28=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   30=>	i2c_clk<='0';	i2c_in2<=reg_p21(0);	idacstate<=idacstate+1;-- step0
					when   32=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   34=>	i2c_clk<='0';	i2c_in2<=reg_p22(0);	idacstate<=idacstate+1;-- magdec0
					when   36=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   38=>	i2c_clk<='0';	i2c_in2<=reg_p22(1);	idacstate<=idacstate+1;-- magdec1
					when   40=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   42=>	i2c_clk<='0';	i2c_in2<=reg_p22(2);	idacstate<=idacstate+1;-- magdec2
					when   44=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   46=>	i2c_clk<='0';	i2c_in2<=reg_p20(5);	idacstate<=idacstate+1;-- mag_bias5
					when   48=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   50=>	i2c_clk<='0';	i2c_in2<=reg_p20(4);	idacstate<=idacstate+1;-- mag_bias4
					when   52=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   54=>	i2c_clk<='0';	i2c_in2<=reg_p20(3);	idacstate<=idacstate+1;-- mag_bias3
					when   56=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   58=>	i2c_clk<='0';	i2c_in2<=reg_p20(2);	idacstate<=idacstate+1;-- mag_bias2
					when   60=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   62=>	i2c_clk<='0';	i2c_in2<=reg_p20(1);	idacstate<=idacstate+1;-- mag_bias1
					when   64=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   66=>	i2c_clk<='0';	i2c_in2<=reg_p20(0);	idacstate<=idacstate+1;-- mag_bias0			
					when   68=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   70=>	i2c_clk<='0';	i2c_in2<=reg_p19(5);	idacstate<=idacstate+1;-- event_bias5
					when   72=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   74=>	i2c_clk<='0';	i2c_in2<=reg_p19(4);	idacstate<=idacstate+1;-- event_bias4
					when   76=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   78=>	i2c_clk<='0';	i2c_in2<=reg_p19(3);	idacstate<=idacstate+1;-- event_bias3
					when   80=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   82=>	i2c_clk<='0';	i2c_in2<=reg_p19(2);	idacstate<=idacstate+1;-- event_bias2
					when   84=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   86=>	i2c_clk<='0';	i2c_in2<=reg_p19(1);	idacstate<=idacstate+1;-- event_bias1
					when   88=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   90=>	i2c_clk<='0';	i2c_in2<=reg_p19(0);	idacstate<=idacstate+1;-- event_bias0								
					when   92=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   94=>	i2c_clk<='0';	i2c_in2<=reg_p18(5);	idacstate<=idacstate+1;-- vln5
					when   96=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   98=>	i2c_clk<='0';	i2c_in2<=reg_p18(4);	idacstate<=idacstate+1;-- vln4
					when  100=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  102=>	i2c_clk<='0';	i2c_in2<=reg_p18(3);	idacstate<=idacstate+1;-- vln3
					when  104=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  106=>	i2c_clk<='0';	i2c_in2<=reg_p18(2);	idacstate<=idacstate+1;-- vln2
					when  108=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  110=>	i2c_clk<='0';	i2c_in2<=reg_p18(1);	idacstate<=idacstate+1;-- vln1
					when  112=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  114=>	i2c_clk<='0';	i2c_in2<=reg_p18(0);	idacstate<=idacstate+1;-- vln0
					when  116=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  118=>	i2c_clk<='0';	i2c_in2<=reg_p17(5);	idacstate<=idacstate+1;-- amp_bias5
					when  120=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  122=>	i2c_clk<='0';	i2c_in2<=reg_p17(4);	idacstate<=idacstate+1;-- amp_bias4
					when  124=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  126=>	i2c_clk<='0';	i2c_in2<=reg_p17(3);	idacstate<=idacstate+1;-- amp_bias3
					when  128=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  130=>	i2c_clk<='0';	i2c_in2<=reg_p17(2);	idacstate<=idacstate+1;-- amp_bias2
					when  132=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  134=>	i2c_clk<='0';	i2c_in2<=reg_p17(1);	idacstate<=idacstate+1;-- amp_bias1
					when  136=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  138=>	i2c_clk<='0';	i2c_in2<=reg_p17(0);	idacstate<=idacstate+1;-- amp_bias0	
					when  140=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  142=>	i2c_clk<='0';	i2c_in2<=reg_p16(5);	idacstate<=idacstate+1;-- comp_bias5
					when  144=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  146=>	i2c_clk<='0';	i2c_in2<=reg_p16(4);	idacstate<=idacstate+1;-- comp_bias4
					when  148=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  150=>	i2c_clk<='0';	i2c_in2<=reg_p16(3);	idacstate<=idacstate+1;-- comp_bias3
					when  152=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  154=>	i2c_clk<='0';	i2c_in2<=reg_p16(2);	idacstate<=idacstate+1;-- comp_bias2
					when  156=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  158=>	i2c_clk<='0';	i2c_in2<=reg_p16(1);	idacstate<=idacstate+1;-- comp_bias1
					when  160=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  162=>	i2c_clk<='0';	i2c_in2<=reg_p16(0);	idacstate<=idacstate+1;-- comp_bias0	
					when  164=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  166=>	i2c_clk<='0';	i2c_in2<=reg_p15(5);	idacstate<=idacstate+1;-- iref_out5
					when  168=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  170=>	i2c_clk<='0';	i2c_in2<=reg_p15(4);	idacstate<=idacstate+1;-- iref_out4
					when  172=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  174=>	i2c_clk<='0';	i2c_in2<=reg_p15(3);	idacstate<=idacstate+1;-- iref_out3
					when  176=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  178=>	i2c_clk<='0';	i2c_in2<=reg_p15(2);	idacstate<=idacstate+1;-- iref_out2
					when  180=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  182=>	i2c_clk<='0';	i2c_in2<=reg_p15(1);	idacstate<=idacstate+1;-- iref_out1
					when  184=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  186=>	i2c_clk<='0';	i2c_in2<=reg_p15(0);	idacstate<=idacstate+1;-- iref_out0	
					when  188=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  190=>	i2c_clk<='0';	i2c_in2<=reg_p10(0);	idacstate<=idacstate+1;-- ref_gen0
					when  192=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  194=>	i2c_clk<='0';	i2c_in2<=reg_p10(1);	idacstate<=idacstate+1;-- ref_gen1
					when  196=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  198=>	i2c_clk<='0';	i2c_in2<=reg_p10(2);	idacstate<=idacstate+1;-- ref_gen2	
					when  200=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  202=>	i2c_clk<='0';	i2c_in2<=reg_p13(0);	idacstate<=idacstate+1;-- wat_0
					when  204=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  206=>	i2c_clk<='0';	i2c_in2<=reg_p13(1);	idacstate<=idacstate+1;-- wat_1
					when  208=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  210=>	i2c_clk<='0';	i2c_in2<=reg_p13(2);	idacstate<=idacstate+1;-- wat_2
					when  212=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  214=>	i2c_clk<='0';	i2c_in2<=reg_p13(3);	idacstate<=idacstate+1;-- wat_3
					when  216=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  218=>	i2c_clk<='0';	i2c_in2<=reg_p13(4);	idacstate<=idacstate+1;-- wat_4
					when  220=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  222=>	i2c_clk<='0';	i2c_in2<=reg_p13(5);	idacstate<=idacstate+1;-- wat_5
					when  224=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  226=>	i2c_clk<='0';	i2c_in2<=reg_p13(6);	idacstate<=idacstate+1;-- wat_6
					when  228=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  230=>	i2c_clk<='0';	i2c_in2<=reg_p13(7);	idacstate<=idacstate+1;-- wat_7
					when  232=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  234=>	i2c_clk<='0';	i2c_in2<=reg_p14(0);	idacstate<=idacstate+1;-- wat_8
					when  236=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  238=>	i2c_clk<='0';	i2c_in2<=reg_p14(1);	idacstate<=idacstate+1;-- wat_9
					when  240=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  242=>	i2c_clk<='0';	i2c_in2<=reg_p23(0);	idacstate<=idacstate+1;-- watermark_en
					when  244=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  246=>	i2c_clk<='0';	i2c_in2<=reg_p12(1);	idacstate<=idacstate+1;-- cryp9
					when  248=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  250=>	i2c_clk<='0';	i2c_in2<=reg_p12(0);	idacstate<=idacstate+1;-- cryp8
					when  252=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  254=>	i2c_clk<='0';	i2c_in2<=reg_p11(7);	idacstate<=idacstate+1;-- cryp7
					when  256=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  258=>	i2c_clk<='0';	i2c_in2<=reg_p11(6);	idacstate<=idacstate+1;-- cryp6
					when  260=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  262=>	i2c_clk<='0';	i2c_in2<=reg_p11(5);	idacstate<=idacstate+1;-- cryp5
					when  264=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  266=>	i2c_clk<='0';	i2c_in2<=reg_p11(4);	idacstate<=idacstate+1;-- cryp4
					when  268=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  270=>	i2c_clk<='0';	i2c_in2<=reg_p11(3);	idacstate<=idacstate+1;-- cryp3
					when  272=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  274=>	i2c_clk<='0';	i2c_in2<=reg_p11(2);	idacstate<=idacstate+1;-- cryp2
					when  276=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  278=>	i2c_clk<='0';	i2c_in2<=reg_p11(1);	idacstate<=idacstate+1;-- cryp1
					when  280=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  282=>	i2c_clk<='0';	i2c_in2<=reg_p11(0);	idacstate<=idacstate+1;-- cryp0
					when  284=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  286=>	i2c_clk<='0';	i2c_in2<=reg_p9(2);	idacstate<=idacstate+1;-- gain2
					when  288=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  290=>	i2c_clk<='0';	i2c_in2<=reg_p9(1);	idacstate<=idacstate+1;-- gain1
					when  292=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  294=>	i2c_clk<='0';	i2c_in2<=reg_p9(0);	idacstate<=idacstate+1;-- gain0
					when  296=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  298=>	i2c_clk<='0';	
					--				ref_pwron<='1'; -- power ON/OFF reference generator
									i2c_in2<='0';
									idacstate	<=idacstate+1;
					when  300=>	idac_busy	<='0';	  -- IDAC routine is not busy
									idacstate<=idacstate+1;
					when others=> idacstate<=idacstate+1;
				end case;
		else	
			i2c_clk<='0';
			i2c_rstb<='1';
			i2c_in2<='0';
		--	ref_pwron<='1'; -- ALWAYS power ON reference generator
			idac_busy<='0'; -- IDAC routine is not busy
			idacstate<=0;
		end if;
	end if;
end process iDAC_Loader_FSM;

end Behavioral;

