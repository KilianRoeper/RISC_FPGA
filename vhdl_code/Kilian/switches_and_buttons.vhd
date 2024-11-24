----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.11.2024 13:24:37
-- Design Name: 
-- Module Name: switches_and_buttons - Behavioral
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

entity switches_and_buttons is
--  Port ( );
end switches_and_buttons;

architecture Behavioral of switches_and_buttons is
    -- switches 
    --signal debounced_switch0    : STD_LOGIC := '0';
    
    -- CPU signals/ constants
    --signal cpu_clock_and_switch : STD_LOGIC := '0';
begin
    -- anding switch with clock for further control
--    cpu_clock_and_switch <= debounced_switch0 and cpu_clock;
    
--    switch_debounce: process(cpu_clock)
--    variable debounce_counter: integer := 0;
--    begin
--        if rising_edge(cpu_clock) then
--            if sw0 /= debounced_switch0 then
--                debounce_counter := debounce_counter + 1;
--                if debounce_counter > DEBOUNCE_THRESHOLD then
--                    debounced_switch0 <= sw0;
--                    debounce_counter := 0;
--                end if;
--            else
--                debounce_counter := 0;
--            end if;
--        end if;
--    end process;

end Behavioral;
