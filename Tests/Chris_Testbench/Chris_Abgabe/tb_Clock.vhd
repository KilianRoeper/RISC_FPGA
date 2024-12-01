----------------------------------------------------------------------------------
-- Testbench for CLock
-- Name: Chris Mueller
----------------------------------------------------------------------------------

-- Library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Entity declaration for the testbench
-- The entity 'tb_Clock' does not have any ports, since it is a testbench.
entity simulation_clock is
end simulation_clock;

-- Architecture definition
-- This architecture describes the behavior of the testbench.
architecture Behavioral of simulation_clock is

  -- Constant declaration for clock cycle time
  constant clk_time : time := 5 ns;  -- Set clock time to 5 nanoseconds
  
  -- Signal declarations for inputs and outputs of the testbench
  signal test_clk_in  : STD_LOGIC := '0';  -- Clock input signal (initial value '0')
  signal test_clk_out : STD_LOGIC := '0';  -- Clock output signal (initial value '0')
  
begin

  -- Instantiate the Unit Under Test (UUT): The clock module
  -- Here we map the input and output of the 'clock' entity to the testbench signals.
  uut: entity work.clock
    PORT MAP (
        fpga_clock_in => test_clk_in,  -- Map the test input clock to the FPGA input
        cpu_clock_out => test_clk_out  -- Map the test output clock to the CPU output
    );

  -- Clock generation process
  Testing_CLK: process
  begin
    -- Toggle the 'test_clk_in' signal (the input clock) every 'clk_time' period
    loop
        test_clk_in <= not test_clk_in;  -- Toggle the clock signal
        wait for clk_time;  -- Wait for the specified clock time (5 ns)
    end loop;
  end process;

end Behavioral;

