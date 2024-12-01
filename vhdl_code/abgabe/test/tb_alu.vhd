----------------------------------------------------------------------------------
-- Entity: tb_alu
-- Name: Kilian Röper
----------------------------------------------------------------------------------

-- testing the alu

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.risc_constants.ALL;

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

library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use work.RISC_constants.ALL;
use IEEE.NUMERIC_STD.ALL;



entity alu_tb is
--  Port ( );
end alu_tb;

architecture Behavioral of alu_tb is
 -- alu component 
    component alu
    Port (  clk_in                  : in STD_LOGIC;
            enable_in               : in STD_LOGIC;
            regA_write_in           : in STD_LOGIC;
            store_enable_in         : in STD_LOGIC;
            reg_B_data_in           : in STD_LOGIC_VECTOR (15 downto 0);
            reg_C_data_in           : in STD_LOGIC_VECTOR (15 downto 0);
            pc_in                   : in STD_LOGIC_VECTOR (15 downto 0);
            im_in                   : in STD_LOGIC_VECTOR (15 downto 0);
            alu_op_in               : in STD_LOGIC_VECTOR (4 downto 0);
            
            result_out              : out STD_LOGIC_VECTOR (15 downto 0);
            branch_enable_out       : out STD_logic ;
            regA_write_out          : out STD_LOGIC;
            store_enable_out        : out STD_LOGIC
       );  
    end component;
    
    -- testbench specific signals
    constant clk_period : time := 10 ns;
    signal cpu_clock 	: STD_LOGIC := '0';
    
    -- alu input signals 
    signal alu_result_out           : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal alu_regA_write_out       : STD_LOGIC := '0';
    signal alu_store_enable_out     : STD_LOGIC := '0';
    signal branch_enable_out        : STD_LOGIC := '0';
    
    -- alu output signals 
    signal opcode                   : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal immediate_data           : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal program_counter          : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal regB_data                : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal regC_data                : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal store_enable             : STD_LOGIC := '0';
    signal regA_write               : STD_LOGIC := '0';
    signal alu_enable               : STD_LOGIC := '0';


begin

-- alu port mappings   
     cpu_alu : alu PORT MAP (
        clk_in                  => cpu_clock,
        enable_in               => alu_enable,
        regA_write_in           => regA_write,
        store_enable_in         => store_enable,
        reg_B_data_in           => regB_data,
        reg_C_data_in           => regC_data,
        pc_in                   => program_counter,
        im_in                   => immediate_data,
        alu_op_in               => opcode,
        
        result_out              => alu_result_out,
        branch_enable_out       => branch_enable_out,
        regA_write_out          => alu_regA_write_out,
        store_enable_out        => alu_store_enable_out
     );

