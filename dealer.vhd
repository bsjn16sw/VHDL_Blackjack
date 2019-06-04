library ieee;
use ieee.math_real.all;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity dealer is
	port(clk,rst : in std_logic;
			rand : out std_logic_vector (5 downto 0);
			d_score : out integer -- final score
			);
end dealer;

architecture behavior of dealer is 
	component LFSR is
		port( clk, rst: in STD_LOGIC;
				max_card : in integer;
				cnt: out STD_LOGIC_VECTOR (5 downto 0) );
	end component;
	
	signal max_card : integer :=1;
	signal tmp : std_logic_vector(5 downto 0);
	signal rand_int : integer;
	signal randcard : integer; -- random card: 1~10
	signal state : integer :=1;
	signal cardsum : integer :=0; -- dealer's current card sum
	
begin

	take_random : LFSR port map (clk,rst,max_card,tmp);
	rand <= tmp; -- printing what is the infinite random value
	rand_int <= (to_integer(signed(tmp)) mod 16) +1; -- 1 ~ 16
	
	process(clk)
	begin
		if rising_edge(clk) then
			if (rand_int >= 11) then
				randcard <= rand_int - 6;
			else
				randcard <= rand_int;
			end if;
		end if;
	end process;
	----------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
			while state=1 loop
				max_card <= max_card + 1;
				cardsum <= cardsum + randcard;
				if cardsum <= 16 then -- hit
					state <= 1;
				else -- stay
					state <= 0;
				end if;
			end loop;
			--d_score <= cardsum;
		end if;
	end process;
	
	d_score <= cardsum;


	-- round에게 cardsum 보내기

end behavior;


-------------------- LFSR ----------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity LFSR is
   port( clk, rst: in STD_LOGIC;
			max_card : in integer;
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