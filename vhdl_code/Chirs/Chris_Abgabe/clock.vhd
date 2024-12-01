----------------------------------------------------------------------------------
-- Entity:Clock
-- Name: Chris Mueller
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity declaration for the clock module
-- The `clock` module divides the input clock frequency from the FPGA into a lower frequency clock for the CPU
entity clock is
    Port (
        fpga_clock_in : in  STD_LOGIC;  -- Input clock signal from the FPGA
        cpu_clock_out : out STD_LOGIC   -- Output clock signal for the CPU
    );
end clock;

-- Behavioral architecture for the clock entity
architecture Behavioral of clock is
    -- Define the number of FPGA clock cycles per new CPU clock cycle
    constant CountsPerClock : INTEGER := 10000; -- 1 equals 100 MHz -> 10kHz
    -- Signal to count FPGA clock cycles
    signal s_cnt : INTEGER range 0 to CountsPerClock := 0; 
    -- Signal to generate the new clock signal (toggled state)
    signal s_clk_new : STD_LOGIC := '0'; 

begin
    -- Process block triggered on every rising edge of the FPGA clock
    Process (fpga_clock_in)
    begin
        if rising_edge(fpga_clock_in) then
            -- Increment the counter on each FPGA clock cycle
            s_cnt <= s_cnt + 1;

            -- Check if the counter has reached the defined clock division threshold
            if s_cnt >= (CountsPerClock) then
                -- Reset the counter to 0
                s_cnt <= 0;
                -- Toggle the new lower clock signal
                s_clk_new <= not s_clk_new;
                -- Assign the toggled signal to the CPU clock output
                cpu_clock_out <= s_clk_new;
            end if;
        end if;
    end Process;
end Behavioral;
