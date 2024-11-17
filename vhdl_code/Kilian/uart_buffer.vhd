----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2024 23:31:35
-- Design Name: 
-- Module Name: uart_buffer - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_buffer is
    generic (
        BUFFER_SIZE : integer := 16;                                    -- size of buffer
        DATA_WIDTH  : integer := 8                                      -- 1 byte per buffer element
    );
    port ( 
        clk_in       : in std_logic;
      --  reset        : in std_logic;
        data_in      : in std_logic_vector(DATA_WIDTH-1 downto 0);
        write_enable : in std_logic;                                    -- signal from processor to write to buffer
        data_out     : out std_logic_vector(DATA_WIDTH-1 downto 0);
        read_enable  : in std_logic;                                    -- signal from uart to read data from buffer
        buffer_full  : out std_logic;
        buffer_empty : out std_logic
    );
end entity;

architecture Behavioral of uart_buffer is
    type buffer_array is array (0 to BUFFER_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal uart_buffer : buffer_array := (others => X"45");
  --  signal uart_buffer2 : buffer_array := (X"45", X"46", X"47", X"48", X"49", X"31", X"32", X"33", X"34", X"35", X"36", X"37", X"38", X"39", X"40", X"41");
    signal write_ptr   : integer range 0 to BUFFER_SIZE - 1 := 0;
    signal read_ptr    : integer range 0 to BUFFER_SIZE - 1 := 0;
    signal count       : integer range 0 to BUFFER_SIZE := 0;           -- number of saved data in buffer 
   -- signal data_out1   : std_logic_vector(DATA_WIDTH-1 downto 0);
   -- signal read_ptr2    : integer range 0 to 15 := 0;

begin

-- refresh state of buffer 
buffer_full <= '1' when count = BUFFER_SIZE else '0';
buffer_empty <= '1' when count = 0 else '0';


process(clk_in)
begin
    if rising_edge(clk_in) then
 --       if reset = '1' then
 --           -- reset all states
 --           write_ptr <= 0;
 --           read_ptr <= 0;
 --           count <= 0;
 --       else
  --          data_out <= uart_buffer2(read_ptr2);
   --         read_ptr2 <= read_ptr2 + 1;
            
            -- writing and reading 
  --          if write_enable = '1' and read_enable = '1' then
  --              if count > 0 and count < BUFFER_SIZE then
  --                  -- count stays the same 
  --                  uart_buffer(write_ptr) <= data_in;
  --                  data_out <= uart_buffer(read_ptr);
  --                  write_ptr <= (write_ptr + 1) mod BUFFER_SIZE;
  --                  read_ptr <= (read_ptr + 1) mod BUFFER_SIZE;
  --              end if;
            -- reading if buffer not empty 
            if read_enable = '1' and count > 0 then
                data_out <= uart_buffer(read_ptr);
                read_ptr <= (read_ptr + 1) mod BUFFER_SIZE;
                count <= count - 1; 
            -- writing if buffer not full 
            elsif write_enable = '1' and count < BUFFER_SIZE then
                uart_buffer(write_ptr) <= data_in;
                write_ptr <= (write_ptr + 1) mod BUFFER_SIZE;
                count <= count + 1;
            end if;
   --     end if;
    end if;
end process;

end Behavioral;
