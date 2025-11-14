library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--CPU interface
entity uprogCPU is
  port(clk: in std_logic;
	     btnC: in std_logic;
       led: out unsigned(15 downto 0)
       --Signaler för tangentbord

       PS2Clk  : in std_logic;
       PS2Data : in std_logic;
    );

   


end entity;

architecture func of uprogCPU is

  signal rst : std_logic;

  -- micro Memory component
  component uMem
    port(uAddr : in unsigned(7 downto 0);
         uData : out unsigned(31 downto 0));
  end component;

  -- program Memory component
  component pMem
    port(pAddr : in unsigned(15 downto 0);
         pData : out unsigned(31 downto 0));
  end component;

  component KBD_ENC is
    port (
      clk             : in std_logic;   -- system clock (100 MHz)
      rst             : in std_logic;   -- reset signal
      PS2KeyboardCLK  : in std_logic;   -- USB keyboard PS2 clock
      PS2KeyboardData : in std_logic;   -- USB keyboard PS2 data
      ScanCode        : out std_logic_vector(7 downto 0); -- scancode byte
      MAKE_op         : out std_logic);                   -- one-pulsed scancode-enable
  end component;

  --Arithmetic Logic Unit
  --component ALU
  --  port(AR_OUT : out unsigned(15 downto 0);
  --       AR_IN  : in unsigned(15 downto 0);
  --       ALU_BUS_IN : in unsigned(31 downto 0);
  --       op : in unsigned(3 downto 0));
  --end component;

  -- micro memory signals
  signal uM   : unsigned(31 downto 0);                    -- micro Memory output
  alias noFlag: std_logic            is uM(28);           -- Update flags yes/no
  alias ALUi  : unsigned(3 downto 0) is uM(27 downto 24); -- ALU operation
  alias TB    : unsigned(3 downto 0) is uM(23 downto 20); -- Write to bus
  alias FB    : unsigned(3 downto 0) is uM(19 downto 16); -- Read from bus
  alias GrSu  : std_logic            is uM(15);           -- Grmux output select
  alias PCS   : std_logic            is uM(14);           -- PC signal
  alias LCs   : unsigned(1 downto 0) is uM(13 downto 12); -- loop counter
  alias SEQ   : unsigned(3 downto 0) is uM(11 downto 8);  -- Advanced micro program handling
  alias uAddr : unsigned(7 downto 0) is uM(7 downto 0);   -- micro adress for jumps

  -- program memory signals (WIP !!!!!!!!!!!)
  signal PM   : unsigned(31 downto 0);                    -- Program Memory output
  alias instr : unsigned(7 downto 0) is PM(31 downto 24); -- Instruction ID
  alias mode  : unsigned(3 downto 0) is PM(23 downto 20); -- Addressing mode
  alias GrSa  : unsigned(3 downto 0) is PM(19 downto 16); -- GrMux control
  alias addr  : unsigned(15 downto 0) is PM(15 downto 0); -- Address

  -- local registers
  signal AR   : unsigned(15 downto 0) := (others => '0');  -- Accumulation register
  signal HeR  : unsigned(15 downto 0) := (others => '0');  -- Help register
  signal uPC  : unsigned(7 downto 0)  := (others => '0');   -- micro Program Counter
  signal PC   : unsigned(15 downto 0);  -- Program Counter
  signal IR   : unsigned(31 downto 0);  -- Instruction Register
  signal ASR  : unsigned(15 downto 0);  -- Address Register  -- ska va 16 bitar
  signal LC   : unsigned(7 downto 0);

  -- local components
  signal GrSelReg:  unsigned(3 downto 0) := (others => '1');
  signal GrControl: unsigned(3 downto 0);
  signal GrSa_temp: unsigned(3 downto 0);
  signal GrX  :     unsigned(15 downto 0);
  signal VGA  :     unsigned(31 downto 0);  -- TODO: VGA
  signal Pmod :     unsigned(31 downto 0);  -- TODO: PmodPiezo
  signal KeyB :     unsigned(31 downto 0);  -- TODO: Keyboard
  signal SP   :     unsigned(31 downto 0);  -- TODO: Stack pointer

  -- General registers and mux
  signal GR0  : unsigned(15 downto 0) := (others => '0');
  signal GR1  : unsigned(15 downto 0) := (others => '0');
  signal GR2  : unsigned(15 downto 0) := (others => '0');
  signal GR3  : unsigned(15 downto 0) := (others => '0');
  signal GR4  : unsigned(15 downto 0) := (others => '0');
  signal GR5  : unsigned(15 downto 0) := (others => '0');
  signal GR6  : unsigned(15 downto 0) := (others => '0');
  signal GR7  : unsigned(15 downto 0) := (others => '0');
  signal GR8  : unsigned(15 downto 0) := (others => '0');
  signal GR9  : unsigned(15 downto 0) := (others => '0');
  signal GRA  : unsigned(15 downto 0) := (others => '0');
  signal GRB  : unsigned(15 downto 0) := (others => '0');
  signal GRC  : unsigned(15 downto 0) := (others => '0');
  signal GRD  : unsigned(15 downto 0) := (others => '0');
  signal GRE  : unsigned(15 downto 0) := (others => '0');
  signal GRF  : unsigned(15 downto 0) := (others => '0');
  signal S    : unsigned(1 downto 0);

  -- micro program tables
  signal K1   : unsigned(7 downto 0);
  signal K2   : unsigned(7 downto 0);

  -- ALU
  signal res  : unsigned(31 downto 0) := (others => '0');
  signal Z, N, C, V, L                : std_logic;
  signal Zc, Nc, Cc, C_t, Vc, Lco     : std_logic;
  signal A    : unsigned(15 downto 0) := (others => '0');
  signal B    : unsigned(15 downto 0) := (others => '0');

  --Input WIP!! 
  signal keyPress : std_logic; --Flagga för att hantera knapptryck
  signal Input_Vec : std_logic_vector(2 downto 0); --Innehåller vilken knapp som trycktes

  
  -- local combinatorials
  signal DATA_BUS : unsigned(31 downto 0); -- Data Bus

