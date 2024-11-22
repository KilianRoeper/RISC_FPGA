----------------------------------------------------------------------------------
-- Created by Yannick Ott
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.RISC_constants.ALL; 


-- Entity definition for the Control Unit
entity ControlUnit is
Port ( 
        cpu_clock : in STD_LOGIC := '0';    -- Clock signal for the Control Unit
        reset     : in STD_LOGIC := '0'     -- Reset signal to initialize the Control Unit
      );
end ControlUnit;

architecture Behavioral of ControlUnit is
    
-- Signal declarations - Internal signals for connecting components and managing state transitions

    -- Pipeline states - Signal to represent the state of the pipeline (e.g., Fetch, Decode, Execute, etc.)
    type state is (state_fetch, state_decode,state_reg_read, state_alu_en, state_ram_en, state_reg_write);
    signal sig : state := state_fetch;
    
    -- CPU signals
    -- Global reset signal for the CPU
    signal cpu_reset    : STD_LOGIC := '0';
    
    -- Control Unit - Control signals for managing the pipeline stages
    signal sig_fetch             : std_logic := '0';                                -- Enables the fetch cycle
    signal sig_decode            : std_logic := '0';                                -- Enables the decode cycle
    signal sig_reg_read          : std_logic := '0';                                -- Enables register read operations
    signal sig_alu_en            : std_logic := '0';                                -- Enables ALU computation
    signal sig_ram_en            : std_logic := '0';                                -- Enables RAM access
    signal sig_reg_write         : std_logic := '0';                                -- Enables writing to registers
    signal sig_pc_op_out         : std_logic_vector(1 downto 0) := (others => '0'); -- PC operation control (e.g., increment, branch)
    signal sig_regA_load_enable  : std_logic := '0';                                -- Enables loading data into Register A
    signal sig_ram_store_enable  : std_logic := '0';                                -- Enables storing data into RAM
    
    -- Register File - Signals for managing the register file and its operations
    signal sig_regB_out                 : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; -- Output of Register B
    signal sig_regC_out                 : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; -- Output of Register C
    signal sig_regA_data_in             : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; -- Input data for Register A
    signal reg_file_enable_combined     : std_logic := '0';                         -- Combined enable signal for the register file
    
    -- ALU - Signals for controlling and receiving data from the ALU
    signal sig_result_out           : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; -- ALU computation result
    signal sig_branch_enable_out    : STD_LOGIC := '0';                         -- Enables branch condition checking
    signal sig_regA_write_enable_out: STD_LOGIC := '0';                         -- Enables writing to Register A after ALU computation
    
    -- RAM - Signals for managing RAM access and data transfers
    signal sig_data_out            : STD_LOGIC_VECTOR(15 downto 0) := X"0000";  -- Data output from RAM
    signal sig_address_in          : STD_LOGIC_VECTOR(4 downto 0);              -- Address for RAM access
    signal sig_ram_enable_in       : STD_LOGIC := '0';                          -- Enables RAM access
    signal sig_ram_reset           : STD_LOGIC := '0';
        
    -- PC - Signals for controlling and receiving data from the Program Counter
    signal sig_pc_out : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; -- Program Counter output
    
    -- Decoder - Signals for controlling and receiving outputs from the instruction decoder
    signal sig_alu_op_out               : STD_LOGIC_VECTOR(4 downto 0) := "00000";  -- ALU operation control
    signal sig_regA_select_out          : STD_LOGIC_VECTOR(2 downto 0) := "000";    -- Selects Register A
    signal sig_im_data_out : STD_LOGIC_VECTOR(7 downto 0) := X"00";                 -- Immediate value
    signal sig_regA_write_out           : STD_LOGIC := '0';                         -- Enables writing to Register A
    signal sig_regB_select_out          : STD_LOGIC_VECTOR(2 downto 0) := "000";    -- Selects Register B
    signal sig_regC_select_out          : STD_LOGIC_VECTOR(2 downto 0) := "000";    -- Selects Register C
    

