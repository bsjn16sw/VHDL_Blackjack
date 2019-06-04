LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY player_TB IS
END player_TB;
 
ARCHITECTURE behavior OF player_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT player
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         score : OUT  integer;
         a : OUT  integer
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

 	--Outputs
   signal score : integer;
   signal a : integer;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: player PORT MAP (
          clk => clk,
          rst => rst,
          score => score,
          a => a
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
      rst <= '0';
		wait for 20ns;
		rst <= '1';
      wait;
   end process;

END;
