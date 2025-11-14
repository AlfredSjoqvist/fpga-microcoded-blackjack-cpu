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
x"20010000",   --   RIV    immediate   r1   #0000
x"03010001",   --   CMP    immediate   r1   #0001
x"13010000",   --   BNE    immediate   r1   #0000
x"01021337",   --   LOAD   immediate   r2   #1337
x"10010000"    --   JMP    immediate   r1   #0000
);

  signal p_mem : p_mem_t := p_mem_c;


begin  -- pMem
  pData <= p_mem(to_integer(pAddr));

end Behavioral;
