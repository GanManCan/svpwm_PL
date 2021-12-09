library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.FIXED_PKG.ALL;
use IEEE.math_real.ALL; 

entity clarke_transform_tb is
end;
--test
architecture bench of clarke_transform_tb is

	component clarke_transform
		GENERIC(
			bits_res_high	: integer := 20;
			bits_res_low 	: integer := -11 
		); 
		
		PORT( 
		  clk 			: in STD_LOGIC;
		  clarke_start 	: in STD_LOGIC; 
		  reset_n		: in std_logic; 
		  fp_y_a 		: in sfixed(bits_res_high downto bits_res_low);
		  fp_y_b 		: in sfixed(bits_res_high downto bits_res_low);
		  fp_y_c 		: in sfixed(bits_res_high downto bits_res_low); 
		  fp_y_alpha 	: out sfixed(bits_res_high downto bits_res_low);
		  fp_y_beta		: out sfixed(bits_res_high downto bits_res_low);
		  clarke_done 	: out std_logic
		);
	end component;

  signal clk 		: std_logic;
  signal reset_n	: std_logic;
  signal clarke_start 	: std_logic;
  signal clarke_done 	: std_logic; 
  signal fp_y_a		: sfixed(20 downto -11);
  signal fp_y_b		: sfixed(20 downto -11);
  signal fp_y_c		: sfixed(20 downto -11);
  signal fp_y_alpha : sfixed(20 downto -11); 
  signal fp_y_beta	: sfixed(20 downto -11);
 

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;
  
  -- Simulation Signals/constant
  CONSTANT sine_step  : real := 2.0*MATH_PI/100.0; 
  CONSTANT real_DC_input : real := 200.0;
  signal real_sin_a, real_sin_b, real_sin_c, real_rad	: real := 0.0; 

begin

  uut: clarke_transform 
    port map ( 
      clk  => clk,
	  reset_n => reset_n,
	  clarke_start => clarke_start,
	  fp_y_a => fp_y_a,
	  fp_y_b => fp_y_b,
	  fp_y_c => fp_y_c,
	  fp_y_alpha => fp_y_alpha,
	  fp_y_beta => fp_y_beta,
	  clarke_done => clarke_done
	);

  stimulus: process
  begin
    stop_the_clock <= false;
	reset_n <= '0';
	wait for clock_period*2;
	reset_n <= '1';
	clarke_start <= '1'; 

	
	
	
    -- Put initialisation code here
    for I in 0 to 250 loop
		-- loop to allow time to get throught the state machine
		for k in 0 to 8 loop
			wait for clock_period; 
		end loop; -- for k
	  
		-- Increment Radian and calculate sine wave
		real_rad <= real_rad + sine_step;
		real_sin_a <= real_DC_input*sin(real_rad);
		real_sin_b <= real_DC_input*sin(real_rad - (2.0*MATH_PI/3.0));
		real_sin_c <= real_DC_input*sin(real_rad - (4.0*MATH_PI/3.0));
	  
		if(real_rad >= (2.0*MATH_PI-sine_step)) then
			real_rad <= 0.0;
		end if; -- if (real_rad >= MATH_PI)
	  
    end loop; -- for i

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
  