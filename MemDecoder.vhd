----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:26:26 11/17/2015 
-- Design Name: 
-- Module Name:    sram - Behavioral 
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
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MemDecoder is
port(
	clk: in std_logic;
	cpu_clk: in std_logic;
	addr: in std_logic_vector(31 downto 0);
	data_in: in std_logic_vector(31 downto 0);
	data_out: out std_logic_vector(31 downto 0);
	r: in std_logic;
	w: in std_logic;
	
	--device interface with sram
	sram_data:inout std_logic_vector(31 downto 0);
	sram_addr:out std_logic_vector(19 downto 0);
	ce:out std_logic:='0';
	oe:out std_logic:='1';
	we:out std_logic:='1';
	
	--device interface with serial
	serial_data_out:out std_logic_vector(31 downto 0);
	serial_data_in:in std_logic_vector(31 downto 0);
	serial_r:out std_logic;
	serial_w:out std_logic;
	serial_addr:out std_logic_vector(31 downto 0);
	
	led:out std_logic_vector(7 downto 0)
	
	);
end MemDecoder;

architecture Behavioral of MemDecoder is


	constant KSEG0_LO : std_logic_vector(31 downto 0) := X"80000000";
	constant KSEG0_HI : std_logic_vector(31 downto 0) := X"A0000000";

type state_t is ( idle,
						sram_read0,sram_read1,sram_read2,
						sram_write0,sram_write1,sram_write2,
						serial_write0,serial_write1,serial_write2,
						serial_read0,serial_read1,serial_read2);
signal state:state_t:=idle;
signal data_buffer:std_logic_vector(31 downto 0):="00000000000000000000000011111111";
signal count:integer:=0;
signal addr2write:std_logic_vector(19 downto 0):="00000000000000000000";
signal data2write:std_logic_vector(31 downto 0):="00000000000000000000000011111111";


--buffers for inputs
signal addr_buffer:std_logic_vector(31 downto 0):=x"00000000";
signal r_buffer:std_logic;
signal w_buffer:std_logic;

signal sram_data_buffer:std_logic_vector(31 downto 0);
signal serial_data_buffer:std_logic_vector(31 downto 0);

--signals for sram outputs mux
signal sram_out:std_logic_vector(31 downto 0);
signal sram_in:std_logic_vector(31 downto 0);

--signals for device source
signal is_sram:std_logic;
signal is_serial:std_logic;

begin

data_out <= sram_data_buffer when is_sram='1' else serial_data_buffer;



led <= data_buffer(7 downto 0);
process(clk)
begin
	if(clk'event and clk='1') then
		case state is
			when idle=>
				
				if(r = '1' and w = '0') then
					r_buffer<=r;
					w_buffer<=w;
					if (addr = X"bfd003f8" or addr = X"bfd003fc") then
						is_sram <= '0';
						is_serial<= '1';
						serial_r <= '1';
						serial_w <= '0';
						--serial_addr <= X"00000000" when addr = X"bfd003f8" else X"00000004";
						if(addr = X"bfd003f8") then serial_addr <= X"00000000"; end if;
						if(addr = X"bfd003fc") then serial_addr <= X"00000004"; end if;
						
						addr_buffer <= addr;
						state <= serial_read0;
					elsif (addr >= KSEG0_LO and addr < KSEG0_HI) then
						is_sram <= '1';
						is_serial<='0';
					--why to and ?
						sram_addr <= addr(21 downto 2);
						state <= sram_read0;
						sram_data <= (others => 'Z');
						we<='1';
						oe<='0'; 
					else
						is_sram <= '1';
						is_serial<='0';
						state <= sram_read0;
						sram_addr <= addr(21 downto 2);
						sram_data <= (others => 'Z');
						we <= '1';
						oe <='0';
					end if;
				elsif(r = '0' and w = '1') then
					r_buffer<=r;
					w_buffer<=w;
					if (addr = X"bfd003f8" or addr = X"bfd003fc") then
						is_sram <= '0';
						is_serial<= '1';
						serial_r <= '0';
						serial_w <= '1';
						--serial_addr <= X"00000000" when addr = X"bfd003f8" else X"00000004";
						if(addr = X"bfd003f8") then serial_addr <= X"00000000"; end if;
						if(addr = X"bfd003fc") then serial_addr <= X"00000004"; end if;
						serial_data_out <= data_in;
						state <= serial_write0;
					elsif (addr >= KSEG0_LO and addr < KSEG0_HI) then
						is_sram <= '1';
						is_serial<='0';
					--why to and ?
						sram_addr <= addr(21 downto 2);
						sram_data<= data_in;
						state <= sram_write0;
						oe<='1';
						we<='1';
					else
						is_sram <= '1';
						is_serial<='0';
						sram_addr <= addr(21 downto 2);
						sram_data<= data_in;
						state <= sram_write0;
						oe<='1';
						we<='1';
					end if;
				else
					state<=idle;
				end if;
			when sram_write0=>
				we<='0';
				state <= sram_write1;
			when sram_write1 =>
				state <= sram_write2;
			when sram_write2 =>
				sram_data<= (others=>'Z');
				we <= '1';
				state <= idle;
			when sram_read0 =>
				state <= sram_read1;
			when sram_read1=>
				oe<='1';
				sram_data_buffer <= sram_data;
				state <= sram_read2;
			when sram_read2 =>
				sram_data<=(others => 'Z');
				state<=idle;
			when serial_read0=>
				state <= serial_read1;
			when serial_read1=>
				serial_data_buffer <= serial_data_in;
				serial_r <='0';
				state <= serial_read2;
			when serial_read2=>
				state <= idle;
			when serial_write0=>
				state <= serial_write1;
			when serial_write1=>
				serial_w<='0';
				state <= serial_write2;
			when serial_write2=>
				state <= idle;
			when others=>
				state<= idle;
		end case;
	end if;
end process;
end Behavioral;

