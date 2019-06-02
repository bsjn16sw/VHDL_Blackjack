library ieee;
use ieee.math_real.all;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity dealer is
	port(clk,rst,en : in std_logic;
			rand : out std_logic_vector (5 downto 0);
			d_score : out integer
			);
end dealer;

architecture behavior of dealer is 

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
	
	process(clk)
	begin
		while state=1 loop
			cardsum <= cardsum + randcard;
			if cardsum <= 16 then
				state <= 1;
				-- display lcd : Hit, card
			else
				state <= 0;
				-- display lcd : Stay,card
			end if;
		end loop;
		d_score <= cardsum;
	end process;
	
	-- round에게 cardsum 보내기

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
