library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity player is
	port(
	clk, rst : in std_logic;
	start : in std_logic;
	ena : out std_logic;
	random : out STD_LOGIC_VECTOR (5 downto 0);
	fin : out std_logic
	);
end player;

architecture Behavioral of player is

component LFSR is
   port( clk, rst: in STD_LOGIC;
         max_card: in integer;
         en_out: out STD_LOGIC;
         cnt: out STD_LOGIC_VECTOR (5 downto 0) );
end component;

signal a : std_logic;
signal b : std_logic;
signal max_card : integer :=3;
signal en : std_logic;
signal cnt: STD_LOGIC_VECTOR (5 downto 0);

begin
	get_Random : LFSR port map(clk,rst,max_card,en,cnt);
	ena <= en;
	random<=cnt;
	
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

--------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blackjack is
	port(
		clk, rst : in std_logic;
		start : in std_logic;
		enen: out std_logic;
		randcard : out std_logic_VECTOR (5 downto 0);
		fin : out std_logic
		);
end blackjack;

architecture Behavioral of blackjack is

signal fin1: std_logic;
signal fin2: std_logic;
signal fin3: std_logic;
signal random1, random2, random3 : STD_LOGIC_VECTOR (5 downto 0);
signal en1, en2, en3: std_logic;

component player is
	port(
	clk : in std_logic;
	rst : in std_logic;
	start : in std_logic;
	ena : out std_logic;
	random : out STD_LOGIC_VECTOR (5 downto 0);
	fin : out std_logic
	);
end component;

begin
	p1 : player port map(clk,rst, start, en1, random1,fin1);
	p2 : player port map(clk,rst, fin1, en2, random2,fin2);
	p3 : player port map(clk,rst, fin2, en3, random3,fin3);
	
	randcard <= random3;
	fin <= fin3;
	enen <= en3;
	
end Behavioral;

-------------------- LFSR -----------------------------------------------------------------------

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

