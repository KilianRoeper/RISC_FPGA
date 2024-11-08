----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.11.2024 11:20:17
-- Design Name: 
-- Module Name: ISA - Behavioral
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


package RISC_constants is
    -- constants
    
    -- ISA (Instruction Set Architecture) 
    constant OPCODE_ADD : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant OPCODE_SUB : STD_LOGIC_VECTOR(3 downto 0) := "0001";
    constant OPCODE_OR  : STD_LOGIC_VECTOR(3 downto 0) := "0010";
    constant OPCODE_AND : STD_LOGIC_VECTOR(3 downto 0) := "0011";
    constant OPCODE_LI  : STD_LOGIC_VECTOR(3 downto 0) := "0100";
    constant OPCODE_SW  : STD_LOGIC_VECTOR(3 downto 0) := "0101";
    constant OPCODE_LW  : STD_LOGIC_VECTOR(3 downto 0) := "0110";
    constant OPCODE_BEQ : STD_LOGIC_VECTOR(3 downto 0) := "0111";
    constant OPCODE_B   : STD_LOGIC_VECTOR(3 downto 0) := "1000";
    constant OPCODE_SLR : STD_LOGIC_VECTOR(3 downto 0) := "1001";
    constant OPCODE_SLL : STD_LOGIC_VECTOR(3 downto 0) := "1010";
    constant OPCODE_CMP : STD_LOGIC_VECTOR(3 downto 0) := "1011";
    
    -- cmp output bits
    constant CMP_BIT_EQ     : integer := 14;
    constant CMP_BIT_BGC    : integer := 13;
    constant CMP_BIT_BLC    : integer := 12;
    constant CMP_BIT_BZ     :  integer := 11;
    constant CMP_BIT_CZ     :  integer := 10;
    
    -- jump flags
    constant CJF_EQ     : STD_LOGIC_VECTOR(2 downto 0) := "000";
    constant CJF_BZ     : STD_LOGIC_VECTOR(2 downto 0) := "001";
    constant CJF_CZ     : STD_LOGIC_VECTOR(2 downto 0) := "010";
    constant CJF_BNZ    : STD_LOGIC_VECTOR(2 downto 0) := "011";
    constant CJF_CNZ    : STD_LOGIC_VECTOR(2 downto 0) := "100";
    constant CJF_BGC    : STD_LOGIC_VECTOR(2 downto 0) := "101";
    constant CJF_BLC    : STD_LOGIC_VECTOR(2 downto 0) := "110";
    
    -- PC unit opcodes
    constant PC_OP_NOP      : std_logic_vector(1 downto 0):= "00";
    constant PC_OP_INC      : std_logic_vector(1 downto 0):= "01";
    constant PC_OP_ASSIGN   : std_logic_vector(1 downto 0):= "10";
    constant PC_OP_RESET    : std_logic_vector(1 downto 0):= "11";
    
    -- registers 
    constant r0 : std_logic_vector(2 downto 0):= "000";
    constant r1 : std_logic_vector(2 downto 0):= "001";
    constant r2 : std_logic_vector(2 downto 0):= "010";
    constant r3 : std_logic_vector(2 downto 0):= "011";
    constant r4 : std_logic_vector(2 downto 0):= "100";
    constant r5 : std_logic_vector(2 downto 0):= "101";
    constant r6 : std_logic_vector(2 downto 0):= "110";
    constant r7 : std_logic_vector(2 downto 0):= "111";
    
    -- types
    
    -- functions
    -- function my_function(x : integer) return integer;

end package;

package body RISC_constants is
    -- implementation of functions
    -- function double_value(x : integer) return integer is
    -- begin
    --    return x * 2;
    -- end function;
end package body;
