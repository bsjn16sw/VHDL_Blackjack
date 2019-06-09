library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use work.storage.ALL;

entity player is
	port (
		rst: in std_logic;
		clk: in std_logic;
		load_stay: in std_logic;
		load_hit: in std_logic;
		s1_clk, s2_clk, s4_clk: in std_logic;
		sen_idx: out integer;
		hand: out int_arr;
		ncard: out integer;
		id: out integer;	-- 0 for Dealer, 1 for Player
		winner: out integer;	-- 0 for Dealer, 1 for Player
		clk_14s_sec: out std_logic );
end player;

architecture Behavioral of player is

signal make_random: std_logic := '1';
signal rand_data, rand_data_d: integer := 0;
signal init_set: std_logic := '0';
signal card, card_d: int_arr;
signal my_hand: int_arr;
signal cur_idx, cur_idx_d: integer := 0;
signal cardsum, cardsum_d: integer := 0;
signal cardnum: integer := 0;
signal limit: std_logic := '1';
signal change_sen_idx, change_sen_idx2, m_sen_idx: integer := 0;
signal turn, turn1, turn2: std_logic := '1';
signal fin, fin1, fin2: std_logic := '0';
signal fin3: std_logic := '1';
signal s14_clk: std_logic;
signal my_id: integer := 1;

begin

	-- Set out ports
	sen_idx <= m_sen_idx;
	hand <= my_hand;
	ncard <= cardnum;
	id <= my_id;
	clk_14s_sec <= limit;

	-- Make random data
	process(clk)
	begin
		if rising_edge(clk) then
			if make_random = '1' then
				rand_data <= 13 * rand_data + 1;
				rand_data_d <= 17 * rand_data_d + 19;
			end if;
		end if;
	end process;
	
	process(clk, turn, init_set, load_stay, load_hit, fin)
		variable idx: integer := 0;
		variable count_clk: integer range 0 to 5000000;
		variable cnt: std_logic :='0';
	begin
		if rising_edge(clk) then
			-- Make random card deck
			if turn = '1' and init_set  = '0' and idx < 15 then
				make_random <= '0';
				card(idx) <= rand_data mod 8 + 1;
				card_d(idx) <= rand_data_d mod 8 + 1;
				idx := idx + 1;
				make_random <= '1';
			
			-- Initial card draw (Player: 2 cards, Dealer: 1 card)
			elsif turn = '1' and init_set = '0' and idx = 15 then
				init_set <= '1';
				my_hand(0) <= card(3);
				my_hand(1) <= card(4);
				cur_idx <= 5;
				cur_idx_d <= 4;
				cardsum <= card(3) + card(4);
				cardsum_d <= card_d(3);
				cardnum <= 2;
				idx := idx + 1;
				limit <= '1';
			
			-- Get button input
			elsif turn = '1' and init_set = '1' and cnt = '0' then
				limit <= '0';
				-- Stay
				if load_stay = '0' then
					change_sen_idx <= 2;
					turn1 <= '0';
					fin1 <= '1';
					cnt := '1';
					limit <= '1';
					
				-- Hit
				elsif load_hit = '0' then
					my_hand(cardnum) <= card(cur_idx);
					cardsum <= cardsum + card(cur_idx);
					cardnum <= cardnum + 1;
					cur_idx <= cur_idx + 1;
					cnt := '1';
					limit <= '1';
					
					-- Hit & Not burst
					if cardsum < 21 then
						change_sen_idx <= 3;
					-- Hit & Burst
					else
						change_sen_idx <= 4;
						turn1 <= '0';
						fin1 <= '1';
					end if;
				end if;
			
			-- Dealer
			elsif turn = '0' and fin = '1' then
				my_id <= 0;
				if cardsum_d <= 16 then -- hit
					cardsum_d <= card_d(cur_idx_d);
					cur_idx_d <= cur_idx_d + 1;
					
					-- Hit & Not burst
					if cardsum_d < 21 then
						change_sen_idx <= 7;
					-- Hit & Burst
					else
						change_sen_idx <= 8;
						fin3 <= '0';	-- FIN.
					end if;				
				else	-- stay
					change_sen_idx <= 6;
					fin3 <= '0';	-- FIN.
				end if;
			
			-- Game over
			elsif turn = '0' and fin = '0' then
				change_sen_idx <= 9;
				-- Player burst
				if cardsum > 21 then
					if cardsum_d > 21 then
						winner <= 1;	-- Player win
					else
						winner <= 0;	-- Dealer win
					end if;
				-- Player not burst
				else
					if cardsum_d > 21 then
						winner <= 1;	-- Player win
					elsif cardsum > cardsum_d then
						winner <= 1;	-- Player win
					else
						winner <= 0;	-- Dealer win
					end if;
				end if;
			end if;
			
			if count_clk < 5 then -- 5000000
               count_clk:= count_clk + 1;
         else -- clk_1s rising/desending
               cnt := not cnt;
               count_clk:= 0; -- recount
         end if;
		end if;
	end process;
	
	-- Change fin, turn
	process(clk)
	begin
		if rising_edge(clk) then
			if fin1 = '1' or fin2 = '1' then
				fin <= '1';
			end if;
			
			if fin3 = '0' then
				fin <= '0';
			end if;
			
			if turn1 = '0' or turn2 = '0' then
				turn <= '0';
			end if;
		end if;
	end process;
	
	-- 14s Time timer (Reset timer when limit is '1')
	process(rst, s1_clk, limit)
			variable cnt_14s : integer range 0 to 7;
	begin
			if rst = '0' or limit = '1' then -- reset
					s14_clk <= '1';
					cnt_14s := 0;

			elsif s1_clk'event and s1_clk = '1' then -- every 1s
					if cnt_14s < 7 then
							cnt_14s := cnt_14s + 1;
					else
							s14_clk <= not s14_clk; -- flip after 7s
							cnt_14s := 0;
					end if;
			end if;
	end process;
	
	-- 14s Timeout
	process(rst, s14_clk)
	begin
		if rising_edge(s14_clk) then
			if limit = '0' then
				change_sen_idx2 <= 5;
				fin2 <= '1';
				turn2 <= '0';
			end if;
		end if;
	end process;
	
	-- LCD sen_idx
	process(s4_clk)
	begin
		if rising_edge(s4_clk) then
			if cardnum = 2 and m_sen_idx < 1 then
				m_sen_idx <= m_sen_idx + 1;
			end if;
			
			if change_sen_idx = 2 then
				m_sen_idx <= 2;
			elsif change_sen_idx = 3 then
				m_sen_idx <= 3;
			elsif change_sen_idx = 4 then
				m_sen_idx <= 4;
			elsif change_sen_idx = 6 then
				m_sen_idx <= 6;
			elsif change_sen_idx = 7 then
				m_sen_idx <= 7;
			elsif change_sen_idx = 8 then
				m_sen_idx <= 8;
			elsif change_sen_idx = 9 then
				m_sen_idx <= 9;
			end if;
			
			if change_sen_idx2 = 5 then
				m_sen_idx <= 5;
			end if;
		end if;
	end process;

