library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity clock is
	port ( rst_n : in STD_LOGIC;
				CLK : in STD_LOGIC;
				LCD_A : out STD_LOGIC_VECTOR (1 downto 0);
				LCD_EN : out  STD_LOGIC;
           LCD_D : out  STD_LOGIC_VECTOR (7 downto 0);
			  DIGIT : out  STD_LOGIC_VECTOR (6 downto 1); -- LED display digit, 6 segments
           SEG_A : out  STD_LOGIC; -- display a
           SEG_B : out  STD_LOGIC; -- display b
           SEG_C : out  STD_LOGIC; -- display c
           SEG_D : out  STD_LOGIC; -- display d
           SEG_E : out  STD_LOGIC; -- display e
           SEG_F : out  STD_LOGIC; -- display f
           SEG_G : out  STD_LOGIC; -- display g
           SEG_DP : out  STD_LOGIC);
end clock;

architecture Behavioral of clock is

	component lcd
		port(FPGA_RSTB : in  STD_LOGIC;		-- reset
           FPGA_CLK : in  STD_LOGIC;		-- FPGA clock
           LCD_A : out  STD_LOGIC_VECTOR (1 downto 0);		-- signal RS, RW
           LCD_EN : out  STD_LOGIC;		-- LCD enable, 1: always enable
           LCD_D : out  STD_LOGIC_VECTOR (7 downto 0));
	end component;
	
	component digital_clock
		port(rst_n : in  STD_LOGIC; -- rst_n='0' -> initialize as 12:58:20
           clk : in  STD_LOGIC; -- 4MHz FPGA oscilator
           DIGIT : out  STD_LOGIC_VECTOR (6 downto 1); -- LED display digit, 6 segments
           SEG_A : out  STD_LOGIC; -- display a
           SEG_B : out  STD_LOGIC; -- display b
           SEG_C : out  STD_LOGIC; -- display c
           SEG_D : out  STD_LOGIC; -- display d
           SEG_E : out  STD_LOGIC; -- display e
           SEG_F : out  STD_LOGIC; -- display f
           SEG_G : out  STD_LOGIC; -- display g
           SEG_DP : out  STD_LOGIC);
	end component;
	
begin

	lcd_clock: lcd port map(rst_n, CLK, LCD_A, LCD_EN, LCD_D);
	
	seg_clock: digital_clock port map(rst_n, CLK, DIGIT, SEG_A, 
									SEG_B, SEG_C, SEG_D, SEG_E, SEG_F,
									SEG_G, SEG_DP);

end Behavioral;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity digital_clock is
    Port ( rst_n : in  STD_LOGIC; -- rst_n='0' -> initialize as 12:58:20
           clk : in  STD_LOGIC; -- 4MHz FPGA oscilator
           DIGIT : out  STD_LOGIC_VECTOR (6 downto 1); -- LED display digit, 6 segments
           SEG_A : out  STD_LOGIC; -- display a
           SEG_B : out  STD_LOGIC; -- display b
           SEG_C : out  STD_LOGIC; -- display c
           SEG_D : out  STD_LOGIC; -- display d
           SEG_E : out  STD_LOGIC; -- display e
           SEG_F : out  STD_LOGIC; -- display f
           SEG_G : out  STD_LOGIC; -- display g
           SEG_DP : out  STD_LOGIC); -- display dp
end digital_clock;

architecture Behavioral of digital_clock is

signal s01_clk : std_logic; -- clock for seconds, rising/descending every 0.5sec
signal hr10_cnt, hr01_cnt : std_logic_vector( 3 downto 0 ); -- count hours
signal min10_cnt, min01_cnt : std_logic_vector( 3 downto 0 ); -- count minutes
signal sec10_cnt, sec01_cnt : std_logic_vector( 3 downto 0 ); -- count seconds
signal sel : std_logic_vector( 2 downto 0 ); -- 7 segment select, select DIGIT
signal data : std_logic_vector( 3 downto 0 ); -- display value
signal seg : std_logic_vector( 7 downto 0 ); -- 7 segment display

