----------------------------------------------------------------------------------
-- Testbench for Decoder
-- Name: Chris Mueller
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.RISC_constants.all; -- Import constants like opcode definitions from the RISC_constants package

-- Entity declaration for the testbench testbench
-- This testbench verifies the functionality of the decoder module.
entity testbench_decoder is
end testbench_decoder;

architecture Behavioral of testbench_decoder is
  -- Clock and timing constants
  constant clk_time : time := 5 ns;         -- Clock period (5 ns for a 200 MHz clock)
  constant waitTime : time := 2 * clk_time; -- General wait time between instructions
  constant InvalidTime : time := 1.5 * clk_time; -- Optional time duration for invalid states
  
  -- Signals for inputs to the decoder module
  signal test_clk_in          : STD_LOGIC := '1'; -- Clock signal for the decoder
  signal test_enable_in       : STD_LOGIC := '0'; -- Enable signal (activates the decoder when set to '1')
  signal test_instruction_in  : STD_LOGIC_VECTOR (15 downto 0); -- 16-bit input instruction
  
  -- Temporary signals for constructing instructions
  signal OP_Code : STD_LOGIC_VECTOR (3 downto 0); -- Opcode portion of the instruction
  signal RegA    : STD_LOGIC_VECTOR (2 downto 0) := "000"; -- Register A selector
  signal RegB    : STD_LOGIC_VECTOR (2 downto 0) := "000"; -- Register B selector
  signal RegC    : STD_LOGIC_VECTOR (2 downto 0) := "000"; -- Register C selector
  signal Im      : STD_LOGIC_VECTOR (7 downto 0) := "00000000"; -- Immediate value
  signal Flag    : STD_LOGIC := '0'; -- Flag bit (e.g., for branching instructions)

  -- Signals to capture the outputs of the decoder module
  signal test_alu_op_out       : STD_LOGIC_VECTOR (4 downto 0); -- ALU operation output
  signal test_im_data_out      : STD_LOGIC_VECTOR (15 downto 0); -- Immediate data output
  signal test_regA_select_out  : STD_LOGIC_VECTOR (2 downto 0); -- Register A selector output
  signal test_regB_select_out  : STD_LOGIC_VECTOR (2 downto 0); -- Register B selector output
  signal test_regC_select_out  : STD_LOGIC_VECTOR (2 downto 0); -- Register C selector 

