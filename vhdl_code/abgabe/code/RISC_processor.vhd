----------------------------------------------------------------------------------
-- Yannick Ott
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.risc_constants.all;
use IEEE.NUMERIC_STD.ALL;


-- Entity Declaration
-- Description: This is the top-level entity of the RISC processor, integrating all subcomponents such as the control unit, program counter, RAM, ALU, and UART
entity risc_processor is
Port (  
        cpu_clock       : in STD_LOGIC;     -- Input clock for the processor
        uart_rxd_out    : out STD_LOGIC;    -- Output UART pin to communicate with the terminal (e.g., Putty)
        sw0             : in STD_LOGIC      -- Input switch
    );
end risc_processor; 


architecture Behavioral of risc_processor is 


    -- Signal Declarations
    -- Switches and Buttons
    signal debounced_sw             : STD_LOGIC := '0';     -- Debounced signal for input switch
    
    -- Clock
    signal clk_reduced              : STD_LOGIC := '0';     -- Reduced frequency clock for internal operations

    -- Reset
    signal cpu_reset                : STD_LOGIC := '0';     -- Reset signal for all components

    -- Control Unit Signals
    signal fetch_enable             : STD_LOGIC := '0';                         -- Fetch stage enable signal
    signal decode_enable            : STD_LOGIC := '0';                         -- Decode stage enable signal
    signal regread_enable           : STD_LOGIC := '0';                         -- Register read enable signal
    signal alu_enable               : STD_LOGIC := '0';                         -- ALU operation enable signal
    signal ram_enable               : STD_LOGIC := '0';                         -- RAM operation enable signal
    signal regwrite_enable          : STD_LOGIC := '0';                         -- Register write enable signal
    signal ram_enable_combined      : STD_LOGIC := '0';                         -- Combined RAM enable signal
    signal reg_file_enable_combined : STD_LOGIC := '0';                         -- Combined register file enable signal
    signal pc_op                    : STD_LOGIC_VECTOR(1 downto 0) := "00";     -- Program counter operation signal
    signal ram_store_enable         : STD_LOGIC := '0';                         -- RAM store/write enable signal
    signal regA_load_enable         : STD_LOGIC := '0';                         -- Enable signal for loading data into Register A
    signal regA_data                : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; -- Data for Register A
    signal ram_address              : STD_LOGIC_VECTOR(7 downto 0) := X"00";    -- Address for RAM access
    signal start_tx                 : STD_LOGIC := '0';                         -- Signal to start UART transmission
    signal buffer_write_enable      : std_logic := '0';                         -- Enable signal for writing to the UART buffer
    signal buffer_read_enable       : std_logic := '0';                         -- Enable signal for reading from the UART buffer
    signal buffer_data_from_cu      : STD_LOGIC_VECTOR(7 downto 0) := X"00";    -- Data from Control Unit to UART buffer
    
    -- Program Counter Signals
    signal pc_out                   : STD_LOGIC_VECTOR(7 downto 0) := X"00";    -- Current value of the Program Counter
    
    -- RAM Signals
    signal ram_data                 : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; -- Data output from RAM
    
    -- Decoder Signals
    signal alu_op                   : STD_LOGIC_VECTOR(4 downto 0) := "00000";  -- Operation code for the ALU
    signal im_data                  : STD_LOGIC_VECTOR(7 downto 0) := X"00";    -- Immediate data for the ALU
    signal selA                     : STD_LOGIC_VECTOR(2 downto 0) := "000";    -- Selector for Register A
    signal selB                     : STD_LOGIC_VECTOR(2 downto 0) := "000";    -- Selector for Register B
    signal selC                     : STD_LOGIC_VECTOR(2 downto 0) := "000";    -- Selector for Register C
    
    -- Register File Signals
    signal regB_data                : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; -- Data output from Register B
    signal regC_data                : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; -- Data output from Register C

    -- ALU Signals
    signal alu_result               : STD_LOGIC_VECTOR(15 downto 0) := X"0000"; -- Result of ALU operations
    signal branch_enable            : STD_LOGIC := '0';                         -- Signal to enable branching based on ALU result
    
    -- UART Transmission Signals
    signal tx_ready                 : std_logic := '0';                         -- UART ready signal
    
    -- UART Buffer Signals
    signal buffer_data              : STD_LOGIC_VECTOR(7 downto 0) := X"00";    -- Data from UART buffer
    signal buffer_read_valid        : std_logic := '0';                         -- Signal indicating valid data in UART buffer
    signal buffer_full              : std_logic := '0';                         -- Signal indicating buffer is full
    signal buffer_full_next         : std_logic := '0';                         -- Next state of the buffer full signal
    signal buffer_empty             : std_logic := '1';                         -- Signal indicating buffer is empty
    signal buffer_empty_next        : std_logic := '1';                         -- Next state of the buffer empty signal
    constant BUFFER_WIDTH           : integer := 8;                             -- Width of the UART buffer
    constant BUFFER_DEPTH           : integer := 16;                            -- Depth of the UART buffer


