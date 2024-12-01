----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.11.2024 13:39:36
-- Design Name: 
-- Module Name: reset - Behavioral
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

entity reset is
Port ( 
        clk_in      : in STD_LOGIC;
        reset_out   : out STD_LOGIC
);
end reset;

architecture Behavioral of reset is

signal reset_done   : STD_LOGIC := '0';

begin
process(clk_in)
    begin
        if rising_edge(clk_in) then
            if reset_done = '0' then
                reset_out <= '1';  
                reset_done <= '1'; 
            else
                reset_out <= '0'; 
            end if;
        end if;
    end process; 

end Behavioral;
