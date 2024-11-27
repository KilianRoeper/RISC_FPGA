----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.11.2024 14:56:59
-- Design Name: 
-- Module Name: register_file - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_file is
Port (  clk_in          : in STD_LOGIC;
        enable_in       : in STD_LOGIC;
        write_enable_in : in STD_LOGIC;
        regA_data_in    : in STD_LOGIC_VECTOR (15 downto 0);
        regA_select_in  : in STD_LOGIC_VECTOR (2 downto 0);
        regB_select_in  : in STD_LOGIC_VECTOR (2 downto 0);
        regC_select_in  : in STD_LOGIC_VECTOR (2 downto 0);
        
        regB_out        : out STD_LOGIC_VECTOR (15 downto 0); 
        regC_out        : out STD_LOGIC_VECTOR (15 downto 0)
          );
end register_file;

architecture Behavioral of register_file is
    type register_type is array (0 to 7) of std_logic_vector(15 downto 0);  -- 8 registers of 16 bit each
    signal regs: register_type := (others => X"0000");                      --initialising all registers to all zeros
begin
process(clk_in, enable_in)
  begin
    if rising_edge(clk_in) and enable_in = '1' then
        regB_out <= regs(to_integer(unsigned(regB_select_in)));
        regC_out <= regs(to_integer(unsigned(regC_select_in)));
        if (write_enable_in = '1') then
          regs(to_integer(unsigned(regA_select_in))) <= regA_data_in;
        end if;
     end if;
  end process;

end Behavioral;
