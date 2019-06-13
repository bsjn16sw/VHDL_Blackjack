------------------DATA_GEN------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.storage.ALL;

entity data_gen is
	port (
		rst: in std_logic;
		clk: in std_logic;
		idx: in integer;
		hand: in int_arr;
		player_sum: in integer;
		dealer_sum: in integer;
		winner: in integer;
		w_enable: in std_logic;
		data_out: out std_logic;
		addr: out std_logic_vector (4 downto 0);
		data: out std_logic_vector (7 downto 0) );
end data_gen;

architecture Behavioral of data_gen is

signal reg_file: reg;

signal cnt : std_logic_vector(4 downto 0);
signal my_idx: integer;
signal hand_ascii: reg :=	 -- To display player's card in his hand (First initialized with white-space)
	(X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20",
	 X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20");

begin

	my_idx <= idx;
	
	-- Revise hand_ascii(i) with hand(i)
	hand_ascii(0) <= X"20" when hand(0) = 0 else X"30" + std_logic_vector(to_unsigned(hand(0), 8));
   hand_ascii(1) <= X"20" when hand(1) = 0 else X"30" + std_logic_vector(to_unsigned(hand(1), 8));
   hand_ascii(2) <= X"20" when hand(2) = 0 else X"30" + std_logic_vector(to_unsigned(hand(2), 8));
   hand_ascii(3) <= X"20" when hand(3) = 0 else X"30" + std_logic_vector(to_unsigned(hand(3), 8));
   hand_ascii(4) <= X"20" when hand(4) = 0 else X"30" + std_logic_vector(to_unsigned(hand(4), 8));
   hand_ascii(5) <= X"20" when hand(5) = 0 else X"30" + std_logic_vector(to_unsigned(hand(5), 8));
   hand_ascii(6) <= X"20" when hand(6) = 0 else X"30" + std_logic_vector(to_unsigned(hand(6), 8));
   hand_ascii(7) <= X"20" when hand(7) = 0 else X"30" + std_logic_vector(to_unsigned(hand(7), 8));
   hand_ascii(8) <= X"20" when hand(8) = 0 else X"30" + std_logic_vector(to_unsigned(hand(8), 8));

	-- Process 1: Make reg_file according to my_idx
	-- e.g. my_idx is i then copy reg_buf_i to reg_file
	process(rst, clk)
	begin
		if rst = '0' then
			for i in 0 to 31 loop
				reg_file(i) <= X"20";
			end loop;
		elsif rising_edge(clk) then
			if my_idx = 0 then
				for i in 0 to 31 loop
					reg_file(i) <= reg_buf_0(i);
				end loop;
			elsif my_idx = 1 then
				for i in 0 to 22 loop
					reg_file(i) <= reg_buf_1(i);
				end loop;
				-- Represent cards
				reg_file(23) <= hand_ascii(0);
				reg_file(24) <= hand_ascii(1);
				reg_file(25) <= hand_ascii(2);
				reg_file(26) <= hand_ascii(3);
				reg_file(27) <= hand_ascii(4);
				reg_file(28) <= hand_ascii(5);
				reg_file(29) <= hand_ascii(6);
				reg_file(30) <= hand_ascii(7);
				reg_file(31) <= hand_ascii(8);
			elsif my_idx = 2 then
				for i in 0 to 31 loop
					reg_file(i) <= reg_buf_2(i);
				end loop;
			elsif my_idx = 3 then
				for i in 0 to 22 loop
					reg_file(i) <= reg_buf_3(i);
				end loop;
				-- Represent cards
				reg_file(23) <= hand_ascii(0);
				reg_file(24) <= hand_ascii(1);
				reg_file(25) <= hand_ascii(2);
				reg_file(26) <= hand_ascii(3);
				reg_file(27) <= hand_ascii(4);
				reg_file(28) <= hand_ascii(5);
				reg_file(29) <= hand_ascii(6);
				reg_file(30) <= hand_ascii(7);
				reg_file(31) <= hand_ascii(8);
			elsif my_idx = 4 then
				for i in 0 to 31 loop
					reg_file(i) <= reg_buf_4(i);
				end loop;
			elsif my_idx = 5 then
				for i in 0 to 31 loop
					reg_file(i) <= reg_buf_5(i);
				end loop;
			elsif my_idx = 6 then
				for i in 0 to 31 loop
					reg_file(i) <= reg_buf_6(i);
				end loop;
			elsif my_idx = 7 then
				for i in 0 to 31 loop
					reg_file(i) <= reg_buf_7(i);
				end loop;
			elsif my_idx = 8 then
				for i in 0 to 31 loop
					reg_file(i) <= reg_buf_8(i);
				end loop;
			elsif my_idx = 9 then
				for i in 0 to 31 loop
					reg_file(i) <= reg_buf_9(i);
				end loop;
				
				-- Represent sum of player's card
				if player_sum < 10 then	-- 0 ~ 9
               reg_file(18) <= X"30";
               reg_file(19) <= X"30" + std_logic_vector(to_unsigned(player_sum, 5));
            elsif player_sum < 20 then	-- 10 ~ 19
               reg_file(18) <= X"31";
               reg_file(19) <= X"30" + std_logic_vector(to_unsigned(player_sum - 10, 5));
            elsif player_sum < 30 then	-- 20 ~ 29
               reg_file(18) <= X"32";
               reg_file(19) <= X"30" + std_logic_vector(to_unsigned(player_sum - 20, 5));
				elsif player_sum < 40 then	-- 30 ~ 39
               reg_file(18) <= X"33";
               reg_file(19) <= X"30" + std_logic_vector(to_unsigned(player_sum - 30, 5));
				else	-- 40 ~
					reg_file(18) <= X"34";
               reg_file(19) <= X"30" + std_logic_vector(to_unsigned(player_sum - 40, 5));
            end if;
            
				-- Represent sum of dealer's card
            if dealer_sum < 10 then	-- 0 ~ 9
               reg_file(23) <= X"30";
               reg_file(24) <= X"30" + std_logic_vector(to_unsigned(dealer_sum, 5));
            elsif dealer_sum < 20 then	-- 10 ~ 19
               reg_file(23) <= X"31";
               reg_file(24) <= X"30" + std_logic_vector(to_unsigned(dealer_sum - 10, 5));
            elsif dealer_sum < 30 then	-- 20 ~ 29
               reg_file(23) <= X"32";
               reg_file(24) <= X"30" + std_logic_vector(to_unsigned(dealer_sum - 20, 5));
				elsif dealer_sum < 40 then	-- 30 ~ 39
               reg_file(23) <= X"33";
               reg_file(24) <= X"30" + std_logic_vector(to_unsigned(dealer_sum - 30, 5));
				else	-- 40 ~
					reg_file(23) <= X"34";
               reg_file(24) <= X"30" + std_logic_vector(to_unsigned(dealer_sum - 40, 5));
            end if;
            
				-- Represent winner
            if winner = 0 then      -- Dealer win
               reg_file(26) <= X"44";
            elsif winner = 1 then   -- Player win
               reg_file(26) <= X"50";
            end if;
				
			end if;
		end if;
	end process;
	
	-- Process 2: Set out ports which will be delivered to lcd_test
	process(rst, clk)
	begin
		if rst = '0' then
			cnt <= (others => '0');
			data_out <= '0';
		elsif rising_edge(clk) then
			if w_enable = '1' then
				data <= reg_file(conv_integer(cnt));
				addr <= cnt;
				data_out <= '1';
				if cnt = X"1F" then
					cnt <= (others => '0');
				else
					cnt <= cnt + 1;
				end if;
			else
				data_out <= '0';
			end if;
		end if;
	end process;

end Behavioral;

------------------LCD_TEST------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.storage.ALL;

entity lcd_test is
	port (
		rst: in STD_LOGIC;
		clk: in STD_LOGIC;
		data_out: in STD_LOGIC;
		addr: in STD_LOGIC_VECTOR (4 downto 0);
		data: in STD_LOGIC_VECTOR (7 downto 0);
		LCD_A: out STD_LOGIC_VECTOR (1 downto 0);
		LCD_EN: out STD_LOGIC;
		LCD_D: out STD_LOGIC_VECTOR (7 downto 0);
		w_enable: out STD_LOGIC );
end lcd_test;

architecture Behavioral of lcd_test is

signal load_100k, clk_100k, load_50, clk_50: STD_LOGIC;
signal cnt_100k: STD_LOGIC_VECTOR (7 downto 0);
signal cnt_50: STD_LOGIC_VECTOR (11 downto 0);
signal lcd_state, lcd_nstate, lcd_db: STD_LOGIC_VECTOR (7 downto 0);
signal reg_file: reg;
signal w_enable_reg: STD_LOGIC;

begin
	
	-- Process 1: Clock generator (100KHz)
	process(rst, clk, load_100k, cnt_100k)
	begin
		if rst = '0' then
			cnt_100k <= (others => '0');
			clk_100k <= '0';
		elsif rising_edge(clk) then
			if load_100k = '1' then
				cnt_100k <= (others => '0');
				clk_100k <= not clk_100k;
			else
				cnt_100k <= cnt_100k + 1;
			end if;
		end if;
	end process;
	
	load_100k <= '1' when (cnt_100k = X"13") else '0';
	
	-- Process 2: Clock generator (50Hz)
	process(rst, clk_100k, load_50, cnt_50)
	begin
		if rst = '0' then
			cnt_50 <= (others => '0');
			clk_50 <= '0';
		elsif rising_edge(clk_100k) then
			if load_50 = '1' then
				cnt_50 <= (others => '0');
				clk_50 <= not clk_50;
			else
				cnt_50 <= cnt_50 + 1;
			end if;
		end if;
	end process;
	
	load_50 <= '1' when (cnt_50 = X"3E7") else '0';
	
	-- Process 3: Assign lcd_state
	process(rst, clk_50)
	begin
		if rst = '0' then
			lcd_state <= (others =>'0');
		elsif rising_edge(clk_50) then
			lcd_state <= lcd_nstate;
		end if;
	end process;
	
	w_enable_reg <= '0' when lcd_state < X"06" else '1';
	
	-- Process 4: Assign reg_file
	process(rst, clk)
	begin
		if rst = '0' then
			for i in 0 to 31 loop
				reg_file(i) <= X"20";
			end loop;
		elsif clk'event and clk = '1' then
			if w_enable_reg = '1' and data_out = '1' then
				reg_file(conv_integer(addr)) <= data;
			end if;
		end if;
	end process;
	
	-- Process 5: Display LCD
	process(rst, lcd_state)
	begin
		if rst = '0' then
			lcd_nstate <= X"00";
		else
			case lcd_state is
				when X"00" => lcd_db <= "00111000" ; -- Function set
								lcd_nstate <= X"01" ;
				when X"01" => lcd_db <= "00001000" ; -- Display OFF
								lcd_nstate <= X"02" ;
				when X"02" => lcd_db <= "00000001" ; -- Display clear
								lcd_nstate <= X"03" ;
				when X"03" => lcd_db <= "00000110" ; -- Entry mode set
								lcd_nstate <= X"04" ;
				when X"04" => lcd_db <= "00001100" ; -- Display ON
								lcd_nstate <= X"05" ;
				when X"05" => lcd_db <= "00000011" ; -- Return Home
								lcd_nstate <= X"06" ;
				when X"06" => lcd_db <= reg_file(0) ;
								lcd_nstate <= X"07" ;
				when X"07" => lcd_db <= reg_file(1) ;
								lcd_nstate <= X"08" ;
				when X"08" => lcd_db <= reg_file(2) ;
								lcd_nstate <= X"09" ;
				when X"09" => lcd_db <= reg_file(3) ;
								lcd_nstate <= X"0A" ;
				when X"0A" => lcd_db <= reg_file(4) ;
								lcd_nstate <= X"0B" ;
				when X"0B" => lcd_db <= reg_file(5) ;
								lcd_nstate <= X"0C" ;
				when X"0C" => lcd_db <= reg_file(6) ;
								lcd_nstate <= X"0D" ;
				when X"0D" => lcd_db <= reg_file(7) ;
								lcd_nstate <= X"0E" ;
				when X"0E" => lcd_db <= reg_file(8) ;
								lcd_nstate <= X"0F" ;
				when X"0F" => lcd_db <= reg_file(9) ;
								lcd_nstate <= X"10" ;
				when X"10" => lcd_db <= reg_file(10) ;
								lcd_nstate <= X"11" ;
				when X"11" => lcd_db <= reg_file(11) ;
								lcd_nstate <= X"12" ;
				when X"12" => lcd_db <= reg_file(12) ;
								lcd_nstate <= X"13" ;
				when X"13" => lcd_db <= reg_file(13) ;
								lcd_nstate <= X"14" ;
				when X"14" => lcd_db <= reg_file(14) ;
								lcd_nstate <= X"15" ;
				when X"15" => lcd_db <= reg_file(15) ;
								lcd_nstate <= X"16" ;
				when X"16" => lcd_db <= X"C0" ; -- Change Line
								lcd_nstate <= X"17" ;
				when X"17" => lcd_db <= reg_file(16) ;
								lcd_nstate <= X"18" ;
				when X"18" => lcd_db <= reg_file(17) ;
								lcd_nstate <= X"19" ;
				when X"19" => lcd_db <= reg_file(18) ;
								lcd_nstate <= X"1A" ;
				when X"1A" => lcd_db <= reg_file(19) ;
								lcd_nstate <= X"1B" ;
				when X"1B" => lcd_db <= reg_file(20) ;
								lcd_nstate <= X"1C" ;
				when X"1C" => lcd_db <= reg_file(21) ;
								lcd_nstate <= X"1D" ;
				when X"1D" => lcd_db <= reg_file(22) ;
								lcd_nstate <= X"1E" ;
				when X"1E" => lcd_db <= reg_file(23) ;
							lcd_nstate <= X"1F" ;
				when X"1F" => lcd_db <= reg_file(24) ;
							lcd_nstate <= X"20" ;
				when X"20" => lcd_db <= reg_file(25) ;
								lcd_nstate <= X"21" ;
				when X"21" => lcd_db <= reg_file(26) ;
								lcd_nstate <= X"22" ;
				when X"22" => lcd_db <= reg_file(27) ;
								lcd_nstate <= X"23" ;
				when X"23" => lcd_db <= reg_file(28) ;
								lcd_nstate <= X"24" ;
				when X"24" => lcd_db <= reg_file(29) ;
								lcd_nstate <= X"25" ;
				when X"25" => lcd_db <= reg_file(30) ;
								lcd_nstate <= X"26" ;
				when X"26" => lcd_db <= reg_file(31) ;
								lcd_nstate <= X"05" ; -- return home
				when others => lcd_db <= (others => '0') ;
			end case;
		end if;
	end process;
	
	-- Set out ports
	LCD_A(1) <= '0';
	LCD_A(0) <= '0' when (lcd_state >= X"00" and lcd_state < X"06") or
		(lcd_state = X"16") else '1';
	LCD_EN <= clk_50;

	LCD_D <= lcd_db;
	w_enable <= w_enable_reg;
	

end Behavioral;


-------------------PLAYER-------------------

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
		load_random: in std_logic;
		s1_clk, s2_clk, s4_clk: in std_logic;
		sen_idx: out integer;
		hand: out int_arr;
		ncard: out integer;
		playersum: out integer;
		dealersum: out integer;
		id: out integer;	-- 0 for Dealer, 1 for Player
		winner: out integer;	-- 0 for Dealer, 1 for Player
		clk_14s_sec: out std_logic );
