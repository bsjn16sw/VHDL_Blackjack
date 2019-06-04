library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity player is
	port ( clk, rst: in STD_LOGIC;
			rand: out STD_LOGIC_VECTOR (5 downto 0);
			randcard: out integer );
end player;

architecture Behavioral of player is

component LFSR is
   port( clk, rst: in STD_LOGIC;
			max_card: in integer;
			cnt: out STD_LOGIC_VECTOR (5 downto 0) );
end component;

signal max_card2: integer := 2;
signal tmp: STD_LOGIC_VECTOR (5 downto 0);
signal rand_int: integer;

begin
	take_random: LFSR port map (clk, rst, max_card2, tmp);
	rand <= tmp;
	rand_int <= (to_integer(signed(tmp)) mod 16) + 1;
	randcard <= rand_int - 6 when rand_int >= 11 else rand_int;
end Behavioral;

-------------------- LFSR ----------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity LFSR is
   port( clk, rst: in STD_LOGIC;
			max_card: in integer;
			cnt: out STD_LOGIC_VECTOR (5 downto 0) );
end LFSR;

architecture Behavioral of LFSR is

signal cur_card: integer := 0;
signal count_i : STD_LOGIC_VECTOR(99 downto 0);
signal en, feedback : STD_LOGIC;

begin
   feedback <= not(count_i(99) xor count_i(33));
	en <= '1' when cur_card < max_card else '0';
	
   process(clk)
   begin
      if rising_edge(clk) then
         if rst = '0' then
            count_i <= (others => '0');
         elsif en = '1' then
            count_i <= count_i(98 downto 0) & feedback;
				cur_card <= cur_card + 1;
         end if;
      end if;
   end process;
   cnt <= count_i(99 downto 97) & count_i(2 downto 0);
	
end Behavioral;