begin

	-- determine LED display digit by sel value
	process(sel)
	begin
			case sel is
					when "000" => DIGIT <= "000001"; -- DIGIT1 for hour(tens)
							data <= hr10_cnt;
					when "001" => DIGIT <= "000010"; -- DIGIT2 for hour(units)
							data <= hr01_cnt;
					when "010" => DIGIT <= "000100"; -- DIGIT3 for minute(tens)
							data <= min10_cnt;
					when "011" => DIGIT <= "001000"; -- DIGIT4 for minute(units)
							data <= min01_cnt;
					when "100" => DIGIT <= "010000"; -- DIGIT5 for second(tens)
							data <= sec10_cnt;
					when "101" => DIGIT <= "100000"; -- DIGIT6 for second(units)
							data <= sec01_cnt;
					when others => null;
			end case;
	end process;
	
	
	-- determine sel value, display time every 50us on 7 segment
	process(rst_n, clk)
			variable seg_clk_cnt: integer range 0 to 200; -- determine sweep time(4MHz clk * 200 = 50us period)
	begin
			if(rst_n = '0') then -- reset
					sel <= "000"; -- recount
					seg_clk_cnt:= 0; -- recount
			elsif(clk'event and clk='1') then -- when clock is rising
					if(seg_clk_cnt = 200) then -- change sel value
							seg_clk_cnt:= 0; -- recount
							if(sel = "101") then -- go back to 0
									sel <= "000";
							else -- increase sel
									sel <= sel + 1;
							end if;
					else -- increase seg_clk_cnt
							seg_clk_cnt:= seg_clk_cnt+1; 
					end if;
			end if;
	end process;
	
	
	-- determine seg by data value
	-- 7 segment decoding process of digital clock
	process(data)
	begin
			case data is -- sequence of decoding bit: dpgfedcba
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
	
	SEG_A <= seg( 0 );
	SEG_B <= seg( 1 );
	SEG_C <= seg( 2 );
	SEG_D <= seg( 3 );
	SEG_E <= seg( 4 );
	SEG_F <= seg( 5 );
	SEG_G <= seg( 6 );
	SEG_DP <= seg( 7 );
	
	
	-- clock dividing process for 1Hz digital clock
	-- clk period: 250ns, count_clk period: 1sec
	process(rst_n, clk)
			-- 250 ns period -> 1/4000000
			variable count_clk: integer range 0 to 2000000; -- flip after counting 2000000 clocks(0.5sec)
	begin
			if(rst_n = '0') then -- reset
					s01_clk <= '1'; -- clock high
					count_clk:= 0; -- recount
			elsif(clk'event and clk='1') then -- when clk is rising
					if(count_clk < 2000000) then -- increase count_clock
							count_clk:= count_clk + 1;
					else -- s01_clk rising/desending
							s01_clk <= not s01_clk; -- flip
							count_clk:= 0; -- recount
					end if;
			end if;
	end process;
	
	
	-- count hours, minutes, seconds by rst_n, s01_clk rising
	process(s01_clk, rst_n)
			variable h10_cnt, h01_cnt : STD_LOGIC_VECTOR ( 3 downto 0); -- count for hour(tens, units)
			variable m10_cnt, m01_cnt : STD_LOGIC_VECTOR ( 3 downto 0); -- count for minute(tens, units)
			variable s10_cnt, s01_cnt : STD_LOGIC_VECTOR ( 3 downto 0); -- count for second(tens, units)
	begin
			if(rst_n = '0') then -- 12:58:20
					s01_cnt:= "0000"; -- '0'
					s10_cnt:= "0010"; -- '2'
					m01_cnt:= "1000"; -- '8'
					m10_cnt:= "0101"; -- '5'
					h01_cnt:= "0010"; -- '2'
					h10_cnt:= "0001"; -- '1'
					
			elsif(s01_clk = '1' and s01_clk'event) then -- when s01_clk is rising
					s01_cnt:= s01_cnt + 1; -- increase second(units)
					-- count of second(units)
					if(s01_cnt > "1001") then -- when s01_cnt = 10, recount and increase s10_cnt
							s01_cnt:= "0000"; -- recount
							s10_cnt:= s10_cnt + 1; -- increase s10_cnt
					end if;
					-- count of second(tens)
					if(s10_cnt > "0101") then -- when s10_cnt = 6, recount and increase m01_cnt
							s10_cnt:= "0000"; -- recount
							m01_cnt:= m01_cnt + 1; -- increase m01_cnt
					end if;
					-- count of minute(units)
					if(m01_cnt > "1001") then -- when m01_cnt = 10, recount and increase m10_cnt
							m01_cnt:= "0000"; -- recount
							m10_cnt:= m10_cnt + 1; -- increase m10_cnt
					end if;
					-- count of minute(tens)
					if(m10_cnt > "0101") then -- when m10_cnt = 6, recount and increase h01_cnt
							m10_cnt:= "0000"; -- recount
							h01_cnt:= h01_cnt + 1; -- increase h01_cnt
					end if;
					-- count of hour(units)
					if(h01_cnt > "1001") then -- when h01_cnt = 10, recount and increase h10_cnt
							h01_cnt:= "0000"; -- recount
							h10_cnt:= h10_cnt + 1; -- increase h10_cnt
					end if;
					--12:59:59±îÁö
					if(h10_cnt = "0001" and h01_cnt > "0010") then -- go back to 01:00:00
							h10_cnt:= "0000";
							h01_cnt:= "0001";
							m10_cnt:= "0000";
							m01_cnt:= "0000";
							s10_cnt:= "0000";
							s01_cnt:= "0000";
					end if;
			end if;
			
			sec01_cnt <= s01_cnt;
			sec10_cnt <= s10_cnt;
			min01_cnt <= m01_cnt;
			min10_cnt <= m10_cnt;
			hr01_cnt <= h01_cnt;
			hr10_cnt <= h10_cnt;
			
	end process;
	
end Behavioral;





library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity lcd is
    Port ( FPGA_RSTB : in  STD_LOGIC;		-- reset
           FPGA_CLK : in  STD_LOGIC;		-- FPGA clock
           LCD_A : out  STD_LOGIC_VECTOR (1 downto 0);		-- signal RS, RW
           LCD_EN : out  STD_LOGIC;		-- LCD enable, 1: always enable
           LCD_D : out  STD_LOGIC_VECTOR (7 downto 0));		-- LCD data
end lcd;

architecture Behavioral of lcd is

signal load_100k : std_logic;		-- high: clk_100k flip
signal clk_100k : std_logic;		-- 100 KHz clock
signal cnt_100k : std_logic_vector (7 downto 0);	-- count for load_100k, clk_100k
signal load_50 : std_logic;	-- high: clk_50 flip
signal clk_50 : std_logic;		-- 50 Hz clock
signal cnt_50 : std_logic_vector (11 downto 0);	-- count for load_50, clk_50
signal lcd_cnt : std_logic_vector (8 downto 0);	-- decide lcd_state
signal lcd_state : std_logic_vector (7 downto 0);	-- LCD state, decide lcd_db
signal lcd_db : std_logic_vector (7 downto 0);		-- LCD data

begin

	-- make 100KHz clock: 10us pulse
	process(FPGA_RSTB, FPGA_CLK, load_100k, cnt_100k)
		begin
			if FPGA_RSTB = '0' then						-- reset
					cnt_100k <= (others => '0');
					clk_100k <= '0';
			elsif rising_edge(FPGA_CLK) then			-- when FPGA_CLK rising
					if load_100k = '1' then				-- when cnt_100k = 19
							cnt_100k <= (others => '0');	-- reset
							clk_100k <= not clk_100k;	-- flip
					else										-- when cnt_100k < 19
							cnt_100k <= cnt_100k + 1;	-- count
					end if;
			end if;
	end process;
	-- count 250ns pulse as 40 => count until cnt_100k = 19
	load_100k <= '1' when (cnt_100k = X"13") else '0';		-- 19
	
	-- make 50Hz clock: 20ms pulse
	process(FPGA_RSTB, clk_100k, load_50, cnt_50)
		begin
			if FPGA_RSTB = '0' then						-- reset
					cnt_50 <= (others => '0');
					clk_50 <= '0';
			elsif rising_edge(clk_100k) then			-- when FPGA_CLK rising
					if load_50 = '1' then				-- when cnt_50 = 999
							cnt_50 <= (others => '0');	-- reset
							clk_50 <= not clk_50;		-- flip
					else										-- when cnt_50 < 999
							cnt_50 <= cnt_50 + 1;		-- count
					end if;
			end if;
	end process;
	-- count 10us pulse(100KHz) as 2000 => count until cnt_50 = 999
	load_50 <= '1' when (cnt_50 = X"3E7") else '0';		-- 999
	
	-- assign LCD state
	process(FPGA_RSTB, clk_50, lcd_cnt)
		begin
			if FPGA_RSTB = '0' then						-- reset
					lcd_cnt <= (others => '0');
			elsif rising_edge(clk_50) then			-- when clk_50 rising
					if (lcd_cnt >= "001010110") then	-- when lcd_cnt >= 86(random number over 72)
							lcd_cnt <= lcd_cnt;			-- no count
					else										-- when lcd_cnt < 86
							lcd_cnt <= lcd_cnt + 1;		-- count
					end if;
			end if;
	end process;
	-- lcd_state = lcd_cnt * 1/2, max: 00101011(43)
	lcd_state <= lcd_cnt(8 downto 1);
	
	-- set output of each output state
	process(lcd_state) -- total 6 instruction codes + 32 states
		begin
			case lcd_state is		-- 0~43
					when X"00" => lcd_db <= "00111000";		-- function set
					when X"01" => lcd_db <= "00001000";		-- display OFF
					when X"02" => lcd_db <= "00000001";		-- display clear
					when X"03" => lcd_db <= "00000110";		-- entry mode set
					when X"04" => lcd_db <= "00001100";		-- display ON
					when X"05" => lcd_db <= "00000011";		-- return home
					when X"06" => lcd_db <= X"3C";			-- <
					when X"07" => lcd_db <= X"33";			-- 3
					when X"08" => lcd_db <= X"31";			-- 1
					when X"09" => lcd_db <= X"33";			-- 3
					when X"0A" => lcd_db <= X"36";			-- 6
					when X"0B" => lcd_db <= X"31";			-- 1
					when X"0C" => lcd_db <= X"34";			-- 4
					when X"0D" => lcd_db <= X"3E";			-- >
					when X"0E" => lcd_db <= X"3C";			-- <
					when X"0F" => lcd_db <= X"33";			-- 3
					when X"10" => lcd_db <= X"31";			-- 1
					when X"11" => lcd_db <= X"30";			-- 0
					when X"12" => lcd_db <= X"31";			-- 1
					when X"13" => lcd_db <= X"31";			-- 1
					when X"14" => lcd_db <= X"38";			-- 8
					when X"15" => lcd_db <= X"3E";			-- >
					when X"16" => lcd_db <= X"C0";			-- change line
					when X"17" => lcd_db <= X"20";			-- space
					when X"18" => lcd_db <= X"4B";			-- K
					when X"19" => lcd_db <= X"20";			-- space
					when X"1A" => lcd_db <= X"48";			-- H
					when X"1B" => lcd_db <= X"20";			-- space
					when X"1C" => lcd_db <= X"52";			-- R
					when X"1D" => lcd_db <= X"21";			-- !
					when X"1E" => lcd_db <= X"20";			-- space
					when X"1F" => lcd_db <= X"20";			-- space
					when X"20" => lcd_db <= X"53";			-- S
					when X"21" => lcd_db <= X"20";			-- space
					when X"22" => lcd_db <= X"4A";			-- J
					when X"23" => lcd_db <= X"20";			-- space
					when X"24" => lcd_db <= X"53";			-- S
					when X"25" => lcd_db <= X"3F";			-- ?
					when X"26" => lcd_db <= X"20";			-- space
					when others => lcd_db <= (others => '0');
			end case;
	end process;
	-- connect internal signal with port
	LCD_A(1) <= '0';
	LCD_A(0) <= '0' when 	-- LCD_A = 00(read)
								(lcd_state >= X"00" and lcd_state < X"06")
								or (lcd_state = X"16")		-- change line
						else '1';		-- LCD_A = 01(write)
	LCD_EN <= not lcd_cnt(0);
	LCD_D <= lcd_db;

end Behavioral;

