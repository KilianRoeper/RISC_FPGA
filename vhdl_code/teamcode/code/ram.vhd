----------------------------------------------------------------------------------
-- Entity: ram
-- Name: Kelly Velten
----------------------------------------------------------------------------------

-- implements the RAM to hold the instructions generically

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.risc_constants.ALL;

-- Entity declaration for the RAM module
entity ram is
generic (
        ram_content : ram_type := (others => (others => '0'))
        );
Port (  clk_in           : in STD_LOGIC; --Clock input
        write_enable_in  : in STD_LOGIC; --Write enable signal
        enable_in        : in STD_LOGIC; --enable signal to activate RAM
        data_in          : in STD_LOGIC_VECTOR (15 downto 0); --16-bit data input for write operations
        addr_in          : in STD_LOGIC_VECTOR (7 downto 0); --8- bit address input for memory access
        
        data_out         : out STD_LOGIC_VECTOR (15 downto 0) --16-bit data output for read operations
       );
end ram;

--Architecture definition
architecture Behavioral of ram is
   signal ram: ram_type := ram_content;
   
begin
-- Process triggered on the rising edge of the clock and dependent on the enable signal
process (clk_in, enable_in)
	begin
		-- Perform operations on the rising edge of the clock if RAM is enabled
		if rising_edge(clk_in) and enable_in = '1' then
			-- put the input data into the RAM at the specified address if the write enable signal is high
			if (write_enable_in = '1') then
				ram(to_integer(unsigned(addr_in))) <= data_in;
			else
			-- ouput the stored data at addr_in if the ram is enabled
				data_out <= ram(to_integer(unsigned(addr_in)));
			end if;
		end if;
	end process;

end Behavioral;
