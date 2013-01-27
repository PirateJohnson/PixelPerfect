----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:26:22 01/21/2013 
-- Design Name: 
-- Module Name:    TxTest - Behavioral 
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

entity TxTest is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  test_led : out STD_LOGIC;
			  ftdi_data	: inout STD_LOGIC_VECTOR(7 downto 0);
			  txe			: in STD_LOGIC;
			  rxf			: in STD_LOGIC;
			  rd			: OUT STD_LOGIC;
			  wr			: out STD_LOGIC;
			  
           asic_sck : in  STD_LOGIC;
           asic_miso : in  STD_LOGIC;
           asic_cs : in  STD_LOGIC;
           tx_sck : out  STD_LOGIC;
           tx_ce : out  STD_LOGIC;
           tx_csn : out  STD_LOGIC;
           tx_mosi : out  STD_LOGIC;
           tx_miso : in  STD_LOGIC);
end TxTest;

architecture Behavioral of TxTest is
	COMPONENT tx_module
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		payload : IN std_logic_vector(255 downto 0);
		spi_miso : IN std_logic;
		tx_go : IN std_logic;          
		spi_mosi : OUT std_logic;
		spi_cs : OUT std_logic;
		Tx_ce : OUT std_logic;
		spi_sck : OUT std_logic;
		tx_ready : OUT std_logic
		);
	END COMPONENT;
	COMPONENT pointer_control
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		inc_ptr : IN std_logic;          
		colptr : OUT std_logic_vector(7 downto 0);
		rowptr : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
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
signal ftdi_din, ftdi_dout, data_in, data_out	: STD_LOGIC_VECTOR(7 downto 0);
signal ftdi_send, dir, ftdi_done, ftdi_busy : STD_LOGIC;
signal serial_data_ready : STD_LOGIC;
COMPONENT fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    wr_ack : OUT STD_LOGIC;
    overflow : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    underflow : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
    wr_data_count : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
  );
END COMPONENT;
	COMPONENT fifo_writer
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		write_fifo : IN std_logic;
		fifo_full : IN std_logic;
		fifo_din : IN std_logic_vector(7 downto 0);          
		wr_clk : OUT std_logic;
		wr_en : OUT std_logic;
		write_fifo_busy : OUT std_logic;
		din : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	COMPONENT fifo_reader
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		dout : IN std_logic_vector(7 downto 0);
		get_data : IN std_logic;
		empty : IN std_logic;          
		 rd_en : out STD_LOGIC;
		fifo_dout : OUT std_logic_vector(7 downto 0);
		data_sent : OUT std_logic;
		data_available : OUT std_logic;
		rd_clk : OUT std_logic
		);
	END COMPONENT;
	COMPONENT packet_control
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		data_available : IN std_logic;
		frame_data : IN std_logic_vector(7 downto 0);
		row_ptr : IN std_logic_vector(7 downto 0);
		col_ptr : IN std_logic_vector(7 downto 0);
		ack_data : IN std_logic;          
		inc_ptr : OUT std_logic;
		req_data : OUT std_logic;
		tx_go : OUT std_logic;
		tx_ready : IN STD_LOGIC;
		data : OUT std_logic_vector(255 downto 0)
		);
	END COMPONENT;
