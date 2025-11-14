-- Code written by ShawarmianAssembler 1.0

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- pMem interface
entity pMem is
  port(
    pAddr : in unsigned(15 downto 0);
    pData : out unsigned(31 downto 0));
end pMem;

architecture Behavioral of pMem is

-- program Memory
type p_mem_t is array (0 to 4) of unsigned(31 downto 0);
constant p_mem_c : p_mem_t :=
--inMGaddr
(
x"01210003",   --   LOAD   indirect    r1   #0003
x"04010003",   --   ADD    immediate   r1   #0003
x"05010001",   --   SUB    immediate   r1   #0001
x"01040004",   --   LOAD   immediate   r4   #0004
x"01041337"    --   LOAD   immediate   r4   #1337
);

  signal p_mem : p_mem_t := p_mem_c;


begin  -- pMem
  pData <= p_mem(to_integer(pAddr));

end Behavioral;
