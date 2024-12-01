----------------------------------------------------------------------------------
-- Yannick Ott
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.risc_constants.all;
use IEEE.NUMERIC_STD.ALL;


-- Entity Declaration
-- Description: The Control Unit manages the operation of various components in the RISC processor based on the current state and input signals
entity control_unit is
Port (  
        clk_in                      : in STD_LOGIC;                         -- System clock
        reset_in                    : in STD_LOGIC;                         -- Reset signal
        alu_op_in                   : in STD_LOGIC_VECTOR(3 downto 0);      -- ALU operation code
        regB_data_in                : in STD_LOGIC_VECTOR(7 downto 0);      -- Data from register B
        ram_data_in                 : in STD_LOGIC_VECTOR(15 downto 0);     -- Data from RAM
        pc_in                       : in STD_LOGIC_VECTOR(7 downto 0);      -- Program Counter
        alu_result_in               : in STD_LOGIC_VECTOR(15 downto 0);     -- ALU result
        tx_ready_in                 : in STD_LOGIC;                         -- UART: ready to transmit
        buffer_read_valid_in        : in STD_LOGIC;                         -- FIFO: valid read data
        buffer_full_in              : in STD_LOGIC;                         -- FIFO: full status
        buffer_empty_in             : in STD_LOGIC;                         -- FIFO: empty status
        
        fetch_enable_out            : out STD_LOGIC;                        -- Enable fetch cycle
        decode_enable_out           : out STD_LOGIC;                        -- Enable decode cycle
        regread_enable_out          : out STD_LOGIC;                        -- Enable register read
        alu_enable_out              : out STD_LOGIC;                        -- Enable ALU
        ram_enable_out              : out STD_LOGIC;                        -- Enable RAM access
        regwrite_enable_out         : out STD_LOGIC;                        -- Enable register write
        ram_enable_combined_out     : out STD_LOGIC;                        -- Combined RAM enable signal
        reg_file_enable_combined_out: out STD_LOGIC;                        -- Combined register file enable signal
        pc_op_out                   : out STD_LOGIC_VECTOR(1 downto 0);     -- Program Counter operation control
        ram_store_enable_out        : out STD_LOGIC;                        -- RAM write control
        regA_load_enable_out        : out STD_LOGIC;                        -- Register A write enable
        regA_data_out               : out STD_LOGIC_VECTOR(15 downto 0);    -- Data for Register A
        ram_address_out             : out STD_LOGIC_VECTOR(7 downto 0);     -- RAM address
        start_tx_out                : out STD_LOGIC;                        -- Start UART transmission
        buffer_read_enable_out      : out STD_LOGIC;                        -- FIFO: read enable
        buffer_write_enable_out     : out STD_LOGIC;                        -- FIFO: write enable
        buffer_data_out             : out STD_LOGIC_VECTOR(7 downto 0)      -- FIFO: data for transmission
    ); 
end control_unit; 

architecture Behavioral of control_unit is
    -- State signal: 6-bit state register for controlling the state machine
    signal s_state                  : STD_LOGIC_VECTOR(5 downto 0) := "000001";
        
