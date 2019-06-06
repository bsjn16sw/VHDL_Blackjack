library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_idx_gen is
	port (
		rst: in std_logic;
		clk: in std_logic;
		idx: out integer );
end reg_idx_gen;

architecture Behavioral of reg_idx_gen is

signal temp_idx: integer := 0;

begin
	idx <= temp_idx;
	
	process(clk)
	begin
		if rising_edge(clk) then
			temp_idx <= temp_idx + 1;
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
		idx: out integer );
end main2;

architecture Behavioral of main2 is

component reg_idx_gen is
	port (
		rst: in std_logic;
		clk: in std_logic;
		idx: out integer );
end component;

signal my_idx: integer;

begin

	my_reg_idx_gen: reg_idx_gen port map (rst, clk, my_idx);
	idx <= my_idx;

end Behavioral;

