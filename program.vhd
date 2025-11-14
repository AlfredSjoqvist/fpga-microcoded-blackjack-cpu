
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
type p_mem_t is array (0 to 8) of unsigned(31 downto 0);
constant p_mem_c : p_mem_t :=
--inMGaddr
(
x"01000001",
x"01010003",
x"01020003",
x"01030007",
x"02170010",
x"01000001",
x"01010003",
x"01020003",
x"01030007"
);

  signal p_mem : p_mem_t := p_mem_c;


begin  -- pMem
  pData <= p_mem(to_integer(pAddr));

end Behavioral;
