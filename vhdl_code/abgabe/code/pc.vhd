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

-- Entity declaration for the program counter
entity pc is
Port (  clk_in      : in STD_LOGIC; -- Clock input for synchronous operations
        pc_op_in    : in STD_LOGIC_VECTOR (1 downto 0); -- Signal controlling the PC operationmode
        pc_in       : in STD_LOGIC_VECTOR (15 downto 0); -- Input address for branching
        branch_in   : in STD_LOGIC; -- Branch signal to jump to pc_in
        
        pc_out      : out STD_LOGIC_VECTOR (7 downto 0) -- 8-bit program counter output, current value of pc
    );
end pc;

architecture Behavioral of PC is
  signal current_pc: STD_LOGIC_VECTOR(15 downto 0) := X"0000"; -- Initial value set to 0
begin

        -- Process triggered on the rising edge of the clock
  process (clk_in)
  begin
    if rising_edge(clk_in) then
        -- branch to the address given by pc_in if the branch_in signal is set high
        if branch_in = '1' then 
            current_pc <= pc_in;
        else
         -- Handle operations based on the opcode
          case pc_op_in is
            when PC_OP_NOP => 	                                             -- 00 / no operation
            when PC_OP_INC => 	                                             -- 01 / increment
              current_pc <= STD_LOGIC_VECTOR(unsigned(current_pc) + 1);       
            when PC_OP_RESET => 	                                     -- 11 / reset
              current_pc <= X"0000";
            when others =>         -- Undefined opcode: No operation
          end case;
        end if;
    end if;
  end process;

  pc_out <= current_pc(7 downto 0); -- Output the lower 8 bits of the program counter


end Behavioral;