begin
-- Port Mappings

    -- Register File
     cpu_register_file : entity work.register_file PORT MAP (
        clk_in          => cpu_clock,
        enable_in       => reg_file_enable_combined,               -- Activates the register file for read/write operations
        write_enable_in => sig_regA_write_enable_out,              -- Write enable for Register A
        regA_data_in    => sig_regA_data_in,                       -- Data to be written into Register A
        regA_select_in  => sig_regA_select_out,                    -- Selection signal for Register A
        regB_select_in  => sig_regB_select_out,                    -- Selection signal for Register B
        regC_select_in  => sig_regC_select_out,                    -- Selection signal for Register C
        regB_out        => sig_regB_out,                           -- Output data from Register B
        regC_out        => sig_regC_out                            -- Output data from Register C
    );

    -- Decoder
    cpu_decoder : entity work.decoder PORT MAP (
        clk_in           => cpu_clock,
        enable_in        => sig_decode,             -- Activates the decoder for instruction decoding
        instruction_in   => sig_data_out,           -- Instruction input from RAM
        alu_op_out       => sig_alu_op_out,         -- ALU operation code output
        im_data_out      => sig_im_data_out,        -- Immediate data output
        regA_select_out  => sig_regA_select_out,    -- Register A selection signal output
        regB_select_out  => sig_regB_select_out,    -- Register B selection signal output
        regC_select_out  => sig_regC_select_out     -- Register C selection signal output
    );
    
    -- ALU
    cpu_alu : entity work.alu PORT MAP  (
        clk_in                => cpu_clock,
        enable_in             => sig_alu_en,                -- Activates the ALU for computations
        regB_data_in          => sig_regB_out,              -- Input data from Register B
        regC_data_in          => sig_regC_out,              -- Input data from Register C
        im_in                 => sig_im_data_out,           -- Immediate data input
        alu_op_in             => sig_alu_op_out,            -- ALU operation code input
        result_out            => sig_result_out,            -- Computation result output
        branch_enable_out     => sig_branch_enable_out      -- Branch condition signal output
    );
    
    -- Program Counter (PC)
    cpu_pc : entity work.pc PORT MAP (
        clk_in      => cpu_clock,
        pc_op_in    => sig_pc_op_out,           -- Program Counter operation control signal
        pc_in       => sig_result_out,          -- Input value for Program Counter
        branch_in   => sig_branch_enable_out,   -- Branch enable signal
        pc_out      => sig_pc_out               -- Program Counter output
    );
    
    -- RAM
      cpu_ram : entity work.ram 
      GENERIC MAP ( 
        ram_content => test_ram_content1
      ) 
      PORT MAP(
        clk_in              => cpu_clock,   
        reset_in            => sig_ram_reset,
        write_enable_in     => sig_ram_store_enable,         -- Write enable signal for RAM
        enable_in           => sig_ram_en,                   -- Activates RAM for data access
        data_in             => sig_result_out,               -- Data to be written into RAM
        addr_in             => sig_address_in,   -- Address input for RAM
        data_out            => sig_data_out                  -- Data output from RAM
    );
    


    -- Clock-driven process to manage control signals and state transitions
    process(cpu_clock)
    begin
        if rising_edge(cpu_clock) then
            if reset = '1' then
                -- Reset all control signals
                sig_fetch <= '0';
                sig_decode <= '0';
                sig_reg_read <= '0';
                sig_alu_en <= '0';
                sig_ram_en <= '0';
                sig_reg_write <= '0';
                sig_regA_load_enable <= '0';
                sig_ram_store_enable <= '0';
            else
                -- State-based control signal activation
                case sig is
                    when state_fetch =>
                        sig_reg_write <= '0';
                        sig_fetch <= '1';
                        sig <= state_decode;
                    when state_decode =>
                        sig_fetch <= '0';
                        sig_decode <= '1';
                        sig <= state_reg_read;
                    when state_reg_read =>
                        sig_decode <= '0';
                        sig_reg_read <= '1';
                        sig <= state_alu_en;
                    when state_alu_en =>
                        sig_reg_read <= '0';
                        sig_alu_en <= '1';
                        sig <= state_ram_en;
                    when state_ram_en =>
                        sig_alu_en <= '0';
                        sig_ram_en <= '1';
                        sig <= state_reg_write;
                    when state_reg_write =>
                        sig_ram_en <= '0';
                        sig_reg_write <= '1';
                        sig <= state_fetch;  -- Restart the cycle
                    when others =>
                        sig <= state_fetch;
                end case;
    
                -- Combined control signals for Register File and RAM
                reg_file_enable_combined <= sig_reg_read or sig_reg_write;
                sig_ram_enable_in <= sig_fetch or sig_ram_en;
    
                -- Program Counter operation control
                if reset = '1' then
                    sig_pc_op_out <= "11";  -- Reset
                elsif sig_reg_write = '1' then
                    sig_pc_op_out <= "01";  -- Increment
                else
                    sig_pc_op_out <= "00";  -- No operation (NOP)
                end if;
    
                -- Address multiplexer control for RAM (PC or Register B)
                if sig_ram_store_enable = '1' then
                    sig_address_in <= sig_regB_out(4 downto 0);   -- Address from Register B
                else
                    sig_address_in <= sig_pc_out(4 downto 0);       -- Address from PC    
                end if;
    
                -- Data multiplexer control for Register A (RAM or ALU)
                if sig_regA_load_enable = '1' then
                    sig_regA_data_in <= sig_data_out;       -- Data from RAM   
                else 
                    sig_regA_data_in <= sig_result_out;     -- Data from ALU
                end if;                          
                
                -- enabling regA write for one cycle
                if not(sig_alu_op_out(4 downto 1) = OPCODE_SW 
                    or sig_alu_op_out(4 downto 1) = OPCODE_BEQ 
                    or sig_alu_op_out(4 downto 1) = OPCODE_B) 
                    and sig_ram_en = '1' then 
                        sig_regA_load_enable <= '1';
                elsif not(sig_alu_op_out(4 downto 1) = OPCODE_SW 
                    or sig_alu_op_out(4 downto 1) = OPCODE_BEQ 
                    or sig_alu_op_out(4 downto 1) = OPCODE_B) 
                    and sig_reg_write = '1' then
                        sig_regA_load_enable <= '0';
                else 
                    sig_regA_load_enable <= '0';     
                end if;    
                
                    -- enabling RAM-write for one cycle 
                if sig_alu_op_out(4 downto 1) = OPCODE_SW and sig_alu_en = '1' then
                    sig_ram_store_enable <= '1';
                elsif sig_alu_op_out(4 downto 1) = OPCODE_SW and sig_ram_en = '1' then
                    sig_ram_store_enable <= '0';
                else 
                    sig_ram_store_enable <= '0';
                end if;
                    
                end if;
        end if;
    end process;
end Behavioral;
