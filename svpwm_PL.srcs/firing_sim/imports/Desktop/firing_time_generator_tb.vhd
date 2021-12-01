library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity sin_table_tb is
end;

architecture bench of firing_time_generator_tb is

  component firing_time_generator
  port (
    clk         : in std_logic;
	reset_n		: in std_logic;
	ena			: in std_logic; 
	test_in		: in std_logic_vector(7 downto 0)); 
  end component;

  signal clk 		: std_logic;
  signal reset_n	: std_logic;
  signal ena 		: std_logic;
  signal test_in	: std_logic_vector(7 downto 0);

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: firing_time_generator 
    port map ( 
      clk  => clk,
	  reset_n => reset_n,
	  ena => ena,
	  test_in => test_in
	);

  stimulus: process
  begin
  
    -- Put initialisation code here
    for I in 0 to 255 loop
      test_in <= std_logic_vector(to_unsigned(I,test_in'length));
      wait for clock_period*2; 
    end loop; 

    -- Put test bench stimulus code here

    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
  