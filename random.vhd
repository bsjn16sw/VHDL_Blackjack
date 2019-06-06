library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;

entity player is
	port(
	rst : in std_logic;
	clk : in std_logic;
	start : in std_logic;
	load_stay : in std_logic;
	load_hit : in std_logic;
	randnum : out integer;
	tmp1 : out integer;
	tmp2 : out integer;
	tmp3 : out integer;
	tmp4 : out integer;
	tmp5 : out integer;
	tmp6 : out integer;
	tmp7 : out integer;
	tmp8 : out integer;
	tmp9 : out integer;
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
signal s1_clk, s2_clk, s14_clk: STD_LOGIC;
signal my_limit: std_logic := '0';

begin

	tmpstart <= start;
	limit <= my_limit;
	
	process(clk)
	begin
		if rising_edge(clk) and en='0' then
			a<=13*a+1;
		end if;
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) then
	--		if idx < 10 then
			if tmpstart='1' and idx < 15 and ttmpstart='1' then -- 인덱스 좀 바꿨는데, 쓰레기값 너무 많이 들어가서 걍 대충 3~11로 안전한 값으로 바꿈ㅎ
				en <= '1';
				b <= a mod 16 +1; -- ㅋ ㅋ ㅋ ㅋ ㅋ ㅋ ㅋ ㅋ b값을 같은 인티져?에 넣어주고 돌리니까 또 됨ㅋ ㅋ ㅋ ㅋ
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
		--	report "term value is" & std_logic'image(term); -- 콜롬버스 신대륙 발견급,,,,,,,,,,,,,,,,,ㅎ,,,,,,,충격,,,,,,, tb돌릴때 콘솔창에떠,,ㅎ
			if term = '1' and tterm = '0' then
				-- display " stay or hit? "
				-- display card? 
				if load_stay = '0' then -- stay
					-- display stay					
					fin <= '1';	-- turn to next player
			--		ttmpstart <= '0';
					term <= '0';

				elsif load_hit = '0' then -- hit
					-- display hit
					cardsum <= cardsum + card(idx);
		--			report "The value of 'cardsum' is " & integer'image(cardsum);
					idx <= idx + 1;
					if cardsum > 21 then	-- burst
						-- display burst
						term <= '0';
						fin <= '1';
			--			ttmpstart <= '0';
					end if;
				end if;
	
			end if;
		end if;
	end process;
	
	process(s2_clk) -- 15초과
	begin
		if rising_edge(s2_clk) then
			if load_stay='1' and load_hit='1' and term='1' then
				my_limit <= '1';
				tterm <= '1';
				fin <= '1';
			end if;
		end if;	
	end process;
	
	-- 1. Clock generator (Period = 1s)
	process(rst, clk)
		variable s1_cnt: integer range 0 to 2000000;
	begin
		if rst = '0' then
			s1_clk <= '1';
			s1_cnt := 0;
		elsif clk'event and clk = '1' then
			if s1_cnt < 2000000 then
				s1_cnt := s1_cnt + 1;
			else
				s1_clk <= s1_clk;
				s1_cnt := 0;
			end if;
		end if;
	end process;
	
	-- 2. Clock generator (Period = 2s, 14s)
	process(rst, s1_clk)
		variable s14_cnt: integer range 0 to 7;
	begin
		if rst = '0' then
			s2_clk <= '1';
			s14_clk <= '1';
			s14_cnt := 0;
		elsif s1_clk'event and s1_clk = '1' then
			s2_clk <= not s2_clk;
			if s14_cnt < 7 then
				s14_cnt := s14_cnt + 1;
			else
				s14_clk <= not s14_clk;
				s14_cnt := 0;
			end if;
		end if;
	end process;
	
	tmp1 <= card(3);
	tmp2 <= card(4);
	tmp3 <= card(5);
	tmp4 <= card(6);
	tmp5 <= card(7);
	tmp6 <= card(8);
	tmp7 <= card(9);
	tmp8 <= card(10);
	tmp9 <= card(11);
	
	randnum <= b;
	
	total <= cardsum;

end Behavioral;

-------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blackjack is
	port(
		rst : in std_logic;
		clk : in std_logic;
		start : in std_logic;
		load_stay : in std_logic;
		load_hit : in std_logic;
		rand : out integer;
		tmp1 : out integer;
		tmp2 : out integer;
		tmp3 : out integer;
		tmp4 : out integer;
		tmp5 : out integer;
		tmp6 : out integer;
		tmp7 : out integer;
		tmp8 : out integer;
		tmp9 : out integer;
		total1, total2, total3 : out integer;
		fin : out std_logic;
		limit1 : out std_logic;
		limit2 : out std_logic;
		limit3 : out std_logic
		);
end blackjack;

architecture Behavioral of blackjack is

signal fin1: std_logic;
signal fin2: std_logic;
signal fin3: std_logic;
signal r1,r2,r3 : integer;
signal t1,t2,t3 : integer;
signal limitt1, limitt2, limitt3: std_logic;

type int_arr2 is array (0 to 30) of integer;
signal ttmp : int_arr2;

component player is
	port(
	rst : in std_logic;
	clk : in std_logic;
	start : in std_logic;
	load_stay : in std_logic;
	load_hit : in std_logic;
	randnum : out integer;
	tmp1 : out integer;
	tmp2 : out integer;
	tmp3 : out integer;
	tmp4 : out integer;
	tmp5 : out integer;
	tmp6 : out integer;
	tmp7 : out integer;
	tmp8 : out integer;
	tmp9 : out integer;
	total : out integer;
	fin : out std_logic;
	limit : out std_logic
	);
end component;

begin
	p1 : player port map(rst, clk, start, load_stay, load_hit,r1,ttmp(0),ttmp(1),ttmp(2),ttmp(3),ttmp(4),ttmp(5),ttmp(6),ttmp(7),ttmp(8),t1,fin1, limitt1);
	p2 : player port map(rst, clk, fin1, load_stay, load_hit,r2,ttmp(9),ttmp(10),ttmp(11),ttmp(12),ttmp(13),ttmp(14),ttmp(15),ttmp(16),ttmp(17),t2,fin2, limitt2);
	p3 : player port map(rst, clk, fin2,load_stay, load_hit, r3,ttmp(18),ttmp(19),ttmp(20),ttmp(21),ttmp(22),ttmp(23),ttmp(24),ttmp(25),ttmp(26),t3,fin3, limitt3);
	
	tmp1<=ttmp(0);
	tmp2<=ttmp(1);
	tmp3<=ttmp(2);
	tmp4<=ttmp(3);
	tmp5<=ttmp(4);
	tmp6<=ttmp(5);
	tmp7<=ttmp(6);
	tmp8<=ttmp(7);
	tmp9<=ttmp(8);
	
	total1<=t1;
	total2<=t2;
	total3<=t3;
	
	rand<=r3;

	fin <= fin3;
	
	limit1 <= limitt1;
	limit2 <= limitt2;
	limit3 <= limitt3;

end Behavioral;