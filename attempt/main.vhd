library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_package.ALL;

entity main is
	port ( RST: in STD_LOGIC;
		CLK: in STD_LOGIC;
		LCD_A: out STD_LOGIC_VECTOR (1 downto 0);
		LCD_EN: out STD_LOGIC;
		LCD_D: out STD_LOGIC_VECTOR (7 downto 0);
		DIGIT: out STD_LOGIC_VECTOR (6 downto 1);
		SEG_A: out STD_LOGIC;
		SEG_B: out STD_LOGIC;
		SEG_C: out STD_LOGIC;
		SEG_D: out STD_LOGIC;
		SEG_E: out STD_LOGIC;
		SEG_F: out STD_LOGIC;
		SEG_G: out STD_LOGIC;
		SEG_DP: out STD_LOGIC;
		CLK_2s: out STD_LOGIC;
		CLK_14s: out STD_LOGIC );
end main;

architecture Behavioral of main is

signal my_reg: reg_3d;

begin
	my_clock: entity work.clock port map ( RST, CLK, LCD_A, LCD_EN, LCD_D,
		DIGIT, SEG_A, SEG_B, SEG_C, SEG_D, SEG_E, SEG_F, SEG_G, SEG_DP, CLK_2s, CLK_14s );

end Behavioral;

