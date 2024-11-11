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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_unit is
Port (  
        cpu_clock : in STD_LOGIC;  
        led2 : out std_logic;
        led3 : out std_logic;
        led4 : out std_logic;
        led5 : out std_logic
    );
end control_unit; 

architecture Behavioral of control_unit is

-- components      

    -- program counter component
    component pc
    Port ( clk_in   : in STD_LOGIC;
           pc_op_in : in STD_LOGIC_VECTOR (1 downto 0);
           pc_in    : in STD_LOGIC_VECTOR (15 downto 0);
           
           pc_out   : out STD_LOGIC_VECTOR (15 downto 0) 
    );
    end component;
    
    -- ram component
    component ram
    generic (
        ram_content : ram_type := (others => (others => '0'))
    );
    Port ( clk_in           : in STD_LOGIC;
           write_enable_in  : in STD_LOGIC;
           enable_in        : in STD_LOGIC;
           data_in          : in STD_LOGIC_VECTOR (15 downto 0);
           addr_in          : in STD_LOGIC_VECTOR (4 downto 0);
           
           data_out         : out STD_LOGIC_VECTOR (15 downto 0)
    );
    end component;
    
    -- decoder component 
    component decoder
    Port (clk_in            : in STD_LOGIC;
          enable_in         : in STD_LOGIC; 
          instruction_in    : in STD_LOGIC_VECTOR (15 downto 0);
          
          alu_op_out        : out STD_LOGIC_VECTOR (4 downto 0);
          im_data_out       : out STD_LOGIC_VECTOR (7 downto 0);
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
            reg_B_data_in           : in STD_LOGIC_VECTOR (15 downto 0);
            reg_C_data_in           : in STD_LOGIC_VECTOR (15 downto 0);
            im_in                   : in STD_LOGIC_VECTOR (7 downto 0);
            alu_op_in               : in STD_LOGIC_VECTOR (4 downto 0);
            
            result_out              : out STD_LOGIC_VECTOR (15 downto 0);
            branch_enable_out       : out STD_logic 

    );  
    end component;
      
    
    
    
      
      
      
      
      
      
      
-- signals and constants
    signal s_state : STD_LOGIC_VECTOR(5 downto 0) := "000001";
    
    -- CPU signals/ constants
    signal reset_done : STD_LOGIC := '0';
    signal cpu_reset    : STD_LOGIC := '0';
      
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
    signal ram_address          : STD_LOGIC_VECTOR(4 downto 0) := "00000";
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
        
    signal led2_state : STD_LOGIC := '0';
    signal led3_state : STD_LOGIC := '0';
    signal led4_state : STD_LOGIC := '0';
    signal led5_state : STD_LOGIC := '0';
    
    signal counter2 : integer := 0;
    signal counter3 : integer := 0;
    signal counter4 : integer := 0; 
    signal divider : integer := 1000000;
    
begin

-- port mappings  
     
    -- program counter port mappings
    cpu_pc : pc PORT MAP (
        clk_in      => cpu_clock,
        pc_op_in    => pc_op_out,
        pc_in       => alu_result_out,
        
        pc_out      => pc_out
    );
        
    -- ram port mappings 
    cpu_ram : ram 
    GENERIC MAP ( 
        ram_content => test_ram_content
    ) 
    PORT MAP (
        clk_in          => cpu_clock,
        write_enable_in => ram_store_enable,
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
        
        alu_op_out          => alu_op_out, 
        im_data_out         => im_data_out,
        regA_select_out     => selA_out,
        regB_select_out     => selB_out,
        regC_select_out     => selC_out
        );
        
    --register file port mappings
    cpu_register_file : register_file PORT MAP (
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
        
     -- alu port mappings   
     cpu_alu : alu PORT MAP ( 
        clk_in                  => cpu_clock,
        enable_in               => alu_enable,
        reg_B_data_in           => regB_data,
        reg_C_data_in           => regC_data,
        im_in                   => im_data_out,
        alu_op_in               => alu_op_out,
        
        result_out              => alu_result_out,
        branch_enable_out       => branch_enable_out
     );
     
    process(cpu_clock, fetch_enable, decode_enable, regread_enable)
    begin
        if rising_edge(cpu_clock) then
            
            counter2 <= counter2 + 1;
            counter3 <= counter3 + 1;
            counter4 <= counter4 + 1;
            
            if fetch_enable = '1' then
                if (counter2 = divider) then
                    counter2 <= 0;
                    led2_state <= not led2_state;
                end if;
            end if;
            
            if decode_enable = '1' then
                if (counter3 = divider) then
                    counter3 <= 0;
                    led3_state <= not led3_state;
                end if;
            end if;
            
            if regread_enable = '1' then
                if (counter4 = divider) then
                    counter4 <= 0;
                    led4_state <= not led4_state;
                end if;
            end if;
        end if;
    end process;
        

    -- core clock process to pulse the entire computer 
    process(cpu_clock, cpu_reset) 
    begin
        if rising_edge(cpu_clock) then 
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
            led2_state,
            led3_state,
            led4_state,
            led5_state)
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
            elsif branch_enable_out = '0' and fetch_enable = '1' then
                pc_op_out <= PC_OP_INC;  -- increment
            elsif branch_enable_out = '1' and alu_enable = '1' then
                pc_op_out <= PC_OP_ASSIGN;  -- jump
            else
                pc_op_out <= PC_OP_NOP;  -- nop
            end if;
            
            
            -- pc_or_regfile
            if ((alu_op_out(4 downto 1) = OPCODE_SW or alu_op_out(4 downto 1) = OPCODE_LW) and alu_enable = '1') then
                ram_address <= regB_data(4 downto 0); 
            else
                ram_address <= pc_out(4 downto 0);     
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
                led5_state <= not led5_state;
            elsif alu_op_out(4 downto 1) = OPCODE_SW and ram_enable = '1' then
                ram_store_enable <= '0';
            else 
                ram_store_enable <= '0';
                led5_state <= led5_state;
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
    
    
        
    -- stimulation process to reset processor on startup    
    stim_proc: process(cpu_clock)
    begin
        if rising_edge(cpu_clock) then
            if reset_done = '0' then
                cpu_reset <= '1';  
                reset_done <= '1'; 
            else
                cpu_reset <= '0'; 
            end if;
        end if;
    end process;
    
    led2 <= led2_state;
    led3 <= led3_state;
    led4 <= led4_state;
    led5 <= led5_state;
       
end Behavioral;