vectors: process
    begin  
        -- testing write and store signals 
        store_enable <= '1';
        regA_write <= '1';
        
    -- testing Opcodes 
    
        -- unsigned ADD
        opcode <= OPCODE_ADD & '0';
        regB_data <= X"AB00";
        regC_data <= X"00CD";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out = X"ABCD") report " ADD unsigned incorrect" severity error;
        
        -- signed ADD
        opcode <= OPCODE_ADD & '1';
        regB_data <= X"AB00";
        regC_data <= X"A0CD";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out = X"4BCD") report " ADD signed incorrect" severity error;
        
        -- SUB unsigned
        opcode <= OPCODE_SUB & '0';
        regB_data <= X"3060";
        regC_data <= X"104D";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out = X"2013") report " SUB unsigned incorrect" severity error;
        
        -- SUB signed
        opcode <= OPCODE_SUB & '1';
        regB_data <= X"0060";
        regC_data <= X"004D";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out = X"0013") report " SUB signed incorrect" severity error;
        
        -- OR
        opcode <= OPCODE_OR & '0';
        regB_data <= X"0680";
        regC_data <= X"400A";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out = X"468A") report " OR incorrect" severity error;
        
        -- AND
        opcode <= OPCODE_AND & '0';
        regB_data <= X"00A4";
        regC_data <= X"00D7";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out = X"0084") report " AND incorrect" severity error;
        
        -- LI F=0 upper 8 bits
        opcode <= OPCODE_LI & '0';
        immediate_data <= X"ABAB";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out = X"AB00") report " LI F=0 incorrect" severity error;
        
        -- LI F=1 lower 8 bits
        opcode <= OPCODE_LI & '1';
        immediate_data <= X"ABAB";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out = X"00AB") report " LI F=1 incorrect" severity error;
        
        -- SW 
        opcode <= OPCODE_SW & '0';
        regC_data <= X"CBCB";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out = X"CBCB") report " SW incorrect" severity error;
        
        -- LW
        opcode <= OPCODE_LW & '0';
        regB_data <= X"EFEF";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out = X"EFEF") report " LW incorrect" severity error;
        
        -- CMP
            -- CMP_BIT_EQ
        opcode <= OPCODE_CMP & '0';
        regB_data <= X"EFEF";
        regC_data <= X"EFEF";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out(CMP_BIT_EQ) = '1') report " CMP - CMP_BIT_EQ incorrect" severity error;

            -- CMP_BIT_BZ
        regB_data <= X"0000";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out(CMP_BIT_BZ) = '1') report " CMP - CMP_BIT_BZ incorrect" severity error;
        
            -- CMP_BIT_CZ
        regC_data <= X"0000";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out(CMP_BIT_CZ) = '1') report " CMP - CMP_BIT_CZ incorrect" severity error;

            -- CMP_BIT_BGC F = 0
        regB_data <= X"FFEF";
        regC_data <= X"EFEF";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out(CMP_BIT_BGC) = '1') report " CMP - CMP_BIT_BGC F = 0 incorrect" severity error;
        
            -- CMP_BIT_BLC F = 0
        regB_data <= X"EFEF";
        regC_data <= X"FFEF";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out(CMP_BIT_BLC) = '1') report " CMP - CMP_BIT_BLC F = 0 incorrect" severity error;
        
            -- CMP_BIT_BGC F = 1
        opcode <= OPCODE_CMP & '1';
        regB_data <= X"FFEF";
        regC_data <= X"EFEF";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out(CMP_BIT_BGC) = '1') report " CMP - CMP_BIT_BGC F = 1 incorrect" severity error;
        
            -- CMP_BIT_BLC F = 1
        regB_data <= X"EFEF";
        regC_data <= X"FFEF";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out(CMP_BIT_BLC) = '1') report " CMP - CMP_BIT_BLC F = 1 incorrect" severity error;
        
        -- BEQ
        regB_data <= X"1234";
        
            -- CMP_BIT_EQ; CJF_EQ
        regC_data <= X"0000";
        opcode <= OPCODE_BEQ & CJF_EQ(2);
        immediate_data <= X"000" & "00" & CJF_EQ(1 downto 0);
        regC_data(CMP_BIT_EQ) <= '1'; 
        alu_enable <= '1';
        wait for clk_period;
        assert (branch_enable_out = '1') report " didn't set branch_enable BEQ - CMP_BIT_EQ - CJF_EQ" severity error;
        assert (alu_result_out = X"1234") report " branch address wasn't set BEQ - CMP_BIT_EQ - CJF_EQ" severity error;
        
            -- CMP_BIT_BZ; CJF_BZ
        regC_data <= X"0000";
        opcode <= OPCODE_BEQ & CJF_BZ(2);
        immediate_data <= X"000" & "00" & CJF_BZ(1 downto 0);
        regC_data(CMP_BIT_BZ) <= '1'; 
        alu_enable <= '1';
        wait for clk_period;
        assert (branch_enable_out = '1') report " didn't set branch_enable BEQ - CMP_BIT_BZ - CJF_BZ" severity error;
        assert (alu_result_out = X"1234") report " branch address wasn't set BEQ - CMP_BIT_BZ - CJF_BZ" severity error;
        
            -- CMP_BIT_CZ; CJF_CZ
        regC_data <= X"0000";
        opcode <= OPCODE_BEQ & CJF_CZ(2);
        immediate_data <= X"000" & "00" & CJF_CZ(1 downto 0);
        regC_data(CMP_BIT_CZ) <= '1'; 
        alu_enable <= '1';
        wait for clk_period;
        assert (branch_enable_out = '1') report " didn't set branch_enable BEQ - CMP_BIT_CZ - CJF_CZ" severity error;
        assert (alu_result_out = X"1234") report " branch address wasn't set BEQ - CMP_BIT_CZ - CJF_CZ" severity error;
        
            -- CMP_BIT_BZ; CJF_BNZ
        regC_data <= X"0000";
        opcode <= OPCODE_BEQ & CJF_BNZ(2);
        immediate_data <= X"000" & "00" & CJF_BNZ(1 downto 0);
        regC_data(CMP_BIT_BZ) <= '0'; 
        alu_enable <= '1';
        wait for clk_period;
        assert (branch_enable_out = '1') report " didn't set branch_enable BEQ - CMP_BIT_BZ - CJF_BNZ" severity error;
        assert (alu_result_out = X"1234") report " branch address wasn't set BEQ - CMP_BIT_BZ - CJF_BNZ" severity error;
        
            -- CMP_BIT_CZ; CJF_CNZ
        regC_data <= X"0000";
        opcode <= OPCODE_BEQ & CJF_CNZ(2);
        immediate_data <= X"000" & "00" & CJF_CNZ(1 downto 0);
        regC_data(CMP_BIT_CZ) <= '0'; 
        alu_enable <= '1';
        wait for clk_period;
        assert (branch_enable_out = '1') report " didn't set branch_enable BEQ - CMP_BIT_CZ - CJF_CNZ" severity error;
        assert (alu_result_out = X"1234") report " branch address wasn't set BEQ - CMP_BIT_CZ - CJF_CNZ" severity error;
        
            -- CMP_BIT_BGC; CJF_BGC
        regC_data <= X"0000";
        opcode <= OPCODE_BEQ & CJF_BGC(2);
        immediate_data <= X"000" & "00" & CJF_BGC(1 downto 0);
        regC_data(CMP_BIT_BGC) <= '1'; 
        alu_enable <= '1';
        wait for clk_period;
        assert (branch_enable_out = '1') report " didn't set branch_enable BEQ - CMP_BIT_BGC - CJF_BGC" severity error;
        assert (alu_result_out = X"1234") report " branch address wasn't set BEQ - CMP_BIT_BGC - CJF_BGC" severity error;
        
            -- CMP_BIT_BLC; CJF_BLC
        regC_data <= X"0000";
        opcode <= OPCODE_BEQ & CJF_BLC(2);
        immediate_data <= X"000" & "00" & CJF_BLC(1 downto 0);
        regC_data(CMP_BIT_BLC) <= '1'; 
        alu_enable <= '1';
        wait for clk_period;
        assert (branch_enable_out = '1') report " didn't set branch_enable BEQ - CMP_BIT_BLC - CJF_BLC" severity error;
        assert (alu_result_out = X"1234") report " branch address wasn't set BEQ - CMP_BIT_BLC - CJF_BLC" severity error;
        
        opcode <= OPCODE_SLL & '0';
        regB_data <= X"1111";
        regC_data <= X"0002";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out = X"4444") report " OPCODE_SLL" severity error;
        
        opcode <= OPCODE_SLR & '0';
        regB_data <= X"1111";
        regC_data <= X"0001";
        alu_enable <= '1';
        wait for clk_period;
        assert (alu_result_out = X"0888") report " OPCODE_SLR" severity error;
        
        opcode <= OPCODE_B & '0';
        immediate_data <= X"ABAB";
        alu_enable <= '1';
        wait for clk_period;
        assert (branch_enable_out = '1') report " didn't set branch_enable B" severity error;
        assert (alu_result_out = X"00AB") report " OPCODE_B" severity error;

        
        wait;
    end process;

clk_process : process
    begin
        cpu_clock <= '0';
        wait for clk_period / 2;
        cpu_clock <= '1';
        wait for clk_period / 2;
    end process;
end Behavioral;
