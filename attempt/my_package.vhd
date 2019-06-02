library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package my_package is
	type reg_2d is array (0 to 31) of STD_LOGIC_VECTOR (7 downto 0);
	type reg_3d is array (0 to 2) of reg_2d;
end package my_package;