begin
  uut: entity work.decoder
       PORT MAP (
          clk_in            => test_clk_in,
          enable_in         => test_enable_in,
          instruction_in    => test_instruction_in,
          alu_op_out        => test_alu_op_out,        
          im_data_out       => test_im_data_out,           
          regA_select_out   => test_regA_select_out,  
          regB_select_out   => test_regB_select_out,   
          regC_select_out   => test_regC_select_out
       );    

  -- Clock Generation Process
  -- Generates a periodic clock signal with the specified period (`clk_time`).
  Testing_CLK: process
  begin
    loop
        test_clk_in <= not test_clk_in; -- Toggle clock signal
        wait for clk_time;              -- Wait for half clock period
    end loop;    
  end process; 

  -- Testing Process
  -- Provides a series of test instructions to the decoder module to verify its behavior.
  Testing_ins: process
  begin
        -- Start Testing with decoder disabled for 4 instructions to show that the decoder 
        -- dosen't working wihtout the enable signal
        -- Store Word (SW) Instruction: 0x5EA4
        -- SW: Opcode 0101, RegA: 111, Flag: 0, RegB: 101, RegC: 001, Suffix: 00
        OP_Code <= OPCODE_SW;          -- Assign the SW opcode
        RegA <= "111";                 -- Set Register A selector
        Flag <= '0';                   -- Set Flag bit
        RegB <= "101";                 -- Set Register B selector
        RegC <= "001";                 -- Set Register C selector
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "00"; -- Concatenate to form instruction
        wait for waitTime;

        -- Branch Equal (BEQ) Instruction: 0x75FF
        -- BEQ: Opcode 0111, RegA: 010, Flag: 1, RegB: 111, RegC: 111, Suffix: 11
        OP_Code <= OPCODE_BEQ;         -- Assign the BEQ opcode
        RegA <= "010";                 -- Set Register A selector
        Flag <= '1';                   -- Set Flag bit
        RegB <= "111";                 -- Set Register B selector
        RegC <= "111";                 -- Set Register C selector
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "11"; -- Concatenate to form instruction
        wait for waitTime;

        -- Branch (B) Instruction: 0x84FF
        -- B: Opcode 1000, RegA: 010, Flag: 0, Immediate: 11111111
        OP_Code <= OPCODE_B;           -- Assign the B opcode
        RegA <= "010";                 -- Set Register A selector
        Flag <= '0';                   -- Set Flag bit
        Im <= "11111111";              -- Set Immediate value
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & Im; -- Concatenate to form instruction
        wait for waitTime;

        -- Logical AND Instruction: 0x3FB3
        -- AND: Opcode 0011, RegA: 111, Flag: 1, RegB: 101, RegC: 100, Suffix: 11
        OP_Code <= OPCODE_AND;         -- Assign the AND opcode
        RegA <= "111";                 -- Set Register A selector
        Flag <= '1';                   -- Set Flag bit
        RegB <= "101";                 -- Set Register B selector
        RegC <= "100";                 -- Set Register C selector
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "11"; -- Concatenate to form instruction
        wait for waitTime;   

        ------------------------------------------------------------------------------------------------------------
         
         -- Enable the decoder to see How its working
        test_enable_in <= '1';test_enable_in <= '1'; -- Set enable signal to '1' to activate the decoder

        ------------------------------------------------------------------------------------------------------------

        -- Store and Branch instructions

        -- Store Word (SW) Instruction: 0x5EA4
        -- SW Format: Opcode (0101), RegA (111), Flag (0), RegB (101), RegC (001), Suffix (00)
        OP_Code <= OPCODE_SW;       -- Assign the SW opcode (0101) to specify a Store Word operation
        RegA <= "111";              -- Set Register A selector to "111"
        Flag <= '0';                -- Set Flag bit to '0'
        RegB <= "101";              -- Set Register B selector to "101"
        RegC <= "001";              -- Set Register C selector to "001"
        wait for clk_time;          -- Wait for one clock period
        test_instruction_in <= OPCODE_SW & RegA & Flag & RegB & RegC & "00"; 
                                    -- Concatenate fields to form the full 16-bit SW instruction
        wait for clk_time;          -- Wait for another clock period to simulate instruction execution

        -- Branch Equal (BEQ) Instruction: 0x75FF
        -- BEQ Format: Opcode (0111), RegA (010), Flag (1), RegB (111), RegC (111), Suffix (11)
        OP_Code <= OPCODE_BEQ;      -- Assign the BEQ opcode (0111) to specify a Branch Equal operation
        RegA <= "010";              -- Set Register A selector to "010"
        Flag <= '1';                -- Set Flag bit to '1' (indicating the condition to check)
        RegB <= "111";              -- Set Register B selector to "111"
        RegC <= "111";              -- Set Register C selector to "111"
        wait for clk_time;          -- Wait for one clock period
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "11"; 
                                    -- Concatenate fields to form the full 16-bit BEQ instruction
        wait for clk_time;          -- Wait for another clock period to simulate instruction execution

        -- Branch (B) Instruction: 0x84FF
        -- B Format: Opcode (1000), RegA (010), Flag (0), Immediate (11111111)
        OP_Code <= OPCODE_B;        -- Assign the B opcode (1000) to specify a Branch operation
        RegA <= "010";              -- Set Register A selector to "010"
        Flag <= '0';                -- Set Flag bit to '0' (indicating no condition)
        RegB <= "111";              -- (Unused in this example but initialized for clarity)
        Im <= "11111111";           -- Set Immediate value to "11111111" (target address)
        wait for clk_time;          -- Wait for one clock period
        test_instruction_in <= OP_Code & RegA & Flag & Im; 
                                    -- Concatenate fields to form the full 16-bit B instruction
        wait for clk_time;          -- Wait for another clock period to simulate instruction execution

        ------------------------------------------------------------------------------------------------------------
        -- Aretmetic instructions
        -- Addition (ADD) Instruction: 0x0FB3
        -- ADD Format: Opcode (0000), RegA (111), Flag (1), RegB (101), RegC (100), Suffix (11)
        OP_Code <= OPCODE_ADD;       -- Assign the ADD opcode (0000) to perform an addition operation
        RegA <= "111";               -- Set Register A selector to "111"
        Flag <= '1';                 -- Set Flag bit to '1' (indicating an additional operation behavior, if applicable)
        RegB <= "101";               -- Set Register B selector to "101"
        RegC <= "100";               -- Set Register C selector to "100"
        wait for clk_time;           -- Wait for one clock period
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "11"; 
                                     -- Concatenate fields to form the full 16-bit ADD instruction
        wait for clk_time;           -- Wait for another clock period to simulate instruction execution

        -- Subtraction (SUB) Instruction: 0x1650
        -- SUB Format: Opcode (0001), RegA (011), Flag (0), RegB (010), RegC (100), Suffix (00)
        OP_Code <= OPCODE_SUB;       -- Assign the SUB opcode (0001) to perform a subtraction operation
        RegA <= "011";               -- Set Register A selector to "011"
        Flag <= '0';                 -- Set Flag bit to '0'
        RegB <= "010";               -- Set Register B selector to "010"
        RegC <= "100";               -- Set Register C selector to "100"
        wait for clk_time;           -- Wait for one clock period
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "00"; 
                                     -- Concatenate fields to form the full 16-bit SUB instruction
        wait for clk_time;           -- Wait for another clock period to simulate instruction execution

        -- AND Instruction: 0x0FB3
        -- AND Format: Opcode (0011), RegA (011), Flag (0), RegB (010), RegC (100), Suffix (11)
        OP_Code <= OPCODE_AND;       -- Assign the AND opcode (0011) to perform a bitwise AND operation
        RegA <= "011";               -- Set Register A selector to "011"
        Flag <= '0';                 -- Set Flag bit to '0'
        RegB <= "010";               -- Set Register B selector to "010"
        RegC <= "100";               -- Set Register C selector to "100"
        wait for clk_time;           -- Wait for one clock period
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "00"; 
                                     -- Concatenate fields to form the full 16-bit AND instruction
        wait for clk_time;           -- Wait for another clock period to simulate instruction execution

        -- OR Instruction: 0x2650
        -- OR Format: Opcode (0010), RegA (011), Flag (0), RegB (010), RegC (100), Suffix (00)
        OP_Code <= OPCODE_OR;        -- Assign the OR opcode (0010) to perform a bitwise OR operation
        RegA <= "011";               -- Set Register A selector to "011"
        Flag <= '0';                 -- Set Flag bit to '0'
        RegB <= "010";               -- Set Register B selector to "010"
        RegC <= "100";               -- Set Register C selector to "100"
        wait for clk_time;           -- Wait for one clock period
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "00"; 
                                      -- Concatenate fields to form the full 16-bit OR instruction
        wait for clk_time;           -- Wait for another clock period to simulate instruction execution

        -- Shift-Right Logical (SLR) Instruction: 0x2650
        -- SLR Format: Opcode (1001), RegA (011), Flag (0), RegB (010), RegC (100), Suffix (00)
        OP_Code <= OPCODE_SLR;       -- Assign the SLR opcode (1001) to perform a shift-right logical operation
        RegA <= "011";               -- Set Register A selector to "011"
        Flag <= '0';                 -- Set Flag bit to '0'
        RegB <= "010";               -- Set Register B selector to "010"
        RegC <= "100";               -- Set Register C selector to "100"
        wait for clk_time;           -- Wait for one clock period
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "00"; 
                                      -- Concatenate fields to form the full 16-bit SLR instruction
        wait for clk_time;           -- Wait for another clock period to simulate instruction execution

        -- shift-left logical (SLL) Instruction: 0x2650
        -- SLL Format: Opcode (1010), RegA (011), Flag (0), RegB (010), RegC (100), Suffix (00)
        OP_Code <= OPCODE_SLL;       -- Assign the SLL opcode (1010) to perform a shift-left logical operation
        RegA <= "011";               -- Set Register A selector to "011"
        Flag <= '0';                 -- Set Flag bit to '0'
        RegB <= "010";               -- Set Register B selector to "010"
        RegC <= "100";               -- Set Register C selector to "100"
        wait for clk_time;           -- Wait for one clock period
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "00"; 
                                      -- Concatenate fields to form the full 16-bit SLL instruction
        wait for clk_time;           -- Wait for another clock period to simulate instruction execution


        ----------------------------------------------------------------------------
        -- Compaire and Load instructions

        -- Shift-Left Logical (SLL) Instruction: 0xA650
        -- CMP Format: Opcode (1011), RegA (011), Flag (0), RegB (010), RegC (100), Suffix (00)
        OP_Code <= OPCODE_CMP;        -- Assign the CMP opcode (1011) to perform a comparison operation
        RegA <= "011";                -- Set Register A selector to "011"
        Flag <= '0';                  -- Set Flag bit to '0' (indicating no special flag for this operation)
        RegB <= "010";                -- Set Register B selector to "010"
        RegC <= "100";                -- Set Register C selector to "100"
        wait for clk_time;            -- Wait for one clock period
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "00"; 
                                      -- Concatenate fields to form the full 16-bit CMP instruction
        wait for clk_time;            -- Wait for another clock period to simulate instruction execution

        -- Load Immediate(SLL) Instruction: 0x4650
        -- LI Format: Opcode (0100), RegA (011), Flag (0), Immediate (10101010)
        OP_Code <= OPCODE_LI;         -- Assign the LI opcode (0100) to load an immediate value
        RegA <= "011";                -- Set Register A selector to "011"
        Flag <= '0';                  -- Set Flag bit to '0'
        Im <= "10101010";             -- Set the Immediate value to "10101010"
        wait for clk_time;            -- Wait for one clock period
        test_instruction_in <= OP_Code & RegA & Flag & Im; 
                                      -- Concatenate fields to form the full 16-bit LI instruction
        wait for clk_time;            -- Wait for another clock period to simulate instruction execution

        -- Load Immediate(SLL) Instruction: 0x6600
        -- LW Format: Opcode (0110), RegA (011), RegB (010), Flag (0), Suffix (00000000)
        OP_Code <= OPCODE_LW;         -- Assign the LW opcode (0110) to load data from memory
        RegA <= "011";                -- Set Register A selector to "011"
        RegB <= "010";                -- Set Register B selector to "010"
        Flag <= '0';                  -- Set Flag bit to '0'
        wait for clk_time;            -- Wait for one clock period
        test_instruction_in <= OP_Code & RegA & Flag & "00000000"; 
                                    -- Concatenate fields to form the full 16-bit LW instruction with a zeroed-out suffix
        wait for clk_time;          -- Wait for another clock period to simulate instruction execution
  end process; 
end Behavioral;