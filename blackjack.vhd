library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seg_clock is
    Port ( rst_n : in  STD_LOGIC;
           clk : in  STD_LOGIC; -- 4MHz FPGA oscilator
			  CLK_14s_rst : in STD_LOGIC;
			  CLK_1s : out STD_LOGIC;
			  CLK_2s : out STD_LOGIC;
			  CLK_14s : out STD_LOGIC);
end seg_clock;

architecture Behavioral of seg_clock is

signal s1_clk : std_logic; -- clock for seconds, rising/descending every 0.5sec
signal s2_clk, s14_clk : std_logic; -- clock for 2 / 14 seconds, rising / descending every 1sec / 7sec

begin

	-- clock dividing process for 1Hz digital clock
	-- clk period: 250ns, count_clk period: 1sec
	process(rst_n, clk)
			-- 250 ns period -> 1/4000000
			variable count_clk: integer range 0 to 2000000; -- flip after counting 2000000 clocks(0.5sec)
	begin
			if(rst_n = '0') then -- reset
					s1_clk <= '1';
					count_clk:= 0;
			elsif(clk'event and clk='1') then
					if(count_clk < 2000000) then
							count_clk:= count_clk + 1;
					else -- clk_1s rising/desending
							s1_clk <= not s1_clk;
							count_clk:= 0; -- recount
					end if;
			end if;
	end process;
	
	-- 2sec clock, 14sec clock
	process(rst_n, s1_clk, CLK_14s_rst)
			variable cnt_14s : integer range 0 to 7;
	begin
			if(rst_n = '0') then -- reset
					s2_clk <= '1';
					s14_clk <= '1';
					cnt_14s := 0;
			elsif(CLK_14s_rst = '0') then
					s14_clk <= '1';
					cnt_14s := 0;
			elsif(s1_clk'event and s1_clk='1') then -- every 1s
					s2_clk <= not s2_clk; -- flip after 1s
					if(cnt_14s < 7) then
							cnt_14s := cnt_14s + 1;
					else
							s14_clk <= not s14_clk; -- flip after 7s
							cnt_14s := 0;
					end if;			
			end if;
	end process;
	
	CLK_1s <= s1_clk;
	CLK_2s <= s2_clk;
	CLK_14s <= s14_clk;
	
end Behavioral;	

--segment clock 분리하기!!!!!!!!!!!!!
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_segment is
    Port ( rst_n : in  STD_LOGIC;
           clk : in  STD_LOGIC; -- 4MHz FPGA oscilator
			  CLK_1s : in STD_LOGIC;
			  ID : in integer;
			  SUM1 : in integer;
			  --SUM2 : in integer;
			  --SUM3 : in integer;			  
           DIGIT : out  STD_LOGIC_VECTOR (6 downto 1);
           SEG_A : out  STD_LOGIC;
           SEG_B : out  STD_LOGIC;
           SEG_C : out  STD_LOGIC;
           SEG_D : out  STD_LOGIC;
           SEG_E : out  STD_LOGIC;
           SEG_F : out  STD_LOGIC;
           SEG_G : out  STD_LOGIC;
           SEG_DP : out  STD_LOGIC);
end display_segment;

architecture Behavioral of display_segment is

signal sum10, sum01 : std_logic_vector( 3 downto 0 ); -- 현재 플레이어 점수
signal id10, id01 : std_logic_vector( 3 downto 0 ); -- 현재 플레이어의 아이디
signal sec10_cnt, sec01_cnt : std_logic_vector( 3 downto 0 ); -- count seconds
signal sel : std_logic_vector( 2 downto 0 ); -- 7 segment select, select DIGIT
signal data : std_logic_vector( 3 downto 0 ); -- display value
signal seg : std_logic_vector( 7 downto 0 ); -- 7 segment display
signal myid, mysum1 : integer;
--signal mysum2, mysum3 : integer;
signal tmp : std_logic_vector(4 downto 0);

begin

	myid <= ID;
	mysum1 <= SUM1;
	--mysum2 <= SUM2;
	--mysum3 <= SUM3;
	
	-- determine LED display digit by sel value
	process(sel)
	begin
			case sel is
					when "000" => DIGIT <= "000001"; -- 현재 플레이어 점수(tens)
							data <= id10;
					--when "001" => DIGIT <= "000010"; -- 현재 플레이어 점수(units)
							--data <= id01;
					when "010" => DIGIT <= "000100"; -- 현재 플레이어의 아이디(tens)
							data <= sum10;
					when "011" => DIGIT <= "001000"; -- 현재 플레이어의 아이디(units)
							data <= sum01;
					when "100" => DIGIT <= "010000"; -- second(tens)
							data <= sec10_cnt;
					when "101" => DIGIT <= "100000"; -- second(units)
							data <= sec01_cnt;
					when others => null;
			end case;
	end process;
	
	
	-- determine sel value, display time every 50us on 7 segment
	process(rst_n, clk)
			variable seg_clk_cnt: integer range 0 to 200; -- determine sweep time(4MHz clk * 200 = 50us period)
	begin
			if(rst_n = '0') then -- reset
					sel <= "000";
					seg_clk_cnt:= 0;
			elsif(clk'event and clk='1') then
					if(seg_clk_cnt = 200) then -- change sel value
							seg_clk_cnt:= 0; -- recount
							if(sel = "101") then
									sel <= "000";
							else
									sel <= sel + 1;
							end if;
					else
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
	
	-- count seconds by rst_n, s1_clk rising
	process(CLK_1s, rst_n)
			variable s10_cnt, s01_cnt : STD_LOGIC_VECTOR ( 3 downto 0); -- count for second(tens, units)
	begin
			if(rst_n = '0') then -- 00:00:00
					s01_cnt:= "0000"; -- '0'
					s10_cnt:= "0000"; -- '0'
					
			elsif(CLK_1s = '1' and CLK_1s'event) then -- when s01_clk is rising
					s01_cnt:= s01_cnt + 1; -- increase second(units)
					-- count of second(units)
					if(s01_cnt > "1001") then -- when s01_cnt = 10, recount and increase s10_cnt
							s01_cnt:= "0000"; -- recount
							s10_cnt:= s10_cnt + 1; -- increase s10_cnt
					end if;
					-- --:--:15
					if(s10_cnt = "0001" and s01_cnt > "0100") then -- go back to --:--:00
							s10_cnt:= "0000";
							s01_cnt:= "0000";
					end if;
			end if;
			
			sec01_cnt <= s01_cnt;
			sec10_cnt <= s10_cnt;
			
	end process;
	
	-- display id, sum
	process(clk, rst_n)
			variable sum01_cnt, sum10_cnt : STD_LOGIC_VECTOR(3 downto 0);
			variable id10_cnt : std_logic_vector(3 downto 0);
	begin
			if(rst_n = '0') then
					id01 <= "0000";
					sum01 <= "0000";
					sum10 <= "0000";
			elsif(clk = '1' and clk'event) then
				if myid = 1 then	-- player1
						id10_cnt:= "0001";
						tmp <= std_logic_vector(to_unsigned(mysum1, 5));
				else -- dealer
						id10_cnt:= "0000";
				--elsif myid = 2 then	-- player2
						--id01_cnt:= "0010";
						--tmp <= std_logic_vector(to_unsigned(mysum2, 5));
				--else		-- player3
						--id01_cnt:= "0011";
						--tmp <= std_logic_vector(to_unsigned(mysum3, 5));
				end if;
				
				if tmp < "01010" then	-- 0s
						sum10_cnt:= "0000";
						sum01_cnt:= tmp(3 downto 0);
				elsif tmp >= "01010" and tmp < "10100" then	-- 10s
						sum10_cnt:= "0001";
						sum01_cnt:= tmp - "01010";
				elsif tmp >= "10100" and tmp < "11110" then	-- 20s
						sum10_cnt:= "0010";
						sum01_cnt:= tmp - "10100";
				elsif tmp >= "11110" and tmp <= "11111" then
						sum10_cnt:= "0011";
						sum01_cnt:= tmp - "11110";
				end if;
				
				--id01 <= id01_cnt;
				id10 <= id10_cnt;
				sum01 <= sum01_cnt;
				sum10 <= sum10_cnt;
			end if;
	end process;

end Behavioral;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;

entity player is
	port(
	rst : in std_logic;
	clk : in std_logic;
	clk_14s : in std_logic;
	start : in std_logic;
	load_stay : in std_logic;
	load_hit : in std_logic;
	total : out integer;
	fin : out std_logic;
	limit : out std_logic
	);
end player;

architecture Behavioral of player is

signal a : integer:=0;
signal b : integer;
signal tmp : integer;
signal idx : integer:=0;
signal en : std_logic:='0';
type int_arr is array (0 to 15) of integer;
signal card : int_arr;
signal term : std_logic := '0';
signal tterm : std_logic := '0';

signal cardsum: integer := 0;
signal tmpstart : std_logic;
signal ttmpstart : std_logic :='1';
signal my_limit: std_logic := '0';
signal finn : std_logic:='0';

begin

	tmpstart <= start;
	limit <= my_limit;
	
	process(clk)
	begin
		if rising_edge(clk) and en='0' then
			a<=15*a+1;
		end if;
	end process;
	
	process(clk)
		variable count_clk: integer range 0 to 5000000; -- flip after counting 5000000 clocks(0.5sec)
		variable cnt: std_logic :='0';
	begin
		if rising_edge(clk) then
		report "finn " & std_logic'image(finn);
	--		if idx < 10 then
			if tmpstart='1' and idx < 15 and ttmpstart='1' then
				en <= '1';
				b <= a mod 16 +1;
				tmp <= b;
				card(idx) <= tmp;
				idx<=idx+1;
				en <= '0';
			end if;
			if idx = 15 then
				ttmpstart <= '0';
				term <= '1';
				idx <= 5;	-- index of next card
				cardsum<=card(3)+card(4);	-- card sum of initial 2 cards
			end if;
	---------------------------------------------------	
			--if term = '1' and tterm = '0' then
			if term = '1' and cnt = '0' then
				-- display " stay or hit? "
				-- display card? 
				if load_stay = '0' then -- stay
					cnt := '1';
					-- display stay					
					finn <= not finn;	-- turn to next player
			--		ttmpstart <= '0';
					term <= '0';

				elsif load_hit = '0' then -- hit
					cnt := '1';
					-- display hit
					cardsum <= cardsum + card(idx);
		--			report "The value of 'cardsum' is " & integer'image(cardsum);
					idx <= idx + 1;
					if cardsum > 21 then	-- burst
						-- display burst
						term <= '0';
						finn <= not finn;
			--			ttmpstart <= '0';
					end if;
				end if;
			end if;
			
			if(count_clk < 5000000) then
					count_clk:= count_clk + 1;
			else -- clk_1s rising/desending
					cnt := not cnt;
					count_clk:= 0; -- recount
			end if;
						
		end if;
	end process;
	
--	process(clk_14s) -- 14초과
	--begin
		--if rising_edge(clk_14s) then
			--if load_stay='0' and load_hit='0' and term='1' then
				--my_limit <= '1';
--				tterm <= '1';
	--			fin <= '1';
		--	end if;
--		end if;	
	--end process;
	
	total <= cardsum;
	fin <= finn;

end Behavioral;

-------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blackjack is
	port(
		rst : in std_logic;
		clk : in std_logic;
		load_stay : in std_logic;
		load_hit : in std_logic;
		DIGIT : out  STD_LOGIC_VECTOR (6 downto 1);
		SEG_A : out  STD_LOGIC;
		SEG_B : out  STD_LOGIC;
		SEG_C : out  STD_LOGIC;
		SEG_D : out  STD_LOGIC;
		SEG_E : out  STD_LOGIC;
		SEG_F : out  STD_LOGIC;
		SEG_G : out  STD_LOGIC;
		SEG_DP : out  STD_LOGIC;
		fin : out std_logic
		);
end blackjack;

architecture Behavioral of blackjack is

component seg_clock is
	port(
	rst_n : in  STD_LOGIC;
   clk : in  STD_LOGIC; -- 4MHz FPGA oscilator
	CLK_14s_rst : in STD_LOGIC;
   CLK_1s : out STD_LOGIC;
   CLK_2s : out STD_LOGIC;
   CLK_14s : out STD_LOGIC
	);
end component;

component player is
	port(
	rst : in std_logic;
	clk : in std_logic;
	clk_14s : in std_logic;
	start : in std_logic;
	load_stay : in std_logic;
	load_hit : in std_logic;
	total : out integer;
	fin : out std_logic;
	limit : out std_logic
	);
end component;

component display_segment is
	port(
	rst_n : in  STD_LOGIC;
   clk : in  STD_LOGIC; -- 4MHz FPGA oscilator
   CLK_1s : in STD_LOGIC;
   ID : in integer;
   SUM1 : in integer;
	--SUM2 : in integer;
	--SUM3 : in integer;		
   DIGIT : out  STD_LOGIC_VECTOR (6 downto 1);
   SEG_A : out  STD_LOGIC;
   SEG_B : out  STD_LOGIC;
   SEG_C : out  STD_LOGIC;
   SEG_D : out  STD_LOGIC;
   SEG_E : out  STD_LOGIC;
   SEG_F : out  STD_LOGIC;
   SEG_G : out  STD_LOGIC;
   SEG_DP : out  STD_LOGIC
	);
end component;

signal fin1: std_logic;
--signal fin2: std_logic;
--signal fin3: std_logic;
signal r1 : integer;
--signal r2, r3 : integer;
signal sum1 : integer;
--sum2,sum3 : integer; -- card sum
signal limitt1 : std_logic;
--signal limitt2, limitt3: std_logic;
signal s1_clk, s2_clk, s14_clk : std_logic;
signal s14_clk_rst : std_logic := '1';
signal seg_digit : std_logic_vector(6 downto 1);
signal a, b, c, d, e, f, g, dp  : std_logic;
signal id : integer := 1;
signal sum11 : integer :=0;
--signal sum22 : integer :=0;
--signal sum33 : integer :=0;

type int_arr2 is array (0 to 30) of integer;
signal ttmp : int_arr2;

begin

	process(clk)
	begin
		if (clk'event and clk='1') then
			id <= 1;
			if(fin1 = '1') then
				id <= 0;
			--if (fin1 = '1' and fin2 = '0') then
				--id <= 2;
			--elsif (fin1 = '1' and fin2 = '1') then
				--id <= 3;
			end if;
		end if;
	end process;
	
	clock : seg_clock port map(rst, clk, s14_clk_rst, s1_clk, s2_clk, s14_clk);

	p1 : player port map(rst, clk, s14_clk, '1', '0', load_hit,sum1,fin1, limitt1);
	--p2 : player port map(rst, clk, s14_clk, fin1, load_stay, load_hit,sum2,fin2, limitt2);
	--p3 : player port map(rst, clk, s14_clk, fin2,load_stay, load_hit, sum3,fin3, limitt3);
	
	seg: display_segment port map(rst, clk, s1_clk, id, sum11, seg_digit, a, b, c, d, e, f, g, dp);
	--seg: display_segment port map(rst, clk, s1_clk, id, sum11, sum22, sum33, seg_digit, a, b, c, d, e, f, g, dp);
	
	sum11 <= sum1;
	--sum22 <= sum2;
	--sum33 <= sum3;
	
	DIGIT<=seg_digit;
	SEG_A<=a;
	SEG_B<=b;
	SEG_C<=c;
	SEG_D<=d;
	SEG_E<=e;
	SEG_F<=f;
	SEG_G<=g;
	SEG_DP<=dp;
	
	--fin <= fin1;
	
end Behavioral;