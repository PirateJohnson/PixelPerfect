----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:19:44 01/22/2013 
-- Design Name: 
-- Module Name:    rx_driver - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rx_driver is
    Port ( clk : in  STD_LOGIC;
				rx_mosi	: OUT STD_LOGIC;
				rx_miso	: IN STD_LOGIC;
				rx_cs		: OUT STD_LOGIC;
				rx_ce		: OUT STD_LOGIC;
				payload	: OUT STD_LOGIC_VECTOR(255 downto 0);
				payload_available	: OUT STD_LOGIC;
				rx_sck	: OUT STD_LOGIC;
				
           rst : in  STD_LOGIC);
end rx_driver;

architecture Behavioral of rx_driver is
	COMPONENT Generic_SPI_FSM
	PORT(
		MISO : IN std_logic;
		Din : IN std_logic_vector(7 downto 0);
		Din_big : IN std_logic_vector(255 downto 0);
		Dout_big	: OUT STD_LOGIC_VECTOR(255 downto 0);
		SCL_Pulses : IN std_logic_vector(8 downto 0);
		SCL_width : IN std_logic_vector(3 downto 0);
		CS_width : IN std_logic_vector(3 downto 0);
		CS_enable : IN std_logic;
		go : IN std_logic;
		dir : IN std_logic;
		rst : IN std_logic;
		clk : IN std_logic;          
		MOSI : OUT std_logic;
		CS_out : OUT std_logic;
		SCL : OUT std_logic;
		Dout : OUT std_logic_vector(7 downto 0);
		done : OUT std_logic
		);
	END COMPONENT;

	constant D_CONFIG 		: STD_LOGIC_VECTOR (7 downto 0) := "00001011"; --Rx
	constant D_EN_AA			: STD_LOGIC_VECTOR (7 downto 0) := "00000000"; --NO AA
	constant D_EN_RXADDR 	: STD_LOGIC_VECTOR (7 downto 0) := "00000010"; --En DP1
	constant D_SETUP_AW 		: STD_LOGIC_VECTOR (7 downto 0) := "00000011"; --5 addr bytes
	constant D_SETUP_RETR	: STD_LOGIC_VECTOR (7 downto 0) := "00000000"; -- No retre
	constant D_RF_CH			: STD_LOGIC_VECTOR (7 downto 0) := "00000010"; --RF chan
	constant D_RF_SETUP		: STD_LOGIC_VECTOR (7 downto 0) := "00001111"; --RF setup 
	constant D_STATUS			: STD_LOGIC_VECTOR (7 downto 0) := "01110000";	--Clear status reg
	constant D_RX_PW_P0		: STD_LOGIC_VECTOR (7 downto 0) := "00100000";	--32 byte payload
	constant D_RX_ADDR_P0	: STD_LOGIC_VECTOR (39 downto 0) := X"DEADBEEFFF"; -- may need to be reversed
	constant D_TX_ADDR 		: STD_LOGIC_VECTOR (39 downto 0) := X"DEADBEEFFF";	
	
	constant RA_CONFIG		: STD_LOGIC_VECTOR (4 downto 0) := "00000";
	constant RA_EN_AA			: STD_LOGIC_VECTOR (4 downto 0) := "00001";
	constant RA_EN_RXADDR	: STD_LOGIC_VECTOR (4 downto 0) := "00010";
	constant RA_SETUP_AW		: STD_LOGIC_VECTOR (4 downto 0) := "00011";
	constant RA_SETUP_RETR	: STD_LOGIC_VECTOR (4 downto 0) := "00100";
	constant RA_RF_CH			: STD_LOGIC_VECTOR (4 downto 0) := "00101";
	constant RA_RF_SETUP		: STD_LOGIC_VECTOR (4 downto 0) := "00110";
	constant RA_STATUS		: STD_LOGIC_VECTOR (4 downto 0) := "00111";
	constant RA_OBSERVE_TX	: STD_LOGIC_VECTOR (4 downto 0) := "01000";
	constant RA_RX_ADDR_P0	: STD_LOGIC_VECTOR (4 downto 0) := "01011";
	constant RA_TX_ADDR		: STD_LOGIC_VECTOR (4 downto 0) := "10000";
	constant RA_RX_PW_P0		: STD_LOGIC_VECTOR (4 downto 0) := "10010";
	constant RA_FIFO_STATUS	: STD_LOGIC_VECTOR (4 downto 0) := "10111";
	
	
	constant FLUSH_RX			: STD_LOGIC_VECTOR(7 downto 0) := "11100001" ;
	
	constant W_TX_PAYLOAD	: STD_LOGIC_VECTOR( 7 downto 0) := "10100000";
	constant R_REGISTER		: STD_LOGIC_VECTOR  (2 downto 0) := "000";
	constant W_REGISTER		: STD_LOGIC_VECTOR(2 downto 0) := "001";
	constant R_RX_PAYLOAD	: STD_LOGIC_VECTOR(7 downto 0) := "01100001"	;
	signal R_CONFIG			: STD_LOGIC_VECTOR(7 downto 0) := D_CONFIG;
	signal R_EN_AA				: STD_LOGIC_VECTOR(7 downto 0) := D_EN_AA;
	signal R_EN_RXADDR		: STD_LOGIC_VECTOR(7 downto 0) := D_EN_RXADDR;
	signal R_SETUP_AW			: STD_LOGIC_VECTOR(7 downto 0) := D_SETUP_AW;
	signal R_SETUP_RETR		: STD_LOGIC_VECTOR(7 downto 0) := D_SETUP_RETR;
	signal R_RF_CH				: STD_LOGIC_VECTOR(7 downto 0) := D_RF_CH;
	signal R_RF_SETUP			: STD_LOGIC_VECTOR(7 downto 0) := D_RF_SETUP;
	signal R_STATUS			: STD_LOGIC_VECTOR(7 downto 0) := D_STATUS;
	signal R_TX_ADDR			: STD_LOGIC_VECTOR(39 downto 0) := D_TX_ADDR;
	signal R_RX_ADDR_P0		: STD_LOGIC_VECTOR(39 downto 0) := D_RX_ADDR_P0;
	signal R_RX_PW_P0			: STD_LOGIC_VECTOR(7 downto 0) := D_RX_PW_P0;	
	signal SR_back				: STD_LOGIC_VECTOR(7 downto 0);
	signal tstate				: integer range 0 to 10000000;	
	signal cstate				:integer range 0 to 207000;
	signal fstate				:integer range 0 to 32;
	signal spi_rst				: STD_LOGIC;
	signal enable_ce 			: STD_LOGIC;
	signal ce_high				: STD_LOGIC;
	signal fifo_din, fifo_dout : STD_LOGIC_VECTOR(7 downto 0);
	signal 
				rd_en, 
				full, 
				empty,
				tx_ready,
				  almost_full,
				  wr_ack,
				  overflow,
				  almost_empty,
				  valid,
				  underflow : STD_LOGIC;
	signal CS_override : STD_LOGIC;
	signal cnt 					: STD_LOGIC_VECTOR(9 downto 0);
	signal cnt_en, cnt_rst				: STD_LOGIC;
	signal data_count				:STD_LOGIC_VECTOR(15 downto 0);
	signal dout_big 				:STD_LOGIC_VECTOR(255 downto 0);
	signal row_ptr, col_ptr		: STD_LOGIC_VECTOR(7 downto 0);
	signal tx_go					: STD_LOGIC;
	--fp
	--signal payload					: STD_LOGIC_VECTOR(255 downto 0);
	signal rcstate					: integer range 0 to 200*150;
	signal pl_cnt					: integer range 0 to 45;
	signal load_data 				: STD_LOGIC;
	signal pix						: STD_LOGIC_VECTOR(7 downto 0);
	signal fwr						: STD_LOGIC;
	signal wr_en					: STD_LOGIC;
	signal wr_s1					: STD_LOGIC;
	signal din, dout						: STD_LOGIC_VECTOR(7 downto 0);
	signal din_big						: STD_LOGIC_VECTOR(255 downto 0);
	signal sck_pulses				: STD_LOGIC_VECTOR(8 downto 0);
	signal spi_go, spi_dir, spi_done, spi_cs_enable	: STD_LOGIC;