end player;

architecture Behavioral of player is

signal make_random: std_logic := '1';
signal rand_data, rand_data_d: integer := 0;
signal init_set: std_logic := '0';
signal card, card_d: int_arr;
signal my_hand: int_arr := (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
signal cur_idx, cur_idx_d: integer := 0;
signal cardsum, cardsum_d: integer := 0;
signal cardnum: integer := 0;
signal limit: std_logic := '1';
signal change_sen_idx, change_sen_idx2, change_sen_idx0, change_sen_idx4, m_sen_idx: integer := 0;
signal turn, turn1, turn2, turn4: std_logic := '1';
signal fin, fin1, fin2, fin4: std_logic := '0';
signal fin3, fin5: std_logic := '1';
signal s14_clk: std_logic;
signal my_id: integer := 1;
signal timeout: std_logic := '0';
signal randrand: integer := 0;

begin

	-- Set out ports
	sen_idx <= m_sen_idx;
	hand <= my_hand;
	ncard <= cardnum;
	id <= my_id;
	clk_14s_sec <= limit;
	playersum <= cardsum;
	dealersum <= cardsum_d;
	
	-- Process 1: Increase randrand while load_random is '0'
	process(clk)
	begin
		if rising_edge(clk) then
			if load_random = '1' then
				randrand <= randrand + 1;
			end if;
		end if;
	end process;

	-- Process 2: Make random data
	process(clk)
	begin
		if rising_edge(clk) then
			if make_random = '1' then
				rand_data <= 13 * randrand * rand_data + 3;
				rand_data_d <= 17 * randrand * rand_data_d + 7;
			end if;
		end if;
	end process;
	
	-- Process 3: Game is in progress
	process(clk, turn, init_set, load_stay, load_hit, fin)
		variable idx: integer := 0;
		variable clk_delay: std_logic :='0';					-- clock for showing certain sentences on display for 5sec
		variable count_clk: integer range 0 to 20000000;	-- count for clk_delay
		variable clk_delay2: std_logic :='0';					-- clock for showing certain sentences on display for 2.5sec
		variable clk_delay2_tmp: std_logic :='1';				-- assist clk_delay2, 1: delay, 0: pass
		variable count_clk2 : integer range 0 to 10000000;	-- count for clk_delay2
		variable cardsum_tmp: integer := 0;
	begin
		if rising_edge(clk) then
			-- Make random card decks of player and dealer using Process 1 and 2
			-- Range of random value is [1, 8]
			if turn = '1' and init_set  = '0' and idx < 15 and clk_delay = '1' then
				make_random <= '0';
				card(idx) <= rand_data mod 8 + 1;
				card_d(idx) <= rand_data_d mod 8 + 1;
				idx := idx + 1;
				make_random <= '1';
			
			-- Initial cards draw after making card decks
			-- Player draws 2 cards and dealer draws 1 card initially
			elsif turn = '1' and init_set = '0' and idx = 15 then
				my_hand(0) <= card(3);	-- 1st card for player
				my_hand(1) <= card(4);	-- 2nd card for player
				cardsum <= card(3) + card(4);	-- Sum of two cards
				cur_idx <= 5;				-- Idx of player's next card
				cardnum <= 2;				-- Current # of cards
				
				cardsum_d <= card_d(3);	-- Sum of one card for dealer
				cur_idx_d <= 4;			-- Idx of dealer's next card
				
				idx := idx + 1;			-- Not to enter this elsif again
				init_set <= '1';			-- Mark initial card draw is done
				limit <= '1';
			
			-- Get button input when player's turn is in progress and
			-- initial card draw is done
			elsif turn = '1' and init_set = '1' and clk_delay = '0' then
				limit <= '0';
				
				-- When 'Stay' button is pushed
				if load_stay = '0' then
					change_sen_idx <= 2;	-- Mark that it's time to change sen_idx to 2
					turn1 <= '0';	-- Player's turn is done
					fin1 <= '1';	-- Dealer's turn has to be started
					clk_delay := '1';
					count_clk := 0;
					count_clk2 := 0;
					clk_delay2 := '1';
					limit <= '1';
					
				-- When 'Hit' button is pushed
				elsif load_hit = '0' then
					my_hand(cardnum) <= card(cur_idx);	-- Get next card
					cardsum <= cardsum + card(cur_idx);	-- Calculate cardsum again
					if cardnum < 15 then
						cardnum <= cardnum + 1;	-- Accumulate cardnum by 1
					end if;
					if cur_idx < 15 then
						cur_idx <= cur_idx + 1;	-- Increase cur_idx by 1
					end if;
					clk_delay := '1';
					count_clk := 0;
					count_clk2 := 0;
					clk_delay2 := '1';
					limit <= '1';
					
					-- Check if player got bursted
					if cardsum <= 21 then	-- 'Hit' but NOT bursted
						change_sen_idx <= 3;	-- Mark that it's time to change sen_idx to 3
					end if;
				end if;
			
			-- Go on dealer's turn when player's turn is done and
			-- signal fin marked that dealer's turn can be started
			elsif turn = '0' and fin = '1' and clk_delay2 = '0' then
				my_id <= 0;		-- Dealer's ID is 0
				
				if clk_delay2_tmp = '1' then
					clk_delay2 := '1';
				end if;
				count_clk2 := 0;
				
				-- Dealer select 'Hit' automatically when current sum is
				-- same or lower than 16
				if cardsum_d <= 16 then
					--
					if clk_delay2_tmp = '1' then
						cardsum_tmp := cardsum_d + card_d(cur_idx_d);	-- Calculate cardsum_d again
						if cur_idx_d < 15 then
							cur_idx_d <= cur_idx_d + 1;	-- Increase cur_idx_d by 1
						end if;
					end if;
					clk_delay2_tmp := '0';
					
					change_sen_idx <= 7;	-- Mark that it's time to change sen_idx to 7
					
					if clk_delay2 = '0' then
						cardsum_d <= cardsum_tmp;
						clk_delay2_tmp := '1';
					end if;
					
					if cardsum_d <= 16 then
						clk_delay2 := '1';
					else
						clk_delay2 := '0';
					end if;
					
				-- Dealer select 'Stay' automatically when current sum is
				-- bigger than 16
				else
					change_sen_idx <= 6;	-- Mark that it's time to change sen_idx to 6
					clk_delay2_tmp := '0';
					if clk_delay2 = '0' then	-- Go to Game over
						clk_delay2 := '1';
						fin3 <= '0';
					end if;
				end if;
			
			-- Game over since player's turn and dealer's turn are both done
			elsif turn = '0' and fin = '0' and clk_delay2 = '0' then
				change_sen_idx <= 9;	-- Mark that it's time to change sen_idx to 9
				
				-- Determine winner (0 for dealer and 1 for player)
				-- 1) Player got bursted
				if cardsum > 21 then
					winner <= 0;		-- Dealer win

				-- 2) Player got not bursted
				else
					-- 2-1) Dealer got bursted
					if cardsum_d > 21 then
						winner <= 1;	-- Player win
					-- 2-2) Dealer got not bursted and
					-- cardsum is bigger than cardsum_d
					elsif cardsum > cardsum_d then
						winner <= 1;	-- Player win
					-- 2-3) Dealer got not bursted and
					-- cardsum_d is same or bigger than cardsum
					else
						winner <= 0;	-- Dealer win
					end if;
				end if;
			end if;
			
			-- make counting clock for showing certain sentences for 5 sec
			-- clk_delay is rising evey 5 sec
			if count_clk < 20000000 then
               count_clk:= count_clk + 1;		-- count
         else
               clk_delay := not clk_delay;	-- flip
               count_clk:= 0; -- recount
         end if;
			
			-- make counting clock for showing certain sentences for 2.5 sec
			-- clk_delay2 is rising evey 2.5 sec
			if count_clk2 < 10000000 then
               count_clk2:= count_clk2 + 1;		-- count
         else
               clk_delay2 := not clk_delay2;		-- flip
               count_clk2:= 0; -- recount
         end if;
		end if;
	end process;
	
	-- Process 4: 14s Timer (Reset timer when limit is '1')
	process(rst, s1_clk, limit)
			variable cnt_14s : integer range 0 to 7;
	begin
			if rst = '0' or limit = '1' then -- Reset
					s14_clk <= '1';
					cnt_14s := 0;

			elsif s1_clk'event and s1_clk = '1' then -- In every 1s
					if cnt_14s < 7 then
							cnt_14s := cnt_14s + 1;
					else
							s14_clk <= not s14_clk; -- Flip after 7s
							cnt_14s := 0;
					end if;
			end if;
	end process;
	
	-- Process 5: 14s Timeout in player's turn
	process(rst, s14_clk)
	begin
		if rising_edge(s14_clk) then
			if limit = '0' then
				change_sen_idx2 <= 5;
				timeout <= '1';
			end if;
		end if;
	end process;
	
	-- Process 6:
	process(rst, clk)		
		variable count_clk : integer range 0 to 10000000;
		variable cnt: std_logic := '0';
		variable cnt_tmp: std_logic := '0';
	begin
		if rising_edge(clk) then
			if timeout = '1' and cnt = '0' then
				if cnt_tmp = '0' then
					cnt := '1';
					count_clk := 0;
					cnt_tmp := '1';
				else
					fin2 <= '1';
					turn2 <= '0';
				end if;
			end if;
			
			if count_clk < 10000000 then -- 10000000
				count_clk:= count_clk + 1;
			else
				cnt := not cnt;
				count_clk:= 0; -- recount
			end if;
		end if;
	end process;
	
	-- Process 7: Control timing to display LCD
	-- when player of dealer got bursted
	process(clk)
      variable count_clk : integer range 0 to 10000000;
      variable cnt: std_logic :='0';
      variable cnt_tmp: std_logic := '0';
   begin
      if rising_edge(clk) then
         -- Player got bursted when player's turn is in progress,
			-- initial card draw is done and cardsum is bigger than 21
         if turn = '1' and init_set = '1' then
            if cardsum > 21 then
               change_sen_idx4 <= 4;	-- Mark it's time to change sen_idx to 4
               if fin4 = '0' then
                  count_clk := 0;
                  cnt := '0';
               end if;
               fin4 <= '1';
               if cnt='1' then
                  turn4 <= '0';
               end if;
            end if;
				
         -- Dealer got bursted when dealer's turn is in progress,
			-- signal fin marked that dealer's turn can be started and
			-- cardsum_d is bigger than 21
         elsif turn = '0' and fin = '1' then
            if cardsum_d > 21 then
               change_sen_idx4 <= 8;	-- Mark it's time to change sen_idx to 8
               if cnt_tmp = '0' then
                  cnt := '1';
                  cnt_tmp := '1';
               end if;
               if cnt = '0' then
                  fin5 <= '0';
               end if;
            end if;
         end if;
         
         if count_clk < 10000000 then -- 10000000
               count_clk:= count_clk + 1;
         else -- clk_1s rising/desending
               cnt := not cnt;
               count_clk:= 0; -- recount
         end if;
         
      end if;
   end process;
	
	-- Process 8: Change fin and turn by their families
	-- There are fin and turn families to change fin and turn
	-- in several processes and this is violated by VHDL syntax
	process(clk)
	begin
		if rising_edge(clk) then
			if fin1 = '1' then
				fin <= '1';
			end if;
			if fin2 = '1' then
				fin <= '1';
			end if;
			if fin4 = '1' then
				fin <= '1';
			end if;
			if fin3 = '0' then
				fin <= '0';
			end if;
			if turn1 = '0' or turn2 = '0' then
				turn <= '0';
			end if;
			if fin5 = '0' then
				fin <= '0';
			end if;
			if turn4 = '0' then
				turn <= '0';
			end if;
		end if;
	end process;
	
	-- Process 9: Send signal to change sen_idx
	-- for first two sentences (Each sentence is displayed for 4 sec)
   process(s4_clk)
   begin
      if rising_edge(s4_clk) then
         if cardnum = 2 and m_sen_idx = 0 then
            change_sen_idx0 <= 1;
         end if;
      end if;
   end process;
   
	-- Process 10: Change m_sen_idx by their familes
	-- There are change_sen_idx family to change m_sen_idx
	-- in several processes and this is violated by VHDL syntax
   process(clk)
   begin
      if rising_edge(clk) then
         if change_sen_idx0 = 1 then
            m_sen_idx <= 1;	-- "Stay or hit? / Cards: "
         end if;
         
         if change_sen_idx = 2 then
            m_sen_idx <= 2;	-- "You chose stay / Turn to dealer"
         elsif change_sen_idx = 3 then
            m_sen_idx <= 3;	-- "You chose hit / Cards: "
			end if;
			
         if change_sen_idx4 = 4 then
            m_sen_idx <= 4;	-- "You chose hit / But bursted..."
			end if;
			
			if change_sen_idx2 = 5 then
            m_sen_idx <= 5;	-- "14sec is over / Turn to dealer"
         end if;
			
         if change_sen_idx = 6 then
            m_sen_idx <= 6;	-- "Dealer's turn / Sum>=17 so stay"
         elsif change_sen_idx = 7 then
            m_sen_idx <= 7;	-- "Dealer's turn / Sum<17 so hit"
			end if;
         if change_sen_idx4 = 8 then
            m_sen_idx <= 8;	-- "Dealer's turn / But bursted..."
			end if;
			
         if change_sen_idx = 9 then
            m_sen_idx <= 9;	-- "Game over / P:00 D:00 P win"
         end if;
      end if;
   end process;

