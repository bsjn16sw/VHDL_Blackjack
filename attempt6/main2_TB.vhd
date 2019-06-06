LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY main2_TB IS
END main2_TB;
 
ARCHITECTURE behavior OF main2_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT main2
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         idx : OUT  integer
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal idx : integer;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: main2 PORT MAP (
          rst => rst,
          clk => clk,
          idx => idx
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait;
   end process;

END;
