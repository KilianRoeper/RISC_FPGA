----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.11.2024 16:26:17
-- Design Name: 
-- Module Name: clock - Behavioral
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

entity clock is
Port (
        fpga_clock_in : in  STD_LOGIC;
        cpu_clock_out : out STD_LOGIC
    );
end clock;

architecture Behavioral of clock is
    constant CountsPerClock : INTEGER := 10000;
    signal s_cnt : INTEGER range 0 to CountsPerClock := 0;
    signal s_clk_new : STD_LOGIC := '0';

begin
Process (fpga_clock_in)
    begin
        if rising_edge(fpga_clock_in) then
            s_cnt <= s_cnt + 1;
            if s_cnt >= (CountsPerClock) then
                s_cnt <= 0;
                s_clk_new <= not s_clk_new;
                cpu_clock_out <= s_clk_new;
            end if;
        end if;
    end Process;

end Behavioral;
