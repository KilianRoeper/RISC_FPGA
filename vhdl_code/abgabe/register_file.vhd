----------------------------------------------------------------------------------
-- Entity: Register File 
-- Name: Chris Mueller
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity declaration for the register file
-- The `register_file` provides read and write access to a set of 8 registers, each 16 bits wide.
entity register_file is
    Port (  
      -- Inputs
        clk_in          : in  STD_LOGIC;                -- Clock signal
        enable_in       : in  STD_LOGIC;                -- Enable signal for the register file
        write_enable_in : in  STD_LOGIC;                -- Write enable signal for register A
        regA_data_in    : in  STD_LOGIC_VECTOR (15 downto 0); -- Data to be written to register A
        regA_select_in  : in  STD_LOGIC_VECTOR (2 downto 0);  -- Register A selection (write target)
        regB_select_in  : in  STD_LOGIC_VECTOR (2 downto 0);  -- Register B selection (read source)
        regC_select_in  : in  STD_LOGIC_VECTOR (2 downto 0);  -- Register C selection (read source)
        -- Outputs
        regB_out        : out STD_LOGIC_VECTOR (15 downto 0); -- Data output from register B
        regC_out        : out STD_LOGIC_VECTOR (15 downto 0)  -- Data output from register C
    );
end register_file;

-- Behavioral architecture for the register file entity
architecture Behavioral of register_file is
    -- Define an array of 8 registers, each 16 bits wide
    type register_type is array (0 to 7) of std_logic_vector(15 downto 0);  
    -- Declare a signal to hold the register values, initialized to all zeros
    signal regs: register_type := (others => X"0000");
begin
    -- Process triggered on the rising edge of the clock or when `enable_in` changes
    process(clk_in, enable_in)
    begin
        -- Operate only on the rising edge of the clock and when `enable_in` is high
        if rising_edge(clk_in) and enable_in = '1' then
            -- Read data from the register specified by `regB_select_in` and output it
            regB_out <= regs(to_integer(unsigned(regB_select_in)));
            
            -- Read data from the register specified by `regC_select_in` and output it
            regC_out <= regs(to_integer(unsigned(regC_select_in)));
            
            -- Write data to the register specified by `regA_select_in` if `write_enable_in` is high
            if (write_enable_in = '1') then
                regs(to_integer(unsigned(regA_select_in))) <= regA_data_in;
            end if;
        end if;
    end process;
end Behavioral;

