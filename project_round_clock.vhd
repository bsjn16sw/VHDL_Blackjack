library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity project_round is
	port( rst_n : in STD_LOGIC;
			clk : in STD_LOGIC;
			DIGIT : out  STD_LOGIC_VECTOR (6 downto 1);
           SEG_A : out  STD_LOGIC;
           SEG_B : out  STD_LOGIC;
           SEG_C : out  STD_LOGIC;
           SEG_D : out  STD_LOGIC;
           SEG_E : out  STD_LOGIC;
           SEG_F : out  STD_LOGIC;
           SEG_G : out  STD_LOGIC;
           SEG_DP : out  STD_LOGIC
			  CLK_2s : out STD_LOGIC;
			  CLK_14s : out STD_LOGIC);
end project_round;

architecture Behavioral of project_round is

	signal sel : std_logic_vector( 2 downto 0 ); -- 7 segment select, select DIGIT
	signal data : std_logic_vector( 3 downto 0 ); -- display value
	signal seg : std_logic_vector( 7 downto 0 ); -- 7 segment display
	signal s2_clk, s14_clk : std_logic; -- clock for 2 / 14 seconds, rising / descending every 1sec / 7sec
	signal s1_clk : std_logic; -- clock for seconds, rising/descending every 0.5sec
	signal sec10_cnt, sec01_cnt : std_logic_vector( 3 downto 0 ); -- count seconds

begin
		
	-- determine LED display digit by sel value
	process(sel)
	begin
		case sel is
					when "000" => DIGIT <= "000001"; -- 현재 플레이어 카드 합(tens)
							data <= sum10;
					when "001" => DIGIT <= "000010"; -- 현재 플레이어 카드 합(units)
							data <= sum01;
					when "010" => DIGIT <= "000100"; -- 현재 플레이어의 점수(tens)
							data <= score10;
					when "011" => DIGIT <= "001000"; -- 현재 플레이어의 점수(units)
							data <= score01;
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
	process(rst_n, s1_clk)
			variable cnt_14s : integer range 0 to 7;
	begin
			if(rst_n = '0') then -- reset
					s2_clk <= '1';
					s14_clk <= '1';
					cnt_15s := 0;
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
	
	CLK_2s <= s2_clk;
	CLK_14s <= s14_clk;
	
	-- count hours, minutes, seconds by rst_n, s01_clk rising
	process(s1_clk, rst_n) -- input score, sum!!!!!!!!!!!
			variable s10_cnt, s01_cnt : STD_LOGIC_VECTOR ( 3 downto 0); -- count for second(tens, units)
	begin
			if(rst_n = '0') then -- 00:00:00
					s01_cnt:= "0000"; -- '0'
					s10_cnt:= "0000"; -- '0'
					
			elsif(s1_clk = '1' and s1_clk'event) then -- when s01_clk is rising
					s01_cnt:= s01_cnt + 1; -- increase second(units)
					-- count of second(units)
					if(s01_cnt > "1001") then -- when s01_cnt = 10, recount and increase s10_cnt
							s01_cnt:= "0000"; -- recount
							s10_cnt:= s10_cnt + 1; -- increase s10_cnt
					end if;
					-- 00:00:15
					if(s10_cnt = "0001" and s01_cnt > "0101") then -- go back to 00:00:00
							s10_cnt:= "0000";
							s01_cnt:= "0000";
					end if;
			end if;
			
			sec01_cnt <= s01_cnt;
			sec10_cnt <= s10_cnt;
			score01 <= "0000"; -- input score, sum!!!!!!!!
			score10 <= "0000";
			sum01 <= "0000";
			sum10 <= "0000";
			
	end process;

end Behavioral;

