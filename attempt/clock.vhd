--------------------clock--------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.my_package.ALL;

entity clock is
	port ( RST: in STD_LOGIC;
		CLK: in STD_LOGIC;
		LCD_A: out STD_LOGIC_VECTOR (1 downto 0);
		LCD_EN: out STD_LOGIC;
		LCD_D: out STD_LOGIC_VECTOR (7 downto 0);
		DIGIT: out STD_LOGIC_VECTOR (6 downto 1);
		SEG_A: out STD_LOGIC;
		SEG_B: out STD_LOGIC;
		SEG_C: out STD_LOGIC;
		SEG_D: out STD_LOGIC;
		SEG_E: out STD_LOGIC;
		SEG_F: out STD_LOGIC;
		SEG_G: out STD_LOGIC;
		SEG_DP: out STD_LOGIC;
		CLK_2s: out STD_LOGIC;
		CLK_14s: out STD_LOGIC );

end clock;

architecture Behavioral of clock is

component lcd_clock
	port ( RST_LCD: in STD_LOGIC;
		CLK_LCD: in STD_LOGIC;
		LCD_A: out STD_LOGIC_VECTOR (1 downto 0);
		LCD_EN: out STD_LOGIC;
		LCD_D: out STD_LOGIC_VECTOR (7 downto 0) );
end component;

component seg_clock
	port ( RST_SEG: in STD_LOGIC;
		CLK_SEG: in STD_LOGIC;
		DIGIT: out STD_LOGIC_VECTOR (6 downto 1);
		SEG_A: out STD_LOGIC;
		SEG_B: out STD_LOGIC;
		SEG_C: out STD_LOGIC;
		SEG_D: out STD_LOGIC;
		SEG_E: out STD_LOGIC;
		SEG_F: out STD_LOGIC;
		SEG_G: out STD_LOGIC;
		SEG_DP: out STD_LOGIC;
		CLK_2s: out STD_LOGIC;
		CLK_14s: out STD_LOGIC );
end component;

begin
	lcd_clock_m: lcd_clock port map ( RST, CLK, LCD_A, LCD_EN, LCD_D );
	seg_clock_m: seg_clock port map ( RST, CLK, DIGIT, SEG_A, SEG_B,
		SEG_C, SEG_D, SEG_E, SEG_F, SEG_G, SEG_DP, CLK_2s, CLK_14s );

end Behavioral;

--------------------lcd_clock--------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lcd_clock is
	port ( RST_LCD: in STD_LOGIC;
		CLK_LCD: in STD_LOGIC;
		LCD_A: out STD_LOGIC_VECTOR (1 downto 0);
		LCD_EN: out STD_LOGIC;
		LCD_D: out STD_LOGIC_VECTOR (7 downto 0) );
end lcd_clock;

architecture Behavioral of lcd_clock is

signal load_100k: STD_LOGIC;	-- High: clk_100k flip
signal clk_100k: STD_LOGIC;		-- 100 KHz clock
signal cnt_100k: STD_LOGIC_VECTOR (7 downto 0);	-- count for load_100k, clk_100k
signal load_50: STD_LOGIC;		-- High: clk_50 flip
signal clk_50: STD_LOGIC;			-- 50Hz clock
signal cnt_50: STD_LOGIC_VECTOR (11 downto 0);	-- count for load_50, clk_50
signal lcd_cnt: STD_LOGIC_VECTOR (8 downto 0);	-- decide lcd_state
signal lcd_state: STD_LOGIC_VECTOR (7 downto 0);	-- LCD state, decide lcd_db
signal lcd_db: STD_LOGIC_VECTOR (7 downto 0);	-- LCD data

signal s1_clk, s2_clk, s14_clk: STD_LOGIC;	-- Pulse 1s, 2s, 14s

