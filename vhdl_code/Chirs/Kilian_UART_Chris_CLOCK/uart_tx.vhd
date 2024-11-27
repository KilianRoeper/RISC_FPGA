library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_tx is
    Port ( clk_in       : in  std_logic;                     
           tx_start_in  : in  std_logic;                     
           tx_data_in   : in  std_logic_vector(7 downto 0);  
           
           tx_ready_out : out std_logic;                     
           tx_pin_out   : out std_logic                    
          );
end uart_tx;

architecture Behavioral of uart_tx is
    constant BAUD_RATE      : integer := 9600;         -- UART baudrate
    constant CLOCK_FREQ     : integer := 100000000;       -- system clock in Hz
    constant BIT_TIME       : integer := CLOCK_FREQ / BAUD_RATE;

    type tx_state_type is (IDLE, START, DATA, STOP);     -- states
    signal tx_state        : tx_state_type := IDLE;
    signal clk_counter     : integer range 0 to BIT_TIME - 1 := 0;
    signal bit_index       : integer range 0 to 7 := 0;
    signal tx_reg          : std_logic := '1';
    signal tx_shift_reg    : std_logic_vector(7 downto 0) := (others => '0');
begin

    process(clk_in)
    begin
        if rising_edge(clk_in) then
            case tx_state is
                when IDLE =>
                    tx_reg <= '1'; -- TX-line high by default during idle 
                    tx_ready_out <= '1'; -- module ready
                    if tx_start_in = '1' then
                        tx_shift_reg <= tx_data_in; -- load data into shift register
                        tx_state <= START;
                        tx_ready_out <= '0';
                    end if;

                when START =>
                    if clk_counter < BIT_TIME - 1 then
                        clk_counter <= clk_counter + 1;
                    else
                        clk_counter <= 0;
                        tx_reg <= '0'; -- send startbit
                        tx_state <= DATA;
                    end if;

                when DATA =>
                    if clk_counter < BIT_TIME - 1 then
                        clk_counter <= clk_counter + 1;
                    else
                        clk_counter <= 0;
                        tx_reg <= tx_shift_reg(bit_index); -- send databits 
                        if bit_index < 7 then
                            bit_index <= bit_index + 1;
                        else
                            bit_index <= 0;
                            tx_state <= STOP; -- all databits have been send 
                        end if;
                    end if;

                when STOP =>
                    if clk_counter < BIT_TIME - 1 then
                        clk_counter <= clk_counter + 1;
                    else
                        clk_counter <= 0;
                        tx_reg <= '1'; -- send stopbit (high)
                        tx_state <= IDLE; -- back to idle
                    end if;
            end case;
        end if;
    end process;

    tx_pin_out <= tx_reg; -- UART TX output
end Behavioral;
