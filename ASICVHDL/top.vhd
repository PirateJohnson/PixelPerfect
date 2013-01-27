----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:22:53 10/18/2012 
-- Design Name: 
-- Module Name:    top - Behavioral 
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
--library UNISIM;
library IEEE;
--use UNISIM.VComponents.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity top is
Port ( 		MCLK 	: in  STD_LOGIC;	--MCLK
				MRST 	: in  STD_LOGIC;	--MRST

				--LCD Ports 
				CS : OUT STD_LOGIC;	--
				SDA : OUT STD_LOGIC;--
				SCL : OUT STD_LOGIC;--
				
				---- USB ports
				FT_TXE 	: in  STD_LOGIC;	--
				FT_RXF 	: in  STD_LOGIC;--
				FT_WR 	: out  STD_LOGIC;	--FT_WR	--
				FT_RD 	: out  STD_LOGIC;	--FT_RD--
				--FT_D 		: inout  STD_LOGIC_VECTOR (7 downto 0);--
				FT_DIN	: IN STD_LOGIC_VECTOR(7 downto 0);
				FT_DOUT	: OUT STD_LOGIC_VECTOR(7 downto 0);
				FT_DIR 	: OUT STD_LOGIC;		--		
				
				
				--Tx ports				
				SCK		: out STD_LOGIC;--
				MOSI		: out STD_LOGIC;--
				MISO		: in STD_LOGIC;--
				CSN		: out STD_LOGIC;--
				CE			: out STD_LOGIC;--
				
				--SSLAR ports
				RDEC_CLK		:out  STD_LOGIC;--
				RDEC_RST		:out  STD_LOGIC;--
				ROW_RST		:OUT  STD_LOGIC;--
				ROW_SEL		:OUT  STD_LOGIC;--
				ROW_BOOST	:OUT  STD_LOGIC;--
				CDEC_CLK		:OUT  STD_LOGIC;--
				CDEC_RST		:OUT  STD_LOGIC;--
				COL_VLN_CASC:OUT  STD_LOGIC;--
				COL_SH		:OUT  STD_LOGIC;--
				AMP_RST		:OUT  STD_LOGIC;--
				COMP_RST1	:OUT  STD_LOGIC;--
				COMP_RST2	:OUT  STD_LOGIC;--
				DATA 			:IN   STD_LOGIC_VECTOR (7 DOWNTO 0);--
			--	REF_PWRON	:OUT  STD_LOGIC;
				I2C_RSTB		:OUT  STD_LOGIC;--
				I2C_CLK		:OUT  STD_LOGIC;---
				I2C_IN		:OUT  STD_LOGIC;--
				ADC_CLK	:OUT  STD_LOGIC;--
			--	ADC_JUMP	:OUT  STD_LOGIC;
			--	ADC_DONE	:IN   STD_LOGIC;
				RAMP_RST	:OUT  STD_LOGIC;--
				RAMP_SET	:OUT  STD_LOGIC;--
				PDAC_CLK	:OUT  STD_LOGIC; --
				PDAC_SIN	:OUT  STD_LOGIC;--
				PDAC_SYNC:OUT  STD_LOGIC);--
end top;
	
architecture Behavioral of top is
	COMPONENT LCD_Controller
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		lcd_go : IN std_logic;
		frame_data : IN std_logic_vector(7 downto 0);
		frame_begin : IN std_logic;
		frame_end : IN std_logic;    
		sda : OUT std_logic;      
		scl : OUT std_logic;
		cs : OUT std_logic
		);
	END COMPONENT;
