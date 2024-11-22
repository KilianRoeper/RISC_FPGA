----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.11.2024 10:12:51
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use work.RISC_constants.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
Port (  clk_in                  : in STD_LOGIC;
        enable_in               : in STD_LOGIC;
        regB_data_in           : in STD_LOGIC_VECTOR (15 downto 0);
        regC_data_in           : in STD_LOGIC_VECTOR (15 downto 0);
        im_in                   : in STD_LOGIC_VECTOR (7 downto 0);
        alu_op_in               : in STD_LOGIC_VECTOR (4 downto 0);
        
        result_out              : out STD_LOGIC_VECTOR (15 downto 0);
        branch_enable_out       : out STD_logic
       );
end alu;

architecture Behavioral of alu is
    -- 's_' means storing 
    signal s_result : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');
    signal s_branch_enable : STD_LOGIC := '0';
begin
process (clk_in, enable_in)
  begin
    
    if rising_edge(clk_in) then
        s_branch_enable <= '0';
        if enable_in = '1' then
        
            case alu_op_in(4 downto 1) is
                -- ADD (addition)
                when OPCODE_ADD =>
                    if alu_op_in(0) = '0' then
                        s_result(16 downto 0) <= std_logic_vector(unsigned('0' & regB_data_in) + unsigned( '0' & regC_data_in));
                    else
                        s_result(16 downto 0) <= std_logic_vector(signed(regB_data_in(15) & regB_data_in) + signed( regC_data_in(15) & regC_data_in));
                    end if;
                    s_branch_enable <= '0';
                  
                -- SUB (subtraction)
                when OPCODE_SUB =>
                    if alu_op_in(0) = '0' then
                        s_result(16 downto 0) <= std_logic_vector(unsigned('0' & regB_data_in) - unsigned( '0' & regC_data_in));
                    else
                        s_result(16 downto 0) <= std_logic_vector(signed(regB_data_in(15) & regB_data_in) - signed( regC_data_in(15) & regC_data_in));
                    end if;
                    s_branch_enable <= '0';
                  
                -- OR
                when OPCODE_OR =>
                  s_result(15 downto 0) <= regB_data_in or regC_data_in;
                  s_branch_enable <= '0';
                
                -- AND
                when OPCODE_AND =>
                  s_result(15 downto 0) <= regB_data_in and regC_data_in;
                  s_branch_enable <= '0';
                  
                -- LI (load immideate)  
                when OPCODE_LI =>
                  if alu_op_in(0) = '0' then
                    s_result(15 downto 0) <= im_in & X"00";
                  else
                    s_result(15 downto 0) <= X"00" & im_in;
                  end if;
                  s_branch_enable <= '0';
                  
                -- SW (store word of regC into address of regB)
                when OPCODE_SW =>
                    s_result <= "00" & regC_data_in;
                    s_branch_enable <= '0';
                    
                -- LW (load word at address of regB into regA) 
                when OPCODE_LW =>
                s_result <= "00" & regB_data_in;
                    s_branch_enable <= '0';
                 
                -- CMP (compare) 
                when OPCODE_CMP =>
                    -- unsigned comparisons 
                    -- regB == regC
                    if regB_data_in = regC_data_in then
                        s_result(CMP_BIT_EQ) <= '1';
                    else
                        s_result(CMP_BIT_EQ) <= '0';
                    end if;
                    
                    -- regB == 0x0000
                    if regB_data_in = X"0000" then
                        s_result(CMP_BIT_BZ) <= '1';
                    else
                        s_result(CMP_BIT_BZ) <= '0';
                    end if;
                    
                    -- regC == 0x0000
                    if regC_data_in = X"0000" then
                      s_result(CMP_BIT_CZ) <= '1';
                    else
                      s_result(CMP_BIT_CZ) <= '0';
                    end if;
                    
                    -- possible singed comparisons - verified with flag bit
                    if alu_op_in(0) = '0' then
                        -- unsigned CMP
                        -- regB > regC
                        if unsigned(regB_data_in) > unsigned(regC_data_in) then
                            s_result(CMP_BIT_BGC) <= '1';
                        else
                            s_result(CMP_BIT_BGC) <= '0';
                        end if;
                        -- regB < regC
                        if unsigned(regB_data_in) < unsigned(regC_data_in) then
                            s_result(CMP_BIT_BLC) <= '1';
                        else
                            s_result(CMP_BIT_BLC) <= '0';
                        end if;
                    else
                        -- signed CMP
                        -- regB > regC
                        if signed(regB_data_in) > signed(regC_data_in) then
                            s_result(CMP_BIT_BGC) <= '1';
                        else
                            s_result(CMP_BIT_BGC) <= '0';
                        end if;
                        -- regB < regC
                        if signed(regB_data_in) < signed(regC_data_in) then
                            s_result(CMP_BIT_BLC) <= '1';
                        else
                            s_result(CMP_BIT_BLC) <= '0';
                        end if;
                    end if;
                    s_result(15) <= '0';
                    s_result(9 downto 0) <= "0000000000";
                    s_branch_enable <= '0';
                
                -- BEQ (branch on equal)
                when OPCODE_BEQ =>
                    -- set branch target regardless for program counter
                    s_result(15 downto 0) <= regB_data_in;
                
                    -- the condition to jump is based on aluop(0) and dataimm(1 downto 0);
                    case (alu_op_in(0) & im_in(1 downto 0)) is
                        when CJF_EQ =>
                            s_branch_enable <= regC_data_in(CMP_BIT_EQ);
                        when CJF_BZ =>
                            s_branch_enable <= regC_data_in(CMP_BIT_BZ);
                        when CJF_CZ =>
                            s_branch_enable <= regC_data_in(CMP_BIT_CZ);
                        when CJF_BNZ =>
                            s_branch_enable <= not regC_data_in(CMP_BIT_BZ);
                        when CJF_CNZ =>
                            s_branch_enable <= not regC_data_in(CMP_BIT_CZ);
                        when CJF_BGC =>
                            s_branch_enable <= regC_data_in(CMP_BIT_BGC);
                        when CJF_BLC =>
                            s_branch_enable <= regC_data_in(CMP_BIT_BLC);
                        when others =>
                            s_branch_enable <= '0';
                    end case;     
                    
                -- SLL (shift logical left)    
                when OPCODE_SLL =>
                    s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(regB_data_in), to_integer(unsigned(regC_data_in(3 downto 0)))));
                    s_branch_enable <= '0';
                    
                -- SLR (shift logical right)
                when OPCODE_SLR =>
                    s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(regB_data_in), to_integer(unsigned(regC_data_in(3 downto 0)))));
                    s_branch_enable <= '0';
                    
                -- B (branch)    
                when OPCODE_B =>
                    s_result(15 downto 0) <= X"00" &  im_in;
                    s_branch_enable <= '1';
                when others =>
                s_result <= "00" & X"FEFE";
          end case;
       end if;
    end if;
  end process;

  result_out <= s_result(15 downto 0);
  branch_enable_out <= s_branch_enable;

end Behavioral;