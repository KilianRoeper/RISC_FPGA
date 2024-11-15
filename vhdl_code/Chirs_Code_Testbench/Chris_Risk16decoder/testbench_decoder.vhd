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
  signal test_enable_in       : STD_LOGIC := '1'; -- Setze auf '1', falls immer aktiviert
  signal test_instruction_in  : STD_LOGIC_VECTOR (15 downto 0);
  
  signal OP_Code : STD_LOGIC_VECTOR (3 downto 0);
  signal RegA    : STD_LOGIC_VECTOR (2 downto 0) := "000"; -- Initialisiere auf einen gültigen Wert
  signal RegB    : STD_LOGIC_VECTOR (2 downto 0) := "000";
  signal RegC    : STD_LOGIC_VECTOR (2 downto 0) := "000";
  signal Im      : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
  signal Flag    : STD_LOGIC := '0';
  
  signal test_store_enable_out : STD_LOGIC;
  signal test_alu_op_out       : STD_LOGIC_VECTOR (4 downto 0);
  signal test_im_data_out      : STD_LOGIC_VECTOR (15 downto 0);
  signal test_regA_write_out   : STD_LOGIC;
  signal test_regA_select_out  : STD_LOGIC_VECTOR (2 downto 0);
  signal test_regB_select_out  : STD_LOGIC_VECTOR (2 downto 0);
  signal test_regC_select_out  : STD_LOGIC_VECTOR (2 downto 0);

begin
  uut: entity work.decoder
       PORT MAP (
          clk_in            => test_clk_in,
          enable_in         => test_enable_in,
          instruction_in    => test_instruction_in,
          store_enable_out  => test_store_enable_out, 
          alu_op_out        => test_alu_op_out,        
          im_data_out       => test_im_data_out,       
          regA_write_out    => test_regA_write_out,    
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
        -- SW 111 0 101 001 00
        OP_Code <= OPCODE_SW;
        RegA <= "111";
        Flag <= '0';
        RegB <= "101";
        RegC <= "001";
        wait for clk_time;
        test_instruction_in <= OPCODE_SW & RegA & Flag & RegB & RegC & "00";
        wait for clk_time;
        -- BEQ 010 1 111 111 11
        OP_Code <= OPCODE_BEQ;
        RegA <= "010";
        Flag <= '1';
        RegB <= "111";
        RegC <= "111";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "11";
        wait for clk_time;
        
        -- B 001 0 11111111
        OP_Code <= OPCODE_B;
        RegA <= "010";
        Flag <= '1';
        RegB <= "111";
        Im <= "11111111";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & Im;
        wait for clk_time;
        
        -- AND 001 1 001 001 00
        OP_Code <= OPCODE_AND;
        RegA <= "111";
        Flag <= '1';
        RegB <= "101";
        RegC <= "100";
        wait for clk_time;
        test_instruction_in <= OPCODE_AND & RegA & Flag & RegB & RegC & "11";
        wait for clk_time;
        
--        test_enable_in <= '1';
        
        -- SW 111 0 101 001 00
        OP_Code <= OPCODE_SW;
        RegA <= "111";
        Flag <= '0';
        RegB <= "101";
        RegC <= "001";
        wait for clk_time;
        test_instruction_in <= OPCODE_SW & RegA & Flag & RegB & RegC & "00";
        wait for clk_time;
        
        -- BEQ 010 1 111 111 11
        OP_Code <= OPCODE_BEQ;
        RegA <= "010";
        Flag <= '1';
        RegB <= "111";
        RegC <= "111";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & RegB & RegC & "11";
        wait for clk_time;
        
        -- B 001 1 001 001 00
        OP_Code <= OPCODE_B;
        RegA <= "010";
        Flag <= '1';
        RegB <= "111";
        Im <= "11111111";
        wait for clk_time;
        test_instruction_in <= OP_Code & RegA & Flag & Im;
        wait for clk_time;
        
         -- AND 001 1 001 001 00
        OP_Code <= OPCODE_AND;
        RegA <= "111";
        Flag <= '1';
        RegB <= "101";
        RegC <= "100";
        wait for clk_time;
        test_instruction_in <= OPCODE_AND & RegA & Flag & RegB & RegC & "11";
        wait for clk_time;
        
        OP_Code <= OPCODE_OR;
        RegA <= "011";
        Flag <= '0';
        RegB <= "010";
        RegC <= "100";
        wait for clk_time;
        test_instruction_in <= OPCODE_AND & RegA & Flag & RegB & RegC & "00";
        wait for clk_time;
  end process; 
end Behavioral;