COMPONENT usb_controller_mux
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		go : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);
		dir : IN std_logic;
		txe : IN std_logic;
		rxf : IN std_logic;
		ftdi_din : IN std_logic_vector(7 downto 0);          
		done : OUT std_logic;
		data_out : OUT std_logic_vector(7 downto 0);
		busy : OUT std_logic;
		rd : OUT std_logic;
		wr : OUT std_logic;
		ftdi_dout : OUT std_logic_vector(7 downto 0);
		dbg : OUT std_logic_vector(2 downto 0)
		);
	END COMPONENT;
	COMPONENT usb_fsm
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		pdac_busy : IN std_logic;
		idac_busy : IN std_logic;
		usb_done : IN std_logic;
		usb_busy : IN std_logic;
		usb_dout : IN std_logic_vector(7 downto 0);
		frame_data : IN std_logic_vector(7 downto 0);
		frame_data_ready : IN std_logic;
		frame_beginning : IN std_logic;
		frame_end : IN std_logic;          
		pdac_data : OUT std_logic_vector(23 downto 0);
		pdac_update_en : OUT std_logic;
		idac_update_en : OUT std_logic;
		usb_go : OUT std_logic;
		usb_dir : OUT std_logic;
		usb_din : OUT std_logic_vector(7 downto 0);
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
	END COMPONENT;
	COMPONENT DAC_Loader_FSM
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		pdac_update_en : IN std_logic;
		pdac_data : IN std_logic_vector(23 downto 0);          
		pdac_clk : OUT std_logic;
		pdac_sin : OUT std_logic;
		pdac_sync : OUT std_logic;
		pdac_busy : OUT std_logic
		);
	END COMPONENT;
	COMPONENT iDAC_Loader_FSM
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		idac_update_en : IN std_logic;
		reg_p9 : IN std_logic_vector(7 downto 0);
		reg_p10 : IN std_logic_vector(7 downto 0);
		reg_p11 : IN std_logic_vector(7 downto 0);
		reg_p12 : IN std_logic_vector(7 downto 0);
		reg_p13 : IN std_logic_vector(7 downto 0);
		reg_p14 : IN std_logic_vector(7 downto 0);
		reg_p15 : IN std_logic_vector(7 downto 0);
		reg_p16 : IN std_logic_vector(7 downto 0);
		reg_p17 : IN std_logic_vector(7 downto 0);
		reg_p18 : IN std_logic_vector(7 downto 0);
		reg_p19 : IN std_logic_vector(7 downto 0);
		reg_p20 : IN std_logic_vector(7 downto 0);
		reg_p21 : IN std_logic_vector(7 downto 0);
		reg_p22 : IN std_logic_vector(7 downto 0);
		reg_p23 : IN std_logic_vector(7 downto 0);
		reg_p24 : IN std_logic_vector(7 downto 0);
		reg_p25 : IN std_logic_vector(7 downto 0);          
		idac_busy : OUT std_logic;
		i2c_clk : OUT std_logic;
		i2c_in2 : OUT std_logic;
		i2c_rstb : OUT std_logic
	--	ref_pwron : OUT std_logic
		);
	END COMPONENT;
	COMPONENT Frame_reader
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		coldata : IN std_logic_vector(7 downto 0);
	--	adc_done : IN std_logic;
		disable_frame_reader : IN std_logic;          
		frame_end : OUT std_logic;
		frame_ready : OUT std_logic;
		data_available : OUT std_logic;
		dout : OUT std_logic_vector(7 downto 0);
		col_ptr : OUT std_logic_vector(7 downto 0);
		row_ptr : out std_logic_vector(7 downto 0);
		rdec_clk : OUT std_logic;
		rdec_rst : OUT std_logic;
		row_rst : OUT std_logic;
		row_sel : OUT std_logic;
		row_boost : OUT std_logic;
		cdec_clk : OUT std_logic;
		cdec_rst : OUT std_logic;
		col_vln_casc : OUT std_logic;
		col_sh : OUT std_logic;
		amp_rst : OUT std_logic;
		comp_rst1 : OUT std_logic;
		comp_rst2 : OUT std_logic;
		i2c_in1 : OUT std_logic;
		adc_clk : OUT std_logic;
	--	adc_jump : OUT std_logic;
		ramp_rst : OUT std_logic;
		ramp_set : OUT std_logic;
		frame_beginning : OUT std_logic
		);
	END COMPONENT;

	COMPONENT spitx
	PORT(
		frame_data : IN std_logic_vector(7 downto 0);
		column_data : IN std_logic_vector(7 downto 0);
		row_data : IN std_logic_vector(7 downto 0);
		DA : IN std_logic;
		clk : IN std_logic;
		rst : IN std_logic;          
		MOSI : OUT std_logic;
		CS : OUT std_logic;
		SCK : OUT std_logic
		);
	END COMPONENT;
	signal reg_p1  		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p2  		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p3  		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p4  		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p5  		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p6  		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p7  		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p8  		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p9  		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p10 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p11 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p12 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p13 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p14 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p15 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p16 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p17 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p18 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p19 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p20 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p21 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p22 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p23 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p24 		: STD_LOGIC_VECTOR(7 downto 0);
	signal reg_p25 		: STD_LOGIC_VECTOR(7 downto 0);
	
	signal pdac_update_en, 
				pdac_busy, 
				idac_busy, 
				idac_update_en,
				usb_go,
				usb_done,
				usb_busy,
				usb_dir,
				frame_data_ready,
				frame_beginning,
				frame_ready,
				i2c_in1,
				i2c_in2,
				dir,
				frame_end : STD_LOGIC;
	signal pdac_data : STD_LOGIC_VECTOR(23 downto 0);
	signal usb_din, usb_dout, frame_data, dout, din: STD_LOGIC_VECTOR(7 downto 0);
	signal usb_dbg : STD_LOGIC_VECTOR(2 downto 0);
	signal frame_dbg : STD_LOGIC_VECTOR(7 downto 0);
	signal fake_fd : STD_LOGIC_VECTOR(7 downto 0);
	signal col_ptr, row_ptr : STD_LOGIC_VECTOR(7 downto 0);
	signal fstate : integer range 0 to 31;
begin
i2c_in<=((i2c_in1) OR (i2c_in2));

FT_DIR <= not dir;

