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

entity uart_ring_buffer is
  generic (
    RAM_WIDTH : natural;
    RAM_DEPTH : natural
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    wr_en : in std_logic;                                       -- Write ports
    wr_data : in std_logic_vector(RAM_WIDTH - 1 downto 0);
    rd_en : in std_logic;                                       -- Read ports
    rd_valid : out std_logic;
    rd_data : out std_logic_vector(RAM_WIDTH - 1 downto 0);
    empty : out std_logic;                                      -- Flags
    empty_next : out std_logic;
    full : out std_logic;
    full_next : out std_logic
  --  fill_count : out integer range RAM_DEPTH - 1 downto 0       -- The number of elements in the FIFO
  );
end uart_ring_buffer;

architecture Behavioral of uart_ring_buffer is

    type ram_type is array (0 to RAM_DEPTH - 1) of std_logic_vector(wr_data'range);
    signal ram : ram_type;
      
    subtype index_type is integer range ram_type'range;
    signal head : index_type;
    signal tail : index_type;
      
    signal empty_i : std_logic;
    signal full_i : std_logic;
    signal fill_count_i : integer range RAM_DEPTH - 1 downto 0;
      
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
    empty <= empty_i;
    full <= full_i;
  --  fill_count <= fill_count_i;
      
    -- Set the flags
    empty_i <= '1' when fill_count_i = 0 else '0';
    empty_next <= '1' when fill_count_i <= 1 else '0';
    full_i <= '1' when fill_count_i >= RAM_DEPTH - 1 else '0';
    full_next <= '1' when fill_count_i >= RAM_DEPTH - 2 else '0';
    
    PROC_HEAD : process(clk)
    begin
      if rising_edge(clk) then
        if rst = '1' then
          head <= 0;
        else
      
          if wr_en = '1' and full_i = '0' then
            incr(head);
          end if;
      
        end if;
      end if;
    end process;
    
    PROC_TAIL : process(clk)
    begin
      if rising_edge(clk) then
        if rst = '1' then
          tail <= 0;
          rd_valid <= '0';
        else
          rd_valid <= '0';
      
          if rd_en = '1' and empty_i = '0' then
            incr(tail);
            rd_valid <= '1';
          end if;
        end if;
      end if;
    end process;
    
    PROC_RAM : process(clk)
    begin
      if rising_edge(clk) then
        ram(head) <= wr_data;
        rd_data <= ram(tail);
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