begin

  -- Reset signal combinatorial
  rst <= btnC;


  -- mPC : micro Program Counter
  process(clk)
  begin
    if rising_edge(clk) then
      
      if (rst = '1') then
        uPC <= (others => '0');
      -- The case-when clause for determining where the micro program counter goes
      -- This is based on the table from uProg/uprog.org which is a file in the repo
      else
        case SEQ is
          when "0000" =>
            uPC <= uPC + 1;
          when "0001" =>
            uPC <= K1;
          when "0010" =>
            uPC <= K2;
          when "0011" =>
            uPC <= (others => '0');
          when "0100" =>
            uPC <= uAddr;
          when "0101" =>
            if (Z = '0') then uPC <= uAddr;
            end if;
          when "0110" =>
            if (N = '0') then uPC <= uAddr;
            end if;
          when "0111" =>
            if (C = '0') then uPC <= uAddr;
            end if;
          when "1000" =>
            if (V = '0') then uPC <= uAddr;
            end if;
          when "1001" =>
            if (L = '0') then uPC <= uAddr;
            end if;
          when "1010" =>
            if (Z = '1') then uPC <= uAddr;
            end if;
          when "1011" =>
            if (N = '1') then uPC <= uAddr;
            end if;
          when "1100" =>
            if (C = '1') then uPC <= uAddr;
            end if;
          when "1101" =>
            if (V = '1') then uPC <= uAddr;
            end if;
          when "1110" =>
            if (L = '1') then uPC <= uAddr;
            end if;
          when others =>
            -- TODO: HALT
        end case;
      end if;
    end if;
  end process;


  -- IR : Instruction Register
  -- Most of the registers generally work the same where they have a reset
  -- and an option to read from (and write to) the bus
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        IR <= (others => '0');
      elsif (FB = "0001") then
        IR <= DATA_BUS;
      end if;
    end if;
  end process;


  -- ASR : Address Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        ASR <= (others => '0');
      elsif (FB = "0011") then
        ASR <= DATA_BUS(15 downto 0);
      end if;
    end if;
  end process;


  -- LC : Loop counter
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        LC <= (others => '0');
        Lco <= '0';
      else
      L <= Lco;
      case LCs is
        when "00" =>
          null;
        when "01" =>
          LC <= LC - 1;
        when "10" =>
          LC <= DATA_BUS(7 downto 0);
        when others =>
          LC <= uAddr;
        end case;
      end if;
    end if;
  end process;

  -- Loop counter flag combinatorial
  Lco <= '1' when LC = 0 else
         '0';

  GrControl <=  GrSa_temp when (GrSu = '0') else
                GrSelReg;
  
  -- GrX : General register mux 
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        Gr0 <= (others => '0'); Gr1 <= (others => '0'); Gr2 <= (others => '0'); Gr3 <= (others => '0');
        Gr4 <= (others => '0'); Gr5 <= (others => '0'); Gr6 <= (others => '0'); Gr7 <= (others => '0');
        Gr8 <= (others => '0'); Gr9 <= (others => '0'); GrA <= (others => '0'); GrB <= (others => '0');
        GrC <= (others => '0'); GrD <= (others => '0'); GrE <= (others => '0'); GrF <= (others => '0');
        -- GrControl <= (others => '0');
        GrSelReg <= (others => '1');
        -- Check where to read the MUX control bits from:
        elsif (FB = "0110") then
          case GrControl is
            when "0000" => Gr0 <= DATA_BUS(15 downto 0);
            when "0001" => Gr1 <= DATA_BUS(15 downto 0);
            when "0010" => Gr2 <= DATA_BUS(15 downto 0);
            when "0011" => Gr3 <= DATA_BUS(15 downto 0);
            when "0100" => Gr4 <= DATA_BUS(15 downto 0);
            when "0101" => Gr5 <= DATA_BUS(15 downto 0);
            when "0110" => Gr6 <= DATA_BUS(15 downto 0);
            when "0111" => Gr7 <= DATA_BUS(15 downto 0);
            when "1000" => Gr8 <= DATA_BUS(15 downto 0);
            when "1001" => Gr9 <= DATA_BUS(15 downto 0);
            when "1010" => GrA <= DATA_BUS(15 downto 0);
            when "1011" => GrB <= DATA_BUS(15 downto 0);
            when "1100" => GrC <= DATA_BUS(15 downto 0);
            when "1101" => GrD <= DATA_BUS(15 downto 0);
            when "1110" => GrE <= DATA_BUS(15 downto 0);
            when others => GrF <= DATA_BUS(15 downto 0);
          end case;
      end if;
    end if;
  end process;

  GrX <=  Gr0 when (GrControl = "0000") else
          Gr1 when (GrControl = "0001") else
          Gr2 when (GrControl = "0010") else
          Gr3 when (GrControl = "0011") else
          Gr4 when (GrControl = "0100") else
          Gr5 when (GrControl = "0101") else
          Gr6 when (GrControl = "0110") else
          Gr7 when (GrControl = "0111") else
          Gr8 when (GrControl = "1000") else
          Gr9 when (GrControl = "1001") else
          GrA when (GrControl = "1010") else
          GrB when (GrControl = "1011") else
          GrC when (GrControl = "1100") else
          GrD when (GrControl = "1101") else
          GrE when (GrControl = "1110") else
          GrF;

  -- PC : Program Counter
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        PC <= (others => '0');
      elsif (FB = "0111") then
        PC <= DATA_BUS(15 downto 0);
      elsif (PCS = '1') then
        GrSa_temp <= GrSa;
        PC <= PC + 1;
      end if;
    end if;
  end process;


  -- VGA : VGA reader placeholder (WIP!!!)
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        VGA <= (others => '0');
      elsif (FB = "1001") then
        VGA <= DATA_BUS;
      end if;
    end if;
  end process;


  -- Pmod : Pmod reader placeholder (WIP!!!)
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') thenMerge remote-tracking branch 'origin/alfred_0904'
        Pmod <= DATA_BUS;
      end if;
    end if;
  end process;


  -- SP : Stack pointer placeholder (WIP!!!)
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        SP <= (others => '0');
      elsif (FB = "1011") then
        SP <= DATA_BUS;
      end if;
    end if;
  end process;


  -- ALU : Operations
  A <= AR;
  B <= DATA_BUS(15 downto 0);

  process(A, B, ALUi)
  begin
    --res <= (others => '0');
    case ALUi is
      when "0000" =>    -- NOP
        null;  
        --res <= (others => '0');
      when "0001" =>    -- Bus
        res(15 downto 0) <= B;
      when "0010" =>    -- Invert
        res(14 downto 0) <= B(14 downto 0);
        res(15)          <= '1';
      when "0011" =>    -- 0
        res <= (others => '0');          
      when "0100" =>    -- Addition
        res(16 downto 0) <= ('0'&A) + ('0'&B);
      when "0101" =>    -- Subtraction
        res(16 downto 0) <= ('0'&A) - ('0'&B);
      when "0110" =>    -- AND
        res(15 downto 0) <= A and B;
      when "0111" =>    -- OR
        res(15 downto 0) <= A or B;
      when "1000" =>    -- Multiplication
        res <= A * B;
      when "1001" =>    -- Signed multiplication
        res <= unsigned(signed(A) * signed(B));
      when "1010" =>    -- Logical shift right
        C_t <= A(0);
        res(15 downto 0) <= A srl 1;
      when "1011" =>    -- Logical shift left
        C_t <= A(15);
        res(15 downto 0) <= A sll 1;
      when others =>    -- etc...
        null;
    end case;
  end process;


  -- Synchronous register setting
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        HeR  <= (others => '0');
        AR   <= (others => '0');
      elsif (FB = "0101") then
        HeR <= DATA_BUS(15 downto 0);
      else
        AR <= res(15 downto 0);
        HeR <= res(31 downto 16);
      end if;
    end if;
  end process;


  -- Combinatorial setting of ALU flags
  -- Zero
  Zc <= '1' when res(31 downto 0) = 0 and ((ALUi = "1000")  or (ALUi = "1001") ) else -- Multiplication (signed & unsigned)
        '1' when res(15 downto 0) = 0 and ((ALUi /= "1000") or (ALUi /= "1001")) else -- Everything else
        '0';

  -- Negative
  Nc <= '1' when (res(31) = '1') and ((ALUi = "1000")   or (ALUi = "1001")  ) else -- Multiplication (signed & unsigned)
        '1' when (res(15) = '1') and ((ALUi /= "1000")  or (ALUi /= "1001") ) else -- Everything else
        '0';

  -- Carry
  Cc <= '1' when (res(16) = '1') and (ALUi = "0100")  else -- Addition
        '1' when (res(16) = '0') and (ALUi = "0101")  else -- Subtraction (Note: Inverted carry)
        C_t when ((ALUi = "1010") or (ALUi = "1011")) else -- LSR & LSL
        '0';

  -- Overflow (carry med negativ tallinje)
  Vc <= '1' when (((A(15) = '0') and (B(15) = '0') and (res(15) = '1')) or 
                  ((A(15) = '1') and (B(15) = '1') and (res(15) = '0'))) and (ALUi = "0100") else -- Addition
        '1' when (((A(15) = '0') and (B(15) = '1') and (res(15) = '1')) or 
                  ((A(15) = '1') and (B(15) = '0') and (res(15) = '0'))) and (ALUi = "0101") else -- Subtraction
        '0';
  

  -- ALU : Flag setting and synchronous reset
  process(clk) 
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        Z <= '0'; 
        N <= '0'; 
        C <= '0'; 
        V <= '0'; 
        L <= '0';
      elsif (noFlag = '0') then
        case ALUi is
          when "0000" =>    -- NOP
            null;
          when "0001" =>    -- Bus
            Z <= Zc; N <= Nc;
          when "0010" =>    -- Invert
            Z <= Zc; N <= Nc;
          when "0011" =>    -- 0
            Z <= Zc; N <= Nc;
          when "0100" =>    -- Addition
            Z <= Zc; N <= Nc; V <= Vc; C <= Cc;
          when "0101" =>    -- Subtraction
            Z <= Zc; N <= Nc; V <= Vc; C <= Cc;
          when "0110" =>    -- AND
            Z <= Zc; N <= Nc;
          when "0111" =>    -- OR
            Z <= Zc; N <= Nc;
          when "1000" =>    -- Multiplication
            Z <= Zc; N <= Nc;
          when "1001" =>    -- Signed multiplication
            Z <= Zc; N <= Nc;
          when "1010" =>    -- Logical shift right
            Z <= Zc; N <= Nc; C <= Cc;
          when "1011" =>    -- Logical shift left
            Z <= Zc; N <= Nc; C <= Cc;
          when others =>    -- etc...
            null;
        end case;
      end if;
    end if;
  end process;

  


  -- Micro memory component connection
  U0 : uMem port map(uAddr=>uPC, uData=>uM);

  -- Program memory component connection
 
  U1 : pMem port map(pAddr=>ASR, pData=>PM);

  -- keyboard encoder component connection -- WIP
  -- implementera PS2DATA, ScanCode, make_op
	U2 : kbd_enc port map
    (  clk=>clk,
       rst=>btnC,
       Input_Vec => Input_Vec,
       PS2Clk => PS2KeyboardCLK
       PS2Data => PS2KeyboardData;
       
       );
  -- Data bus assignment
  DATA_BUS <= IR   when (TB = "0001") else
              PM   when (TB = "0010") else
              unsigned'(31 downto 16 => '0') & ASR  when (TB = "0011") else  -- TODO Styrord? 0011 (will probably not be used)
              unsigned'(31 downto 16 => '0') & AR   when (TB = "0100") else
              unsigned'(31 downto 16 => '0') & HeR  when (TB = "0101") else
              unsigned'(31 downto 16 => '0') & GrX  when (TB = "0110") else
              unsigned'(31 downto 16 => '0') & PC   when (TB = "0111") else
              unsigned'(31 downto 3  => '0') & Input_Vec when (TB = "1000") else
              VGA  when (TB = "1001") else
              Pmod when (TB = "1010") else  -- Will not be used
              SP   when (TB = "1011") else
              -- Do we need to be able to read from micro memory output??
              (others => '0');

  -- Control unit
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        K1 <= (others => '0');
        K2 <= (others => '0');
      end if;

      case instr is
        when x"00"  =>    K1 <= x"00"; -- No operation
        when x"01"  =>    K1 <= x"20"; -- Load
        when x"02"  =>    K1 <= x"21"; -- Store
        when x"03"  =>    K1 <= x"22"; -- Compare
        when x"04"  =>    K1 <= x"24"; -- Add
        when x"05"  =>    K1 <= x"27"; -- Subtract
        when x"06"  =>    K1 <= x"2A"; -- AND
        when x"07"  =>    K1 <= x"2D"; -- OR
        when x"08"  =>    K1 <= x"30"; -- Multiply
        when x"09"  =>    K1 <= x"33"; -- Signed multiply
        when x"0A"  =>    K1 <= x"36"; -- Logical shift right
        when x"0B"  =>    K1 <= x"39"; -- Logical shift left
        when x"0C"  =>    K1 <= x"3C"; -- Invert
        when x"0D"  =>    K1 <= x"00"; --
        when x"0E"  =>    K1 <= x"00"; --
        when x"0F"  =>    K1 <= x"4F"; -- Halt
        when x"10"  =>    K1 <= x"50"; -- Jump
        when x"11"  =>    K1 <= x"51"; -- Relative jump
        when x"12"  =>    K1 <= x"54"; -- Branch if equal
        when x"13"  =>    K1 <= x"56"; -- Branch if not equal
        -- ...
        when x"20"  =>    K1 <= x"80"; -- Read from input vector
        when others =>    K1 <= x"00"; -- Error
        end case;
      case mode is
        when x"0"   =>    K2 <= x"03"; -- Immediate
        when x"1"   =>    K2 <= x"04"; -- Direct
        when x"2"   =>    K2 <= x"05"; -- Indirect
        when x"3"   =>    K2 <= x"07"; -- Indexed
        when x"4"   =>    K2 <= x"0A"; -- Relative
        when others =>    K2 <= x"00"; -- Error
        end case;
    end if;
  end process;
end architecture;