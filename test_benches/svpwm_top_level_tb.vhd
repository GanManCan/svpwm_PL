library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.FIXED_PKG.ALL;

entity svpwm_top_level_tb is
end;
--test
architecture bench of svpwm_top_level_tb is

  component svpwm_top_level
  port (
    clk 	  : in std_logic; 
	reset_n   : in std_logic; 
    v_alpha   : in std_logic_vector(31 downto 0); 
	v_beta    : in std_logic_vector(31 downto 0); 
	gate_u, gate_u_n : out std_logic;
	gate_v, gate_v_n : out std_logic; 
	gate_w, gate_w_n : out std_logic
  );	
  end component;

  
  signal clk 		: std_logic;
  signal reset_n	: std_logic;
  signal v_alpha	: std_logic_vector(31 downto 0);
  signal v_beta		: std_logic_vector(31 downto 0);
  signal gate_u, gate_u_n    : std_logic;
  signal gate_v, gate_v_n    : std_logic;
  signal gate_w, gate_w_n    : std_logic;



  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: svpwm_top_level
    port map ( 
      clk  => clk,
	  reset_n => reset_n,
	  v_alpha => v_alpha,
	  v_beta => v_beta,
	  gate_u => gate_u,
	  gate_u_n => gate_u_n,
	  gate_v => gate_v,
	  gate_v_n => gate_v_n,
	  gate_w => gate_w,
	  gate_w_n => gate_w_n
	);

  stimulus: process
  begin
    stop_the_clock <= false;
	reset_n <= '0';
	wait for clock_period*2;
	reset_n <= '1'; 
	
	v_alpha <= std_logic_vector(to_signed(40, v_alpha'length)); 
	v_beta <= std_logic_vector(to_signed(10, v_beta'length)); 
	
	
    -- Keep running for 4500 seconds
    for I in 0 to 50_000 loop
      wait for clock_period; 
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
  