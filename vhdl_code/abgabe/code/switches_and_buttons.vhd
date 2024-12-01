----------------------------------------------------------------------------------
-- Entity: switches_and_buttons
-- Name: Kilian Röper
----------------------------------------------------------------------------------

-- implements a module to handle all external in and ouputs for buttons and switches 
-- debouncing included

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.risc_constants.DEBOUNCE_THRESHOLD;

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
