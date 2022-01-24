library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.FIXED_PKG.ALL;

entity open_loop_ref_tb is
end;
--test
architecture bench of open_loop_ref_tb is

  constant freq_bits 	: integer := 32;
  
  component open_loop_ref
  generic(
	sys_clk		: integer;
	freq_bits 	: integer 
  );
  port (
 		clk 				: IN std_logic;
		reset_n				: IN std_logic;
		en					: IN std_logic;
		freq				: IN std_logic_vector(freq_bits downto 0);
		fp_v_alpha_open		: OUT sfixed (20 downto -11);  
		fp_v_beta_open		: OUT sfixed (20 downto -11) 
	);	
  end component;

  
  
  signal clk 				: std_logic;
  signal reset_n			: std_logic;
  signal en					: std_logic; 
  signal freq 				: std_logic_vector(freq_bits downto 0);
  signal fp_v_alpha_open 	: sfixed(20 downto -11); 
  signal fp_v_beta_open		: sfixed(20 downto -11);

  

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: open_loop_ref 
	generic map( sys_clk => 50_000_000, freq_bits => freq_bits)
    port map ( 
		clk => clk,
		reset_n => reset_n,
		en => en,
		freq => freq,
		fp_v_alpha_open => fp_v_alpha_open,
		fp_v_beta_open => fp_v_beta_open
	);

  stimulus: process
  begin
    stop_the_clock <= false;
	reset_n <= '0';
	en <= '0';
	freq <= std_logic_vector(to_signed(5_000_000, freq'length));
	wait for clock_period*2;
	reset_n <= '1';
	
	wait for clock_period*2; 
	en <= '1'; 
	
	
	
    -- Put initialisation code here
    for I in 0 to 1_000_000 loop
      
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
  