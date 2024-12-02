----------------------------------------------------------------------------------
-- Entity: tb_ram
-- Name: Kelly Velten
-- Description: Testbench for RAM module. Validates read, write, reset, 
--              and NOP behaviour of the RAM through various test cases.
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

entity custom_ram_tb is
end custom_ram_tb;

architecture Behavioral of custom_ram_tb is

    signal clk_in : STD_LOGIC := '0'; --Clock signal
    signal reset_in : STD_LOGIC := '0'; --Reset signal
    signal enable_in : STD_LOGIC := '0'; --Enable signal for RAM
    signal write_enable_in : STD_LOGIC := '0'; --Write enable signal
    signal addr_in : STD_LOGIC_VECTOR(4 downto 0) := (others => '0'); --address signal
    signal data_in : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); --data input signal for write
    signal data_out : STD_LOGIC_VECTOR(15 downto 0); --data out signal for read

-- component declaration for the RAM module under test
    component custom_ram
        Port (
            clk_in : in STD_LOGIC;
            reset_in : in STD_LOGIC;
            enable_in : in STD_LOGIC;
            write_enable_in : in STD_LOGIC;
            addr_in : in STD_LOGIC_VECTOR(4 downto 0);
            data_in : in STD_LOGIC_VECTOR(15 downto 0);
            data_out : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

begin
	-- instantiation of the RAM module
    uut: custom_ram
        Port map (
            clk_in => clk_in,
            reset_in => reset_in,
            enable_in => enable_in,
            write_enable_in => write_enable_in,
            addr_in => addr_in,
            data_in => data_in,
            data_out => data_out
        );

 -- Clock generation process (50 MHz clock with 20 ns period)
    clk_process : process
    begin
        clk_in <= '0';
        wait for 10 ns; --Low phase of clock
        clk_in <= '1';
        wait for 10 ns; --High phase of clock
    end process clk_process;

	--Stimulus process for applying test cases
    stimulus_process : process
    begin
        -- Step 1: Test reset functionality
        reset_in <= '1'; --Apply reset
        wait for 20 ns;
        reset_in <= '0'; --Deactivate reset
        wait for 20 ns;
        
        -- Step 2: Test write and read operation at address 1
        enable_in <= '1'; --Enable RAM
        write_enable_in <= '1'; --Enable write
        addr_in <= "00001";              -- Address 1
        data_in <= "0000000000001010";   -- Write value 10 in Hex
        wait for 20 ns;

        write_enable_in <= '0'; --Disable write for read operation
        wait for 20 ns;
        assert data_out = "0000000000001010" 
        report "Fehler bei Lesen von Adresse 1" severity error;

        -- Step 3: Test write and read operation at address 2
        write_enable_in <= '1'; -- Enable write
        addr_in <= "00010";              -- Address 2
        data_in <= "0000000000001100";   -- Write value 12 in Hex
        wait for 20 ns;

        write_enable_in <= '0'; --Disable write for read operation
        addr_in <= "00010";              -- return to address 2
        wait for 20 ns;
        assert data_out = "0000000000001100"
        report "Fehler bei Lesen von Adresse 2" severity error;

        -- Step 4: Test writing to multiple addresses
        write_enable_in <= '1'; --Enable write
        addr_in <= "00011";              -- Address 3
        data_in <= "0000000000001111";   -- Write value 15 in Hex
        wait for 20 ns;

        addr_in <= "00100";              -- Address 4
        data_in <= "0000000000000001";   -- Write value 1 in Hex
        wait for 20 ns;

        -- Step 5: Validate reading from multiple addresses
        write_enable_in <= '0'; --Disable write
        addr_in <= "00011";              -- Address 3
        wait for 20 ns;
        assert data_out = "0000000000001111"
        report "Fehler bei Lesen von Adresse 3" severity error;

        addr_in <= "00100";              -- Address 4
        wait for 20 ns;
        assert data_out = "0000000000000001"
        report "Fehler bei Lesen von Adresse 4" severity error;

        -- Step 6: Test reset functionality and memory retention
        reset_in <= '1'; --Apply reset
        wait for 20 ns;
        reset_in <= '0'; --Deactivate reset
        wait for 20 ns;

        -- Überprüfen, ob Daten nach Reset unverändert sind
        addr_in <= "00001"; --Address 1
        wait for 20 ns;
        assert data_out = "0000000000001010"
        report "Datenverlust bei Adresse 1 nach Reset" severity error;

        addr_in <= "00010"; --Address 2
        wait for 20 ns;
        assert data_out = "0000000000001100"
        report "Datenverlust bei Adresse 2 nach Reset" severity error;

        -- Step 7: Test reading from uninitialized addresses 
        addr_in <= "00101";  -- Address 5, unwritten
        wait for 20 ns;
        assert data_out = "0000000000000000"
        report "Nicht beschriebene Adresse 5 enthält nicht NOP" severity error;

        -- Ende der Simulation
        wait;
    end process stimulus_process;

end Behavioral;
