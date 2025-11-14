--Fö11 som inspiration för kodstruktur--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity ALU is
    port(
    AR_IN : in unsigned(15 downto 0);
    AR_OUT : out unsigned(15 downto 0); --Tal 1
    ALU_BUS_IN : in unsigned(31 downto 0);
    op : in unsigned(3 downto 0)); --Tal 2

    --   AR      BUSS
    --	_____  _____      Z - Zero flag 
    --   \   \/   /       N - Negative flag
    --    \      /        C - Carry flag
    --     \____/         V - Overflow flag
        --  Res => AR  

    signal res : unsigned(31 downto 0);
    signal Zc, Nc, Cc, Vc : std_logic; --Flaggorna (kombinatoriskt)
    signal Z, N, C, V : std_logic; --De faktiska klockade flaggorna
    signal SLICED_BUS : unsigned(15 downto 0);

end ALU;

architecture Behavioral of ALU is

    process(AR_IN, SLICED_BUS, op) begin
        --res <= (others => '0'); --Default
        case op is
            when "0000" => --TODO: NOP -> res = 0 ???                -- No op
            when "0001" => res <= unsigned'(31 downto 16 => '0') & SLICED_BUS;  --Bus
            when "0010" => res <= unsigned'(31 downto 16 => '0') & SLICED_BUS;  --TODO: tvåkomplementstal
            when "0011" => res <= (others => '0');           --AR := 0
            when "0100" => res <= unsigned'(31 downto 17 => '0') & (('0'&AR_IN) + ('0'&SLICED_BUS));
            when "0101" => res <= unsigned'(31 downto 17 => '0') & (('0'&AR_IN) - ('0'&SLICED_BUS));
            when "0110" => res <= unsigned'(31 downto 16 => '0') & (AR_IN and SLICED_BUS);
            when "0111" => res <= unsigned'(31 downto 16 => '0') & (AR_IN or SLICED_BUS);
            when "1000" => res <= AR_IN * SLICED_BUS;
            when "1001" => res <= (AR_IN rem SLICED_BUS) & (AR_IN / SLICED_BUS);
            --when "0101" => res <= (AR rem SLICED_BUS) & (AR/SLICED_BUS);           --A/B (unsigned)
            --when "0110" => res <= (others => '0');
            --           --AR <= 0
             --Möjlighet till utökning beroende på vad vi vill ha
            when others res => null; --error
        end case;
        AR_IN <= res(15 downto 0);
    end process;
    
    --Kombinatorisk uträkning av flaggor dvs icke syncade värden
    
    
    --TODO: fixa så det funkar med kombinatorisk tilldelning
    SLICED_BUS <= ALU_BUS_IN(15 downto 0);


    Zc <= '1' when res(31 downto 0) = 0 and ((op="1000") or (op = "1001")) else --mul/muls
          '1' when res(15 downto 0) = 0 and ((op/="1000") or (op /= "1001")) else-- not mul/muls
          '0';
    Nc <= '0';  --TODO: Negativa tal --res(31) when ((op = "0011") or (op = "0100")) else res(15); --mul/muls

    Cc <= res(16) when (op = "0100") else
          '0';
    
    Vc <= res(16) when (op = "0100") else
          '0';

    process(clk) begin
        if rising_edge(clk) then
            if (rst = '1') then
                Z <= '0'; N <= '0'; C <= '0'; V <= '0';
            else
              case op is 
                when "0000" => null; -- No op
                when "0001" => Z <= Zc;
                when "0010" => Z <= Zc;
                when "0011" => Z <= Zc;
                when "0100" => Z <= Zc; V <= Vc; C <= Cc;
                when "0101" => Z <= Zc; V <= Vc; C <= Cc;
                when "0110" => Z <= Zc;
                when "0111" => Z <= Zc;
                when "1000" => Z <= Zc; V <= Vc; C <= Cc;
                when "1001" => Z <= Zc; V <= Vc; C <= Cc;
                when others => null; -- error
             end case;
            end if;
        end if;
        
    end process;
end Behavioral; 