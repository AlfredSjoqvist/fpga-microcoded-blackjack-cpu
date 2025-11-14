pmem_start = """-- Code written by ShawarmianAssembler 1.0

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
type p_mem_t is array (0 to """


pmem_mid = """) of unsigned(31 downto 0);
constant p_mem_c : p_mem_t :=
--inMGaddr
(
"""


pmem_end = """
);

  signal p_mem : p_mem_t := p_mem_c;


begin  -- pMem
  pData <= p_mem(to_integer(pAddr));

end Behavioral;
"""