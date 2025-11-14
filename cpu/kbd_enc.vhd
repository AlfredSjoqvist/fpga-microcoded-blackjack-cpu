--tangentbordsavkodare baserad på lab4
--Läser av signaler skapade av tangentbord av typ PS/2 och skickar Scancode till datorn
--Pret delen från labbb byggs även in här,
--Sedan sätts flagga för hantering av input mha assembly instruktion
--Detta kan ske som avbrott eller kollas mellanåt

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                      
entity KBD_ENC is
	port (
		clk             : in std_logic;   -- system clock (100 MHz)
		rst             : in std_logic;   -- reset signal
		PS2KeyboardCLK  : in std_logic;   -- USB keyboard PS2 clock
		PS2KeyboardData : in std_logic;   -- USB keyboard PS2 data
		ScanCode        : out std_logic_vector(7 downto 0); -- scancode byte
		MAKE_op         : out std_logic);                   -- one-pulsed scancode-enable
end KBD_ENC;

-- architecture
architecture behavioral of KBD_ENC is
	signal PS2Clk  : std_logic;              -- Synchronized PS2 clock
	signal PS2Data : std_logic;              -- Synchronized PS2 data
	signal PS2Clk_Q1, PS2Clk_Q2 : std_logic; -- PS2 clock one pulse flip flop
	signal PS2Clk_op : std_logic;            -- PS2 clock one pulse 
	
	signal PS2Data_sr : std_logic_vector(10 downto 0);-- PS2 data shift register
	signal ScanCode_int : std_logic_vector(7 downto 0); -- internal version of ScanCode
	
	signal PS2BitCounter : unsigned(3 downto 0); -- PS2 bit counter
	signal BC11 : std_logic;                     -- '1' when PS2BitCounter = "00" when 11
	
	type state_type is (IDLE, MAKE, BREAK); -- declare state types for PS2
	signal PS2state : state_type;           -- PS2 state
	
    signal : std_logic_vector(2 downto 0); 

begin
	
	-- Synchronize PS2-KBD signals
	process(clk)
	begin
		if rising_edge(clk) then
			PS2Clk <= PS2KeyboardCLK;
			PS2Data <= PS2KeyboardData;
		end if;
	end process;
	
	-- Generate one cycle pulse from PS2 clock, negative edge
	process(clk)"00" when 
	begin
		if rising_edge(clk) then
			if rst='1' then
				PS2Clk_Q1 <= '1';
				PS2Clk_Q2 <= '0';
			else
				PS2Clk_Q1 <= PS2Clk;
				PS2Clk_Q2 <= not PS2Clk_Q1;
			end if;
		end if;
	end process;
	
	PS2Clk_op <= (not PS2Clk_Q1) and (not PS2Clk_Q2);

	-- PS2 data shift register
	process(clk)
	begin
		if rising_edge(clk) then
			if(rst = '1') then
				PS2Data_sr <= "00000000000";
			elsif (PS2Clk_op = '1') then
				PS2Data_sr(9 downto 0) <= PS2Data_sr(10 downto 1);
				PS2Data_sr(10) <= PS2Data;
			end if;
		end if;
	end process;
                         
	-- *  PS2Data_sr                     
    ScanCode_int <= PS2Data_sr(8 downto 1); -- To be used internally
	ScanCode <= ScanCode_int;  -- Not allowed to read from out signal

	-- PS2 bit counter
	process(clk) begin
		if rising_edge(clk) then
			if(rst = '1') or (BC11 = '1') then
				PS2BitCounter <= "0000";
			elsif(PS2Clk_op = '1') then
				PS2BitCounter <= PS2BitCounter+1;
			end if;
		end if;
	end process;

	-- *  PS2BitCounter & BC11           *
	BC11 <= '1' when (PS2BitCounter = "1011") else '0';

    -- PS2 state
	-- Either MAKE or BREAK state is identified from the scancode
	-- Only single character scan codes are identified
	-- The behavior of multiple character scan codes is undefined
	process(clk) begin
		if rising_edge(clk) then
			case PS2State is
				when MAKE =>
					PS2State <= IDLE;
				when IDLE =>
					if(BC11 = '1') and (ScanCode_int /= "11110000") then
						PS2State <= MAKE;--make
					elsif(BC11 = '1') and (ScanCode_int = "11110000") then
						PS2State <= BREAK;
					end if;
				when BREAK =>
					if(BC11 = '1') then
						PS2State <= IDLE;
					end if;
			end case;
		end if;
	end process;
	
	-- *  PS2State                       
        MAKE_op <= '1' when PS2state = MAKE else '0';

    -- *Hantering av ScanCodes *-- 
    with ScanCode select
        Input_Vec <= 
        "000" when x"E06B", --Vänsterpil
        "001" when x"E075", --Pil upp  
        "010" when x"E074", --Högerpil
        "011" when x"E072" --Pil ned
        "111" when others;
        
                        
        
end behavioral;