begin
    -- Clock Process: State machine
    -- Description: Cycles through states sequentially, controlled by the clock and reset signals
    process(clk_in, reset_in) 
    begin
        if rising_edge(clk_in) then 
            if reset_in = '1' then
                s_state <= "000001";  -- Reset state
            elsif s_state = "100000" then
                s_state <= "000001";  -- Reset state
            else
                -- Transition to the next state (shift left)
                s_state <= s_state(s_state'left-1 downto 0) & '0';  
            end if;     
        end if;
    end process;
    
    
    -- Control Process
    -- Description: Sets control signals based on the current state and input signals
    process(s_state, reset_in, alu_op_in, regB_data_in, pc_in, ram_data_in, alu_result_in, buffer_full_in, tx_ready_in, buffer_empty_in, buffer_read_valid_in)
        begin
            -- State signals 
            fetch_enable_out <= s_state(0);
            decode_enable_out <= s_state(1);
            regread_enable_out <= s_state(2);
            alu_enable_out <= s_state(3);
            ram_enable_out <= s_state(4);
            regwrite_enable_out <= s_state(5);
            reg_file_enable_combined_out <= s_state(2) or s_state(5);
            ram_enable_combined_out <= s_state(0) or s_state(4);
                        
                            
            -- Program Counter control
            if reset_in = '1' then
                pc_op_out <= PC_OP_RESET;   -- Reset
            elsif s_state(4) = '1' then
                pc_op_out <= PC_OP_INC;     -- Increment
            else
                pc_op_out <= PC_OP_NOP;     -- No operation
            end if;
            
            
            -- RAM address selection: choose between PC and register B
            if ((alu_op_in = OPCODE_SW or alu_op_in = OPCODE_LW) and s_state(4) = '1') then
                ram_address_out <= regB_data_in; 
            else
                ram_address_out <= pc_in;     
            end if;
                 
            
            -- Register A data selection: choose between RAM and ALU
            if alu_op_in = OPCODE_LW and s_state(4) = '1' then
                regA_data_out <= ram_data_in;       
            else 
                regA_data_out <= alu_result_in;
            end if;
            
            
            -- RAM write control
            if alu_op_in = OPCODE_SW and s_state(4) = '1' then
                ram_store_enable_out <= '1';
            else 
                ram_store_enable_out <= '0';
            end if;
            
            
            -- Register A write control
            if not(alu_op_in = OPCODE_SW 
                        or alu_op_in = OPCODE_BEQ 
                        or alu_op_in = OPCODE_B) 
                        and s_state(5) = '1' then
                regA_load_enable_out <= '1';
            else 
                regA_load_enable_out <= '0';     
            end if;       
            
            -- UART Control
            -- Write numbers or ASCII values to the FIFO
            if alu_op_in = OPCODE_SW and s_state(4) = '1' and regB_data_in = UART_INTERFACE_NUMBER and buffer_full_in = '0' then
                buffer_data_out <= std_logic_vector(to_unsigned((to_integer(unsigned(alu_result_in)) / 100) + 48, 8));              -- Hundreds digit
                buffer_write_enable_out <= '1';  
            elsif alu_op_in = OPCODE_SW and s_state(5) = '1' and regB_data_in = UART_INTERFACE_NUMBER and buffer_full_in = '0' then
                buffer_data_out <= std_logic_vector(to_unsigned(((to_integer(unsigned(alu_result_in)) mod 100) / 10) + 48, 8));     -- Tens digit
                buffer_write_enable_out <= '1';  
            elsif alu_op_in = OPCODE_SW and s_state(0) = '1' and regB_data_in = UART_INTERFACE_NUMBER and buffer_full_in = '0' then
                buffer_data_out <= std_logic_vector(to_unsigned((to_integer(unsigned(alu_result_in)) mod 10) + 48, 8));             -- Units digit
                buffer_write_enable_out <= '1';  
            -- Writing an ASCII character
            elsif alu_op_in = OPCODE_SW and s_state(4) = '1' and regB_data_in = UART_INTERFACE_ASCII and buffer_full_in = '0' then
                buffer_data_out <= alu_result_in(7 downto 0);
                buffer_write_enable_out <= '1';
            else 
                buffer_data_out <= X"00";
                buffer_write_enable_out <= '0';
            end if;
            
            
            -- FIFO read control
            -- Increment read pointer to next location for next read and start tx with read data
            if tx_ready_in = '1' and s_state(1) = '1' and buffer_empty_in = '0' then
                buffer_read_enable_out <= '1';
            else
                buffer_read_enable_out <= '0';
            end if;
            
            
             -- UART transmit start signal
            if buffer_read_valid_in = '1' then 
                start_tx_out <= '1';
            else
                start_tx_out <= '0';    
            end if;
    end process;
end Behavioral;
