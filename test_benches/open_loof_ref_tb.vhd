library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.FIXED_PKG.ALL;

entity open_loop_ref_tb is
end;
--test
architecture bench of open_loop_ref_tb is

  component open_loop_ref
  port (
 		clk 				: IN std_logic;
		reset_n				: IN std_logic;
		en					: IN std_logic;
		fp_v_alpha_open		: OUT sfixed (20 downto -11);  
		fp_v_beta_open		: OUT sfixed (20 downto -11) 
	);	
  end component;

  signal clk 				: std_logic;
  signal reset_n			: std_logic;
  signal en					: std_logic; 
  signal fp_v_alpha_open 	: sfixed(20 downto -11); 
  signal fp_v_beta_open		: sfixed(20 downto -11);


  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: open_loop_ref 
    port map ( 
		clk =? clk,
		reset_n => reset_n,
		en => en,
		fp_v_alpha_open => fp_v_alpha_open,
		fp_v_beta_open => fp_v_beta_open
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
  