library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISC_constants.ALL;

entity ram is 
    generic (
        ram_content : ram_type := (others => (others => '0'))
        );
    Port (
        clk_in : in STD_LOGIC;               -- Clock Input
        reset_in : in STD_LOGIC;             -- Reset Signal
        enable_in : in STD_LOGIC;            -- RAM Enable
        write_enable_in : in STD_LOGIC;      -- Write Enable
        addr_in : in STD_LOGIC_VECTOR(4 downto 0); -- Address (5 Bit)
        data_in : in STD_LOGIC_VECTOR(15 downto 0);  -- Data Input
        data_out : out STD_LOGIC_VECTOR(15 downto 0) -- Data Output
    );
end ram;

architecture Behavioral of ram is
    signal mem: ram_type := ram_content;
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if reset_in = '1' then
                -- Im Falle eines Reset nur data_out leeren, aber den RAM-Inhalt nicht beeinflussen
                data_out <= (others => '0');
            elsif enable_in = '1' then  -- RAM ist aktiv
                if write_enable_in = '1' then  -- Schreiben in den RAM
                    mem(to_integer(unsigned(addr_in))) <= data_in;
                else  -- Lesen aus dem RAM
                    data_out <= mem(to_integer(unsigned(addr_in)));
                end if;
            end if;
        end if;
    end process;
end Behavioral;