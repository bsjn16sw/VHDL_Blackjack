library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_idx_gen is
	port (
		rst: in std_logic;
		clk: in std_logic;
		idx: out integer );
end reg_idx_gen;

architecture Behavioral of reg_idx_gen is

signal s1_clk: std_logic;
signal temp_idx: integer := 0;

begin
	idx <= temp_idx;
	
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
	
	process(s1_clk)
	begin
		if rising_edge(s1_clk) then
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