begin

	-- Process 1: Make 100KHz clock
	process(RST_LCD, CLK_LCD, load_100k, cnt_100k)
	begin
		-- When reset button is pushed
		if RST_LCD = '0' then
			cnt_100k <= (others => '0');
			clk_100k <= '0';
		-- When CLK_LCD is rising
		elsif rising_edge(CLK_LCD) then
			-- When cnt_100k == 19
			if load_100k = '1' then
				cnt_100k <= (others => '0');	-- Reset cnt_100k
				clk_100k <= not clk_100k;		-- Flip clk_100k
			-- When cnt_100k < 19
			else
				cnt_100k <= cnt_100k + 1;			-- Accumulate cnt_100k
			end if;
		end if;
	end process;
	
	-- 100KHz clock pulse is 10000ns = 250ns * 40
	-- Flip load_100k in every 5000ns = 250ns * 20
	load_100k <= '1' when (cnt_100k = X"13") else '0';	-- X"13" == 19
	
	-- Process 2: Make 50Hz clock
	process(RST_LCD, clk_100k, load_50, cnt_50)
	begin
		-- When reset button is pushed
		if RST_LCD = '0' then
			cnt_50 <= (others => '0');
			clk_50 <= '0';
		-- When clk_100k is rising
		elsif rising_edge(clk_100k) then
			-- When cnt_50 == 999
			if load_50 = '1' then
				cnt_50 <= (others => '0');	-- Reset cnt_50
				clk_50 <= not clk_50;		-- Flip clk_50
			-- When cnt_50 < 999
			else
				cnt_50 <= cnt_50 + 1;		-- Accumulate cnt_50
			end if;
		end if;
	end process;
	
	-- 50Hz clock pulse is 2000 times of 100KHz clock pulse
	-- Flip load_50 in every 1000 times of 100KHz clock pulse
	load_50 <= '1' when (cnt_50 = X"3E7") else '0';	-- X"3E7" == 999
	
	-- Process 3: Assign LCD state
	process(RST_LCD, clk_50, lcd_cnt)
	begin
		-- When reset button is pushed
		if RST_LCD = '0' then
			lcd_cnt <= (others => '0');
		-- When clk_50 is rising
		elsif rising_edge(clk_50) then
			-- When lcd_cnt >= 86 (86 is random number over 72)
			if lcd_cnt >= "001010110" then
				lcd_cnt <= lcd_cnt;		-- No count
			-- When lcd_cnt < 86
			else
				lcd_cnt <= lcd_cnt + 1;	-- Count
			end if;
		end if;
	end process;
	
	-- lcd_state == lcd_cnt * 1/2, Max: 00101011(43)
	lcd_state <= lcd_cnt (8 downto 1);
	
	-- Process 4: Set output of each lcd_state
	process(lcd_state)
	begin
		case lcd_state is
			when X"00" => lcd_db <= "00111000";      -- function set
			when X"01" => lcd_db <= "00001000";      -- display OFF
			when X"02" => lcd_db <= "00000001";      -- display clear
			when X"03" => lcd_db <= "00000110";      -- entry mode set
			when X"04" => lcd_db <= "00001100";      -- display ON
			when X"05" => lcd_db <= "00000011";      -- return home
			when X"06" => lcd_db <= X"41"; --reg_file(0);
			when X"07" => lcd_db <= X"41"; --reg_file(1);
			when X"08" => lcd_db <= X"41"; --reg_file(2);
			when X"09" => lcd_db <= X"41"; --reg_file(3);
			when X"0A" => lcd_db <= X"41"; --reg_file(4);
			when X"0B" => lcd_db <= X"41"; --reg_file(5);
			when X"0C" => lcd_db <= X"41"; --reg_file(6);
			when X"0D" => lcd_db <= X"41"; --reg_file(7);
			when X"0E" => lcd_db <= X"41"; --reg_file(8);
			when X"0F" => lcd_db <= X"41"; --reg_file(9);
			when X"10" => lcd_db <= X"41"; --reg_file(10);
			when X"11" => lcd_db <= X"41"; --reg_file(11);
			when X"12" => lcd_db <= X"41"; --reg_file(12);
			when X"13" => lcd_db <= X"41"; --reg_file(13);
			when X"14" => lcd_db <= X"41"; --reg_file(14);
			when X"15" => lcd_db <= X"41"; --reg_file(15);
			when X"16" => lcd_db <= X"C0";         -- change line
			when X"17" => lcd_db <= X"41"; --reg_file(16);
			when X"18" => lcd_db <= X"41"; --reg_file(17);
			when X"19" => lcd_db <= X"41"; --reg_file(18);
			when X"1A" => lcd_db <= X"41"; --reg_file(19);
			when X"1B" => lcd_db <= X"41"; --reg_file(20);
			when X"1C" => lcd_db <= X"41"; --reg_file(21);
			when X"1D" => lcd_db <= X"41"; --reg_file(22);
			when X"1E" => lcd_db <= X"41"; --reg_file(23);
			when X"1F" => lcd_db <= X"41"; --reg_file(24);
			when X"20" => lcd_db <= X"41"; --reg_file(25);
			when X"21" => lcd_db <= X"41"; --reg_file(26);
			when X"22" => lcd_db <= X"41"; --reg_file(27);
			when X"23" => lcd_db <= X"41"; --reg_file(28);
			when X"24" => lcd_db <= X"41"; --reg_file(29);
			when X"25" => lcd_db <= X"41"; --reg_file(30);
			when X"26" => lcd_db <= X"41"; --reg_file(31);
			when others => lcd_db <= (others => '0');
		end case;
	end process;
	
	-- Set 3 output ports with internal signal
	-- Read when LCD_A == 00, Write when LCD_A == 01
	LCD_A(1) <= '0';
	LCD_A(0) <= '0' when (lcd_state >= X"00" and lcd_state < X"06") or
		(lcd_state = X"16") else '1';
	
	LCD_EN <= not lcd_cnt(0);
	LCD_D <= lcd_db;

