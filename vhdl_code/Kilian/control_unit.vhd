----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.11.2024 13:51:38
-- Design Name: 
-- Module Name: control_unit - Behavioral
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
use work.risc_constants.all;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_unit is
Port (  
        clk_in                      : in STD_LOGIC;
        reset_in                    : in STD_LOGIC;
        alu_op_in                   : in STD_LOGIC_VECTOR(3 downto 0);
        regB_data_in                : in STD_LOGIC_VECTOR(7 downto 0);
        ram_data_in                 : in STD_LOGIC_VECTOR(15 downto 0);
        pc_in                       : in STD_LOGIC_VECTOR(7 downto 0);
        alu_result_in               : in STD_LOGIC_VECTOR(15 downto 0);
        tx_ready_in                 : in STD_LOGIC;
        buffer_read_valid_in        : in STD_LOGIC;
        buffer_full_in              : in STD_LOGIC;
        buffer_empty_in             : in STD_LOGIC;
        
        fetch_enable_out            : out STD_LOGIC;
        decode_enable_out           : out STD_LOGIC;
        regread_enable_out          : out STD_LOGIC;
        alu_enable_out              : out STD_LOGIC;
        ram_enable_out              : out STD_LOGIC;
        regwrite_enable_out         : out STD_LOGIC;
        ram_enable_combined_out     : out STD_LOGIC;
        reg_file_enable_combined_out: out STD_LOGIC;
        pc_op_out                   : out STD_LOGIC_VECTOR(1 downto 0);
        ram_store_enable_out        : out STD_LOGIC;
        regA_load_enable_out        : out STD_LOGIC; 
        regA_data_out               : out STD_LOGIC_VECTOR(15 downto 0);
        ram_address_out             : out STD_LOGIC_VECTOR(7 downto 0);
        start_tx_out                : out STD_LOGIC;
        buffer_read_enable_out      : out STD_LOGIC;
        buffer_write_enable_out     : out STD_LOGIC
    ); 
end control_unit; 

architecture Behavioral of control_unit is
 
    signal s_state                  : STD_LOGIC_VECTOR(5 downto 0) := "000001";
        
begin
    -- core clock process to pulse the entire computer 
    process(clk_in, reset_in) 
    begin
        if rising_edge(clk_in) then 
            if reset_in = '1' then
                s_state <= "000001";
            elsif s_state = "100000" then
                s_state <= "000001";
            else
                s_state <= s_state(s_state'left-1 downto 0) & '0';  
            end if;     
        end if;
    end process;
    
    process(s_state, reset_in, alu_op_in, regB_data_in, pc_in, ram_data_in, alu_result_in, buffer_full_in, tx_ready_in, buffer_empty_in, buffer_read_valid_in)
        begin
             
            fetch_enable_out <= s_state(0);
            decode_enable_out <= s_state(1);
            regread_enable_out <= s_state(2);
            alu_enable_out <= s_state(3);
            ram_enable_out <= s_state(4);
            regwrite_enable_out <= s_state(5);
            reg_file_enable_combined_out <= s_state(2) or s_state(5);
            ram_enable_combined_out <= s_state(0) or s_state(4);
                            
            -- pc_op selection
            if reset_in = '1' then         -- or btn0 = '1'
                pc_op_out <= PC_OP_RESET;  -- reset 
            elsif s_state(4) = '1' then
                pc_op_out <= PC_OP_INC;  -- increment
            else
                pc_op_out <= PC_OP_NOP;  -- nop
            end if;
            
            
            -- pc_or_regfile
            if ((alu_op_in = OPCODE_SW or alu_op_in = OPCODE_LW) and s_state(4) = '1') then
                ram_address_out <= regB_data_in; 
            else
                ram_address_out <= pc_in;     
            end if;
                 
            -- ram_or_alu 
            if alu_op_in = OPCODE_LW and s_state(4) = '1' then
                regA_data_out <= ram_data_in;       
            else 
                regA_data_out <= alu_result_in;
            end if;
            
            -- enabling RAM-write for one cycle 
            if alu_op_in = OPCODE_SW and s_state(4) = '1' then
                ram_store_enable_out <= '1';
            else 
                ram_store_enable_out <= '0';
            end if;
            
            -- enabling regA write for one cycle
            if not(alu_op_in = OPCODE_SW 
                        or alu_op_in = OPCODE_BEQ 
                        or alu_op_in = OPCODE_B) 
                        and s_state(5) = '1' then
                regA_load_enable_out <= '1';
            else 
                regA_load_enable_out <= '0';     
            end if;       
            
        -- UART 
            -- write for each SW and address 0x0064 as long as buffer is not full
            if alu_op_in = OPCODE_SW and s_state(4) = '1' and regB_data_in = UART_INTERFACE and buffer_full_in = '0' then 
                buffer_write_enable_out <= '1';
            else
                buffer_write_enable_out <= '0';
            end if;
            
            -- increment read pointer to next location for next read and start tx with read data
            if tx_ready_in = '1' and s_state(1) = '1' and buffer_empty_in = '0' then
                buffer_read_enable_out <= '1';
            else
                buffer_read_enable_out <= '0';
            end if;
            
            if buffer_read_valid_in = '1' then 
                start_tx_out <= '1';
            else
                start_tx_out <= '0';
            end if;
    end process;
end Behavioral;
