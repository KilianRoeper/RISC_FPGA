----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.12.2024 15:25:15
-- Design Name: 
-- Module Name: control_unit_tb - Behavioral
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
use work.risc_constants.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_unit_tb is
end control_unit_tb;

architecture Behavioral of control_unit_tb is

-- test bench specific signals
    signal cpu_clock                : STD_LOGIC := '0'; 
    signal cpu_reset                : STD_LOGIC := '0';
    constant clk_period             : time := 10 ns;

-- control unit output signals 
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
    signal buffer_data_from_cu      : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    
-- control unit input signals 
    signal alu_op                   : STD_LOGIC_VECTOR(3 downto 0) := X"0";
    signal regB_data                : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    signal ram_data                 : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal pc_out                   : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    signal alu_result               : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal tx_ready                 : std_logic := '0'; 
    signal buffer_read_valid        : std_logic := '0'; 
    signal buffer_full              : std_logic := '0'; 
    signal buffer_empty             : std_logic := '1'; 

begin

control_unit_inst : entity work.control_unit
    PORT MAP (
        clk_in                          => cpu_clock,
        reset_in                        => cpu_reset,
        alu_op_in                       => alu_op,           
        regB_data_in                    => regB_data,         
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
        buffer_write_enable_out         => buffer_write_enable, 
        buffer_data_out                 => buffer_data_from_cu 
    );
    
    test_proc: process
    begin
        -- testing if all enable and enable combined signals are shifted at least once within a cycle
        wait for clk_period * 5;
        assert(regwrite_enable = '1') report " cycle didn't enable last stage" severity error;
        
        -- testing if the control unit is reset properly
        cpu_reset <= '1';
        wait for clk_period;
        assert(fetch_enable = '1') report " should have gotten to stage fetch again" severity error;
        assert(pc_op = PC_OP_RESET) report " should have reset the pc" severity error;
        
        -- enhance clock to ram_enable stage
        cpu_reset <= '0';
        wait for clk_period * 3;
        
        -- test if the ram_address is set by the contents of the register file during OPCODE_SW and if the ram store enable signal is set in time
        alu_op <= OPCODE_SW;
        regB_data <= X"0A";
        wait for clk_period;
        assert(ram_address = X"0A") report " ram address should be set according to regB_data" severity error;
        assert(ram_store_enable = '1') report " ram store_enable should have been set during OPCODE_SW" severity error;
        
        -- test if ram_address is set accordingly by pc on next clock enhancement 
        pc_out <= X"03";
        wait for clk_period;
        assert(ram_address = X"03") report " ram address should be set according to pc" severity error;
        
        -- enhance clock to test next operations
        wait for clk_period * 4;
        
        -- test whether data to write to RegA is set properly during OPCODE_LW
        alu_op <= OPCODE_LW;
        ram_data <= X"0064";
        wait for clk_period;
        assert(regA_data = X"0064") report " regA data is not set by ram_data" severity error;
        
        -- test whether regA_data is set by alu_result otherwise
        alu_result <= X"EF12";
        wait for clk_period;
        assert(regA_data = X"EF12") report " regA data is not set by alu result" severity error;
        
        -- enhance clock to test next operations
        wait for clk_period * 4;
        
       
         
        
        
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
