library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use work.my_package.ALL;

entity player is
   port ( clk, rst: in STD_LOGIC;
         score: out integer;
         a: out integer );
end player;

architecture Behavioral of player is

component LFSR is
   port( clk, rst: in STD_LOGIC;
         max_card: in integer;
         en_out: out STD_LOGIC;
         cnt: out STD_LOGIC_VECTOR (5 downto 0) );
end component;

signal max_card2: integer := 10;
signal en: STD_LOGIC;
signal tmp: STD_LOGIC_VECTOR (5 downto 0);
signal rand_int: integer;
signal randcard: integer;

begin
   take_random: LFSR port map (clk, rst, max_card2, en, tmp);
   
   process(clk)
   begin
      if rising_edge(clk) then
         if rst = '0' then
            randcard <= 0;
            p1_score <= 0;
            score <= 0;
         elsif en = '1' then
            rand_int <= (to_integer(signed(tmp)) mod 16) + 1;
            if rand_int >= 11 then
               randcard <= rand_int - 6;
            else
               randcard <= rand_int;
            end if;
            
            if randcard /= integer'low then
               p1_score <= p1_score + randcard;
               score <= p1_score;
            end if;
         else
            randcard <= 0;
         end if;
      end if;
   end process;
   
   a <= randcard;
   
   
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
         en_out: out STD_LOGIC;
         cnt: out STD_LOGIC_VECTOR (5 downto 0) );
end LFSR;

architecture Behavioral of LFSR is

signal cur_card: integer := 0;
signal count_i : STD_LOGIC_VECTOR(99 downto 0);
signal en, feedback : STD_LOGIC;

begin
   feedback <= not(count_i(99) xor count_i(33));
   en <= '1' when cur_card < max_card else '0';
   en_out <= en;
   
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