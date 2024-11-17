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
use work.RISC_constants.all;
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
        cpu_clock       : in STD_LOGIC;
        uart_rxd_out    : out STD_LOGIC;        -- pin to send to putty shell
        sw0             : in STD_LOGIC;
        btn0            : in STD_LOGIC
    );
end control_unit; 

architecture Behavioral of control_unit is
 
-- signals and constants
    signal s_state : STD_LOGIC_VECTOR(5 downto 0) := "000001";
    
    -- switches 
    signal debounced_switch0    : STD_LOGIC := '0';
    
    -- CPU signals/ constants
    signal reset_done           : STD_LOGIC := '0';
    signal cpu_reset            : STD_LOGIC := '0';
    signal cpu_clock_and_switch : STD_LOGIC := '0';
      
    -- Control Unit
    signal fetch_enable         : STD_LOGIC := '0';
    signal decode_enable        : STD_LOGIC := '0';
    signal regread_enable       : STD_LOGIC := '0';
    signal alu_enable           : STD_LOGIC := '0';
    signal ram_enable           : STD_LOGIC := '0';
    signal regwrite_enable      : STD_LOGIC := '0';
    signal pc_op_out            : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal ram_store_enable     : STD_LOGIC := '0';
    signal regA_load_enable     : STD_LOGIC := '0';
    
    -- Program Counter
    signal pc_out : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    
    -- ram 
    signal ram_data             : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal ram_address          : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal ram_enable_combined  : STD_LOGIC := '0';
    
    --decoder 
    signal alu_op_out               : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal im_data_out              : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    signal selA_out                 : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal selB_out                 : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal selC_out                 : STD_LOGIC_VECTOR(2 downto 0) := "000";
    
    -- register file
    signal regB_data                : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal regC_data                : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal regA_data_in_ram_alu     : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal reg_file_enable_combined : STD_LOGIC := '0';

    -- alu
    signal alu_result_out           : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal branch_enable_out        : STD_LOGIC := '0';
    
    -- uart_tx
    signal tx_ready         : std_logic := '0'; 
    signal start_tx         : std_logic := '1';   
    
    -- uart buffer
    signal buffer_data_in       : STD_LOGIC_VECTOR(7 downto 0) := X"46";
    signal buffer_data_out      : STD_LOGIC_VECTOR(7 downto 0) := X"41";
    signal buffer_write_enable  : std_logic := '0'; 
    signal buffer_read_enable   : std_logic := '0'; 
    signal buffer_full          : std_logic := '0'; 
    signal buffer_empty         : std_logic := '1'; 
    signal read_from_buffer     : integer := 2; 
    signal wrote_to_buffer     : integer := 2; 

        
begin

