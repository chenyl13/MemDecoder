--------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
--
-- Create Date:   09:57:03 11/03/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_MemDecoder.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MemDecoder
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY top_MemDecoder IS
	port(clk:in std_logic;
	
		--sram
		addr_sram:out std_logic_vector(19 downto 0);
		data_bus:inout std_logic_vector(31 downto 0);
		ce: out std_logic:='0';
		oe: out std_logic:='1';
		we: out std_logic:='1';
		led:out std_logic_vector(7 downto 0):=x"00";
		RX:in std_logic;
		TX:out std_logic;
		reset : in std_logic
	);
END top_MemDecoder;
 
ARCHITECTURE behavior OF top_MemDecoder IS 
	function checkZ(data : std_logic_vector(31 downto 0)) return boolean is
	begin
		for i in 0 to 31 loop
			if data(i) /= 'Z' then
				return False;
			end if;
		end loop;
		return True;
	end checkZ;
 
    -- Component Declaration for the Unit Under Test (UUT)
 
	component Serial is
    Port (  addr : in STD_LOGIC_VECTOR(31 downto 0);
				clk : in  STD_LOGIC;
            reset : in  STD_LOGIC; 
				en_r : in STD_LOGIC; --serialController
				en_w : in STD_LOGIC; --serialController
            RX : in  STD_LOGIC;
            TX : out  STD_LOGIC;
            data_in : in  STD_LOGIC_VECTOR(31 downto 0);
				data_out : out  STD_LOGIC_VECTOR(31 downto 0);
				intr : out  STD_LOGIC
		);
	end component;
		
    COMPONENT MemDecoder
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
				led:out std_logic_vector(7 downto 0);
				
				serial_data_out:out std_logic_vector(31 downto 0);
				serial_data_in:in std_logic_vector(31 downto 0);
				serial_r:out std_logic;
				serial_w:out std_logic;
				serial_addr:out std_logic_vector(31 downto 0)
	
		);
    END COMPONENT;
	

	--Inputs
	signal addr : std_logic_vector(31 downto 0) := (others => '0');
	signal addr_serial : std_logic_vector(31 downto 0);
	signal r : std_logic := '0';
	signal w : std_logic := '0';
	signal data_in : std_logic_vector(31 downto 0) := (others => '0');
	signal sub_clk: std_logic := '0';
	signal cpu_clk : std_logic := '0';

	--Outputs
	signal data_out : std_logic_vector(31 downto 0);
	
	signal r_bus : std_logic;
	signal w_bus : std_logic;
	signal r_serial : std_logic;
	signal w_serial : std_logic;
	signal r_sram : std_logic;
	signal w_sram : std_logic;
	signal intr : std_logic;

	-- Clock period definitions
	constant clk_period : time := 10 ns;
	constant cpu_clk_period : time := 40 ns;
	
	signal test: std_logic:='1';
	signal led1: std_logic_vector(7 downto 0);
	type state_t is (state0, state1,state2,state3,state4);
	signal state:state_t:=state0;
	signal count:integer:=0;
	signal clk_count:integer:=0;
	signal data2write:std_logic_vector(31 downto 0):=X"00000001";
	signal addr2write:std_logic_vector(31 downto 0):=X"80000000";
	signal data_buffer:std_logic_vector(31 downto 0):=X"80000000";
	
	
	--signal intermeideate serial
	signal serial_data_out:std_logic_vector(31 downto 0);
	signal serial_data_in: std_logic_vector(31 downto 0);
	signal serial_r:std_logic;
	signal serial_w: std_logic;
	signal serial_addr:std_logic_vector(31 downto 0);
	
	signal intr_count : std_logic_vector(2 downto 0) := "000";
	signal sram_count : std_logic_vector(2 downto 0) := "000";
	
	signal inner_reset : std_logic;
