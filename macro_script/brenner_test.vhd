library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- pMem interface
entity pMem is
  port(
    pAddr  : in  unsigned(15 downto 0);
    spAddr : in  unsigned(15 downto 0);
    pData  : out unsigned(31 downto 0);
    spData : out unsigned(31 downto 0));
end pMem;

architecture Behavioral of pMem is

-- program Memory
type p_mem_t is array (0 to 63) of unsigned(31 downto 0);
constant p_mem_c : p_mem_t :=
--   inMGaddr
  (x"0101000A",
   x"02110030",
   x"04010001",
   x"02110031",
   x"05010002",
   x"02110032",
   x"07010006",
   x"02110033",
   x"06010014",
   x"02110034",
   x"08010004",
   x"02110035",
   x"09018002",
   x"02110036",
   x"00000000",
   x"00000000",

   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",

--Testkort-- 6 Bitar för att uttryck kort: 4 Valör 2 Färg FFVVVV
-- 00 --> Hjärter  01 --> Ruter
-- 10 --> Spader - 11 --> Klöver 

   x"00000000", -- Hjärter ess
   x"00000028", -- Klöver 8
   x"00000002",
   x"00000003",
   x"0000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",

   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000",
   x"00000000"
   );

  signal p_mem : p_mem_t := p_mem_c;


begin  -- pMem
  pData  <= p_mem(to_integer(pAddr));
  spData <= p_mem(to_integer(spAddr));

end Behavioral;