-- port mappings  

    buffer_inst : entity work.uart_buffer
        GENERIC MAP ( 
        BUFFER_SIZE => 16,
        DATA_WIDTH => 8
        )
        port map (
            clk_in          => cpu_clock,
     --       reset           => cpu_reset, 
            data_in         => buffer_data_in,
            write_enable    => buffer_write_enable,                      
            data_out        => buffer_data_out,
            read_enable     => buffer_read_enable,                           
            buffer_full     => buffer_full,
            buffer_empty    => buffer_empty
        ); 

    uart_tx_inst : entity work.uart_tx  
        port map (
            clk_in      => cpu_clock, 
            tx_start    => start_tx,
            tx_data     => buffer_data_out,
            tx_ready    => tx_ready,
            tx          => uart_rxd_out
        );
     
    -- program counter port mappings
    cpu_pc : entity work.pc PORT MAP (
        clk_in      => cpu_clock_and_switch,
        pc_op_in    => pc_op_out,
        pc_in       => alu_result_out,
        branch_in   => branch_enable_out,
        
        pc_out      => pc_out
    );
        
    -- ram port mappings 
    cpu_ram : entity work.ram 
    GENERIC MAP ( 
        ram_content => test_ram_content3
    ) 
    PORT MAP (
        clk_in          => cpu_clock_and_switch,
        write_enable_in => ram_store_enable,
        enable_in       => ram_enable_combined,
        data_in         => alu_result_out,
        addr_in         => ram_address,

        data_out        => ram_data
        );
     
    -- decoder port mappings 
    cpu_decoder : entity work.decoder PORT MAP (
        clk_in              => cpu_clock_and_switch,
        enable_in           => decode_enable,
        instruction_in      => ram_data,
        
        alu_op_out          => alu_op_out, 
        im_data_out         => im_data_out,
        regA_select_out     => selA_out,
        regB_select_out     => selB_out,
        regC_select_out     => selC_out
        );
        
    --register file port mappings
    cpu_register_file : entity work.register_file PORT MAP (
        clk_in          => cpu_clock_and_switch,
        enable_in       => reg_file_enable_combined,
        write_enable_in => regA_load_enable,
        regA_data_in    => regA_data_in_ram_alu,
        regA_select_in  => selA_out,
        regB_select_in  => selB_out,
        regC_select_in  => selC_out,
        
        regB_out        => regB_data,
        regC_out        => regC_data
        );
        
     -- alu port mappings   
     cpu_alu : entity work.alu PORT MAP ( 
        clk_in                  => cpu_clock_and_switch,
        enable_in               => alu_enable,
        reg_B_data_in           => regB_data,
        reg_C_data_in           => regC_data,
        im_in                   => im_data_out,
        alu_op_in               => alu_op_out,
        
        result_out              => alu_result_out,
        branch_enable_out       => branch_enable_out
     );
     
    

    -- core clock process to pulse the entire computer 
    process(cpu_clock_and_switch, cpu_reset) 
    begin
        if rising_edge(cpu_clock_and_switch) then 
            if cpu_reset = '1' then
                s_state <= "000001";
            elsif s_state = "100000" then
                s_state <= "000001";
            else
                s_state <= s_state(s_state'left-1 downto 0) & '0';  
            end if;     
        end if;
    end process;
    
    process(s_state, 
            cpu_reset, 
            branch_enable_out, 
            fetch_enable, 
            alu_enable, 
            ram_enable, 
            regwrite_enable, 
            alu_op_out, 
            regB_data, 
            pc_out, 
            ram_data, 
            alu_result_out,
            ram_address,
            tx_ready)
        begin
             
            fetch_enable <= s_state(0);
            decode_enable <= s_state(1);
            regread_enable <= s_state(2);
            alu_enable <= s_state(3);
            ram_enable <= s_state(4);
            regwrite_enable <= s_state(5);
            reg_file_enable_combined <= s_state(2) or s_state(5);
            ram_enable_combined <= s_state(0) or s_state(4);
                            
            -- pc_op selection
            if cpu_reset = '1' or btn0 = '1' then 
                pc_op_out <= PC_OP_RESET;  -- reset 
            elsif fetch_enable = '1' then
                pc_op_out <= PC_OP_INC;  -- increment
            else
                pc_op_out <= PC_OP_NOP;  -- nop
            end if;
            
            
            -- pc_or_regfile
            if ((alu_op_out(4 downto 1) = OPCODE_SW or alu_op_out(4 downto 1) = OPCODE_LW) and alu_enable = '1') then
                ram_address <= regB_data; 
            elsif regwrite_enable = '1' then
                ram_address <= pc_out;     
            end if;
                 
            -- ram_or_alu 
            if alu_op_out(4 downto 1) = OPCODE_LW and alu_enable = '1' then
                regA_data_in_ram_alu <= ram_data;       
            else 
                regA_data_in_ram_alu <= alu_result_out;
            end if;
            
            -- enabling RAM-write for one cycle 
            if alu_op_out(4 downto 1) = OPCODE_SW and alu_enable = '1' then
                ram_store_enable <= '1';
            elsif alu_op_out(4 downto 1) = OPCODE_SW and ram_enable = '1' then
                ram_store_enable <= '0';
            else 
                ram_store_enable <= '0';
            end if;
            
            -- enabling regA write for one cycle
            if not(alu_op_out(4 downto 1) = OPCODE_SW 
                        or alu_op_out(4 downto 1) = OPCODE_BEQ 
                        or alu_op_out(4 downto 1) = OPCODE_B) 
                        and ram_enable = '1' then
                 regA_load_enable <= '1';
            elsif not(alu_op_out(4 downto 1) = OPCODE_SW 
                        or alu_op_out(4 downto 1) = OPCODE_BEQ 
                        or alu_op_out(4 downto 1) = OPCODE_B) 
                        and regwrite_enable = '1' then
                 regA_load_enable <= '0';
            else 
                regA_load_enable <= '0';     
            end if;       
    end process;
    
    
    uart_proc: process(cpu_clock, alu_op_out, ram_enable)
    begin
        if rising_edge(cpu_clock) then
            -- write for each SW and address 0x0100 as long as buffer is not full
            if wrote_to_buffer = 2 and alu_op_out(4 downto 1) = OPCODE_SW and ram_address = X"0100" and ram_enable = '1' then           -- and buffer_full = '0' 
                buffer_data_in <= alu_result_out(7 downto 0);
                wrote_to_buffer <= wrote_to_buffer - 1;
            elsif wrote_to_buffer = 1 then 
                 buffer_write_enable <= '1';
            else 
                wrote_to_buffer <= 2;
                buffer_write_enable <= '0';
            end if;
            
            -- read from buffer if not empty and uart_tx signals ready  
            if tx_ready = '1' and read_from_buffer = 2 then             -- and buffer_empty = '0' 
                buffer_read_enable <= '1';
                read_from_buffer <= read_from_buffer - 1;
                
            --after reading from buffer, send data to uart_tx 
            elsif read_from_buffer = 1 and tx_ready = '1' then
                buffer_read_enable <= '0';
                start_tx <= '1';
                read_from_buffer <= read_from_buffer - 1;
            else
               start_tx <= '0';
                read_from_buffer <= 2;
           end if;
        end if;
    end process;
    
    
        
    -- stimulation process to reset processor on startup    
    stim_proc: process(cpu_clock_and_switch)
    begin
        if rising_edge(cpu_clock_and_switch) then
            if reset_done = '0' then
                cpu_reset <= '1';  
                reset_done <= '1'; 
            else
                cpu_reset <= '0'; 
            end if;
        end if;
    end process;       
    
    -- anding switch with clock for further control
    cpu_clock_and_switch <= debounced_switch0 and cpu_clock;
    
    switch_debounce: process(cpu_clock)
    variable debounce_counter: integer := 0;
    begin
        if rising_edge(cpu_clock) then
            if sw0 /= debounced_switch0 then
                debounce_counter := debounce_counter + 1;
                if debounce_counter > DEBOUNCE_THRESHOLD then
                    debounced_switch0 <= sw0;
                    debounce_counter := 0;
                end if;
            else
                debounce_counter := 0;
            end if;
        end if;
    end process;

    
end Behavioral;
