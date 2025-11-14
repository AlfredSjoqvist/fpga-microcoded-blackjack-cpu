library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- uMem interface
entity uMem is
  port (
    uAddr : in unsigned(7 downto 0);
    uData : out unsigned(31 downto 0));
end uMem;

architecture Behavioral of uMem is

-- TODO: understand what is going on here

-- micro Memory
type u_mem_t is array (0 to 15) of unsigned(31 downto 0);
constant u_mem_c : u_mem_t :=
   -- NaN  ALU   TB   FB GrPcLc  SEQ    uAddr
  (b"0000_0000_0111_0011_0_0_00_0000_00000000", -- ASR:=PC
   b"0000_0000_0010_0001_0_1_00_0000_00000000", -- IR:=PM, PC:=PC+1
   b"0000_0000_0000_0000_0_0_00_0010_00000000", -- uPC := K2
   b"0000_0000_0000_0000_0_0_00_0001_00000000", -- uPC := K1 ; Immediate
   b"0000_0000_0000_0000_0_0_00_0000_00000000", -- 
   b"0000_0000_0000_0000_0_0_00_0000_00000000", --                  
   b"0000_0000_0000_0000_0_0_00_0000_00000000", -- 
   b"0000_0000_0000_0000_0_0_00_0000_00000000", -- 
   b"0000_0000_0010_0110_0_0_00_0011_00000000", -- LOAD(GRx, M, ADR) -- GRx := PM(A), uPC := 0
   b"0000_0000_0000_0000_0_0_00_0000_00000000", -- 
   b"0000_0000_0000_0000_0_0_00_0000_00000000", --
   b"0000_0000_0000_0000_0_0_00_0000_00000000", -- 
   b"0000_0000_0000_0000_0_0_00_0000_00000000",
   b"0000_0000_0000_0000_0_0_00_0000_00000000",
   b"0000_0000_0000_0000_0_0_00_0000_00000000",
   b"0000_0000_0000_0000_0_0_00_0000_00000000");

signal u_mem : u_mem_t := u_mem_c;

begin  -- Behavioral
  uData <= u_mem(to_integer(uAddr));

end Behavioral;