--	signal din_big				: STD_LOGIC_VECTOR(255 downto 0);
	signal payload_buffer	: STD_LOGIC_VECTOR(255 downto 0);
--	signal payload_available : STD_LOGIC;
begin
Inst_Generic_SPI_FSM: Generic_SPI_FSM PORT MAP(
		MOSI => rx_mosi,
		MISO => rx_miso,
		CS_out => rx_cs ,
		SCL => rx_sck,
		Din => dout,
		Din_big => dout_big,
		Dout_big => din_big,
		Dout => din,
		SCL_Pulses => sck_pulses,
		SCL_width => "0011",
		CS_width => "0010",
		CS_enable => spi_cs_enable,
		go => spi_go,
		dir => spi_dir,
		rst => rst,
		clk => clk,
		done => spi_done
	);
payload<= payload_buffer;
Reciever : process(clk) is
	begin
		if(rising_edge(clk)) then
			if(rst = '0') then
				R_CONFIG <= D_CONFIG;
				R_EN_AA <= D_EN_AA;
				R_EN_RXADDR <= D_EN_RXADDR;
				R_SETUP_AW	<= D_SETUP_AW;
				R_SETUP_RETR <= D_SETUP_RETR;
				R_RF_CH <= D_RF_CH;
				R_RF_SETUP <= D_RF_SETUP;
				R_STATUS <= D_STATUS;
				R_TX_ADDR <= D_TX_ADDR;
				R_RX_ADDR_P0 <= D_RX_ADDR_P0;
				R_RX_PW_P0	<= D_RX_PW_P0	;
				spi_go <= '0';
				spi_dir <= '0';
				spi_cs_enable <= '1';
				sck_pulses <= "000001000"; -- 8
				dout <= (others => '0');
				tstate <= 0;
		--		Tx_ce <= '0';
