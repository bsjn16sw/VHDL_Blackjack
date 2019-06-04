library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity player is
	port(
	clk : in std_logic;
	start : in std_logic;
	fin : out std_logic
	);
end player;

architecture Behavioral of player is

signal a : std_logic;
signal b : std_logic;
begin
	process(clk,start)
	begin
		if rising_edge(clk) then
			if start='1' then
				a<='1';
				b<='1';
				fin <= '1';
			end if;
		end if;
	end process;

end Behavioral;

-------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blackjack is
	port(
		clk : in std_logic;
		start : in std_logic;
		fin : out std_logic
		);
end blackjack;

architecture Behavioral of blackjack is

signal fin1: std_logic;
signal fin2: std_logic;
signal fin3: std_logic;

component player is
	port(
	clk : in std_logic;
	start : in std_logic;
	fin : out std_logic
	);
end component;

begin
	p1 : player port map(clk, start, fin1);
	p2 : player port map(clk, fin1, fin2);
	p3 : player port map(clk, fin2, fin3);
	
	fin <= fin3;
	
end Behavioral;

------------------------------------------------

-- clock

----------------------------------------------

