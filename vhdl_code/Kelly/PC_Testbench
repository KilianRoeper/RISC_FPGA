library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pc is
-- Keine Ports, da es eine Testbench ist
end tb_pc;

architecture Behavioral of tb_pc is

    -- Konstanten für Operationen
    constant PC_OP_NOP   : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant PC_OP_INC   : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant PC_OP_RESET : STD_LOGIC_VECTOR(1 downto 0) := "11";

    -- Komponenten-Deklaration für den PC
    component pc
        Port (
            clk_in      : in STD_LOGIC;
            pc_op_in    : in STD_LOGIC_VECTOR (1 downto 0);
            pc_in       : in STD_LOGIC_VECTOR (15 downto 0);
            branch_in   : in STD_LOGIC;
            pc_out      : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    -- Signale für den Test
    signal clk_in      : STD_LOGIC := '0';
    signal pc_op_in    : STD_LOGIC_VECTOR(1 downto 0) := PC_OP_NOP;
    signal pc_in       : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal branch_in   : STD_LOGIC := '0';
    signal pc_out      : STD_LOGIC_VECTOR(7 downto 0);

    -- Test-Taktperiode
    constant clk_period : time := 10 ns;

begin

    -- Instanziierung des DUT (Device Under Test)
    uut: pc
        Port map (
            clk_in      => clk_in,
            pc_op_in    => pc_op_in,
            pc_in       => pc_in,
            branch_in   => branch_in,
            pc_out      => pc_out
        );

    -- Takt-Generator
    clk_process: process
    begin
        while true loop
            clk_in <= '0';
            wait for clk_period / 2;
            clk_in <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Testfälle
    test_process: process
    begin
        -- Testfall 1: Initialzustand
        wait for clk_period;
        assert pc_out = "00000000"
        report "Initial PC value incorrect" severity error;

        -- Testfall 2: Inkrementieren
        pc_op_in <= PC_OP_INC;
        wait for clk_period;
        assert pc_out = "00000001"
        report "PC increment incorrect" severity error;

        -- Testfall 3: Branch (Setzen des PC)
        branch_in <= '1';
        pc_in <= X"0055";
        wait for clk_period;
        branch_in <= '0';
        assert pc_out = "01010101"
        report "Branch operation incorrect" severity error;

        -- Testfall 4: Reset
        pc_op_in <= PC_OP_RESET;
        wait for clk_period;
        assert pc_out = "00000000"
        report "PC reset incorrect" severity error;

        -- Testfall 5: No operation (NOP)
        pc_op_in <= PC_OP_NOP;
        wait for clk_period;
        assert pc_out = "00000000"
        report "PC NOP operation incorrect" severity error;

        -- Test abgeschlossen
        report "All test cases passed" severity note;
        wait;
    end process;

end Behavioral;
