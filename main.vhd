-------------DATA_GEN-------------

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
		w_enable: in std_logic;
		data_out: out std_logic;
		addr: out std_logic_vector (4 downto 0);
		data: out std_logic_vector (7 downto 0) );
end data_gen;

architecture Behavioral of data_gen is

signal reg_file: reg;

signal cnt : std_logic_vector(4 downto 0);
signal my_idx: integer;
signal hand_ascii: reg :=
	(X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20",
	 X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20");

begin

	my_idx <= idx;
	
	hand_ascii(0) <= X"30" + std_logic_vector(to_unsigned(hand(0), 8));
	hand_ascii(1) <= X"30" + std_logic_vector(to_unsigned(hand(1), 8));
	hand_ascii(2) <= X"30" + std_logic_vector(to_unsigned(hand(2), 8));
	hand_ascii(3) <= X"30" + std_logic_vector(to_unsigned(hand(3), 8));
	hand_ascii(4) <= X"30" + std_logic_vector(to_unsigned(hand(4), 8));
	hand_ascii(5) <= X"30" + std_logic_vector(to_unsigned(hand(5), 8));
	hand_ascii(6) <= X"30" + std_logic_vector(to_unsigned(hand(6), 8));
	hand_ascii(7) <= X"30" + std_logic_vector(to_unsigned(hand(7), 8));
	hand_ascii(8) <= X"30" + std_logic_vector(to_unsigned(hand(8), 8));

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
				for i in 0 to 31 loop
					reg_file(i) <= reg_buf_1(i);
				end loop;
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
				for i in 0 to 31 loop
					reg_file(i) <= reg_buf_3(i);
				end loop;
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
			end if;
		end if;
	end process;
	
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

-------------LCD_TEST-------------

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
	
	-- 1. Clock generator (100KHz)
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
	
	-- 2. Clock generator (50Hz)
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
	
	-- 3. Assign lcd_state
	process(rst, clk_50)
	begin
		if rst = '0' then
			lcd_state <= (others =>'0');
		elsif rising_edge(clk_50) then
			lcd_state <= lcd_nstate;
		end if;
	end process;
	
	w_enable_reg <= '0' when lcd_state < X"06" else '1';
	
	-- 4. Assign reg_file
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
	
	-- 5. Display LCD
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
	
	LCD_A(1) <= '0';
	LCD_A(0) <= '0' when (lcd_state >= X"00" and lcd_state < X"06") or
		(lcd_state = X"16") else '1';
	LCD_EN <= clk_50;

	LCD_D <= lcd_db;
	w_enable <= w_enable_reg;
	

end Behavioral;


-----------------------------------------------------------------------

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
					if cardnum < 15 then
						cardnum <= cardnum + 1;
					end if;
					if cur_idx < 15 then
						cur_idx <= cur_idx + 1;
					end if;
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
			elsif turn = '0' and fin = '1' and cnt = '0' then
				my_id <= 0;
				if cardsum_d <= 16 then -- hit
					cnt := '1';
					cardsum_d <= cardsum_d + card_d(cur_idx_d);
					if cur_idx_d < 15 then
						cur_idx_d <= cur_idx_d + 1;
					end if;
					
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
			
			if count_clk < 5000000 then -- 5000000
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
		LCD_D: out std_logic_vector (7 downto 0) );
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

component data_gen is
	port (
		rst: in std_logic;
		clk: in std_logic;
		idx: in integer;
		hand: in int_arr;
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

signal s1_clk, s2_clk, s4_clk: std_logic;
signal my_sen_idx, my_ncard, my_id, my_winner: integer;
signal my_hand: int_arr;
signal my_clk_14s_sec: std_logic;

signal data_out_reg, w_enable_reg : std_logic;
signal addr_reg : std_logic_vector(4 downto 0);
signal data_reg : std_logic_vector(7 downto 0);

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
	
	my_player: player port map (rst, clk, load_stay, load_hit, s1_clk, s2_clk, s4_clk,
		my_sen_idx, my_hand, my_ncard, my_id, my_winner, my_clk_14s_sec);
	my_data_gen: data_gen port map(rst, clk, my_sen_idx, my_hand, w_enable_reg,
		data_out_reg, addr_reg, data_reg);
	my_lcd_test: lcd_test port map(rst, clk, data_out_reg, addr_reg,
		data_reg, LCD_A, LCD_EN, LCD_D, w_enable_reg);

end Behavioral;

