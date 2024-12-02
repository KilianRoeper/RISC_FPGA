----------------------------------------------------------------------------------
-- Entity: tb_pc
-- Name: Kelly Velten
-- Description: Testbench for the Program Counter (PC) module. 
--This testbench validates PC operations including increment, branch, reset, and NOP
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.risc_constants.ALL;

entity ram is
generic (
        ram_content : ram_type := (others => (others => '0'))
        );
Port (  clk_in           : in STD_LOGIC;
        write_enable_in  : in STD_LOGIC;
        enable_in        : in STD_LOGIC;
        data_in          : in STD_LOGIC_VECTOR (15 downto 0);
        addr_in          : in STD_LOGIC_VECTOR (7 downto 0);
        
        data_out         : out STD_LOGIC_VECTOR (15 downto 0)
       );
end ram;

architecture Behavioral of ram is
   signal ram: ram_type := ram_content;
   
begin
process (clk_in, enable_in)
	begin
		if rising_edge(clk_in) and enable_in = '1' then
			-- put the input data into the RAM at the specified address if the write enable signal is high
			if (write_enable_in = '1') then
				ram(to_integer(unsigned(addr_in))) <= data_in;
			else
			-- ouput the stored data at addr_in if the ram is enabled
				data_out <= ram(to_integer(unsigned(addr_in)));
			end if;
		end if;
	end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pc is
-- Entity declaration for the testbench, no ports as it is a testbench
end tb_pc;

architecture Behavioral of tb_pc is

    -- Constants for PC operations
    constant PC_OP_NOP   : STD_LOGIC_VECTOR(1 downto 0) := "00"; --no operation
    constant PC_OP_INC   : STD_LOGIC_VECTOR(1 downto 0) := "01"; -- increment operation
    constant PC_OP_RESET : STD_LOGIC_VECTOR(1 downto 0) := "11"; -- reset operation

    -- Component declaration for the Program Counter module
    component pc
        Port (
            clk_in      : in STD_LOGIC; --Clock input
            pc_op_in    : in STD_LOGIC_VECTOR (1 downto 0); --PC operation input
            pc_in       : in STD_LOGIC_VECTOR (15 downto 0); --Input value for branch operation
            branch_in   : in STD_LOGIC; --Branch enable signal
            pc_out      : out STD_LOGIC_VECTOR (7 downto 0) --Output:current value of PC
        );
    end component;

    -- Signal declarations for testbench inputs and outputs
    signal clk_in      : STD_LOGIC := '0'; --Clock signal
    signal pc_op_in    : STD_LOGIC_VECTOR(1 downto 0) := PC_OP_NOP; --PC operations input
    signal pc_in       : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; --PC input for branching
    signal branch_in   : STD_LOGIC := '0'; --Branch enable signal
    signal pc_out      : STD_LOGIC_VECTOR(7 downto 0); --PC output signal

    -- Clock period for simulation
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the device under test
    uut: pc
        Port map (
            clk_in      => clk_in,
            pc_op_in    => pc_op_in,
            pc_in       => pc_in,
            branch_in   => branch_in,
            pc_out      => pc_out
        );

    -- Clock generation process
    clk_process: process
    begin
        while true loop
            clk_in <= '0'; --Clock low
            wait for clk_period / 2;
            clk_in <= '1'; --Clock high
            wait for clk_period / 2;
        end loop;
    end process;

    -- Test cases process
    test_process: process
    begin
        -- Test case 1: Initial state
        wait for clk_period; -- Wait for first clock edge
        assert pc_out = "00000000" -- Expect PC to start at 0
        report "Initial PC value incorrect" severity error;

        -- Test Case 2: Increment operation
        pc_op_in <= PC_OP_INC; -- Set operation to increment
        wait for clk_period;
        assert pc_out = "00000001" -- Expect PC to increment by 1
        report "PC increment incorrect" severity error;

        -- Test Case 3: Branch operation
        branch_in <= '1';  -- Enable branch
        pc_in <= X"0055";  -- Set PC input value
        wait for clk_period;
        branch_in <= '0';  -- Disable branch
        assert pc_out = "01010101"  -- Expect PC to branch to 0x55
        report "Branch operation incorrect" severity error;

        -- Test Case 4: Reset operation
        pc_op_in <= PC_OP_RESET;  -- Set operation to reset
        wait for clk_period;
        assert pc_out = "00000000"  -- Expect PC to reset to 0
        report "PC reset incorrect" severity error;

        -- Test Case 5: No operation (NOP)
        pc_op_in <= PC_OP_NOP;  -- Set operation to NOP
        wait for clk_period;
        assert pc_out = "00000000" -- Expect PC to remain unchanged
        report "PC NOP operation incorrect" severity error;

        -- Test complete
        report "All test cases passed" severity note;
        wait;
    end process;

end Behavioral;
