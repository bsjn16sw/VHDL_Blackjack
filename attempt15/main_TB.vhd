LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY main_TB IS
END main_TB;
 
ARCHITECTURE behavior OF main_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT main
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         data_out : IN  std_logic;
         load_stay : IN  std_logic;
         load_hit : IN  std_logic;
         LCD_A : OUT  std_logic_vector(1 downto 0);
         LCD_EN : OUT  std_logic;
         LCD_D : OUT  std_logic_vector(7 downto 0);
         sec1 : OUT  std_logic;
         sec2 : OUT  std_logic;
         sec4 : OUT  std_logic;
         sen_idx : OUT  integer;
         ncard : OUT  integer;
         id : OUT  integer;
         winner : OUT  integer;
         clk_14s_sec : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal data_out : std_logic := '0';
   signal load_stay : std_logic := '0';
   signal load_hit : std_logic := '0';

 	--Outputs
   signal LCD_A : std_logic_vector(1 downto 0);
   signal LCD_EN : std_logic;
   signal LCD_D : std_logic_vector(7 downto 0);
   signal sec1 : std_logic;
   signal sec2 : std_logic;
   signal sec4 : std_logic;
   signal sen_idx : integer;
   signal ncard : integer;
   signal id : integer;
   signal winner : integer;
   signal clk_14s_sec : std_logic;

   -- Clock period definitions
   constant clk_period : time := 250 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: main PORT MAP (
          rst => rst,
          clk => clk,
          data_out => data_out,
          load_stay => load_stay,
          load_hit => load_hit,
          LCD_A => LCD_A,
          LCD_EN => LCD_EN,
          LCD_D => LCD_D,
          sec1 => sec1,
          sec2 => sec2,
          sec4 => sec4,
          sen_idx => sen_idx,
          ncard => ncard,
          id => id,
          winner => winner,
          clk_14s_sec => clk_14s_sec
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
		load_stay <= '1';
		load_hit <= '1';
		wait for 50 ns;
		rst <= '1';
		wait for 500 us;
		load_hit <= '0';
		wait for 250 ns;
		load_hit <= '1';
		wait for 250 ns;
		load_hit <= '0';
		wait for 250 ns;
		load_stay <= '0';
		wait;
   end process;

END;
