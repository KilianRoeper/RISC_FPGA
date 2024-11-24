library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_rx is
    Port ( clk         : in  std_logic;                  -- Systemtakt
           rx          : in  std_logic;                  -- UART RX-Pin
           uart_rxd_out : out std_logic_vector(7 downto 0); -- Empfangene Daten
           rx_ready    : out std_logic                   -- Daten bereit
          );
end uart_rx;

architecture Behavioral of uart_rx is
    constant BAUD_RATE      : integer := 9600;         -- UART Baudrate
    constant CLOCK_FREQ     : integer := 100000000;       -- Systemtakt in Hz
    constant BIT_TIME       : integer := CLOCK_FREQ / BAUD_RATE;
    
    signal clk_counter      : integer range 0 to BIT_TIME - 1 := 0;
    signal bit_index        : integer range 0 to 9 := 0; -- Startbit, 8 Datenbits, Stopbit
    signal rx_shift_reg     : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_sampled       : std_logic := '1';
    signal receiving        : std_logic := '0';
begin

process(clk)
begin
    if rising_edge(clk) then
        if clk_counter < BIT_TIME - 1 then
            clk_counter <= clk_counter + 1;
        else
            clk_counter <= 0;

            if receiving = '0' then
                -- Empfang starten, wenn Startbit erkannt wird
                if rx = '0' then
                    receiving <= '1';
                    bit_index <= 1; -- Datenbit-Zähler auf das erste Bit setzen
                    rx_ready <= '0';
                end if;

            elsif receiving = '1' then
                -- Empfang der Datenbits und des Stopbits
                if bit_index <= 8 then
                    -- Datenbits empfangen
                    rx_shift_reg(bit_index - 1) <= rx;
                    bit_index <= bit_index + 1;
                elsif bit_index = 9 then
                    -- Stopbit überprüfen
                    if rx = '1' then
                        rx_ready <= '1'; -- Empfang erfolgreich
                    end if;
                    receiving <= '0'; -- Empfang abschließen
                end if;
            end if;
        end if;
    end if;
end process;
uart_rxd_out <= rx_shift_reg;

end Behavioral;
