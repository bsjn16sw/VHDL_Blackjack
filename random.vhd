library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;

entity player is
	port(
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
	fin : out std_logic
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
signal cardsum: integer := 0;
signal tmpstart : std_logic;
signal ttmpstart : std_logic :='1'; --������������������ �� ������ ���� ������ �� �����Ǽȷδ� in port�� ������ tmpstart�� �־��ݾ� �װ� ����ġ�°Ű���!
												-- �ֳ��ϸ� start�� �׻� '1'�̰� �װ� �׻� tmpstart�� ���� �ִµ� �ؿ� � ���ǹ����� tmpstart<='0'�ϸ� �ȵǴ� ����������^^
												-- �̷���쿡�� ���� �������� �ϳ��� �����ϰ� tmpstart���� ���ǹ����� ttmpstart�� �ǵ���� �װɷ� �����ؾ��ϴµ�,,,
begin

	tmpstart <= start;
	
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
			if tmpstart='1' and idx < 15 and ttmpstart='1' then -- �ε��� �� �ٲ�µ�, �����Ⱚ �ʹ� ���� ���� �� ���� 3~11�� ������ ������ �ٲޤ�
				en <= '1';
				b <= a mod 10 +1; -- �� �� �� �� �� �� �� �� b���� ���� ��Ƽ��?�� �־��ְ� �����ϱ� �� �ʤ� �� �� ��
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
		--	report "term value is" & std_logic'image(term); -- �ݷҹ��� �Ŵ�� �߰߱�,,,,,,,,,,,,,,,,,��,,,,,,,���,,,,,,, tb������ �ܼ�â����,,��
			if term = '1' then
				-- display " stay or hit? "
				-- display card? 
				if load_stay = '0' then -- stay
					-- display stay					
					fin <= '1';	-- turn to next player
					ttmpstart <= '0';
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
						ttmpstart <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;
	
--	process(clk)
--	begin
--		if rising_edge(clk) then
--			if term = '1' then
				-- display " stay or hit? "
				-- display card? 
--				if load_stay = '0' then -- stay
					-- display stay					
--					fin <= '1';	-- turn to next player
--					tmpstart <= '0';
--					term <= '0';

--				elsif load_hit = '0' then -- hit
					-- display hit
--					cardsum <= cardsum + card(idx);
--					idx <= idx + 1;
--					if cardsum>21 then	-- burst
						-- display burst
--						term <= '0';
--						fin <= '1';
--						tmpstart <= '0';
--					end if;
--				end if;
--			end if;
--		end if;
--	end process;
	
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
		fin : out std_logic
		);
end blackjack;

architecture Behavioral of blackjack is

signal fin1: std_logic;
signal fin2: std_logic;
signal fin3: std_logic;
signal r1,r2,r3 : integer;
signal t1,t2,t3 : integer;

type int_arr2 is array (0 to 30) of integer;
signal ttmp : int_arr2;

component player is
	port(
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
	fin : out std_logic
	);
end component;

begin
	p1 : player port map(clk, start, load_stay, load_hit,r1,ttmp(0),ttmp(1),ttmp(2),ttmp(3),ttmp(4),ttmp(5),ttmp(6),ttmp(7),ttmp(8),t1,fin1);
	p2 : player port map(clk, fin1, load_stay, load_hit,r2,ttmp(9),ttmp(10),ttmp(11),ttmp(12),ttmp(13),ttmp(14),ttmp(15),ttmp(16),ttmp(17),t2,fin2);
	p3 : player port map(clk, fin2,load_stay, load_hit, r3,ttmp(18),ttmp(19),ttmp(20),ttmp(21),ttmp(22),ttmp(23),ttmp(24),ttmp(25),ttmp(26),t3,fin3);
	
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

end Behavioral;