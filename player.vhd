library ieee;
use ieee.math_real.all;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity player is
	port(clk,rst,en : in std_logic;
			rand : out std_logic_vector (5 downto 0);
			p_score : out integer
			);
end player;

architecture behavior of player is 

	component LFSR port(clk,rst,en : in std_logic;
        cnt : out std_logic_vector(5 downto 0));   
	end component;
	
	signal tmp : std_logic_vector(5 downto 0);
	signal tmp1 : integer;
	signal randcard : integer; -- random card: 1~10
	signal state : integer :=1;
	signal cardsum : integer :=0; -- dealer's current card sum
	
	
begin
	take_random : LFSR port map (clk,rst,en, tmp);
	rand <= tmp; -- printing what is the infinite random value
	tmp1 <= (to_integer(signed(tmp)) mod 16) +1; -- 1 ~ 16
	
	process(clk)
	begin
		if rising_edge(clk) then
			if (tmp1 >= 11) then
				randcard <= tmp1 - 6;
			else
				randcard <= tmp1;
			end if;
		end if;
	end process;
	
	process(clk, 15s) -- main method
		variable cnt : integer := 0; -- total cardnum
	
	begin
		while state=1 loop
			if 15s = '1' then
				cardsum <= cardsum + randcard;
				cnt <= cnt + 1;
				if push_sw(0) then -- hit
					-- display lcd : Hit, card
					state <= 1;
				elsif push_sw(1) then -- stay
					-- display lcd : Stay, card
					state <= 0;
				end if;
			else
				-- display lcd : 15 sec is over
				state <= 0;
			end if;
		end loop;
		
		if cnt=2 and ace='1' and ten='1' then -- 특수한 경우, 200점 리턴
			p_score <= 200; 
		else -- 그 외에 제 값 리턴
			p_score <= cardsum;
		end if;
		
	end process;
	
	process(clk, load_op1, load_op2, load_op3) -- push button
	begin
		if rising_edge(clk) then
			if load_op1 = '0' then
				-- display lcd : p1's total score
			elsif load_op2 = '0' then
				-- display lcd : p2's total score
			elsif load_op3 = '0' then
				-- display lcd : p3's total score
			end if;
		end if;
	end process;
	
	-- round에게 p_score 보내기 portmap (이 코드에서는 p_score를 아웃풋으로 놓음)
	

end behavior;


-------------------- LFSR ----------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity LFSR is
   port(clk,rst,en : in std_logic;
        cnt : out std_logic_vector(5 downto 0)
        );   
end LFSR;

architecture Behavioral of LFSR is
signal count_i : std_logic_vector(99 downto 0);
signal feedback : std_logic;

begin
   feedback<=not(count_i(99) xor count_i(33));
   process(clk)
   begin
      if rising_edge(clk) then
         if rst='1' then
            count_i<=(others=>'0');
         elsif en='1' then
            count_i<=count_i(98 downto 0) & feedback;
         end if;
      end if;
   end process;
   cnt<=count_i(99 downto 97) & count_i(2 downto 0);
end Behavioral;