BEGIN
--	led(7 downto 4) <= data_buffer(3 downto 0);
	
	inner_reset <= not reset;
	
	-- Instantiate the Unit Under Test (UUT)
   uut: MemDecoder PORT MAP (
				clk=>clk,
				cpu_clk=>cpu_clk,
				addr=>addr,
				data_in=>data_in,
				data_out=>data_out,
				r=>r,
				w=>w,
				sram_addr=>addr_sram,
				sram_data=>data_bus,
				ce=>ce,
				oe=>oe,
				we=>we,	
				led=>led1 ,
				serial_data_out=>serial_data_out,
				serial_data_in=>serial_data_in,
				serial_r=>serial_r,
				serial_w=>serial_w,
				serial_addr=>serial_addr
				);

    uut2: Serial PORT MAP(
				addr => serial_addr,
				clk => clk,
            reset =>inner_reset,
				en_r =>serial_r,
				en_w =>serial_w,
            RX => RX,
            TX => TX,
            data_in => serial_data_out,
				data_out =>serial_data_in,
				intr => intr
		);



--    mem: mem_stub Port map(  
--			addr => addr_sram,
--         data => data_bus,
--			r => r_sram,
--         w => w_sram,
--			reset => reset );

--	serial : serial_stub Port map(
--    		addr => addr_serial,
--			data => data_bus,
--			intr => intr, 
--			w => w_serial,
--			r => r_serial,
--			clk => clk,
--			reset => reset);

--   -- Clock process definitions
--   clk_process :process
--   begin
--		clk <= '0';
--		wait for clk_period/2;
--		clk <= '1';
--		wait for clk_period/2;
--   end process;
	
   sub_clk_process :process(clk)
   begin
		if clk'event and clk = '1' then
			sub_clk <= not sub_clk;
		end if;
   end process;
 
   cpu_clk_process :process(sub_clk)
   begin
		if sub_clk'event and sub_clk = '1' then
			cpu_clk <= not cpu_clk;
		end if;
   end process;
	
	process(cpu_clk, inner_reset)
	begin
