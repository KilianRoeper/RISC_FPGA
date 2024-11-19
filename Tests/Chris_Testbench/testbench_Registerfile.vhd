library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;


entity simulation_decoder is
end simulation_decoder;

architecture Behavioral of simulation_decoder is
  constant clk_time :time    := 5 ns;
  constant waitTime :time    := 2 * clk_time;
  constant InvalidTime :time := 1.5 * clk_time;
  
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
        test_enable_in <= '1';
        test_regB_select_in <= "000";
        test_regC_select_in <= "111";
        wait for waitTime;
        test_regB_select_in <= "001";
        test_regC_select_in <= "110";
        test_write_enable_in <= '1';
        test_regA_data_in <= "1010101010101010";
        wait for waitTime;
        test_regB_select_in <= "010";
        test_regC_select_in <= "101";
        test_write_enable_in <= '0';
        test_regA_data_in <= "0101010101010101";
        wait for waitTime;
        test_regB_select_in <= "011";
        test_regC_select_in <= "100";
        test_write_enable_in <= '1';
        test_regA_data_in <= "0101010101010101";
        wait for waitTime;
        test_regB_select_in <= "100";
        test_regC_select_in <= "011";
        test_write_enable_in <= '0';
        test_regA_data_in <= "0000111100001111";
        wait for waitTime;
        test_regB_select_in <= "101";
        test_regC_select_in <= "010";
        test_write_enable_in <= '1';
        test_regA_data_in <= "0000111100001111";
        wait for waitTime;
        test_regB_select_in <= "110";
        test_regC_select_in <= "001";
        test_write_enable_in <= '1';
        test_regA_data_in <= "1111111111111111";
        wait for waitTime;
        test_regB_select_in <= "111";
        test_regC_select_in <= "000";
        test_write_enable_in <= '1';
        test_regA_data_in <= "0000000000000000";
        wait for waitTime;
        test_regB_select_in <= "000";
        test_regC_select_in <= "000";
        wait for waitTime;
        test_enable_in <= '1';
        test_regB_select_in <= "111";
        test_regC_select_in <= "111";
        test_write_enable_in <= '1';
        test_regA_data_in <= "1111111111111111";
  end process; 
end Behavioral;