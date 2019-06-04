library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package my_package is
	type str is array (0 to 31) of STD_LOGIC_VECTOR (7 downto 0);
	type strs is array (0 to 10) of str;
	type p_card_str is array (0 to 9) of STD_LOGIC_VECTOR (7 downto 0);
	type p_score is array (1 to 3) of integer;

	signal sentences: strs :=
	( (X"50", X"31", X"27", X"73", X"20", X"74", X"75", X"72", X"6E", X"20", X"20", X"20", X"20", X"20", X"20", X"20",	-- P1's turn
	   X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20"),	-- 
	   
	  (X"53", X"74", X"61", X"79", X"20", X"6F", X"72", X"20", X"48", X"69", X"74", X"3F", X"20", X"20", X"20", X"20",	-- Stay or hit?
	   X"43", X"61", X"72", X"64", X"3A", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20"),	-- Cards:
	   
	  (X"59", X"6F", X"75", X"20", X"63", X"68", X"6F", X"73", X"65", X"20", X"68", X"69", X"74", X"20", X"20", X"20",	-- You chose hit
	   X"43", X"61", X"72", X"64", X"3A", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20"),	-- Cards:
	   
	  (X"59", X"6F", X"75", X"20", X"63", X"68", X"6F", X"73", X"65", X"20", X"68", X"69", X"74", X"20", X"20", X"20",	-- You chose hit
	   X"42", X"75", X"74", X"20", X"62", X"75", X"72", X"73", X"74", X"65", X"64", X"2E", X"2E", X"2E", X"20", X"20"),	-- But bursted...
	   
	  (X"59", X"6F", X"75", X"20", X"63", X"68", X"6F", X"73", X"65", X"20", X"73", X"74", X"61", X"79", X"20", X"20",	-- You chose stay
	   X"50", X"31", X"27", X"73", X"20", X"74", X"75", X"72", X"6E", X"20", X"6E", X"6F", X"77", X"20", X"20", X"20"),	-- P1's turn now
	   
	  (X"31", X"35", X"73", X"65", X"63", X"20", X"69", X"73", X"20", X"6F", X"76", X"65", X"72", X"20", X"20", X"20",	-- 15sec is over
	   X"50", X"31", X"27", X"73", X"20", X"74", X"75", X"72", X"6E", X"20", X"6E", X"6F", X"77", X"20", X"20", X"20"),	-- P1's turn now
	   
	  (X"44", X"65", X"61", X"6C", X"65", X"72", X"27", X"20", X"74", X"75", X"72", X"6E", X"20", X"20", X"20", X"20",	-- Dealer's turn
	   X"53", X"75", X"6D", X"3C", X"31", X"37", X"20", X"73", X"6F", X"20", X"68", X"69", X"74", X"20", X"20", X"20"),	-- Sum<17 so hit
	   
	  (X"44", X"65", X"61", X"6C", X"65", X"72", X"27", X"20", X"74", X"75", X"72", X"6E", X"20", X"20", X"20", X"20",	-- Dealer's turn
	   X"53", X"75", X"6D", X"76", X"75", X"31", X"37", X"20", X"73", X"6F", X"20", X"73", X"74", X"61", X"79", X"20"),	-- Sum>=17 so stay
	   
	  (X"52", X"6F", X"75", X"6E", X"64", X"31", X"20", X"69", X"73", X"20", X"6F", X"76", X"65", X"72", X"20", X"20",	-- Round1 is over
	   X"50", X"31", X"20", X"77", X"69", X"6E", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20"),	-- P1 win
	   
	  (X"47", X"61", X"6D", X"65", X"20", X"6F", X"76", X"65", X"72", X"20", X"20", X"20", X"20", X"20", X"20", X"20",	-- Game over
	   X"50", X"31", X"20", X"66", X"69", X"6E", X"61", X"6C", X"6C", X"79", X"20", X"77", X"69", X"6E", X"20", X"20"),	-- P1 finally win
	   
	  (X"50", X"31", X"27", X"73", X"20", X"73", X"63", X"6F", X"72", X"65", X"3A", X"20", X"20", X"20", X"20", X"20",	-- P1's score:
	   X"4D", X"61", X"67", X"69", X"63", X"20", X"73", X"63", X"6F", X"72", X"65", X"3A", X"20", X"20", X"20", X"20")	-- Magic score:
	);
	
	signal p1_card_str: p_card_str := (X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20");
	signal p2_card_str: p_card_str := (X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20");
	signal p3_card_str: p_card_str := (X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20");
	
	--signal p_scores: p_score := (0, 0, 0);
	signal p1_score: integer := 0;
	signal p2_score: integer := 0;
	signal p3_score: integer := 0;
	signal d_score: integer := 0;

end package my_package;