end Behavioral;

--------------DISPLAY_SEGMENT---------------

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
			  psum : in integer;
			  dsum : in integer;
			  limit : in std_logic;
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

signal sum10, sum01 : std_logic_vector( 3 downto 0 );				-- current sum of cards of player/dealer
signal id10 : std_logic_vector( 3 downto 0 );						-- 1: player, 0: dealer
signal sec10_cnt, sec01_cnt : std_logic_vector( 3 downto 0 );	-- count seconds
signal sel : std_logic_vector( 2 downto 0 );							-- 7 segment select, select DIGIT
signal data : std_logic_vector( 3 downto 0 ); 						-- display value
signal seg : std_logic_vector( 7 downto 0 ); 						-- 7 segment display
signal myid : integer;														-- 1: player, 0: dealer
signal mypsum, mydsum : integer;											-- current sum of cards of player/dealer
signal tmp : std_logic_vector(4 downto 0);							-- save value of mypsum/mydsum

begin

	myid <= ID;				-- get ID of current user(player or dealer)
	mypsum <= psum;		-- get current sum of cards of player
	mydsum <= dsum;		-- get current sum of cards of dealer
	
	
	-- Process 1: determine LED display digit by sel value
	process(sel)
	begin
			case sel is
					when "000" => DIGIT <= "000001"; -- id of current user(1: player, 0: dealer)
							data <= id10;
					when "010" => DIGIT <= "000100"; -- current sum of cards of current user(tens)
							data <= sum10;
					when "011" => DIGIT <= "001000"; -- current sum of cards of current user(units)
							data <= sum01;
					when "100" => DIGIT <= "010000"; -- second(tens)
							data <= sec10_cnt;
					when "101" => DIGIT <= "100000"; -- second(units)
							data <= sec01_cnt;
					when others => null;
			end case;
	end process;
	
	
	-- Process 2: determine sel value, display time every 50us on 7 segment
	process(rst_n, clk)
			variable seg_clk_cnt: integer range 0 to 200; -- determine sweep time(4MHz clk * 200 = 50us period)
	begin
			if(rst_n = '0') then									 -- reset
					sel <= "000";
					seg_clk_cnt:= 0;
			elsif(clk'event and clk='1') then				 -- when clock is rising
					if(seg_clk_cnt = 200) then 				 -- change sel value
							seg_clk_cnt:= 0;						 -- recount seg_clk_cnt
							if(sel = "101") then					 -- recount sel
									sel <= "000";
							else										 -- count sel
									sel <= sel + 1;
							end if;
					else
							seg_clk_cnt:= seg_clk_cnt+1; 		 -- count seg_clk_cnt
					end if;
			end if;
	end process;
	
	
	-- Process3: determine seg value by data value
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
	
	-- Process4: count seconds by rst_n, s1_clk rising
	process(CLK_1s, rst_n, limit)
			variable s10_cnt, s01_cnt : STD_LOGIC_VECTOR ( 3 downto 0); -- count for second(tens, units)
	begin
			if(rst_n = '0' or limit = '1') then 						-- reset to --:--:00
					s01_cnt:= "0000";
					s10_cnt:= "0000";
					
			elsif(CLK_1s = '1' and CLK_1s'event) then 				-- when CLK_1s is rising
					s01_cnt:= s01_cnt + 1; 									-- increase second(units)
					if(s01_cnt > "1001") then 								-- when s01_cnt = 10, recount and increase s10_cnt
							s01_cnt:= "0000"; 								-- recount
							s10_cnt:= s10_cnt + 1; 							-- increase s10_cnt
					end if;
					if(s10_cnt = "0001" and s01_cnt > "0100") then 	-- when --:--:14, go back to --:--:00
							s10_cnt:= "0000";
							s01_cnt:= "0000";
					end if;
			end if;
			
			sec01_cnt <= s01_cnt;
			sec10_cnt <= s10_cnt;
			
	end process;
	
	-- Process5: transform inputs id and sum to display
	process(clk, rst_n)
			variable sum01_cnt, sum10_cnt : STD_LOGIC_VECTOR(3 downto 0); -- count for sum(tens, units)
			variable id_cnt : std_logic_vector(3 downto 0); 	-- count for id
	begin
			if(rst_n = '0') then		-- reset
					id10 <= "0000";
					sum01 <= "0000";
					sum10 <= "0000";
			elsif(clk = '1' and clk'event) then						-- when clk is rising
				if myid = 1 then											-- player
						id_cnt:= "0001";
						tmp <= std_logic_vector(to_unsigned(mypsum, 5));	-- change mypsum(integer) to tmp(std_logic_vector)
				else 															-- dealer
						id_cnt:= "0000";
						tmp <= std_logic_vector(to_unsigned(mydsum, 5));	-- change mydsum(integer) to tmp(std_logic_vector)
				end if;
				
				if tmp < "01010" then					-- when mypsum/mydsum is 0s
						sum10_cnt:= "0000";
						sum01_cnt:= tmp(3 downto 0);
				elsif tmp < "10100" then				-- when mypsum/mydsum is 10s
						sum10_cnt:= "0001";
						sum01_cnt:= tmp - "01010";
				elsif tmp < "11110" then				-- when mypsum/mydsum is 20s
						sum10_cnt:= "0010";
						sum01_cnt:= tmp - "10100";
				elsif tmp <= "11111" then				-- when mypsum/mydsum is 30s
						sum10_cnt:= "0011";
						sum01_cnt:= tmp - "11110";
				end if;
				
				id10 <= id_cnt;
				sum01 <= sum01_cnt;
				sum10 <= sum10_cnt;
			end if;
	end process;

end Behavioral;



--------------------MAIN--------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.storage.ALL;


entity main is
	port (
		rst: in std_logic;
		clk: in std_logic;
		load_stay: in std_logic;
		load_hit: in std_logic;
		load_random: in std_logic;
		LCD_A: out std_logic_vector (1 downto 0);
		LCD_EN: out std_logic;
		LCD_D: out std_logic_vector (7 downto 0);
		DIGIT : out  STD_LOGIC_VECTOR (6 downto 1);
		SEG_A : out  STD_LOGIC;
		SEG_B : out  STD_LOGIC;
		SEG_C : out  STD_LOGIC;
		SEG_D : out  STD_LOGIC;
		SEG_E : out  STD_LOGIC;
		SEG_F : out  STD_LOGIC;
		SEG_G : out  STD_LOGIC;
		SEG_DP : out  STD_LOGIC	);
end main;

architecture Behavioral of main is

component player is
	port (
		rst: in std_logic;
		clk: in std_logic;
		load_stay: in std_logic;
		load_hit: in std_logic;
		load_random: in std_logic;
		s1_clk, s2_clk, s4_clk: in std_logic;
		sen_idx: out integer;
		hand: out int_arr;
		ncard: out integer;
		playersum: out integer;
		dealersum: out integer;
		id: out integer;	-- 0 for Dealer, 1 for Player
		winner: out integer;	-- 0 for Dealer, 1 for Player
		clk_14s_sec: out std_logic );
end component;

component data_gen is
	port (
		rst: in std_logic;
		clk: in std_logic;
		idx: in integer;
		hand: in int_arr;
		player_sum: in integer;
		dealer_sum: in integer;
		winner: in integer;
		w_enable: in std_logic;
		data_out: out std_logic;
		addr: out std_logic_vector (4 downto 0);
		data: out std_logic_vector (7 downto 0) );
end component;

component lcd_test is
	port (
		rst: in STD_LOGIC;
		clk: in STD_LOGIC;
		data_out: in STD_LOGIC;
		addr: in STD_LOGIC_VECTOR (4 downto 0);
		data: in STD_LOGIC_VECTOR (7 downto 0);
		LCD_A: out STD_LOGIC_VECTOR (1 downto 0);
		LCD_EN: out STD_LOGIC;
		LCD_D: out STD_LOGIC_VECTOR (7 downto 0);
		w_enable: out STD_LOGIC );
end component;

component display_segment is
	port(
	rst_n : in  STD_LOGIC;
   clk : in  STD_LOGIC; -- 4MHz FPGA oscilator
   CLK_1s : in STD_LOGIC;
   ID : in integer;
	psum : in integer;
	dsum : in integer;
	limit : in std_logic;	
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

signal s1_clk, s2_clk, s4_clk: std_logic;
signal my_sen_idx, my_ncard, my_id, my_winner: integer;
signal my_hand: int_arr;
signal my_clk_14s_sec: std_logic;

signal data_out_reg, w_enable_reg : std_logic;
signal addr_reg : std_logic_vector(4 downto 0);
signal data_reg : std_logic_vector(7 downto 0);

signal fin1: std_logic;
signal sum1 : integer;
signal limitt1 : std_logic;
signal seg_digit : std_logic_vector(6 downto 1);
signal a, b, c, d, e, f, g, dp  : std_logic;
signal id : integer := 1;
signal my_playersum, my_dealersum : integer :=0;
signal my_totalsum : integer :=0;

begin

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
	
	-- Instantiations
	my_player: player port map (rst, clk, load_stay, load_hit, load_random, s1_clk, s2_clk, s4_clk,
		my_sen_idx, my_hand, my_ncard, my_playersum, my_dealersum, my_id, my_winner, my_clk_14s_sec);
		 
	my_data_gen: data_gen port map(rst, clk, my_sen_idx, my_hand, my_playersum, my_dealersum, my_winner, w_enable_reg,
		data_out_reg, addr_reg, data_reg);
		
	my_lcd_test: lcd_test port map(rst, clk, data_out_reg, addr_reg,
		data_reg, LCD_A, LCD_EN, LCD_D, w_enable_reg);
		
	my_seg: display_segment port map(rst, clk, s1_clk, id, my_playersum, my_dealersum, my_clk_14s_sec, seg_digit, a, b, c, d, e, f, g, dp);	
	
	id <= my_id;
	
	-- Set out ports
	DIGIT<=seg_digit;
	SEG_A<=a;
	SEG_B<=b;
	SEG_C<=c;
	SEG_D<=d;
	SEG_E<=e;
	SEG_F<=f;
	SEG_G<=g;
	SEG_DP<=dp;

end Behavioral;