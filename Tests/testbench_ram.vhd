----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.11.2024 14:36:09
-- Design Name: 
-- Module Name: testbench_ram - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testbench_ram is
--  Port ( );
end testbench_ram;

architecture Behavioral of testbench_ram is
component ram
    Port ( clk_in           : in STD_LOGIC;
           write_enable_in  : in STD_LOGIC;
           enable_in        : in STD_LOGIC;
           data_in          : in STD_LOGIC_VECTOR (15 downto 0);
           addr_in          : in STD_LOGIC_VECTOR (15 downto 0);
           
           data_out         : out STD_LOGIC_VECTOR (15 downto 0)
       );
    end component;
    
-- ram signals 
signal write_enable_in      : STD_LOGIC := '0';
signal ram_enable_combined  : STD_LOGIC := '0';
signal ram_data_in          : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
signal ram_address          : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
signal ram_data_out         : STD_LOGIC_VECTOR(15 downto 0) := X"0000";

-- clock signals
constant clk_period : time      := 10 ns;
signal cpu_clock 	: STD_LOGIC := '0';

begin

cpu_ram : ram PORT MAP (
        clk_in          => cpu_clock,
        write_enable_in => write_enable_in,
        enable_in       => ram_enable_combined,
        data_in         => ram_data_in,
        addr_in         => ram_address,

        data_out        => ram_data_out
        );
        
clk_process : process
    begin
        cpu_clock <= '0';
        wait for clk_period / 2;
        cpu_clock <= '1';
        wait for clk_period / 2;
    end process;
        
vectors: process
begin   
        -- initialise
        write_enable_in <= '0';
        ram_enable_combined <= '0';
        ram_data_in <= X"0000";
        ram_address <= X"0000";
        wait for clk_period;
        
        -- write to RAM
        ram_enable_combined <= '1'; 
        ram_data_in <= X"ABCD";     
        ram_address <= X"0000";    
        write_enable_in <= '1';     
        wait for clk_period;    

        -- reading from RAM
        write_enable_in <= '0';    
        ram_data_in <= X"0000";    
        wait for clk_period;

        -- assert with expectation
        assert (ram_data_out = X"ABCD") report "Fehler: Erwartete Daten nicht gelesen" severity error;
        
        -- end
        wait;
end process;
         
end Behavioral;
