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
use work.RISC_constants.OPCODE_LW;
use work.RISC_constants.OPCODE_SW;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_unit is
Port (  cpu_clock : in STD_LOGIC := '0'
    );
end control_unit;

architecture Behavioral of control_unit is

-- components      

    -- program counter component
    component PC
    Port ( clk_in   : in STD_LOGIC;
           pc_op_in : in STD_LOGIC_VECTOR (1 downto 0);
           pc_in    : in STD_LOGIC_VECTOR (15 downto 0);
           
           pc_out   : out STD_LOGIC_VECTOR (15 downto 0) 
    );
    end component;
    
    -- ram component
    component ram
    Port ( clk_in           : in STD_LOGIC;
           write_enable_in  : in STD_LOGIC;
           enable_in        : in STD_LOGIC;
           data_in          : in STD_LOGIC_VECTOR (15 downto 0);
           addr_in          : in STD_LOGIC_VECTOR (15 downto 0);
           
           data_out         : out STD_LOGIC_VECTOR (15 downto 0)
       );
    end component;
    
    -- decoder component 
    component decoder
    Port (clk_in            : in STD_LOGIC;
          enable_in         : in STD_LOGIC; 
          instruction_in    : in STD_LOGIC_VECTOR (15 downto 0);
          
          store_enable_out  : out STD_LOGIC;
          alu_op_out        : out STD_LOGIC_VECTOR (4 downto 0);
          im_data_out       : out STD_LOGIC_VECTOR (15 downto 0);
          regA_write_out    : out STD_LOGIC;
          regA_select_out   : out STD_LOGIC_VECTOR (2 downto 0);
          regB_select_out   : out STD_LOGIC_VECTOR (2 downto 0);
          regC_select_out   : out STD_LOGIC_VECTOR (2 downto 0)  
      );
    end component;
    
    -- register file component 
    component register_file
    Port (  clk_in              : in STD_LOGIC;
            enable_in           : in STD_LOGIC;
            write_enable_in     : in STD_LOGIC;
            regA_data_in        : in STD_LOGIC_VECTOR (15 downto 0);
            regA_select_in      : in STD_LOGIC_VECTOR (2 downto 0);
            regB_select_in      : in STD_LOGIC_VECTOR (2 downto 0);
            regC_select_in      : in STD_LOGIC_VECTOR (2 downto 0);
            
            regB_out            : out STD_LOGIC_VECTOR (15 downto 0); 
            regC_out            : out STD_LOGIC_VECTOR (15 downto 0)
          );
            
            
    end component;
    
    -- alu component 
    component alu
    Port (  clk_in                  : in STD_LOGIC;
            enable_in               : in STD_LOGIC;
            regA_write_in           : in STD_LOGIC;
            store_enable_in         : in STD_LOGIC;
            reg_B_data_in           : in STD_LOGIC_VECTOR (15 downto 0);
            reg_C_data_in           : in STD_LOGIC_VECTOR (15 downto 0);
            pc_in                   : in STD_LOGIC_VECTOR (15 downto 0);
            im_in                   : in STD_LOGIC_VECTOR (15 downto 0);
            alu_op_in               : in STD_LOGIC_VECTOR (4 downto 0);
            
            result_out              : out STD_LOGIC_VECTOR (15 downto 0);
            branch_enable_out       : out STD_logic ;
            regA_write_out          : out STD_LOGIC;
            store_enable_out        : out STD_LOGIC
       );  
    end component;
      
    
    
    
      
      
      
      
      
      
      
-- signals and constants
    signal s_state : STD_LOGIC_VECTOR(5 downto 0) := "000001";
    
    -- CPU signals/ constants
    constant clk_period : time := 10 ns;
    signal cpu_reset    : STD_LOGIC := '0';
    
    -- Control Unit
    signal fetch_enable     : STD_LOGIC := '0';
    signal decode_enable    : STD_LOGIC := '0';
    signal regread_enable   : STD_LOGIC := '0';
    signal alu_enable       : STD_LOGIC := '0';
    signal ram_enable       : STD_LOGIC := '0';
    signal regwrite_enable  : STD_LOGIC := '0';
    signal pc_op_out        : STD_LOGIC_VECTOR(1 downto 0) := "00";
    
    -- Program Counter
    signal pc_out : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    
    -- ram 
    signal ram_data             : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal ram_address          : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal ram_enable_combined  : STD_LOGIC := '0';
    
    --decoder 
    signal deco_store_enable_out    : STD_LOGIC := '0';
    signal alu_op_out               : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal selA_out                 : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal im_data_out              : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal regA_write_out           : STD_LOGIC := '0';
    signal selB_out                 : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal selC_out                 : STD_LOGIC_VECTOR(2 downto 0) := "000";

    -- register file
    signal regB_data                : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal regC_data                : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal regA_data_in             : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal reg_file_enable_combined : STD_LOGIC := '0';

    -- alu
    signal alu_result_out       : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal alu_regA_write_out   : STD_LOGIC := '0';
    signal alu_store_enable_out : STD_LOGIC := '0';
    signal branch_enable_out    : STD_LOGIC := '0';
        
   
    