begin 


-- Port mappings  
    
    -- Switches and Buttons
    -- Description: Handles debouncing of input switches and buttons
    switches_and_buttons_inst : entity work.switches_and_buttons
    PORT MAP (
        clk_in      => cpu_clock,-- Input clock signal for debouncing logic
        sw_in       => sw0,-- Input signal from the switch
        
        deb_sw_out  => debounced_sw-- Output signal after debouncing
    );
        
    -- Clock Divider
    -- Description: Reduces the input clock frequency for internal operations
    clock_inst : entity work.clock
    PORT MAP (
        fpga_clock_in   => cpu_clock,-- Input clock signal from the FPGA
        sw_in           => debounced_sw,-- Debounced switch input for clock adjustments
        
        cpu_clock_out   => clk_reduced -- Output clock signal with reduced frequency
    );
    
    -- Reset Controller
    -- Description: Generates a reset signal synchronized with the reduced clock
    reset_inst : entity work.reset
    PORT MAP ( 
        clk_in      => clk_reduced,-- Input clock signal for synchronization
        reset_out   => cpu_reset-- Synchronized reset signal
    );    
    
    -- Control Unit
    -- Description: Manages the control signals for the entire processor based on the current state
    control_unit_inst : entity work.control_unit
    PORT MAP (
        clk_in                          => clk_reduced,                 -- Input clock signal
        reset_in                        => cpu_reset,                   -- Reset signal for the Control Unit
        alu_op_in                       => alu_op(4 downto 1),          -- Input ALU operation code       
        regB_data_in                    => regB_data(7 downto 0),       -- Input data from Register B   
        ram_data_in                     => ram_data,                    -- Input data from RAM       
        pc_in                           => pc_out,                      -- Input program counter value    
        alu_result_in                   => alu_result,                  -- Result from ALU operations          
        tx_ready_in                     => tx_ready,                    -- Indicates UART is ready for transmission  
        buffer_read_valid_in            => buffer_read_valid,           -- Indicates valid data is available in the buffer    
        buffer_full_in                  => buffer_full,                 -- Indicates the buffer is full
        buffer_empty_in                 => buffer_empty,                -- Indicates the buffer is empty
        
        fetch_enable_out                => fetch_enable,                -- Enables instruction fetching  
        decode_enable_out               => decode_enable,               -- Enables instruction decoding
        regread_enable_out              => regread_enable,              -- Enables register read operations
        alu_enable_out                  => alu_enable,                  -- Enables ALU operations      
        ram_enable_out                  => ram_enable,                  -- Enables RAM read or write operations
        regwrite_enable_out             => regwrite_enable,             -- Enables writing to registers    
        ram_enable_combined_out         => ram_enable_combined,         -- Combined enable signal for RAM   
        reg_file_enable_combined_out    => reg_file_enable_combined,    -- Combined enable signal for register file
        pc_op_out                       => pc_op,                       -- Control signal for program counter operations  
        ram_store_enable_out            => ram_store_enable,            -- Enables writing data to RAM
        regA_load_enable_out            => regA_load_enable,            -- Enables loading data into Register A
        regA_data_out                   => regA_data,                   -- Data output to Register A
        ram_address_out                 => ram_address,                 -- Address output for RAM access
        start_tx_out                    => start_tx,                    -- Signal to start UART transmission
        buffer_read_enable_out          => buffer_read_enable,          -- Enables reading data from the buffer
        buffer_write_enable_out         => buffer_write_enable,         -- Enables writing data into the buffer
        buffer_data_out                 => buffer_data_from_cu          -- Data output from the Control Unit to the buffer
    );

    -- Ring Buffer
    -- Description: Implements a circular buffer (FIFO) for temporary data storage
    -- This module allows efficient storage and retrieval of data for communication
    buffer_inst : entity work.ring_buffer 
    GENERIC MAP ( 
        RAM_WIDTH => BUFFER_WIDTH,                      -- Width of each data entry in the buffer
        RAM_DEPTH => BUFFER_DEPTH                       -- Total number of entries in the buffer
    ) 
    PORT MAP (
        clk_in          => clk_reduced,                 -- Input clock signal
        rst_in          => cpu_reset,                   -- Reset signal to initialize the buffer
        write_enable_in => buffer_write_enable,         -- Enable signal for writing data into the buffer
        data_in         => buffer_data_from_cu,         -- Data input signal from the Control Unit                      
        read_enable_in  => buffer_read_enable,          -- Enable signal for reading data from the buffer
        
        read_valid_out  => buffer_read_valid,           -- Indicates if data is valid for reading                           
        data_out        => buffer_data,                 -- Output signal for the data read from the buffer
        empty_out       => buffer_empty,                -- Indicates if the buffer is empty
        empty_next_out  => buffer_empty_next,           -- Predicts if the buffer will be empty after the next operation
        full_out        => buffer_full,                 -- Indicates if the buffer is full
        full_next_out   => buffer_full_next             -- Predicts if the buffer will be full after the next operation
    ); 

    -- UART Transmitter
    -- Description: Handles serial data transmission to an external device
    -- Sends data from the buffer to the UART receiver)
    uart_tx_inst : entity work.uart_tx 
    PORT MAP (
        clk_in          => cpu_clock,                   -- Clock signal for UART transmission
        tx_start_in     => start_tx,                    -- Signal to initiate transmission
        tx_data_in      => buffer_data,                 -- Data to be transmitted from the buffer
        
        tx_ready_out    => tx_ready,                    -- Indicates if the UART is ready for a new transmission
        tx_pin_out      => uart_rxd_out                 -- Transmitted data pin connected to the external UART receiver
    );
     
    -- Program Counter (PC)
    -- Description: Keeps track of the current instruction address in the program
    -- Provides sequential or branch-based instruction flow for the processor
    cpu_pc : entity work.pc 
    PORT MAP (
        clk_in      => clk_reduced,                     -- Clock signal for program counter
        pc_op_in    => pc_op,                           -- Control signal determining the operation of the program counter
        pc_in       => alu_result,                      -- Input address for jump or branch instructions
        branch_in   => branch_enable,                   -- Signal to enable branching
        
        pc_out      => pc_out                           -- Current program counter address
    );
        
    -- RAM
    -- Description: Memory module for instruction and data storage
    -- Handles read and write operations for instructions and data used by the processor
    cpu_ram : entity work.ram 
    GENERIC MAP ( 
        ram_content => test_ram_content3                -- Predefined content for the RAM module
    ) 
    PORT MAP (
        clk_in          => clk_reduced,                 -- Clock signal for RAM operations
        write_enable_in => ram_store_enable,            -- Enables writing data into RAM
        enable_in       => ram_enable_combined,         -- Enables read or write operations in RAM
        data_in         => alu_result,                  -- Data input for writing into RAM
        addr_in         => ram_address,                 -- Address input for accessing RAM locations

        data_out        => ram_data                     -- Data output read from RAM
    );
     
    -- Instruction Decoder
    -- Description: Decodes instructions fetched from RAM into control signals
    -- Provides control signals and data for the ALU, registers, and immediate values
    cpu_decoder : entity work.decoder 
    PORT MAP (
        clk_in              => clk_reduced,             -- Clock signal for the decoder
        enable_in           => decode_enable,           -- Enable signal for instruction decoding
        instruction_in      => ram_data,                -- Input instruction data from RAM
        
        alu_op_out          => alu_op,                  -- Decoded ALU operation code
        im_data_out         => im_data,                 -- Immediate data extracted from the instruction
        regA_select_out     => selA,                    -- Register A select signal
        regB_select_out     => selB,                    -- Register B select signal
        regC_select_out     => selC                     -- Register C select signal
    );
        
    -- Register File
    -- Description: Stores and manages general-purpose registers for the processor
    -- Handles read and write operations to provide data for instructions
    cpu_register_file : entity work.register_file 
    PORT MAP (
        clk_in          => clk_reduced,                 -- Clock signal for register file operations
        enable_in       => reg_file_enable_combined,    -- Enables register file operations
        write_enable_in => regA_load_enable,            -- Enables writing data into registers
        regA_data_in    => regA_data,                   -- Data input for writing into register A
        regA_select_in  => selA,                        -- Register A selection signal
        regB_select_in  => selB,                        -- Register B selection signal
        regC_select_in  => selC,                        -- Register C selection signal
        
        regB_out        => regB_data,                   -- Data output for register B
        regC_out        => regC_data                    -- Data output for register C
    );
        
    -- ALU
    -- Description: Performs arithmetic and logic operations based on instruction control signals
    -- Provides results for computations and branching decisions
     cpu_alu : entity work.alu 
     PORT MAP ( 
        clk_in                  => clk_reduced,         -- Clock signal for ALU operations
        enable_in               => alu_enable,          -- Enable signal for ALU operations
        reg_B_data_in           => regB_data,           -- Data input from register B
        reg_C_data_in           => regC_data,           -- Data input from register C
        im_in                   => im_data,             -- Immediate data input
        alu_op_in               => alu_op,              -- Operation code for ALU operations
        
        result_out              => alu_result,          -- Result of the ALU operation
        branch_enable_out       => branch_enable        -- Branch enable signal for program control
    );

end Behavioral; 
