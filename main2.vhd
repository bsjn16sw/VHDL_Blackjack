    
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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

type reg_2d is array( 0 to 31 ) of std_logic_vector( 7 downto 0 );
signal load_100k, clk_100k, load_50, clk_50: STD_LOGIC;
signal cnt_100k: STD_LOGIC_VECTOR (7 downto 0);
signal cnt_50: STD_LOGIC_VECTOR (11 downto 0);
signal lcd_state, lcd_nstate, lcd_db: STD_LOGIC_VECTOR (7 downto 0);
signal reg_file: reg_2d;
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

---------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity data_gen is
	port (
		rst: in std_logic;
		clk: in std_logic;
		idx: in integer;
		w_enable: in std_logic;
		data_out: out std_logic;
		addr: out std_logic_vector (4 downto 0);
		data: out std_logic_vector (7 downto 0) );
end data_gen;

architecture Behavioral of data_gen is

type reg is array (0 to 31) of std_logic_vector (7 downto 0);
signal reg_file: reg;

constant reg_buf_0: reg :=
	(X"50", X"31", X"27", X"73", X"20", X"74", X"75", X"72", X"6E", X"20", X"20", X"20", X"20", X"20", X"20", X"20",	-- P1's turn
	 X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20");
constant reg_buf_1: reg :=
	(X"53", X"74", X"61", X"79", X"20", X"6F", X"72", X"20", X"48", X"69", X"74", X"3F", X"20", X"20", X"20", X"20",	-- Stay or hit?
	 X"43", X"61", X"72", X"64", X"3A", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20");	-- Cards:
constant reg_buf_2: reg :=
	(X"59", X"6F", X"75", X"20", X"63", X"68", X"6F", X"73", X"65", X"20", X"68", X"69", X"74", X"20", X"20", X"20",	-- You chose hit
	 X"43", X"61", X"72", X"64", X"3A", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20");	-- Cards:
constant reg_buf_3: reg :=
	(X"59", X"6F", X"75", X"20", X"63", X"68", X"6F", X"73", X"65", X"20", X"68", X"69", X"74", X"20", X"20", X"20",	-- You chose hit
	 X"42", X"75", X"74", X"20", X"62", X"75", X"72", X"73", X"74", X"65", X"64", X"2E", X"2E", X"2E", X"20", X"20");	-- But bursted...
constant reg_buf_4: reg :=
	(X"59", X"6F", X"75", X"20", X"63", X"68", X"6F", X"73", X"65", X"20", X"73", X"74", X"61", X"79", X"20", X"20",	-- You chose stay
	 X"50", X"31", X"27", X"73", X"20", X"74", X"75", X"72", X"6E", X"20", X"6E", X"6F", X"77", X"20", X"20", X"20");	-- P1's turn now
constant reg_buf_5: reg :=
	(X"31", X"35", X"73", X"65", X"63", X"20", X"69", X"73", X"20", X"6F", X"76", X"65", X"72", X"20", X"20", X"20",	-- 15sec is over
	 X"50", X"31", X"27", X"73", X"20", X"74", X"75", X"72", X"6E", X"20", X"6E", X"6F", X"77", X"20", X"20", X"20");	-- P1's turn now
constant reg_buf_6: reg :=
	(X"44", X"65", X"61", X"6C", X"65", X"72", X"27", X"73", X"20", X"74", X"75", X"72", X"6E", X"20", X"20", X"20",	-- Dealer's turn
	 X"53", X"75", X"6D", X"3C", X"31", X"37", X"20", X"73", X"6F", X"20", X"68", X"69", X"74", X"20", X"20", X"20");	-- Sum<17 so hit
constant reg_buf_7: reg :=
	(X"44", X"65", X"61", X"6C", X"65", X"72", X"27", X"73", X"20", X"74", X"75", X"72", X"6E", X"20", X"20", X"20",	-- Dealer's turn
	 X"53", X"75", X"6D", X"3E", X"3D", X"31", X"37", X"20", X"73", X"6F", X"20", X"73", X"74", X"61", X"79", X"20");	-- Sum>=17 so stay
constant reg_buf_8: reg :=
	(X"52", X"6F", X"75", X"6E", X"64", X"31", X"20", X"69", X"73", X"20", X"6F", X"76", X"65", X"72", X"20", X"20",	-- Round1 is over
	 X"50", X"31", X"20", X"77", X"69", X"6E", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20");	-- P1 win
constant reg_buf_9: reg :=
	(X"47", X"61", X"6D", X"65", X"20", X"6F", X"76", X"65", X"72", X"20", X"20", X"20", X"20", X"20", X"20", X"20",	-- Game over
	 X"50", X"31", X"20", X"66", X"69", X"6E", X"61", X"6C", X"6C", X"79", X"20", X"77", X"69", X"6E", X"20", X"20");	-- P1 finally win
constant reg_buf_10: reg :=
	(X"50", X"31", X"27", X"73", X"20", X"73", X"63", X"6F", X"72", X"65", X"3A", X"20", X"20", X"20", X"20", X"20",	-- P1's score:
	 X"4D", X"61", X"67", X"69", X"63", X"20", X"73", X"63", X"6F", X"72", X"65", X"3A", X"20", X"20", X"20", X"20");	-- Magic score:

signal cnt : std_logic_vector(4 downto 0);
signal my_idx: integer;

begin

	my_idx <= idx;

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
			elsif my_idx = 2 then
				for i in 0 to 31 loop
					reg_file(i) <= reg_buf_2(i);
				end loop;
			elsif my_idx = 3 then
				for i in 0 to 31 loop
					reg_file(i) <= reg_buf_3(i);
				end loop;
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
			elsif my_idx = 10 then
				for i in 0 to 31 loop
					reg_file(i) <= reg_buf_10(i);
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


----------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;

entity player is
	port (
		rst: in std_logic;
		clk: in std_logic;
		num: in integer;			-- player num
		load_stay: in std_logic;
		load_hit: in std_logic;
		start: in std_logic;
		fin: out std_logic;		-- let next player start (to next player)
		sen_idx: out integer;	-- sentence idx (to data_gen)
		pnum: out integer;		-- player num (to 7seg)
		csum: out integer;		-- card sum (to 7seg)
		stime: out std_logic );	-- start timing (to 7seg)
end player;

architecture Behavioral of player is

signal my_start: std_logic;
signal turn: std_logic := '1';
signal make_random: std_logic := '1';
signal init_set: std_logic := '0';
signal change_sen_idx: integer := 0;

signal s1_clk, s2_clk, s4_clk: std_logic;

signal rand_data: integer := 0;
type int_arr is array (0 to 15) of integer;
signal card: int_arr;
signal cur_idx: integer;
signal cardsum: integer := 0;
signal cardnum: integer := 0;
signal my_sen_idx: integer := 0;

begin

	my_start <= start;
	sen_idx <= my_sen_idx;
	pnum <= num;
	csum <= cardsum;
--	stime <= 

	-- Make random data
	process(clk)
	begin
		if rising_edge(clk) then
			if make_random = '1' then
				rand_data <= 13 * rand_data + 1;
			end if;
		end if;
	end process;
	
	process(clk)
		variable idx: integer := 0;
	begin
		if rising_edge(clk) then
			if my_start = '1' and turn = '1' and idx < 15 then
				make_random <= '0';
				card(idx) <= rand_data mod 16 + 1;
				idx := idx + 1;
				make_random <= '1';
			end if;
			
			if idx = 15 then
				init_set <= '1';
				cur_idx <= 5;
				cardsum <= card(3) + card(4);
				cardnum <= 2;
				idx := idx + 1; -- not to take this if statement
			end if;
			
			if my_start = '1' and turn = '1' and init_set = '1' then
				if load_stay = '0' then
					change_sen_idx <= 4;

--				elsif load_hit = '0' then
					
				end if;
			end if;
		end if;
	end process;
	
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
	
	process(s4_clk)
	begin
		if rising_edge(s4_clk) then
			if cardnum = 2 and my_sen_idx < 1 then
				my_sen_idx <= my_sen_idx + 1;
			end if;
			
			if change_sen_idx = 4 then
				my_sen_idx <= 4;
				turn <= '0';	-- end this player's turn
				fin <= '1';		-- start next player's turn
			end if;
		end if;
	end process;
	

end Behavioral;
		

----------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main2 is
	port(
		rst: in std_logic;
		clk: in std_logic;
		data_out: in std_logic;
		load_stay: in std_logic;
		load_hit: in std_logic;
		LCD_A: out std_logic_vector (1 downto 0);
		LCD_EN: out std_logic;
		LCD_D: out std_logic_vector (7 downto 0) );
end main2;

architecture Behavioral of main2 is

component player is
	port (
		rst: in std_logic;
		clk: in std_logic;
		num: in integer;			-- player num
		load_stay: in std_logic;
		load_hit: in std_logic;
		start: in std_logic;
		fin: out std_logic;		-- let next player start (to next player)
		sen_idx: out integer;	-- sentence idx (to data_gen)
		pnum: out integer;		-- player num (to 7seg)
		csum: out integer;		-- card sum (to 7seg)
		stime: out std_logic );	-- start timing (to 7seg)
end component;

component data_gen is
	port (
		rst: in std_logic;
		clk: in std_logic;
		idx: in integer;
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

signal start: std_logic := '1';
signal fin1, fin2: std_logic := '0';
signal my_idx, my_idx1, my_idx2: integer;
signal data_out_reg, w_enable_reg : std_logic;
signal addr_reg : std_logic_vector(4 downto 0);
signal data_reg : std_logic_vector(7 downto 0);

signal pn1, pn2: integer;
signal cs1, cs2: integer;
signal st1, st2: std_logic;

begin

	p1: player port map (rst, clk, 1, load_stay, load_hit, start,
		fin1, my_idx1, pn1, cs1, st1);
	p2: player port map (rst, clk, 2, load_stay, load_hit, fin1,
		fin2, my_idx2, pn2, cs2, st2);
	my_data_gen: data_gen port map(rst, clk, my_idx, w_enable_reg,
		data_out_reg, addr_reg, data_reg);
	my_lcd_test: lcd_test port map(rst, clk, data_out_reg, addr_reg,
		data_reg, LCD_A, LCD_EN, LCD_D, w_enable_reg);
		
	process(clk)
	begin
		if rising_edge(clk) then
			if fin1 = '0' then
				my_idx <= my_idx1;
			elsif fin1 = '1' and fin2 = '0' then
				my_idx <= my_idx2;
			end if;
		end if;
	end process;
	
	

end Behavioral;