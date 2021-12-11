library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.FIXED_PKG.ALL;

entity firing_time_generator_tb is
end;
--test
architecture bench of firing_time_generator_tb is

  component firing_time_generator
  port (
    clk         : in std_logic;
	reset_n		: in std_logic;
	fire_time_start : in std_logic; 
    fp_v_alpha 	: IN sfixed(20 downto -11); 
	fp_v_beta   : IN sfixed(20 downto -11);
	fire_time_done : out std_logic; 
	fire_u	 	: OUT std_logic_vector(31 downto 0);
	fire_v	 	: OUT std_logic_vector(31 downto 0);
	fire_w	 	: OUT std_logic_vector(31 downto 0)
	);	
  end component;

  signal clk 		: std_logic;
  signal reset_n	: std_logic;
  signal fire_time_start 	: std_logic;
  signal fire_time_done 	: std_logic; 
  signal fp_v_alpha : sfixed(20 downto -11); 
  signal fp_v_beta	: sfixed(20 downto -11);
  signal fire_u		: std_logic_vector(31 downto 0);
  signal fire_v		: std_logic_vector(31 downto 0);
  signal fire_w		: std_logic_vector(31 downto 0);


  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: firing_time_generator 
    port map ( 
      clk  => clk,
	  reset_n => reset_n,
	  fire_time_start => fire_time_start,
	  fp_v_alpha => fp_v_alpha,
	  fp_v_beta => fp_v_beta,
	  fire_time_done => fire_time_done, 
	  fire_u => fire_u,
	  fire_v => fire_v,
	  fire_w => fire_w
	);

  stimulus: process
  begin
    stop_the_clock <= false;
	reset_n <= '0';
	wait for clock_period*2;
	reset_n <= '1';
	fire_time_start <= '1'; 
	
	fp_v_alpha <= to_sfixed(40,fp_v_alpha); 
	fp_v_beta <= to_sfixed(10,fp_v_beta); 
	wait for clock_period*10;
	
	fp_v_alpha <= to_sfixed(10,fp_v_alpha); 
	fp_v_beta <= to_sfixed(40,fp_v_beta); 
	wait for clock_period*10;
	
	fp_v_alpha <= to_sfixed(-40,fp_v_alpha); 
	fp_v_beta <= to_sfixed(10,fp_v_beta); 
	wait for clock_period*10;
	
	fp_v_alpha <= to_sfixed(-40,fp_v_alpha); 
	fp_v_beta <= to_sfixed(-10,fp_v_beta); 
	wait for clock_period*10;
	
	fp_v_alpha <= to_sfixed(10,fp_v_alpha); 
	fp_v_beta <= to_sfixed(-40,fp_v_beta); 
	wait for clock_period*10;
	
	fp_v_alpha <= to_sfixed(40,fp_v_alpha); 
	fp_v_beta <= to_sfixed(-10,fp_v_beta); 
	wait for clock_period*10;
	
	
    -- Put initialisation code here
    for I in 0 to 50 loop
      
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
  