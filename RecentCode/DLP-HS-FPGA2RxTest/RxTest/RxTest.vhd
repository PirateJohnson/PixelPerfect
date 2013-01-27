----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:34:43 01/22/2013 
-- Design Name: 
-- Module Name:    RxTest - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity RxTest is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           rx_sck : out  STD_LOGIC;
           rx_mosi : out  STD_LOGIC;
           rx_miso : in  STD_LOGIC;
           rx_csn : out  STD_LOGIC;
			  rx_ce	: out STD_LOGIC;
           wr : out  STD_LOGIC;
           rd : out  STD_LOGIC;
			  txe : in STD_LOGIC;
			  rxf	: in STD_LOGIC;
           ftdi_data : inout  STD_LOGIC_VECTOR (7 downto 0));
end RxTest;

architecture Behavioral of RxTest is
	COMPONENT ftdi_driver
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
		COMPONENT rx_driver
	PORT(
		clk : IN std_logic;
		rx_miso : IN std_logic;
		rst : IN std_logic;          
		rx_mosi : OUT std_logic;
		rx_cs : OUT std_logic;
		rx_ce : OUT std_logic;
		payload	: OUT STD_LOGIC_VECTOR(255 downto 0);
		payload_available	: OUT STD_LOGIC;
		rx_sck : OUT std_logic
		);
	END COMPONENT;
		COMPONENT packet_cntl
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		payload : IN std_logic_vector(255 downto 0);
		payload_ready : IN std_logic;
		ftdi_done : IN std_logic;          
		dout : OUT std_logic_vector(7 downto 0);
		ftdi_go : OUT std_logic
		);
	END COMPONENT;


	signal ftdi_go, dir, ftdi_busy, ftdi_done : STD_LOGIC;
	signal ftdi_dout, ftdi_din,data_in, data_out  : STD_LOGIC_VECTOR(7 downto 0);
	signal dbg						: STD_LOGIC_VECTOR(2 downto 0);
	signal din, dout				: STD_LOGIC_VECTOR(7 downto 0);
	signal din_big					: STD_LOGIC_VECTOR(255 downto 0);
	signal spi_go, spi_dir, spi_done	: STD_LOGIC;
	signal sck_pulses				: STD_LOGIC_VECTOR(8 downto 0);
	signal payload_available	: STD_LOGIC;
	signal payload					: STD_LOGIC_VECTOR(255 downto 0);
begin
	dir <= '0'; --only writes
		Inst_packet_cntl: packet_cntl PORT MAP(
		clk => clk,
		rst => rst,
		payload => payload,
		dout => data_in,
		payload_ready => payload_available ,
		ftdi_go => ftdi_go ,
		ftdi_done => ftdi_done
	);
	Inst_ftdi_driver: ftdi_driver PORT MAP(
		clk => clk ,
		rst => rst,
		go => ftdi_go,
		done => ftdi_done,
		data_in => data_in,
		data_out => data_out,
		dir => dir,
		busy => ftdi_busy,
		rd => rd,
		wr => wr,
		txe => txe,
		rxf => rxf,
		ftdi_dout => ftdi_dout,
		ftdi_din => ftdi_din,
		dbg => dbg
	);
		Inst_rx_driver: rx_driver PORT MAP(
		clk => clk,
		rx_mosi => rx_mosi,
		rx_miso => rx_miso,
		rx_cs => rx_csn,
		payload => payload,
		payload_available => payload_available,
		rx_ce => rx_ce,
		rx_sck => rx_sck,
		rst => rst
	);
	
	
	
	
	
	
	
	 inst_IOBUF8 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(0),   -- Buffer output
      IO => ftdi_data(0),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(0),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF9 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(1),   -- Buffer output
      IO => ftdi_data(1),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(1),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF10 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(2),   -- Buffer output
      IO => ftdi_data(2),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(2),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF11 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(3),   -- Buffer output
      IO => ftdi_data(3),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(3),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF12 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(4),   -- Buffer output
      IO => ftdi_data(4),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(4),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF13 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(5),   -- Buffer output
      IO => ftdi_data(5),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(5),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF14 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(6),   -- Buffer output
      IO => ftdi_data(6),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(6),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF15 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(7),   -- Buffer output
      IO => ftdi_data(7),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(7),  -- Buffer input
      T => dir       -- 3-state enable input 
  );		
	
end Behavioral;

