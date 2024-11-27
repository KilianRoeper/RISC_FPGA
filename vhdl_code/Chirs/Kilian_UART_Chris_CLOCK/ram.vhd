----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.10.2024 23:31:25
-- Design Name: 
-- Module Name: ram - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
library work;
use work.risc_constants.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram is
generic (
        ram_content : ram_type := (others => (others => '0'))
        );
Port (  clk_in           : in STD_LOGIC;
        write_enable_in  : in STD_LOGIC;
        enable_in        : in STD_LOGIC;
        data_in          : in STD_LOGIC_VECTOR (15 downto 0);
        addr_in          : in STD_LOGIC_VECTOR (7 downto 0);
        
        data_out         : out STD_LOGIC_VECTOR (15 downto 0)
       );
end ram;

architecture Behavioral of ram is
   signal ram: ram_type := ram_content;
   
begin
process (clk_in, enable_in)
	begin
		if rising_edge(clk_in) and enable_in = '1' then
			if (write_enable_in = '1') then
				ram(to_integer(unsigned(addr_in))) <= data_in;
			else
				data_out <= ram(to_integer(unsigned(addr_in)));
			end if;
		end if;
	end process;

end Behavioral;
