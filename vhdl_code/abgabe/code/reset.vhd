----------------------------------------------------------------------------------
-- Entity: reset
-- Name: Kilian Röper
----------------------------------------------------------------------------------

-- resets the entire processor for exactly one clock cycle

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
