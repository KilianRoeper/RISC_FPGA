----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2024 22:58:36
-- Design Name: 
-- Module Name: uart_ring_buffer - Behavioral
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

entity ring_buffer is
  generic (
    RAM_WIDTH : natural;
    RAM_DEPTH : natural
  );
  port (
    clk_in          : in std_logic;
    rst_in          : in std_logic;
    write_enable_in : in std_logic;                                       -- Write ports
    data_in         : in std_logic_vector(RAM_WIDTH - 1 downto 0);
    read_enable_in  : in std_logic;                                       -- Read ports
    
    read_valid_out  : out std_logic;
    data_out        : out std_logic_vector(RAM_WIDTH - 1 downto 0);
    empty_out       : out std_logic;                                      -- Flags
    empty_next_out  : out std_logic;
    full_out        : out std_logic;
    full_next_out   : out std_logic
    --fill_count    : out integer range RAM_DEPTH - 1 downto 0       -- The number of elements in the FIFO
  );
end ring_buffer;

architecture Behavioral of ring_buffer is

    type ram_type is array (0 to RAM_DEPTH - 1) of std_logic_vector(data_in'range);
    signal ram : ram_type;
      
    subtype index_type is integer range ram_type'range;
    signal head : index_type;
    signal tail : index_type;
      
    signal empty_i : std_logic;
    signal full_i : std_logic;
    signal fill_count_i : integer range RAM_DEPTH - 1 downto 0;
    --signal uart_buffer2 : ram_type := (X"45", X"46", X"47", X"48", X"49", X"31", X"32", X"33", X"34", X"35", X"36", X"37", X"38", X"39", X"40", X"41", others=>X"00");
      
    -- Increment and wrap
    procedure incr(signal index : inout index_type) is
    begin
      if index = index_type'high then
        index <= index_type'low;
      else
        index <= index + 1;
      end if;
    end procedure;
    
    begin
    
    -- Copy internal signals to output
    empty_out <= empty_i;
    full_out <= full_i;
    --fill_count <= fill_count_i;
      
    -- Set the flags
    empty_i <= '1' when fill_count_i = 0 else '0';
    empty_next_out <= '1' when fill_count_i <= 1 else '0';
    full_i <= '1' when fill_count_i >= RAM_DEPTH - 1 else '0';
    full_next_out <= '1' when fill_count_i >= RAM_DEPTH - 2 else '0';
    
    PROC_HEAD : process(clk_in)
    begin
      if rising_edge(clk_in) then
        if rst_in = '1' then
          head <= 0;
        else
          if write_enable_in = '1' and full_i = '0' then  
            incr(head);
          end if;
        end if;
      end if;
    end process;
    
    PROC_TAIL : process(clk_in, tail, head) 
    begin
      if rising_edge(clk_in) then
        if rst_in = '1' then
          tail <= 0;
          read_valid_out <= '0';
        else
          read_valid_out <= '0';
          if read_enable_in = '1' and empty_i = '0' then
            incr(tail);
            read_valid_out <= '1';
          end if;
        end if;
      end if;
    end process;
    
    PROC_RAM : process(clk_in)
    begin
      if rising_edge(clk_in) then
        ram(head) <= data_in;
        data_out <= ram(tail);
      end if;
    end process;
    
    PROC_COUNT : process(head, tail)
    begin
      if head < tail then
        fill_count_i <= head - tail + RAM_DEPTH;
      else
        fill_count_i <= head - tail;
      end if;
    end process;

end Behavioral;
