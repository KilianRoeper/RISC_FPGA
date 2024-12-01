----------------------------------------------------------------------------------
-- Entity: Decoder
-- Name: Chris Mueller
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity declaration for the decoder module
-- The `decoder` extracts fields from the instruction and generates control signals for other components.
entity decoder is
    Port (
      -- Inputs
        clk_in            : in  STD_LOGIC;                      -- Clock signal
        enable_in         : in  STD_LOGIC;                      -- Enable signal for the decoder
        instruction_in    : in  STD_LOGIC_VECTOR (15 downto 0); -- Input instruction (16 bits)
      -- Outputs
        alu_op_out        : out STD_LOGIC_VECTOR (4 downto 0);  -- Output for ALU operation code
        im_data_out       : out STD_LOGIC_VECTOR (7 downto 0);  -- Immediate data output
        -- Register Selects
        regA_select_out   : out STD_LOGIC_VECTOR (2 downto 0);  -- Register A-line selection output
        regB_select_out   : out STD_LOGIC_VECTOR (2 downto 0);  -- Register B-line selection output
        regC_select_out   : out STD_LOGIC_VECTOR (2 downto 0)   -- Register C-line selection output
    );
end decoder;

-- Behavioral architecture for the decoder entity
architecture Behavioral of decoder is
begin
    -- Process triggered on the rising edge of the clock or any change in the enable signal
    process (clk_in, enable_in)
    begin
        -- Execute decoding only on the rising edge of the clock and if enable signal is high
        if rising_edge(clk_in) and enable_in = '1' then
            -- Extract the register A select field from the instruction (bits 11 to 9)
            regA_select_out <= instruction_in(11 downto 9);
            
            -- Extract the register B select field from the instruction (bits 7 to 5)
            regB_select_out <= instruction_in(7 downto 5);
            
            -- Extract the register C select field from the instruction (bits 4 to 2)
            regC_select_out <= instruction_in(4 downto 2);
            
            -- Extract immediate data from the instruction (bits 7 to 0)
            im_data_out <= instruction_in(7 downto 0);
            
            -- Combine opcode + flag (bits 15 to 12) and bit 8 for the ALU operation code
            alu_op_out <= instruction_in(15 downto 12) & instruction_in(8);
        end if;
    end process;
end Behavioral;