signal SCK, MISO, CS, sck_buff, miso_buff, cs_buff : STD_LOGIC;
signal rstate : integer range 0 to 55;
signal wfs		: integer range 0 to 10;
signal write_fifo, write_fifo_busy : STD_LOGIC;
signal fifo_din, fifo_dout	: STD_LOGIC_VECTOR(7 downto 0);
signal wr_clk, rd_clk, wr_en, rd_en, full, wr_ack, overflow, empty, valid, underflow : STD_LOGIC;
signal din, dout :STD_LOGIC_VECTOR(7 downto 0);
signal f_buff, r_buff, c_buff : STD_LOGIC_VECTOR (7 downto 0);
signal rd_data_count, wr_data_count : STD_LOGIC_VECTOR(14 downto 0);
signal req_data, ack_data, data_available : STD_LOGIC;
signal dbg	: STD_LOGIC_VECTOR(2 downto 0);
signal tstate : integer range 0 to 10;
signal FE : STD_LOGIC;
signal sync : STD_LOGIC;
signal cntl : integer range 0 to 4;
signal rowptr, colptr, pixel : STD_LOGIC_VECTOR(7 downto 0);
signal inc_ptr : STD_LOGIC;
signal cp, rp	: STD_LOGIC_VECTOR(7 downto 0); --Row and column pointers for packet control
signal tx_go 	: STD_LOGIC;
signal tx_ready	: STD_LOGIC;	
signal payload	: STD_LOGIC_VECTOR(255 downto 0);
begin
dir <= '0';
	Inst_tx_module: tx_module PORT MAP(
		clk => clk,
		rst => rst,
		payload => payload,
		spi_mosi => tx_mosi,
		spi_miso => tx_miso,
		spi_cs => tx_csn,
		Tx_ce => tx_ce,
		spi_sck => tx_sck,
		tx_ready => tx_ready,
		tx_go => tx_go
	);
	Inst_packet_control: packet_control PORT MAP(
		clk => clk,
		rst => rst,
		data_available => data_available,
		frame_data => fifo_dout,
		row_ptr => rp,
		col_ptr => cp,
		inc_ptr => inc_ptr,
		req_data => req_data,
		ack_data => ack_data,
		tx_go => tx_go,
		tx_ready => tx_ready,
		data => payload
	);
	Inst_pointer_control: pointer_control PORT MAP(
		clk => clk,
		rst => rst,
		inc_ptr => inc_ptr,
		colptr => cp,
		rowptr => rp
	);

	Inst_ftdi_driver: ftdi_driver PORT MAP(
		clk => clk,
		rst => rst,
		go => ftdi_send,
		done => ftdi_done ,
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
test_led <= sync;
--tx_csn <= '1';
--tx_mosi <= '0';
--tx_ce <= '0';
--tx_sck <= '0';


FE <= '1' when serial_data_ready = '1' and r_buff = "00000000" and c_buff = "00000000" else '0';


--process(clk) is
--begin
--	if(rising_edge(clk)) then
--		if(rst = '0') then
--			tstate <= 0;
--			ftdi_send <= '0';
--			data_in <= (others => '0');
--			req_data <= '0';
--		else
--			case tstate is
--				when 0=>
--					ftdi_send <= '0';
--					if(data_available = '1') then
--						tstate <= tstate + 1;
--					end if;
--				when 1=>
--					req_data <= '1';
--					tstate <= tstate + 1;
--				when 2=>
--					if(ack_data = '1') then						
--						tstate <= tstate + 1;
--					end if;
--				when 3=>					
--					data_in <= fifo_dout;
--					tstate <= tstate + 1;
--				when 4=>
--					ftdi_send <= '1';
--					
--					tstate <= tstate + 1;
--				when 5=>
--					ftdi_send <= '0';
--					tstate <= 0;
--				when others=>
--					
--			end case;
--		end if;
--	
--	end if;
--end process;
	Inst_fifo_reader: fifo_reader PORT MAP(
		clk => clk,
		rst => rst,
		dout => dout,
		get_data => req_data,
		fifo_dout => fifo_dout,
		data_sent => ack_data,
		data_available => data_available,
		rd_clk => rd_clk,
		 rd_en => rd_en,
		empty => empty
	);
fifo_instance : fifo
  PORT MAP (
    rst => not rst, -- rst active high
    wr_clk => wr_clk,
    rd_clk => rd_clk,
    din => din,
    wr_en => wr_en,
    rd_en => rd_en,
    dout => dout,
    full => full,
    wr_ack => wr_ack,
    overflow => overflow,
    empty => empty,
    valid => valid,
    underflow => underflow,
    rd_data_count => rd_data_count,
    wr_data_count => wr_data_count
  );
Inst_fifo_writer: fifo_writer PORT MAP(
		clk => clk,
		rst => rst,
		wr_clk => wr_clk,
		wr_en => wr_en,
		write_fifo_busy => write_fifo_busy,
		write_fifo => write_fifo,
		fifo_full => full,
		fifo_din => fifo_din,
		din => din
	); 



twoffsync: process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
			sck_buff <= '0';
			SCK <= '0';
			miso_buff <= '0';
			MISO <= '0';
			cs_buff <= '1';
			CS <= '1';
		else		
			SCK <= sck_buff;
			sck_buff <= asic_sck;
			MISO <= miso_buff;
			miso_buff <= asic_miso;
			CS <= cs_buff;
			cs_buff <= asic_cs;
		end if;
	end if;
end process;

spirx: process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
			rstate <= 0;
		--	ftdi_send <= '0';
			f_buff <= (others=>'0');
			r_buff <= (others=>'0');
			c_buff <= (others=>'0');
			serial_data_ready <= '0';
		--	sync <= '0';
		else
			case rstate is
				when 0=>
					--	ftdi_send <= '0';
			--		write_fifo <= '0';
					serial_data_ready <= '0';
					if(CS = '0') then
				--		ftdi_send <= '0';
						rstate <= rstate + 1;
					end if;
				when 1=>
					if(SCK = '1') then
						f_buff(7) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 2=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 3=>
					if(SCK = '1') then
						f_buff(6)  <= MISO;						
						rstate<= rstate + 1;
					end if;
				when 4=>
					if(SCK = '0') then
						rstate<= rstate + 1;
					end if;
				when 5=>
					if(SCK = '1') then
						f_buff(5) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 6=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 7=>
					if(SCK = '1') then 
						f_buff(4) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 8=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 9=>
					if(SCK = '1') then
						f_buff(3) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 10=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 11=>
					if(SCK = '1') then
						f_buff(2) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 12=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 13=>
					if(SCK = '1') then
						f_buff(1) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 14=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 15=>
					if(SCK = '1') then
						f_buff(0) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 16=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
			--Recieved frame data
			
				when 17=>
					if(SCK = '1') then
						c_buff(7) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 18=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 19=>
					if(SCK = '1') then
						c_buff(6)  <= MISO;						
						rstate<= rstate + 1;
					end if;
				when 20=>
					if(SCK = '0') then
						rstate<= rstate + 1;
					end if;
				when 21=>
					if(SCK = '1') then
						c_buff(5) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 22=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 23=>
					if(SCK = '1') then 
						c_buff(4) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 24=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 25=>
					if(SCK = '1') then
						c_buff(3) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 26=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 27=>
					if(SCK = '1') then
						c_buff(2) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 28=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 29=>
					if(SCK = '1') then
						c_buff(1) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 30=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 31=>
					if(SCK = '1') then
						c_buff(0) <= MISO;
						rstate <= rstate + 1;
					end if;
				
	--Recieved Column pointer	
				when 32=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 33=>
					if(SCK = '1') then
						r_buff(7) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 34=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 35=>
					if(SCK = '1') then
						r_buff(6)  <= MISO;						
						rstate<= rstate + 1;
					end if;
				when 36=>
					if(SCK = '0') then
						rstate<= rstate + 1;
					end if;
				when 37=>
					if(SCK = '1') then
						r_buff(5) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 38=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 39=>
					if(SCK = '1') then 
						r_buff(4) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 40=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 41=>
					if(SCK = '1') then
						r_buff(3) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 42=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 43=>
					if(SCK = '1') then
						r_buff(2) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 44=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 45=>
					if(SCK = '1') then
						r_buff(1) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 46=>
					if(SCK = '0') then
						rstate <= rstate + 1;
					end if;
				when 47=>
					if(SCK = '1') then
						r_buff(0) <= MISO;
						rstate <= rstate + 1;
					end if;
				when 48=>
					if(SCK = '0') then
						rstate <= rstate + 1;	
						serial_data_ready <= '1';
					end if;
				when 49=>
					serial_data_ready <= '0';
					if(CS = '1') then
						rstate <= 0;						
					end if;		
				when others=>					
					
			end case;
		end if;	
	end if;
end process;

process(clk) is 
begin
	if (rising_edge(clk)) then
		if(rst = '0') then
			write_fifo <= '0';
			cntl <= 0;
			rowptr <= (others=>'0');
			colptr <= (others=>'0');
			pixel <= (others=>'0');
			sync <= '0';
		else
			case cntl is
				when 0=>
					if(serial_data_ready = '1') then
						rowptr <= r_buff;
						colptr <= c_buff;
						pixel <= f_buff;
						cntl <= cntl + 1;
					end if;
				when 1=>
					if( sync = '0') then
						if( rowptr = "00000000" and colptr = "00000000") then
							sync <= '1';
							cntl <= cntl + 1;
						else
							cntl <= 0;
						end if;						
					else
						cntl <= cntl + 1;
					end if;
				when 2=>	--synchronized to beginning of frame
					if(write_fifo_busy = '0') then
						cntl <= cntl + 1;
					end if;
				when 3=>
					fifo_din <= pixel;
					write_fifo <= '1';
					cntl <= cntl + 1;
				when 4=>
					write_fifo <= '0';
					cntl <= 0;
			
			end case;
			
		end if;
	
	end if;

end process;




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