CE <= '0';

	Inst_spitx: spitx PORT MAP(
		frame_data => frame_data,
		column_data => col_ptr,
		row_data => row_ptr,
		DA => frame_data_ready,
		clk => MCLK,
		rst => MRST,
		MOSI => MOSI,
		CS => CSN,
		SCK => SCK
	);


	Inst_LCD_Controller: LCD_Controller PORT MAP(
		rst => MRST,
		clk => MCLK,
		sda => SDA,
		scl => SCL,
		cs => CS,
		lcd_go => frame_data_ready,
		frame_data => frame_data,
		frame_begin => frame_beginning,
		frame_end => frame_end
	);
	Inst_DAC_Loader_FSM: DAC_Loader_FSM PORT MAP(
		clk => MCLK,
		rst => MRST,
		pdac_clk => pdac_clk,
		pdac_sin => pdac_sin,
		pdac_sync => pdac_sync,
		pdac_update_en => pdac_update_en,
		pdac_data => pdac_data,
		pdac_busy => pdac_busy 
	);
	Inst_usb_fsm: usb_fsm PORT MAP(
		clk => MCLK ,
		rst => MRST,
		pdac_data => pdac_data,
		pdac_busy => pdac_busy,
		idac_busy => idac_busy,
		pdac_update_en => pdac_update_en,
		idac_update_en => idac_update_en,
		usb_go => usb_go ,
		usb_done => usb_done,
		usb_busy => usb_busy,
		usb_dir => dir,
		usb_dout => usb_dout,
		usb_din => usb_din,
		frame_data => frame_data,
		frame_data_ready => frame_data_ready,
		frame_beginning => frame_beginning,
		frame_end => frame_end,
		reg_p1 => reg_p1,
		reg_p2 => reg_p2,
		reg_p3 => reg_p3,
		reg_p4 => reg_p4,
		reg_p5 => reg_p5,
		reg_p6 => reg_p6,
		reg_p7 => reg_p7,
		reg_p8 => reg_p8,
		reg_p9 => reg_p9,
		reg_p10 => reg_p10,
		reg_p11 => reg_p11,
		reg_p12 => reg_p12,
		reg_p13 => reg_p13,
		reg_p14 => reg_p14,
		reg_p15 => reg_p15,
		reg_p16 => reg_p16,
		reg_p17 => reg_p17,
		reg_p18 => reg_p18,
		reg_p19 => reg_p19,
		reg_p20 => reg_p20,
		reg_p21 => reg_p21,
		reg_p22 => reg_p22,
		reg_p23 => reg_p23,
		reg_p24 => reg_p24,
		reg_p25 => reg_p25
	);
		Inst_iDAC_Loader_FSM: iDAC_Loader_FSM PORT MAP(
		clk => MCLK,
		rst => MRST,
		idac_busy => idac_busy,
		i2c_clk => i2c_clk,
		i2c_in2 => i2c_in2,
		i2c_rstb => i2c_rstb,
		idac_update_en => idac_update_en,
		reg_p9 => reg_p9,
		reg_p10 => reg_p10,
		reg_p11 => reg_p11,
		reg_p12 => reg_p12,
		reg_p13 => reg_p13,
		reg_p14 => reg_p14,
		reg_p15 => reg_p15,
		reg_p16 => reg_p16,
		reg_p17 => reg_p17,
		reg_p18 => reg_p18,
		reg_p19 => reg_p19,
		reg_p20 => reg_p20,
		reg_p21 => reg_p21,
		reg_p22 => reg_p22,
		reg_p23 => reg_p23,
		reg_p24 => reg_p24,
		reg_p25 => reg_p25
	);
	Inst_Frame_reader: Frame_reader PORT MAP(
		clk => MCLK,
		rst => MRST,
		frame_end => frame_end,
		frame_ready => frame_ready,
		data_available => frame_data_ready,
		dout => frame_data,
		rdec_clk => rdec_clk,
		rdec_rst => rdec_rst,
		row_rst => row_rst,
		row_sel => row_sel,
		row_boost => row_boost,
		cdec_clk => cdec_clk,
		cdec_rst => cdec_rst,
		col_vln_casc => col_vln_casc,
		col_sh => col_sh,
		amp_rst => amp_rst,
		comp_rst1 => comp_rst1,
		comp_rst2 => comp_rst2,
		coldata => DATA,
		i2c_in1 => i2c_in1,
		col_ptr => col_ptr,
		row_ptr => row_ptr,
		adc_clk => adc_clk,
		ramp_rst => ramp_rst,
		ramp_set => ramp_set,
		frame_beginning => frame_beginning ,
		disable_frame_reader => '0'
	);
		Inst_usb_controller_mux: usb_controller_mux PORT MAP(
		clk =>MCLK ,
		rst => MRST,
		go => usb_go,
		done => usb_done,
		data_in => usb_din,
		data_out => usb_dout,
		dir => dir,
		busy => usb_busy,
		rd => FT_RD,
		wr => FT_WR,
		txe => FT_TXE,
		rxf => FT_RXF,
		ftdi_dout => FT_DOUT,
		ftdi_din => FT_DIN,
		dbg => usb_dbg
	);

end Behavioral;

