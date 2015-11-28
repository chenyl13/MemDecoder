--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:32:38 11/28/2015
-- Design Name:   
-- Module Name:   D:/code/git/github/memdecoder/test_top.vhd
-- Project Name:  memdecoder
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top_MemDecoder
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_top IS
END test_top;
 
ARCHITECTURE behavior OF test_top IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top_MemDecoder
    PORT(
         clk : IN  std_logic;
         addr_sram : OUT  std_logic_vector(19 downto 0);
         data_bus : INOUT  std_logic_vector(31 downto 0);
         ce : OUT  std_logic;
         oe : OUT  std_logic;
         we : OUT  std_logic;
         led : OUT  std_logic_vector(7 downto 0);
         RX : IN  std_logic;
         TX : OUT  std_logic;
         reset : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal RX : std_logic := '0';
   signal reset : std_logic := '0';

	--BiDirs
   signal data_bus : std_logic_vector(31 downto 0);

 	--Outputs
   signal addr_sram : std_logic_vector(19 downto 0);
   signal ce : std_logic;
   signal oe : std_logic;
   signal we : std_logic;
   signal led : std_logic_vector(7 downto 0);
   signal TX : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top_MemDecoder PORT MAP (
          clk => clk,
          addr_sram => addr_sram,
          data_bus => data_bus,
          ce => ce,
          oe => oe,
          we => we,
          led => led,
          RX => RX,
          TX => TX,
          reset => reset
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
		
      wait for 100 ns;	

      wait for clk_period*10;
		
		reset <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