--				test_led <= '1';
				enable_ce <= '0';
				rd_en <= '0';
				tx_ready <= '0';
				CS_override <= '0';
				cnt_en <= '0';
				cnt_rst <= '1';
				wr_en <= '0';
				fwr <= '1';
				load_data <= '0';
				wr_s1	<= '0';
				rx_ce <= '0';
				payload_available<= '0';
				payload_buffer <= (others=>'0');
	--			ftdi_dout <= (others=> '0');
			else
				case tstate is	
						
					when 700000=> -- send out EN_AA -- wait for reset too ~10 ms						
						dout <= W_REGISTER & RA_EN_AA;
						spi_dir <= '0';
						spi_cs_enable <= '0';
						spi_go <= '1';
						tstate <= tstate + 1;
						load_data <= '0';
					when 700002=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700003=> 
						spi_dir <= '0';
						dout <= R_EN_AA;
						spi_go <= '1';
						spi_cs_enable <= '1';
						tstate <= tstate + 1;
					when 700005=>
						spi_go <= '0';
						if( spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700006=>
						spi_go <= '1';
						dout <= R_REGISTER & RA_EN_AA;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700009=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700010=>
						spi_go <= '1';
						dout <= "11111111";
						spi_cs_enable <= '1';
						tstate <= tstate + 1;
					when 700011=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate +1;
						end if;
					-- End of AA setup
					when 700012=>
						spi_go <= '1';
						dout <= W_REGISTER & RA_EN_RXADDR;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700015=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700016=>
						spi_go <= '1';
						spi_cs_enable <= '1';
						dout <= R_EN_RXADDR;
						tstate <= tstate + 1;
					when 700019=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700021=>
						spi_go <= '1';
						dout <= R_REGISTER & RA_EN_RXADDR;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700024=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700026=>
						spi_go <= '1';
						dout <= "11111111";
						spi_cs_enable <= '1';
						tstate <= tstate + 1;
					when 700028=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					-- End of Rx address enable on P0 for autoack
					when 700030=>
						spi_go <= '1';
						spi_cs_enable <= '0';
						dout <= W_REGISTER & RA_SETUP_AW;
						tstate <= tstate + 1;
					when 700032 =>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700034=>
						spi_go <= '1';
						spi_cs_enable <= '1';
						dout <= R_SETUP_AW;
						tstate <= tstate + 1;
					when 700036=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700038=>
						spi_go <= '1';
						spi_cs_enable <= '0';
						dout <= R_REGISTER & RA_SETUP_AW;
						tstate <= tstate + 1;
					when 700040=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700042=>
						spi_go <= '1';
						spi_cs_enable <= '1';
						dout <= "11111111";
						tstate <= tstate + 1;
					when 700044=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					-- End of address width setup
					when 700046=>
						spi_go <= '1';
						dout <= W_REGISTER & RA_SETUP_RETR;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700048=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700050=>
						spi_go <= '1';
						spi_cs_enable <= '1';
						dout <= R_SETUP_RETR;
						tstate <= tstate + 1;
					when 700052=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700054=>
						spi_go <= '1';
						dout <= R_REGISTER & RA_SETUP_RETR;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700056=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700058=>
						spi_go <= '1';
						dout <= "11111111";
						spi_cs_enable <= '1';
						tstate <= tstate + 1;
					when 700060=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					-- End of setup retransmit setup
					when 700062=>
						spi_go <= '1';
						dout <= W_REGISTER & RA_RF_CH;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700064=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700066=>
						spi_go <= '1';
						spi_cs_enable <= '1';
						dout <= R_RF_CH;
						tstate <= tstate + 1;
					when 700068=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700070=>
						spi_go <= '1';
						dout <= R_REGISTER & RA_RF_CH;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700072=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700074=>
						spi_go <= '1';
						dout <= "11111111";
						spi_cs_enable <= '1';
						tstate <= tstate + 1;
					when 700076=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					-- End of RF channel setup
					when 700078=>
						spi_go <= '1';
						dout <= W_REGISTER & RA_RF_SETUP;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700080=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700082=>
						spi_go <= '1';
						spi_cs_enable <= '1';
						dout <= R_RF_SETUP;
						tstate <= tstate + 1;
					when 700084=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700086=>
						spi_go <= '1';
						dout <= R_REGISTER & RA_RF_SETUP;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700088=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700090=>
						spi_go <= '1';
						dout <= "11111111";
						spi_cs_enable <= '1';
						tstate <= tstate + 1;
					when 700092=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					-- End of RF setup
					when 700094=>
						spi_go <= '1';
						dout <= W_REGISTER & RA_RX_ADDR_P0;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700096=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700098=>
						spi_go <= '1';
						spi_cs_enable <= '0';
						dout <= R_RX_ADDR_P0(7 downto 0);
						tstate <= tstate + 1;
					when 700100=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700102=>
						spi_go <= '1';
						dout <= R_RX_ADDR_P0(15 downto 8);
						tstate <= tstate + 1;
					when 700104=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700106=>
						spi_go <= '1';
						dout <= R_RX_ADDR_P0(23 downto 16);
						tstate <= tstate + 1;
					when 700108=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700110=>
						spi_go <= '1';
						dout <= R_RX_ADDR_P0(31 downto 24);
						tstate <= tstate + 1;
					when 700112=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700114=>
						spi_go <= '1';
						spi_cs_enable <= '1';
						dout <= R_RX_ADDR_P0(39 downto 32);
						tstate <= tstate + 1;
					when 700116=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					--End of RxAddress setup
					when 700118=>
						spi_go <= '1';
						dout <= W_REGISTER & RA_TX_ADDR;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700120=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700122=>
						spi_go <= '1';
						spi_cs_enable <= '0';
						dout <= R_TX_ADDR(7 downto 0);
						tstate <= tstate + 1;
					when 700124=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700126=>
						spi_go <= '1';
						dout <= R_TX_ADDR(15 downto 8);
						tstate <= tstate + 1;
					when 700128=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700130=>
						spi_go <= '1';
						dout <= R_TX_ADDR(23 downto 16);
						tstate <= tstate + 1;
					when 700132=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700134=>
						spi_go <= '1';
						dout <= R_TX_ADDR(31 downto 24);
						tstate <= tstate + 1;
					when 700136=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700138=>
						spi_go <= '1';
						spi_cs_enable <= '1';
						dout <= R_TX_ADDR(39 downto 32);
						tstate <= tstate + 1;
					when 700140=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					--End of Transmit address setup
					when 700142=>
						spi_go <= '1';
						dout <= W_REGISTER & RA_RX_PW_P0;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700144=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700146=>
						spi_go <= '1';
						spi_cs_enable <= '1';
						dout <= R_RX_PW_P0;
						tstate <= tstate + 1;
					when 700148=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700150=>
						spi_go <= '1';
						dout <= R_REGISTER & RA_RX_PW_P0;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700152=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700154=>
						spi_go <= '1';
						dout <= "11111111";
						spi_cs_enable <= '1';
						tstate <= tstate + 1;
					when 700156=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					--End of Rx0 payload setting
					when 700158=>
						spi_go <= '1';
						dout <= W_REGISTER & RA_CONFIG;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700160=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700162=>
						spi_go <= '1';
						spi_cs_enable <= '1';
						dout <= R_CONFIG;
						tstate <= tstate + 1;
					when 700164=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700166=>
						spi_go <= '1';
						dout <= R_REGISTER & RA_CONFIG;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 700168=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 700170=>
						spi_go <= '1';
						dout <= "11111111";
						spi_cs_enable <= '1';
						tstate <= tstate + 1;
					when 700172=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					--End of config reg setting
					
					
					--Start getting data
--					
					when 708850=>
						rx_ce <= '1';
						dout <= R_REGISTER & RA_STATUS;
						spi_go <= '1';
						spi_cs_enable <= '1';
						tstate <= tstate + 1;
					when 708852=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 708854=>
						if(din(6) = '1') then
							tstate <= tstate + 1;
						else
							tstate <= 708848;
						end if;
						
	
					when 708855=>
						load_data <= '0';
						--rx_ce <= '0';
						dout <= W_REGISTER & RA_STATUS;
						spi_go <= '1';
						sck_pulses <= "000001000"; -- 8
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 708857=>
					--	fwr <= '1';
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 708859=>
						dout <= "01000000";	--Clear status register 
						spi_go <= '1';
						spi_cs_enable <= '1';
						tstate <= tstate + 1;
					when 708861=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
						
					when 708863=>
						rx_ce <= '1';
						dout <= R_RX_PAYLOAD;
						spi_cs_enable <= '0';
						spi_go <= '1';
						pl_cnt <= 0;
						tstate <= tstate + 1;
					when 708865=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 708867=>
						payload_available<= '0';
						dout <= (others=>'0');
						spi_dir <= '0'; -- reading
						spi_cs_enable <= '1'; -- enable spi cs
						sck_pulses <= "100000000"; -- Grab a bunch of data
						spi_go <= '1';
						tstate <= tstate + 1;
					when 708869=>
						spi_go <= '0';
						if(spi_done = '1') then
								payload_buffer <= din_big;
								payload_available<= '1';
								tstate <= tstate + 1;
						end if;	
					when 708870=>
					--	payload_available <= '0';
					--	payload_buffer <= (others=>'0');
						tstate <= tstate + 1;
					--check status reg
					when 708872=>		
						payload_available <= '0';	--With this, got 3 FPS but noisy image
						payload_buffer <= (others=>'0');
						spi_go <= '1';
						sck_pulses <= "000001000"; -- 8
					--	rx_ce <= '1';
					--	payload_available<= '0';
						dout <= R_REGISTER & RA_FIFO_STATUS;
						spi_cs_enable <= '0';
						tstate <= tstate + 1;
					when 708874=>
						spi_go <= '0';
					--	fwr <= '1';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 708876=>
						spi_go <= '1';
					--	dout <= (others=>'0');
						spi_cs_enable <= '1';
						tstate <= tstate + 1;
					when 708878=>
						spi_go <= '0';
						if(spi_done = '1') then
							tstate <= tstate + 1;
						end if;
					when 708880=>
						payload_available <= '0';
						if(din(0) = '1') then
							tstate <= 708848;
							
						else 
							tstate <= 708862;
						end if;
					when others=> tstate <= tstate + 1;
				end case;
			
			end if;
		end if;
	end process;
	
end Behavioral;