end Behavioral;

--------------------seg_clock--------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity seg_clock is
	port ( RST_SEG: in STD_LOGIC;
		CLK_SEG: in STD_LOGIC;
		DIGIT: out STD_LOGIC_VECTOR (6 downto 1);
		SEG_A: out STD_LOGIC;
		SEG_B: out STD_LOGIC;
		SEG_C: out STD_LOGIC;
		SEG_D: out STD_LOGIC;
		SEG_E: out STD_LOGIC;
		SEG_F: out STD_LOGIC;
		SEG_G: out STD_LOGIC;
		SEG_DP: out STD_LOGIC;
		CLK_2s: out STD_LOGIC;
		CLK_14s: out STD_LOGIC );
end seg_clock;

architecture Behavioral of seg_clock is

signal s1_clk: STD_LOGIC;	-- Pulse = 1s (Rising/Descending in every 0.5s)
signal sum10, sum01: STD_LOGIC_VECTOR (3 downto 0);	-- Cards sum
signal score10, score01: STD_LOGIC_VECTOR (3 downto 0); -- Score
signal sec10_cnt, sec01_cnt: STD_LOGIC_VECTOR (3 downto 0); -- Count seconds
signal sel: STD_LOGIC_VECTOR (2 downto 0); -- 7 segment select, Select DIGIT
signal data: STD_LOGIC_VECTOR (3 downto 0); -- Display value
signal seg: STD_LOGIC_VECTOR (7 downto 0); -- 7 segment display
signal s2_clk, s14_clk: STD_LOGIC; -- Pulse = 2s, 14s (Rising/Descending in every 1s, 7s)

