library IEEE;
use IEEE.STD_LOGIC_1164.all;

package storage is
	-- Type declaration
	type int_arr is array (0 to 15) of integer;
	type reg is array (0 to 31) of std_logic_vector (7 downto 0);
	
	-- Constant declaration
	-- Start
	constant reg_buf_0: reg :=	-- ===Blackjack=== / Player's turn
		(X"3D", X"3D", X"3D", X"42", X"6C", X"61", X"63", X"6B", X"6A", X"61", X"63", X"6B", X"3D", X"3D", X"3D", X"20",
		 X"50", X"6C", X"61", X"79", X"65", X"72", X"27", X"73", X"20", X"74", X"75", X"72", X"6E", X"20", X"20", X"20");
	-- Stay or hit?
	constant reg_buf_1: reg :=	-- Stay or hit? / Cards:
		(X"53", X"74", X"61", X"79", X"20", X"6F", X"72", X"20", X"48", X"69", X"74", X"3F", X"20", X"20", X"20", X"20",
		 X"43", X"61", X"72", X"64", X"73", X"3A", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20");
	-- Player stay
	constant reg_buf_2: reg :=	-- You chose stay / Turn to Dealer
		(X"59", X"6F", X"75", X"20", X"63", X"68", X"6F", X"73", X"65", X"20", X"73", X"74", X"61", X"79", X"20", X"20",
		 X"54", X"75", X"72", X"6E", X"20", X"74", X"6F", X"20", X"44", X"65", X"61", X"6C", X"65", X"72", X"20", X"20");
	-- Player hit
	constant reg_buf_3: reg :=	-- You chose hit / Cards:
		(X"59", X"6F", X"75", X"20", X"63", X"68", X"6F", X"73", X"65", X"20", X"68", X"69", X"74", X"20", X"20", X"20",
		 X"43", X"61", X"72", X"64", X"73", X"3A", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20", X"20");
	-- Player hit but bursted
	constant reg_buf_4: reg :=	-- You chose hit / But bursted...
		(X"59", X"6F", X"75", X"20", X"63", X"68", X"6F", X"73", X"65", X"20", X"68", X"69", X"74", X"20", X"20", X"20",
		 X"42", X"75", X"74", X"20", X"62", X"75", X"72", X"73", X"74", X"65", X"64", X"2E", X"2E", X"2E", X"20", X"20");
	-- Player timeout
	constant reg_buf_5: reg :=	-- 15sec is over / Turn to Dealer
		(X"31", X"35", X"73", X"65", X"63", X"20", X"69", X"73", X"20", X"6F", X"76", X"65", X"72", X"20", X"20", X"20",
		 X"54", X"75", X"72", X"6E", X"20", X"74", X"6F", X"20", X"44", X"65", X"61", X"6C", X"65", X"72", X"20", X"20");
	-- Dealer stay
	constant reg_buf_6: reg :=	-- Dealer's turn / Sum>=17 so stay
		(X"44", X"65", X"61", X"6C", X"65", X"72", X"27", X"73", X"20", X"74", X"75", X"72", X"6E", X"20", X"20", X"20",
		 X"53", X"75", X"6D", X"3E", X"3D", X"31", X"37", X"20", X"73", X"6F", X"20", X"73", X"74", X"61", X"79", X"20");
	-- Dealer hit
	constant reg_buf_7: reg :=	-- Dealer's turn / Sum<17 so hit
		(X"44", X"65", X"61", X"6C", X"65", X"72", X"27", X"73", X"20", X"74", X"75", X"72", X"6E", X"20", X"20", X"20",
		 X"53", X"75", X"6D", X"3C", X"31", X"37", X"20", X"73", X"6F", X"20", X"68", X"69", X"74", X"20", X"20", X"20");
	-- Dealer hit but bursted
	constant reg_buf_8: reg :=	-- Dealer's turn / But bursted...
		(X"44", X"65", X"61", X"6C", X"65", X"72", X"27", X"73", X"20", X"74", X"75", X"72", X"6E", X"20", X"20", X"20",
		 X"42", X"75", X"74", X"20", X"62", X"75", X"72", X"73", X"74", X"65", X"64", X"2E", X"2E", X"2E", X"20", X"20");
	-- Game over
	constant reg_buf_9: reg :=	-- Game over / P:00 D:00 P win
		(X"47", X"61", X"6D", X"65", X"20", X"6F", X"76", X"65", X"72", X"20", X"20", X"20", X"20", X"20", X"20", X"20",
		 X"50", X"3A", X"60", X"60", X"20", X"44", X"3A", X"60", X"60", X"20", X"50", X"20", X"77", X"69", X"6E", X"20");
end storage;

package body storage is
 
end storage;