end Behavioral;

---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.storage.ALL;

entity main is
	port (
		rst: in std_logic;
		clk: in std_logic;
		data_out: in std_logic;
		load_stay: in std_logic;
		load_hit: in std_logic;
		LCD_A: out std_logic_vector (1 downto 0);
		LCD_EN: out std_logic;
		LCD_D: out std_logic_vector (7 downto 0);
		sec1, sec2, sec4: out std_logic;
		sen_idx: out integer;
		ncard: out integer;
		id: out integer;
		winner: out integer;
		clk_14s_sec: out std_logic );
end main;

architecture Behavioral of main is

component player is
	port (
		rst: in std_logic;
		clk: in std_logic;
		load_stay: in std_logic;
		load_hit: in std_logic;
		s1_clk, s2_clk, s4_clk: in std_logic;
		sen_idx: out integer;
		hand: out int_arr;
		ncard: out integer;
		id: out integer;	-- 0 for Dealer, 1 for Player
		winner: out integer;	-- 0 for Dealer, 1 for Player
		clk_14s_sec: out std_logic );
end component;

signal s1_clk, s2_clk, s4_clk: std_logic;
signal my_sen_idx, my_ncard, my_id, my_winner: integer;
signal my_hand: int_arr;
signal my_clk_14s_sec: std_logic;

begin

	sec1 <= s1_clk;
	sec2 <= s2_clk;
	sec4 <= s4_clk;
	sen_idx <= my_sen_idx;
	ncard <= my_ncard;
	id <= my_id;
	winner <= my_winner;
	clk_14s_sec <= my_clk_14s_sec;

	-- Clock generator (Period = 1s)
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
				s1_clk <= not s1_clk;
				s1_cnt := 0;
			end if;
		end if;
	end process;
	
	-- Clock generator (Period = 2s, 4s)
	process(rst, s1_clk)
		variable s4_cnt: integer range 0 to 2;
	begin
		if rst = '0' then
			s2_clk <= '1';
			s4_clk <= '1';
			s4_cnt := 0;
		elsif s1_clk'event and s1_clk = '1' then
			s2_clk <= not s2_clk;
			if s4_cnt < 2 then
				s4_cnt := s4_cnt + 1;
			else
				s4_clk <= not s4_clk;
				s4_cnt := 0;
			end if;
		end if;
	end process;
	
	my_player: player port map (rst, clk, load_stay, load_hit, s1_clk, s2_clk, s4_clk,
		my_sen_idx, my_hand, my_ncard, my_id, my_winner, my_clk_14s_sec);

end Behavioral;