--		if(cpu_clk'event and cpu_clk='1') then
--			case state is
--					when state0=>
--						led(0) <= '1';
--						w<='1';
--						r<='0';
--						addr<=addr2write;
--						data_in<=data2write;
--						state <= state2;
--					when state1=>
--					--inner cycles should start here
--					
--						state <= state2;
--					when state2=>
--					-- we can get data here
--						w <= '0';
--						r <= '1';
--						addr <= addr2write;
--						state <= state3;
--					when state3=>
--					-- inner start here
--						led(7 downto 4) <= data_out(3 downto 0);
--						if(count = 12500000) then
--							count <= 0;
--							state <= state0;
--							addr2write<= addr2write+4;
--							data2write<=data2write+1;
--						else
--							count <= count +1;
--							state <= state3;
--						end if;
--						
--					when state4=>
--					--get data hrere
--						
--					when others => 
--						state <= state0;

			if inner_reset = '1' then
				state <= state0;
				intr_count <= "000";
				sram_count <= "000";
				led(7 downto 5) <= intr_count;
				led(4 downto 2) <= sram_count;
				r <= '0';
				w <= '0';
			elsif cpu_clk'event and cpu_clk = '1' then
				case state is
					when state0 =>
						if intr = '1' then
							led(7 downto 5) <= intr_count;
							intr_count <= intr_count+1;
							r <= '1';
							w <= '0';
							addr <= X"bfd003f8";
							state <= state1;
						else
							r <= '0';
							w <= '0';
							state <= state0;
						end if;
						
					when state1 =>
						w <= '1';
						r <= '0';
						sram_count <= sram_count+1;
						addr <= addr2write;
						data_in <= data_out;
						state <= state2;
						
					when state2 =>
						w <= '0';
						r <= '0';
						addr2write <= addr2write + 4;
						state <= state3;
						led(7 downto 5) <= intr_count;
						led(4 downto 2) <= sram_count;
						
					when state3 =>
						w <= '1';
						r <= '0';
						addr <= X"bfd003f8";
						data_in <= X"00000065";
						state <= state0;
					
					when others =>
						state <= state0;

				end case;
			end if;
	end process;
	
--	led(3) <= test;
--	process(clk)
--	begin
--		if(clk'event and clk='1') then
--			if(clk_count = 50000000)then
--				clk_count <= 0;
--				test <= not test;
--			else
--				clk_count <= clk_count + 1;
--			end if;
--		end if;
--	end process;
-- 
--
--   -- Stimulus process
--   stim_proc: process
--   begin		
--	   reset <= '1';
--	   wait for 40 ns;
--		reset <= '0';
--	   wait for 50 ns;
--	   report "test write ram";
--		assert checkZ(data_bus) report "data_bus error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   addr <= X"80000000";
--	   r <= '0';
--	   w <= '1';
--	   data_in <= X"01234567";
--	   wait for 10 ns;
--	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
--	   assert data_bus = X"01234567" report "data_bus error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--	   wait for 10 ns;
--	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
--	   assert data_bus = X"01234567" report "data_bus error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '1' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '0' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--	   wait for 10 ns;
--	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
--	   assert checkZ(data_bus) report "data_bus error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--	   report "test read ram";
--	   wait for 10 ns;
--	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
--	   assert checkZ(data_bus) report "data_bus error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--	   r <= '1';
--	   w <= '0';
--	   wait for 10 ns;
--	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
--	   assert r_bus = '1' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '0' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--	   wait for 10 ns;
--	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
--	   assert data_out = X"01234567" report "data_out error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--	   wait for 10 ns;
--	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
--	   assert data_out = X"01234567" report "data_out error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--
--	   report "test write serial data";
--	   wait for 10 ns;
--	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
--	   assert checkZ(data_bus) report "data_bus error" severity error;
--	   assert data_out = X"01234567" report "data_out error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--	   r <= '0';
--	   w <= '1';
--	   data_in <= X"FFFFFFFF";
--	   addr <= X"bfd003f8";
--
--	   wait for 10 ns;
--	   assert addr_bus = X"bfd003f8" report "addr_bus error" severity error;
--	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
--	   assert data_bus = X"FFFFFFFF" report "data_bus error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--	   wait for 10 ns;
--	   assert addr_bus = X"bfd003f8" report "addr_bus error" severity error;
--	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
--		assert data_bus = X"FFFFFFFF" report "data_bus error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '1' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '1' report "w_serial error" severity error;
--
--	   wait for 10 ns;
--	   assert addr_bus = X"bfd003f8" report "addr_bus error" severity error;
--	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
--	   assert checkZ(data_bus) report "data_bus error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--
--	   report "test read serial data"; 
--	   wait for 10 ns;
--	   assert addr_bus = X"bfd003f8" report "addr_bus error" severity error;
--	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
--	   assert checkZ(data_bus) report "data_bus error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--	   r <= '1';
--	   w <= '0';
--	   wait for 10 ns;
--	   assert addr_bus = X"bfd003f8" report "addr_bus error" severity error;
--	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
--	   assert r_bus = '1' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '1' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--	   wait for 10 ns;
--	   assert addr_bus = X"bfd003f8" report "addr_bus error" severity error;
--	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
--	   assert data_bus = X"00000031" report "data_bus error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--	   wait for 10 ns;
--	   assert addr_bus = X"bfd003f8" report "addr_bus error" severity error;
--	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
--	   assert data_out = X"00000031" report "data_out error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--
--	   report "test read setial state";
--	   wait for 10 ns;
--	   assert addr_bus = X"bfd003f8" report "addr_bus error" severity error;
--	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
--	   assert checkZ(data_bus) report "data_bus error" severity error;
--	   assert data_out = X"00000031" report "data_out error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--	   addr <= X"bfd003fc";
--	   wait for 10 ns;
--	   assert addr_bus = X"bfd003fc" report "addr_bus error" severity error;
--	   assert addr_serial = X"00000004" report "addr_serial error" severity error;
--	   assert r_bus = '1' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '1' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--	   wait for 10 ns;
--	   assert addr_bus = X"bfd003fc" report "addr_bus error" severity error;
--	   assert addr_serial = X"00000004" report "addr_serial error" severity error;
--	   assert data_bus = X"00000001" report "data_bus error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--
--	   wait for 10 ns;
--	   assert addr_bus = X"bfd003fc" report "addr_bus error" severity error;
--	   assert addr_serial = X"00000004" report "addr_serial error" severity error;
--	   assert data_out = X"00000001" report "data_out error" severity error;
--	   assert r_bus = '0' report "r_bus error" severity error;
--	   assert w_bus = '0' report "w_bus error" severity error;
--	   assert r_sram = '1' report "r_sram error" severity error;
--	   assert w_sram = '1' report "w_sram error" severity error;
--	   assert r_serial = '0' report "r_serial error" severity error;
--	   assert w_serial = '0' report "w_serial error" severity error;
--		
--		wait;
--	   
--   end process;
--
END;
