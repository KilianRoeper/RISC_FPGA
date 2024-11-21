library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;


entity simulation_decoder is
end simulation_decoder;

architecture Behavioral of simulation_decoder is
  constant clk_time :time    := 5 ns;
  constant waitTime :time    := 2 * clk_time;
  
  
  signal test_clk_in          : STD_LOGIC := '1';
  signal test_enable_in       : STD_LOGIC := '0';
  signal test_write_enable_in : STD_LOGIC := '0';
  signal test_regA_data_in    : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
  signal test_regA_select_in  : STD_LOGIC_VECTOR (2 downto 0) := "000";
  signal test_regB_select_in  : STD_LOGIC_VECTOR (2 downto 0) := "000";
  signal test_regC_select_in  : STD_LOGIC_VECTOR (2 downto 0) := "000";
  signal test_regB_out        : STD_LOGIC_VECTOR (15 downto 0);
  signal test_regC_out        : STD_LOGIC_VECTOR (15 downto 0);
  
 
begin
  uut: entity work.register_file
    PORT MAP (
        clk_in          => test_clk_in,
        enable_in       => test_enable_in,
        write_enable_in => test_write_enable_in,
        regA_data_in    => test_regA_data_in,
        regA_select_in  => test_regA_select_in,
        regB_select_in  => test_regB_select_in,
        regC_select_in  => test_regC_select_in,
        regB_out        => test_regB_out,
        regC_out        => test_regC_out
    );
  
  Testing_CLK: process
  begin
    loop
        test_clk_in <= not test_clk_in;
        wait for clk_time;
    end loop;    
  end process; 

  Testing_register: process
  begin
  --Activation
        test_enable_in <= '1';
        test_write_enable_in <= '1';
  -- Write 000 => 1010 1010 1010 1010 AAAA
  -- Read  000
        test_regA_data_in <= "1010101010101010";
        test_regA_select_in <= "000";
        test_regB_select_in <= "000";
        test_regC_select_in <= "000";
        wait for clk_time;
 
        wait for waitTime;
        
        
         -- Write 001 => 0101 0101 0101 0101 5555
         -- Read  000
        test_regA_data_in <= "0101010101010101";
        test_regA_select_in <= "001";
        test_regB_select_in <= "000";
        test_regC_select_in <= "000";
      
        wait for waitTime;
        
         -- Write 010 => 0000 1111 0000 1111 0F0F
         -- Read  001
        test_regA_data_in <= "0000111100001111";
        test_regA_select_in <= "010";
        test_regB_select_in <= "001";
        test_regC_select_in <= "001";
        wait for waitTime;
       
       
        
         -- Write 011 => 1111 0000 1111 0000 F0F0
         -- Read  010
        test_regA_data_in <= "1111000011110000";
        test_regA_select_in <= "011";
        test_regB_select_in <= "010";
        test_regC_select_in <= "010";
        wait for waitTime;
        
        -- Write 100 => 0011 0011 0011 0011 3333
        -- Read  011
        test_regA_data_in <= "0011001100110011";
        test_regA_select_in <= "100";
        test_regB_select_in <= "011";
        test_regC_select_in <= "011";
        wait for clk_time;
      
        wait for clk_time;
        
        -- Write 101 => 0011 1100 1111 0011 3CF3
        -- Read  100
        test_regA_data_in <= "0011110011110011";
        test_regA_select_in <= "101";
        test_regB_select_in <= "100";
        test_regC_select_in <= "100";
        wait for waitTime;
        
        
        -- Write 110 => 1100 1111 0011 1100 CF3C
        -- Read  101        
        test_regA_data_in <= "1100111100111100";
        test_regA_select_in <= "110";
        test_regB_select_in <= "101";
        test_regC_select_in <= "101";
        wait for waitTime;
        
        
        -- Write 111 => 0011 1010 1001 0101 3A95
        -- Read  110
        test_regA_data_in <= "0011101010010101";
        test_regA_select_in <= "111";
        test_regB_select_in <= "110";
        test_regC_select_in <= "110";
        wait for waitTime;
        
        
        
        -- Write 000 => 1110 0100 1001 1110 E49E
        -- Read  111
        test_regA_data_in <= "1110010010011110";
        test_regA_select_in <= "000";
        test_regB_select_in <= "111";
        test_regC_select_in <= "111";
        wait for waitTime;
        
        
        -- Write 010 => 1110 0100 1001 1110 E49E
        -- Read  000 and 111
        test_regA_data_in <= "1110010010011110";
        test_regA_select_in <= "010";
        test_regB_select_in <= "000";
        test_regC_select_in <= "111";
       wait for waitTime;
        
        
        --Disable write
        test_write_enable_in <= '0';
       
        -- Write 011 => 1110 0100 1001 1110 E49E
        -- Read  000 and 010
        test_regA_data_in <= "1110010010011110";
        test_regA_select_in <= "011";
        test_regB_select_in <= "010";
        test_regC_select_in <= "010";
        wait for waitTime;
        
        
        
        -- Read  000 and 010
        test_regB_select_in <= "011";
        test_regC_select_in <= "011";
        wait for clk_time; 
        --Profment
--        assert test_regB_out = "1110010010011110" report "regB_out error" severity error;
--        assert test_regC_out = "1110010010011110" report "regC_out error" severity error;
        wait for clk_time; 
        
        -- Disable in, enable Write 
        test_enable_in <= '0';
        test_write_enable_in <= '1';
        
        -- Write 011 => 1110 1110 1110 1110 EEEE
        -- Read  000 and 010
        test_regA_data_in <= "1110111011101110";
        test_regA_select_in <= "011";
        test_regB_select_in <= "011";
        test_regC_select_in <= "011";
        wait for waitTime;
        
        -- Read  010  
        test_regB_select_in <= "011";
        test_regC_select_in <= "011";
        wait for clk_time;
        --Profment
--        assert test_regB_out = "1110010010011110" report "regB_out error" severity error;
--        assert test_regC_out = "1110010010011110" report "regC_out error" severity error;
        wait for clk_time; 
  end process; 
end Behavioral;