begin

	-- Process 1: Determine LED display digit by sel value
	process(sel)
	begin
		case sel is
			when "000" => DIGIT <= "000001"; -- Cards sum (Tens)
				data <= sum10;
			when "001" => DIGIT <= "000010"; -- Cards sum (Units)
				data <= sum01;
			when "010" => DIGIT <= "000100"; -- Score (Tens)
				data <= score10;
			when "011" => DIGIT <= "001000"; -- Score (Units)
				data <= score01;
			when "100" => DIGIT <= "010000"; -- Left seconds (Tens)
				data <= sec10_cnt;
			when "101" => DIGIT <= "100000"; -- Left seconds (Units)
				data <= sec01_cnt;
			when others => null;
		end case;
	end process;
	
	-- Process 2: Determine sel value
	-- Display each segment in every 50us
	process(RST_SEG, CLK_SEG)
		-- Determine sweep time (250ns * 200 = 50us)
		variable seg_clk_cnt: integer range 0 to 200;
	begin
		-- When reset button is pushed
		if RST_SEG = '0' then
			sel <= "000";
			seg_clk_cnt := 0;
		-- Every 250ns
		elsif CLK_SEG'event and CLK_SEG = '1' then
			-- Change sel value in every 50us
			if seg_clk_cnt = 200 then
				seg_clk_cnt := 0;	-- Recount
				if sel = "101" then
					sel <= "000";
				else
					sel <= sel + 1;
				end if;
			else
				seg_clk_cnt := seg_clk_cnt + 1;
			end if;
		end if;
	end process;
	
	-- Process 3: Determin seg by data value
	process(data)
	begin
		case data is
			-- cf) Sequence of decoding bit in seg: dp,g,f,e,d,c,b,a
			when "0000" => seg <= "00111111"; -- data value will be displayed "0"
			when "0001" => seg <= "00000110"; -- data value will be displayed "1"
			when "0010" => seg <= "01011011"; -- data value will be displayed "2"
			when "0011" => seg <= "01001111"; -- data value will be displayed "3"
			when "0100" => seg <= "01100110"; -- data value will be displayed "4"
			when "0101" => seg <= "01101101"; -- data value will be displayed "5"
			when "0110" => seg <= "01111101"; -- data value will be displayed "6"
			when "0111" => seg <= "00100111"; -- data value will be displayed "7"
			when "1000" => seg <= "01111111"; -- data value will be displayed "8"
			when "1001" => seg <= "01101111"; -- data value will be displayed "9"
			when others => null;
		end case;
	end process;
	
	SEG_A <= seg(0);
	SEG_B <= seg(1);
	SEG_C <= seg(2);
	SEG_D <= seg(3);
	SEG_E <= seg(4);
	SEG_F <= seg(5);
	SEG_G <= seg(6);
	SEG_DP <= seg(7);
	
	-- Process 4: Clock dividing process for 1Hz digital clock
	-- CLK_SEG pulse: 250ns, s1_clk pulse: 1s
	process(RST_SEG, CLK_SEG)
		-- Half pulse: 250ns * 2000000 = 0.5s
		variable count_clk: integer range 0 to 2000000;
	begin
		-- When reset button is pushed
		if RST_SEG = '0' then
			s1_clk <= '1';
			count_clk := 0;
		-- Every 250ns
		elsif CLK_SEG'event and CLK_SEG = '1' then
			if count_clk < 2000000 then
				count_clk := count_clk + 1;
			else
				s1_clk <= not s1_clk;	-- Filp s1_clk in every 0.5s (Pulse: 1s)
				count_clk := 0;	-- Recount
			end if;
		end if;
	end process;
	
	-- Process 5: 2s, 14s clock
	process(RST_SEG, s1_clk)
		variable cnt_14s: integer range 0 to 7;
	begin
		-- When reset button is pushed
		if RST_SEG = '0' then
			s2_clk <= '1';
			s14_clk <= '1';
			cnt_14s := 0;
		-- Every 1s
		elsif s1_clk'event and s1_clk = '1' then
			s2_clk <= not s2_clk;	-- Flip s2_clk in every 1s (Pulse: 2s)
			if cnt_14s < 7 then
				cnt_14s := cnt_14s + 1;
			else
				s14_clk <= not s14_clk;	-- Flip s14_clk in every 7s (Pulse: 14s)
				cnt_14s := 0;	-- Recount
			end if;
		end if;
	end process;
	
	CLK_2s <= s2_clk;
	CLK_14s <= s14_clk;
	
	-- Process 6
	process(RST_SEG, s1_clk)
		-- 
		variable s10_cnt, s01_cnt: STD_LOGIC_VECTOR (3 downto 0);
	begin
		-- When reset button is pushed
		if RST_SEG = '0' then
			s01_cnt := "0000";
			s10_cnt := "0000";
		-- Every 1s
		elsif s1_clk'event and s1_clk = '1' then
			s01_cnt := s01_cnt + 1;	-- Accumulate s01_cnt
			
			-- When s01_cnt > 9, increase s10_cnt by 1 and reset s01_cnt to 0
			if s01_cnt > "1001" then
				s01_cnt := "0000";	-- Recount
				s10_cnt := s10_cnt + 1;
			end if;
			
			-- When 00:00:15, go back to 00:00:00
			if s10_cnt = "0001" and s01_cnt = "0101" then
				s01_cnt := "0000";
				s10_cnt := "0000";
			end if;
		end if;
		
		sec01_cnt <= s01_cnt;
		sec10_cnt <= s10_cnt;
		score01 <= "0000";	-- Have to revise
		score10 <= "0000";	-- Have to revise
		sum01 <= "0000";		-- Have to revise
		sum10 <= "0000";		-- Have to revise
	end process;

end Behavioral;
