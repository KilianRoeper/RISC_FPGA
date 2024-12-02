----------------------------------------------------------------------------------
-- Entity: program counter 
-- Name: Kelly Velten
----------------------------------------------------------------------------------

-- handles the program counter based on the given opcode and the branch signal 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.risc_constants.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pc is
Port (  clk_in      : in STD_LOGIC;
        pc_op_in    : in STD_LOGIC_VECTOR (1 downto 0);
        pc_in       : in STD_LOGIC_VECTOR (15 downto 0);
        branch_in   : in STD_LOGIC;
        
        pc_out      : out STD_LOGIC_VECTOR (7 downto 0) 
    );
end pc;

architecture Behavioral of PC is
  signal current_pc: STD_LOGIC_VECTOR(15 downto 0) := X"0000";
begin

  process (clk_in)
  begin
    if rising_edge(clk_in) then
        -- branch to the address given by pc_in if the branch_in signal is set high
        if branch_in = '1' then 
            current_pc <= pc_in;
        else
          case pc_op_in is
            when PC_OP_NOP => 	                                             -- 00 / halt
            when PC_OP_INC => 	                                             -- 01 / increment
              current_pc <= STD_LOGIC_VECTOR(unsigned(current_pc) + 1);       
            when PC_OP_RESET => 	                                     -- 11 / reset
              current_pc <= X"0000";
            when others =>
          end case;
        end if;
    end if;
  end process;

  pc_out <= current_pc(7 downto 0);


end Behavioral;
