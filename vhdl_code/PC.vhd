----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.11.2024 22:39:19
-- Design Name: 
-- Module Name: PC - Behavioral
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
use work.RISC_constants.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PC is
Port (  clk_in   : in STD_LOGIC;
        pc_op_in : in STD_LOGIC_VECTOR (1 downto 0);
        pc_in    : in STD_LOGIC_VECTOR (15 downto 0);
        
        pc_out   : out STD_LOGIC_VECTOR (15 downto 0) 
    );
end PC;

architecture Behavioral of PC is
  signal current_pc: std_logic_vector( 15 downto 0) := X"0000";
begin

  process (clk_in)
  begin
    if rising_edge(clk_in) then
      case pc_op_in is
        when PC_OP_NOP => 	         -- NOP, keep PC the same/halt
        when PC_OP_INC => 	         -- increment
          current_pc <= std_logic_vector(unsigned(current_pc) + 1);
        when PC_OP_ASSIGN => 	     -- set from external input
          current_pc <= pc_in;        
        when PC_OP_RESET => 	     -- Reset
          current_pc <= X"0000";
        when others =>
      end case;
    end if;
  end process;

  pc_out <= current_pc;


end Behavioral;
