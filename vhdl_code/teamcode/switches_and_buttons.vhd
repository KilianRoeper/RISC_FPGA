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
library work;
use work.risc_constants.DEBOUNCE_THRESHOLD;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity switches_and_buttons is
  Port ( 
        clk_in      : in STD_LOGIC;
        sw_in       : in STD_LOGIC;
        deb_sw_out  : out STD_LOGIC
        );
end switches_and_buttons;

architecture Behavioral of switches_and_buttons is
    -- switches 
    signal debounced_switch0    : STD_LOGIC := '0';
    
begin    
    debounce: process(clk_in)
    variable debounce_counter: integer := 0;
    begin
        if rising_edge(clk_in) then
            if sw_in /= debounced_switch0 then
                debounce_counter := debounce_counter + 1;
                if debounce_counter > DEBOUNCE_THRESHOLD then
                    debounced_switch0 <= sw_in;
                    debounce_counter := 0;
                end if;
            else
                debounce_counter := 0;
            end if;
        end if;
    end process;
    
    set_switch : process(clk_in, debounced_switch0)
    begin   
        if rising_edge(clk_in) then
            deb_sw_out <= debounced_switch0;
        end if;
    end process;

end Behavioral;
