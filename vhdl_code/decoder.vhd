----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.11.2024 23:17:52
-- Design Name: 
-- Module Name: decoder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.RISC_constants.OPCODE_SW;
use work.RISC_constants.OPCODE_BEQ;
use work.RISC_constants.OPCODE_B;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder is
Port (  clk_in            : in STD_LOGIC;
        enable_in         : in STD_LOGIC; 
        instruction_in    : in STD_LOGIC_VECTOR (15 downto 0);
        
        store_enable_out  : out STD_LOGIC;
        alu_op_out        : out STD_LOGIC_VECTOR (4 downto 0);
        im_data_out       : out STD_LOGIC_VECTOR (15 downto 0);
        regA_write_out    : out STD_LOGIC;
        regA_select_out   : out STD_LOGIC_VECTOR (2 downto 0);
        regB_select_out   : out STD_LOGIC_VECTOR (2 downto 0);
        regC_select_out   : out STD_LOGIC_VECTOR (2 downto 0)  
      );
end decoder;

architecture Behavioral of decoder is

begin
  process (clk_in)
  begin
    if rising_edge(clk_in) and enable_in = '1' then
        regA_select_out <= instruction_in(11 downto 9);
        regB_select_out <= instruction_in(7 downto 5);
        regC_select_out <= instruction_in(4 downto 2);
        im_data_out <= instruction_in(7 downto 0) & instruction_in(7 downto 0);
        alu_op_out <= instruction_in(15 downto 12) & instruction_in(8);
        
        case instruction_in(15 downto 12) is
        when OPCODE_SW =>
          regA_write_out <= '0';
          store_enable_out <= '1';
           
        when OPCODE_BEQ => 	
          regA_write_out <= '0';
          store_enable_out <= '0';
          
        when OPCODE_B => 	
          regA_write_out <= '0';
          store_enable_out <= '0';
          
        when others =>
          regA_write_out <= '1';
          store_enable_out <= '0';
      end case;
    end if;
  end process;
end Behavioral;
