-- Library declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;

-- Entity Declaration
-- The entity defines the top level of the design; in this case, a simulation decoder.
entity simulation_decoder is
end simulation_decoder;

-- Architecture definition
-- The architecture Behavioral specifies how the entity behaves during simulation.
architecture Behavioral of simulation_decoder is

  -- Constants for simulation timing
  constant clk_time : time := 5 ns;  -- Clock cycle time
  constant waitTime : time := 2 * clk_time;  -- Wait time between actions
  
  -- Signal declarations for inputs and outputs of the testbench
  signal test_clk_in          : STD_LOGIC := '1';  -- Clock signal (initial value '1')
  signal test_enable_in       : STD_LOGIC := '0';  -- Enable signal (initial value '0')
  signal test_write_enable_in : STD_LOGIC := '0';  -- Write enable signal (initial value '0')
  signal test_regA_data_in    : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";  -- 16-bit data input to Register A
  signal test_regA_select_in  : STD_LOGIC_VECTOR (2 downto 0) := "000";  -- 3-bit select input for Register A
  signal test_regB_select_in  : STD_LOGIC_VECTOR (2 downto 0) := "000";  -- 3-bit select input for Register B
  signal test_regC_select_in  : STD_LOGIC_VECTOR (2 downto 0) := "000";  -- 3-bit select input for Register C
  signal test_regB_out        : STD_LOGIC_VECTOR (15 downto 0);  -- 16-bit output from Register B
  signal test_regC_out        : STD_LOGIC_VECTOR (15 downto 0);  -- 16-bit output from Register C

begin

  -- Instantiate the Unit Under Test (UUT): A register file entity
  uut: entity work.register_file
    PORT MAP (
        clk_in          => test_clk_in,  -- Clock input
        enable_in       => test_enable_in,  -- Enable input
        write_enable_in => test_write_enable_in,  -- Write enable input
        regA_data_in    => test_regA_data_in,  -- Register A data input
        regA_select_in  => test_regA_select_in,  -- Register A select input
        regB_select_in  => test_regB_select_in,  -- Register B select input
        regC_select_in  => test_regC_select_in,  -- Register C select input
        regB_out        => test_regB_out,  -- Register B output
        regC_out        => test_regC_out  -- Register C output
    );

  -- Clock signal generation (flipping the clock every 'clk_time')
  Testing_CLK: process
  begin
    loop
        test_clk_in <= not test_clk_in;  -- Toggle clock signal
        wait for clk_time;  -- Wait for the specified clock time before toggling again
    end loop;    
  end process; 

  -- Register testbench process
  Testing_register: process
  begin
    -- Initial activation (enable the circuit and allow writing)
    test_enable_in <= '1';
    test_write_enable_in <= '1';

    -- Test 1: Write 1010101010101010 (AAAA) to register 000 and then read it
    test_regA_data_in <= "1010101010101010";  -- Write data to A
    test_regA_select_in <= "000";  -- Select register 000
    test_regB_select_in <= "000";  -- Select register 000 to read
    test_regC_select_in <= "000";  -- Select register 000 to read
    wait for clk_time;  -- Wait for the clock cycle

    wait for waitTime;  -- Wait for the specified wait time

    -- Test 2: Write 0101010101010101 (5555) to register 001 and then read register 000
    test_regA_data_in <= "0101010101010101";  -- Write data to A
    test_regA_select_in <= "001";  -- Select register 001
    test_regB_select_in <= "000";  -- Select register 000 to read
    test_regC_select_in <= "000";  -- Select register 000 to read
    wait for waitTime;

    -- Test 3: Write 0000111100001111 (0F0F) to register 010 and then read register 001
    test_regA_data_in <= "0000111100001111";  -- Write data to A
    test_regA_select_in <= "010";  -- Select register 010
    test_regB_select_in <= "001";  -- Select register 001 to read
    test_regC_select_in <= "001";  -- Select register 001 to read
    wait for waitTime;

    -- Additional tests follow the same pattern as above, writing to different registers
    -- and selecting other registers to read based on the specified test vectors.

    -- Disable write and read different registers
    test_write_enable_in <= '0';  -- Disable write operations

    -- Test read after disabling write
    test_regB_select_in <= "011";  -- Read from register 011
    test_regC_select_in <= "011";  -- Read from register 011
    wait for clk_time; 

    -- Disable enable signal and re-enable write to test subsequent writes
    test_enable_in <= '0';  -- Disable the enable signal
    test_write_enable_in <= '1';  -- Re-enable write operations

    -- Final test: Write 1110111011101110 (EEEE) to register 011 and read from registers 000 and 010
    test_regA_data_in <= "1110111011101110";  -- Write data to A
    test_regA_select_in <= "011";  -- Select register 011
    test_regB_select_in <= "011";  -- Select register 011 to read
    test_regC_select_in <= "011";  -- Select register 011 to read
    wait for waitTime;
    
    -- Final read from registers 010
    test_regB_select_in <= "011";  -- Read from register 011
    test_regC_select_in <= "011";  -- Read from register 011
    wait for clk_time;

  end process; 
end Behavioral;
