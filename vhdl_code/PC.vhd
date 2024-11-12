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

entity pc is
Port (  clk_in   : in STD_LOGIC;
        pc_op_in : in STD_LOGIC_VECTOR (1 downto 0);
        pc_in    : in STD_LOGIC_VECTOR (15 downto 0);
        branch_in   : in STD_LOGIC;
        
        pc_out   : out STD_LOGIC_VECTOR (15 downto 0) 
    );
end PC;

architecture Behavioral of PC is
  signal current_pc: STD_LOGIC_VECTOR(15 downto 0) := X"0000";
begin

  process (clk_in)
  begin
    if rising_edge(clk_in) then
        if branch_in = '1' then 
            current_pc <= pc_in;
        else
          case pc_op_in is
            when PC_OP_NOP => 	         -- 00 / halt
            when PC_OP_INC => 	         -- 01 / increment
              current_pc <= STD_LOGIC_VECTOR(unsigned(current_pc) + 1);       
            when PC_OP_RESET => 	     -- 11 / reset
              current_pc <= X"0000";
            when others =>
          end case;
        end if;
    end if;
  end process;

  pc_out <= current_pc;


end Behavioral;