begin
-- port mappings
        
    -- program counter port mappings
    cpu_pc : PC PORT MAP (
        clk_in      => cpu_clock,
        pc_op_in    => pc_op_out,
        pc_in       => alu_result_out,
        
        pc_out      => pc_out
    );
        
    -- ram port mappings 
    cpu_ram : ram PORT MAP (
        clk_in          => cpu_clock,
        write_enable_in => alu_store_enable_out,
        enable_in       => ram_enable_combined,
        data_in         => alu_result_out,
        addr_in         => ram_address,

        data_out        => ram_data
        );
     
    -- decoder port mappings 
    cpu_decoder : decoder PORT MAP (
        clk_in              => cpu_clock,
        enable_in           => decode_enable,
        instruction_in      => ram_data,
        
        store_enable_out    => deco_store_enable_out,
        alu_op_out          => alu_op_out, 
        im_data_out         => im_data_out,
        regA_write_out      => regA_write_out,
        regA_select_out     => selA_out,
        regB_select_out     => selB_out,
        regC_select_out     => selC_out
        );
        
    --register file port mappings
    cpu_register_file : register_file PORT MAP (
        clk_in          => cpu_clock,
        enable_in       => reg_file_enable_combined,
        write_enable_in => alu_regA_write_out,
        regA_data_in    => alu_result_out,
        regA_select_in  => selA_out,
        regB_select_in  => selB_out,
        regC_select_in  => selC_out,
        
        regB_out        => regB_data,
        regC_out        => regC_data
        );
        
     -- alu port mappings   
     cpu_alu : alu PORT MAP (
        clk_in                  => cpu_clock,
        enable_in               => alu_enable,
        regA_write_in           => regA_write_out,
        store_enable_in         => deco_store_enable_out,
        reg_B_data_in           => regB_data,
        reg_C_data_in           => regC_data,
        pc_in                   => pc_out,
        im_in                   => im_data_out,
        alu_op_in               => alu_op_out,
        
        result_out              => alu_result_out,
        branch_enable_out       => branch_enable_out,
        regA_write_out          => alu_regA_write_out,
        store_enable_out        => alu_store_enable_out
     );
        
        
        
        
        

-- core clock process to pulse the entire computer 
    process(cpu_clock) 
    begin
        if rising_edge(cpu_clock) then 
            if(cpu_reset = '1') then
                s_state <= "000001";
            else
                s_state <= s_state(s_state'left-1 downto 0) & '0';  -- Linksverschiebung für pipelining 
            end if;
            fetch_enable <= s_state(0);
            decode_enable <= s_state(1);
            regread_enable <= s_state(2);
            alu_enable <= s_state(3);
            ram_enable <= s_state(4);
            regwrite_enable <= s_state(5);
            reg_file_enable_combined <= regread_enable or regwrite_enable;
            ram_enable_combined <= fetch_enable or ram_enable;
            
            -- pc_op selection
            if cpu_reset = '1' then
                pc_op_out <= "00";  -- reset
            elsif branch_enable_out = '0' and regwrite_enable = '1' then
                pc_op_out <= "01";  -- increment
            elsif branch_enable_out = '1' and regwrite_enable = '1' then
                pc_op_out <= "10";  -- jump
            else
                pc_op_out <= "11";  -- nop
            end if;
            
            -- pc_or_regfile signal
            if ram_enable = '1' and alu_op_out = OPCODE_SW then
                ram_address <= regB_data; 
            else
                ram_address <= pc_out;     
            end if;
            
            -- ram_or_alu signal
            if alu_op_out = OPCODE_LW and ram_enable = '1' then
                regA_data_in <= ram_data;       
            else 
                regA_data_in <= alu_result_out;
            end if;                          
            
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
    
end Behavioral;
