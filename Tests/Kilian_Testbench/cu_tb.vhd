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

entity cu_tb is
-- Port ( cpu_clock : in STD_LOGIC := '0' );  
end cu_tb; 

architecture Behavioral of cu_tb is  
  
-- signals and constants
    signal s_state : STD_LOGIC_VECTOR(5 downto 0) := "000001";
    
    -- CPU signals/ constants
    constant clk_period : time := 10 ns;
    signal cpu_reset    : STD_LOGIC := '0';
    signal cpu_clock    : STD_LOGIC := '0'; 
      
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
    signal pc_out : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    
    -- ram 
    signal ram_data             : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal ram_address          : STD_LOGIC_VECTOR(7 downto 0) := X"00";
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
    
    --uart
    signal tx_ready     : STD_LOGIC := '0'; 
    signal start_tx     : STD_LOGIC := '0';   
    signal tx_data_in   : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    
    -- uart rx pin
    signal uart_rxd_out : STD_LOGIC := '0';
    
    -- uart buffer
    signal buffer_data_in       : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    signal buffer_data_out      : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    signal buffer_write_enable  : STD_LOGIC := '0'; 
    signal buffer_read_enable   : STD_LOGIC := '0'; 
    signal buffer_read_valid    : STD_LOGIC := '0'; 
    signal buffer_full          : STD_LOGIC := '0'; 
    signal buffer_full_next     : STD_LOGIC := '0'; 
    signal buffer_empty         : STD_LOGIC := '1'; 
    signal buffer_empty_next    : STD_LOGIC := '1'; 
    --signal buffer_fill_count  : integer range 16 - 1 downto 0;
           
    constant BUFFER_DEPTH : integer := 16;
    constant BUFFER_WIDTH : integer := 8;
    
begin
-- port mappings

     buffer_inst : entity work.uart_ring_buffer
        GENERIC MAP ( 
        RAM_DEPTH => BUFFER_DEPTH,
        RAM_WIDTH => BUFFER_WIDTH 
        ) 
        port map (
            clk         => cpu_clock,
            rst         => cpu_reset, 
            wr_en       => buffer_write_enable,
            wr_data     => buffer_data_in,                      
            rd_en       => buffer_read_enable,
            rd_valid    => buffer_read_valid,                           
            rd_data     => buffer_data_out,
            empty       => buffer_empty,
            empty_next  => buffer_empty_next,
            full        => buffer_full,
            full_next   => buffer_full_next
           -- fill_count  => buffer_fill_count
        ); 
        
    -- uart
    uart_tx_inst : entity work.uart_tx
        port map (
            clk_in      => cpu_clock,
            tx_start    => start_tx,
            tx_data     => tx_data_in,
            tx_ready    => tx_ready,
            tx          => uart_rxd_out
        );
        
    -- program counter 
    cpu_pc : entity work.pc PORT MAP (
        clk_in      => cpu_clock,
        pc_op_in    => pc_op_out,
        pc_in       => alu_result_out(7 downto 0),
        branch_in   => branch_enable_out,
        
        pc_out      => pc_out
    );
        
    -- ram   
    cpu_ram : entity work.ram 
    GENERIC MAP ( 
        ram_content => test_ram_content3
    ) 
    PORT MAP (
        clk_in          => cpu_clock,
        write_enable_in => ram_store_enable,
        enable_in       => ram_enable_combined,
        data_in         => alu_result_out,
        addr_in         => ram_address,

        data_out        => ram_data
        );
     
    -- decoder   
    cpu_decoder : entity work.decoder PORT MAP (
        clk_in              => cpu_clock,
        enable_in           => decode_enable,
        instruction_in      => ram_data,
        
        alu_op_out          => alu_op_out, 
        im_data_out         => im_data_out,
        regA_select_out     => selA_out,
        regB_select_out     => selB_out,
        regC_select_out     => selC_out
        );
        
    --register file  
    cpu_register_file : entity work.register_file PORT MAP (
        clk_in          => cpu_clock,
        enable_in       => reg_file_enable_combined,
        write_enable_in => regA_load_enable,
        regA_data_in    => regA_data_in_ram_alu,
        regA_select_in  => selA_out,
        regB_select_in  => selB_out,
        regC_select_in  => selC_out,
        
        regB_out        => regB_data,
        regC_out        => regC_data
        );
        
     -- alu     
     cpu_alu : entity work.alu PORT MAP ( 
        clk_in                  => cpu_clock,
        enable_in               => alu_enable,
        reg_B_data_in           => regB_data,
        reg_C_data_in           => regC_data,
        im_in                   => im_data_out,
        alu_op_in               => alu_op_out,
        
        result_out              => alu_result_out,
        branch_enable_out       => branch_enable_out
     );
        

    -- core clock process to pulse the entire computer 
    process(cpu_clock) 
    begin
        if rising_edge(cpu_clock) then 
            if cpu_reset = '1' then
                s_state <= "000001";
            elsif s_state = "100000" then
                s_state <= "000001";
            else
                s_state <= s_state(s_state'left-1 downto 0) & '0';  
            end if;     
            
        -- UART
            -- write for each SW and address 0x0100 as long as buffer is not full
            if alu_op_out(4 downto 1) = OPCODE_SW and ram_address = X"64" and ram_enable = '1' then            
                buffer_write_enable <= '1';
                buffer_data_in <= alu_result_out(7 downto 0); 
            else 
                buffer_write_enable <= '0';
            end if;
                   
            -- increment read pointer to next location for next read and start tx with read data
            if tx_ready = '1' and fetch_enable = '1' then
                buffer_read_enable <= '1';
                tx_data_in <= buffer_data_out;
            else
                buffer_read_enable <= '0';
            end if;
            
            if buffer_read_valid = '1' then 
                start_tx <= '1';
            else
                start_tx <= '0';
            end if;
           
        end if;
    end process;
    
    process(s_state)
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
            if cpu_reset = '1' then 
                pc_op_out <= PC_OP_RESET;  -- reset
            elsif fetch_enable = '1' then
                pc_op_out <= PC_OP_INC;  -- increment
            else
                pc_op_out <= PC_OP_NOP;  -- nop
            end if;
            
            
            -- pc_or_regfile
            if ((alu_op_out(4 downto 1) = OPCODE_SW or alu_op_out(4 downto 1) = OPCODE_LW) and alu_enable = '1') then
                ram_address <= regB_data(7 downto 0); 
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
            end if;       
    end process;
    
    -- stimulation process to reset processor on startup    
    stim_proc: process
    begin        
        cpu_reset <= '1'; -- reset control unit and pc
        wait for clk_period * 5; -- wait
        cpu_reset <= '0';
        wait;
    end process;
       
    -- clock process  
    clk_process : process
    begin 
        cpu_clock <= '0';
        wait for clk_period / 2;
        cpu_clock <= '1';
        wait for clk_period / 2;
    end process; 
    
end Behavioral;
