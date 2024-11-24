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


entity risc_processor_tb is
end risc_processor_tb; 

architecture Behavioral of risc_processor_tb is

    -- test bench specific signals
    signal cpu_clock                : STD_LOGIC := '0'; 
    constant clk_period             : time := 10 ns;
    signal uart_rxd_out             : STD_LOGIC := '0';

    -- reset
    signal cpu_reset                : STD_LOGIC := '0';

    -- control unit
    signal fetch_enable             : STD_LOGIC := '0';
    signal decode_enable            : STD_LOGIC := '0';
    signal regread_enable           : STD_LOGIC := '0';
    signal alu_enable               : STD_LOGIC := '0';
    signal ram_enable               : STD_LOGIC := '0';
    signal regwrite_enable          : STD_LOGIC := '0';
    signal ram_enable_combined      : STD_LOGIC := '0';
    signal reg_file_enable_combined : STD_LOGIC := '0';
    signal pc_op                    : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal ram_store_enable         : STD_LOGIC := '0';
    signal regA_load_enable         : STD_LOGIC := '0';
    signal regA_data                : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal ram_address              : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    signal start_tx                 : STD_LOGIC := '0';
    signal buffer_write_enable      : std_logic := '0'; 
    signal buffer_read_enable       : std_logic := '0'; 
    
    -- Program Counter
    signal pc_out                   : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    
    -- ram 
    signal ram_data                 : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    
    
    --decoder 
    signal alu_op                   : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal im_data                  : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    signal selA                     : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal selB                     : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal selC                     : STD_LOGIC_VECTOR(2 downto 0) := "000";
    
    -- register file
    signal regB_data                : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal regC_data                : STD_LOGIC_VECTOR(15 downto 0) := X"0000";

    -- alu
    signal alu_result               : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal branch_enable            : STD_LOGIC := '0';
    
    -- uart_tx
    signal tx_ready                 : std_logic := '0'; 
    
    -- uart buffer
    signal buffer_data              : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    signal buffer_read_valid        : std_logic := '0'; 
    signal buffer_full              : std_logic := '0'; 
    signal buffer_full_next         : std_logic := '0'; 
    signal buffer_empty             : std_logic := '1'; 
    signal buffer_empty_next        : std_logic := '1'; 
    constant BUFFER_WIDTH           : integer := 8;
    constant BUFFER_DEPTH           : integer := 16;
    --signal buffer_fill_count      : integer range 16 - 1 downto 0;

begin 

-- port mappings  

    reset_inst : entity work.reset
    PORT MAP ( 
        clk_in      => cpu_clock,
        reset_out   => cpu_reset
    );

    control_unit_inst : entity work.control_unit
    PORT MAP (
        clk_in                          => cpu_clock,
        reset_in                        => cpu_reset,
        alu_op_in                       => alu_op(4 downto 1),           
        regB_data_in                    => regB_data(7 downto 0),         
        ram_data_in                     => ram_data,          
        pc_in                           => pc_out,           
        alu_result_in                   => alu_result,             
        tx_ready_in                     => tx_ready,   
        buffer_read_valid_in            => buffer_read_valid,     
        buffer_full_in                  => buffer_full,
        buffer_empty_in                 => buffer_empty,
        
        fetch_enable_out                => fetch_enable,       
        decode_enable_out               => decode_enable,
        regread_enable_out              => regread_enable, 
        alu_enable_out                  => alu_enable,       
        ram_enable_out                  => ram_enable,        
        regwrite_enable_out             => regwrite_enable,        
        ram_enable_combined_out         => ram_enable_combined,     
        reg_file_enable_combined_out    => reg_file_enable_combined, 
        pc_op_out                       => pc_op,     
        ram_store_enable_out            => ram_store_enable,
        regA_load_enable_out            => regA_load_enable,    
        regA_data_out                   => regA_data,    
        ram_address_out                 => ram_address,
        start_tx_out                    => start_tx,
        buffer_read_enable_out          => buffer_read_enable,
        buffer_write_enable_out         => buffer_write_enable  
    );

    buffer_inst : entity work.ring_buffer 
    GENERIC MAP ( 
        RAM_WIDTH => BUFFER_WIDTH, 
        RAM_DEPTH => BUFFER_DEPTH
    ) 
    PORT MAP (
        clk_in          => cpu_clock, 
        rst_in          => cpu_reset,  
        write_enable_in => buffer_write_enable,
        data_in         => alu_result(7 downto 0),                      
        read_enable_in  => buffer_read_enable,
        
        read_valid_out  => buffer_read_valid,                           
        data_out        => buffer_data,
        empty_out       => buffer_empty,
        empty_next_out  => buffer_empty_next,
        full_out        => buffer_full, 
        full_next_out   => buffer_full_next
        -- fill_count   => buffer_fill_count
    ); 

    uart_tx_inst : entity work.uart_tx 
    PORT MAP (
        clk_in          => cpu_clock, 
        tx_start_in     => start_tx,
        tx_data_in      => buffer_data,
        
        tx_ready_out    => tx_ready,
        tx_pin_out      => uart_rxd_out
    );
     
    -- program counter port mappings
    cpu_pc : entity work.pc 
    PORT MAP (
        clk_in      => cpu_clock,
        pc_op_in    => pc_op,
        pc_in       => alu_result,
        branch_in   => branch_enable,
        
        pc_out      => pc_out
    );
        
    -- ram port mappings 
    cpu_ram : entity work.ram 
    GENERIC MAP ( 
        ram_content => test_ram_content3
    ) 
    PORT MAP (
        clk_in          => cpu_clock,
        write_enable_in => ram_store_enable,
        enable_in       => ram_enable_combined,
        data_in         => alu_result,
        addr_in         => ram_address,

        data_out        => ram_data
    );
     
    -- decoder port mappings 
    cpu_decoder : entity work.decoder 
    PORT MAP (
        clk_in              => cpu_clock, 
        enable_in           => decode_enable,
        instruction_in      => ram_data,
        
        alu_op_out          => alu_op, 
        im_data_out         => im_data,
        regA_select_out     => selA,
        regB_select_out     => selB,
        regC_select_out     => selC
    );
        
    --register file port mappings
    cpu_register_file : entity work.register_file 
    PORT MAP (
        clk_in          => cpu_clock,
        enable_in       => reg_file_enable_combined,
        write_enable_in => regA_load_enable,
        regA_data_in    => regA_data,
        regA_select_in  => selA,
        regB_select_in  => selB,
        regC_select_in  => selC,
        
        regB_out        => regB_data,
        regC_out        => regC_data
    );
        
     -- alu port mappings   
     cpu_alu : entity work.alu 
     PORT MAP ( 
        clk_in                  => cpu_clock,
        enable_in               => alu_enable,
        reg_B_data_in           => regB_data,
        reg_C_data_in           => regC_data,
        im_in                   => im_data,
        alu_op_in               => alu_op,
        
        result_out              => alu_result,
        branch_enable_out       => branch_enable
    );

       -- clock process  
    clk_process : process
    begin 
        cpu_clock <= '0';
        wait for clk_period / 2;
        cpu_clock <= '1';
        wait for clk_period / 2;
    end process; 

end Behavioral; 
