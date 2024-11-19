library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.RISC_constants.all;  -- Importiere alle Konstanten aus dem Package

entity simulation_decoder is
end simulation_decoder;

architecture Behavioral of simulation_decoder is
  constant clk_time :time    := 5 ns;
  constant waitTime :time    := 2 * clk_time;
  constant InvalidTime :time := 1.5 * clk_time;
  
  signal test_clk_in          : STD_LOGIC := '1';
  signal test_enable_in       : STD_LOGIC := '0'; -- Setze auf '1', falls immer aktiviert
  signal test_instruction_in  : STD_LOGIC_VECTOR (15 downto 0);
  
  signal OP_Code : STD_LOGIC_VECTOR (3 downto 0);
  signal RegA    : STD_LOGIC_VECTOR (2 downto 0) := "000"; -- Initialisiere auf einen gültigen Wert
  signal RegB    : STD_LOGIC_VECTOR (2 downto 0) := "000";
  signal RegC    : STD_LOGIC_VECTOR (2 downto 0) := "000";
  signal Im      : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
  signal Flag    : STD_LOGIC := '0';
  
  signal test_alu_op_out       : STD_LOGIC_VECTOR (4 downto 0);
  signal test_im_data_out      : STD_LOGIC_VECTOR (15 downto 0);
  signal test_regA_select_out  : STD_LOGIC_VECTOR (2 downto 0);
  signal test_regB_select_out  : STD_LOGIC_VECTOR (2 downto 0);
  signal test_regC_select_out  : STD_LOGIC_VECTOR (2 downto 0);

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

  Testing_CLK: process
  begin
    loop
        test_clk_in <= not test_clk_in;
        wait for clk_time;
    end loop;    
  end process; 

  Testing_ins: process
  begin
        -- SW (0101) 111 0 101 001 00 =>0x5EA4
        OP_Code <= OPCODE_SW;
        RegA <= "111";
        Flag <= '0';
        RegB <= "101";
        RegC <= "001";
        wait for clk_time;
        test_instruction_in <= OPCODE_SW & RegA & Flag & RegB & RegC & "00";
        wait for clk_time;
        -- BEQ (0111) 010 1 111 111 11 =>0x75FF
        OP_Code <= OPCODE_BEQ;
        RegA <= "010";
        Flag <= '1';
        RegB <= "111";
        RegC <= "111";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "11";
        wait for clk_time;
        
        -- B (1000) 010 0 1111 1111 =>x84FF
        OP_Code <= OPCODE_B;
        RegA <= "010";
        Flag <= '0';
        RegB <= "111";
        Im <= "11111111";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & Im;
        wait for clk_time;
        
        -- AND (0011) 111 1 101 100 11 =>0x3fb3
        OP_Code <= OPCODE_AND;
        RegA <= "111";
        Flag <= '1';
        RegB <= "101";
        RegC <= "100";
        wait for clk_time;
        test_instruction_in <= OPCODE_AND & RegA & Flag & RegB & RegC & "11";
        wait for clk_time;
        test_enable_in <= '1';
 -----------------------------------------------------------------------------------------
        -- SW (0101) 111 0 101 001 00 =>0x5EA4
        OP_Code <= OPCODE_SW;
        RegA <= "111";
        Flag <= '0';
        RegB <= "101";
        RegC <= "001";
        wait for clk_time;
        test_instruction_in <= OPCODE_SW & RegA & Flag & RegB & RegC & "00";
        wait for clk_time;
        
        -- BEQ (0111) 010 1 111 111 11 =>7x65FF
        OP_Code <= OPCODE_BEQ;
        RegA <= "010";
        Flag <= '1';
        RegB <= "111";
        RegC <= "111";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "11";
        wait for clk_time;
        
        -- B (1000) 010 0 1111 1111 =>084ff
        OP_Code <= OPCODE_B;
        RegA <= "010";
        Flag <= '0';
        RegB <= "111";
        Im <= "11111111";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & Im;
        wait for clk_time;
        ------------------------------------------------------------------------------------------------------------
        
         -- ADD (0000) 111 1 101 100 11 =>0x03B3
        OP_Code <= OPCODE_ADD;
        RegA <= "111";
        Flag <= '1';
        RegB <= "101";
        RegC <= "100";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "11";
        wait for clk_time;
        
        -- SUB (0001) 011 0 010 100 00 =>0x1650
        OP_Code <= OPCODE_SUB;
        RegA <= "011";
        Flag <= '0';
        RegB <= "010";
        RegC <= "100";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "00";
        wait for clk_time;

        -- AND (0011) 011 0 010 100 11 =>0x3653
        OP_Code <= OPCODE_AND;
        RegA <= "011";
        Flag <= '0';
        RegB <= "010";
        RegC <= "100";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "00";
        wait for clk_time;
        
        -- OR (0010) 011 0 010 100 00 =>0x2650
        OP_Code <= OPCODE_OR;
        RegA <= "011";
        Flag <= '0';
        RegB <= "010";
        RegC <= "100";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "00";
        wait for clk_time;
       
        -- SLR (1001) 011 1 010 100 00 =>0x9650
        OP_Code <= OPCODE_SLR;
        RegA <= "011";
        Flag <= '0';
        RegB <= "010";
        RegC <= "100";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "00";
        wait for clk_time;
        
        -- SLL (1010) 011 1 010 100 00 =>0xA650
        OP_Code <= OPCODE_SLL;
        RegA <= "011";
        Flag <= '0';
        RegB <= "010";
        RegC <= "100";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "00";
        wait for clk_time;
        
        -- CMP (1011) 011 1 010 100 00 =>0xB650
        OP_Code <= OPCODE_CMP;
        RegA <= "011";
        Flag <= '0';
        RegB <= "010";
        RegC <= "100";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "00";
        wait for clk_time;
       ---------------------------------------------------------------------------- 
        -- LI (0100) 011 0 10101010 =>0x46AA
        OP_Code <= OPCODE_LI;
        RegA <= "011";
        Flag <= '0';
        Im <= "10101010";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & Im;
        wait for clk_time;
        
        -- LW (0110) 011 1 0000 0000 =>0x6700
        OP_Code <= OPCODE_LW;
        RegA <= "011";
        RegB <= "010";
        Flag <= '0';
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & "00000000";
        wait for clk_time;
  end process; 
end Behavioral;