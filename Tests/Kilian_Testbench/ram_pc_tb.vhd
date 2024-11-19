----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.11.2024 11:23:25
-- Design Name: 
-- Module Name: ram_pc_tb - Behavioral
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
use work.RISC_constants.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram_pc_tb is
--  Port ( );
end ram_pc_tb;









architecture Behavioral of ram_pc_tb is

    -- ram component
    component ram
    generic ( 
        ram_content : ram_type := (others => (others => '0'))
    );
    Port ( clk_in           : in STD_LOGIC;
           write_enable_in  : in STD_LOGIC;
           enable_in        : in STD_LOGIC;
           data_in          : in STD_LOGIC_VECTOR (15 downto 0);
           addr_in          : in STD_LOGIC_VECTOR (15 downto 0);
           
           data_out         : out STD_LOGIC_VECTOR (15 downto 0)
    );
    end component;
    
    -- program counter component
    component pc
    Port ( clk_in   : in STD_LOGIC;
           pc_op_in : in STD_LOGIC_VECTOR (1 downto 0);
           pc_in    : in STD_LOGIC_VECTOR (15 downto 0);
           
           pc_out   : out STD_LOGIC_VECTOR (15 downto 0) 
    );
    end component;
    
    -- CPU signals/ constants
    constant clk_period : time := 10 ns;
    signal cpu_clock : STD_LOGIC := '0'; 
    
    -- Program Counter
    signal pc_out : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal pc_op_in : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal pc_in    : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    
    -- ram 
    signal ram_data             : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal ram_address          : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal ram_enable_combined  : STD_LOGIC := '0';
    signal ram_write_enable_in  : STD_LOGIC := '0';
    signal data_in              : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    
    --register file
    signal regB_data : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal reg_or_pc  : STD_LOGIC := '0';












begin

    -- program counter port mappings
    cpu_pc : pc PORT MAP (
        clk_in      => cpu_clock,
        pc_op_in    => pc_op_in,
        pc_in       => pc_in,
        
        pc_out      => pc_out
    );
        
    -- ram port mappings 
    cpu_ram : ram 
    GENERIC MAP ( 
        ram_content => test_ram_content
    ) 
    PORT MAP (
        clk_in          => cpu_clock,
        write_enable_in => ram_write_enable_in,
        enable_in       => ram_enable_combined,
        data_in         => data_in,
        addr_in         => ram_address,

        data_out        => ram_data
        );
        
        






    -- testing
    change: process(cpu_clock)
    begin
    -- pc_or_regfile signal
            if reg_or_pc = '0' then
                ram_address <= regB_data; 
            else
                ram_address <= pc_out;     
            end if;
    end process;
     
    vectors: process
    begin  
        -- five defined instructions
        regB_data <= X"0002";
        reg_or_pc <= '0';
        ram_enable_combined <= '1';
        wait for clk_period;
        pc_op_in <= "01";
        wait for clk_period;
        pc_op_in <= "00";
        wait for clk_period;
        
        
        reg_or_pc <= '0';
        pc_op_in <= "01";
        wait for clk_period;
        pc_op_in <= "00";
        wait for clk_period;
        
        
        reg_or_pc <= '1';
        pc_op_in <= "01";
        wait for clk_period;
        pc_op_in <= "00";
        wait for clk_period;
        
        
        pc_op_in <= "01";
        wait for clk_period;
        pc_op_in <= "00";
        wait for clk_period;
        
        
        pc_op_in <= "01";
        wait for clk_period;
        pc_op_in <= "00";
        wait for clk_period;
        
        
        reg_or_pc <= '0';
        pc_op_in <= "01";
        wait for clk_period;
        pc_op_in <= "00";
        wait for clk_period;
        
        pc_op_in <= "00";
        wait for clk_period;
        
        -- all zeros in ram 
        ram_enable_combined <= '0';
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
                
        -- ram_address <= X"001F";
        -- wait for clk_period;
        wait;
    end process;
    
    clk_process : process
    begin 
        cpu_clock <= '0';
        wait for clk_period / 2;
        cpu_clock <= '1';
        wait for clk_period / 2;
    end process; 


end Behavioral;
