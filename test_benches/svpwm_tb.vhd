library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.FIXED_PKG.ALL;

entity svpwm_tb is
end;
--test
architecture bench of svpwm_tb is

  component svpwm
  port (
    clk       : IN std_logic;
    reset_n   : IN std_logic;
    ena       : IN std_logic ;
	fire_u    : IN std_logic_vector(31 downto 0);
	fire_v    : IN std_logic_vector(31 downto 0);
	fire_w    : IN std_logic_vector(31 downto 0);
	gate_u    : OUT std_logic; -- Phase U Gate Drive signal [Top Transistor]
	gate_u_n  : OUT std_logic; -- Phase U Gate Drive signal [Bottom Transistor]
	gate_v    : OUT std_logic; -- Phase V Gate Drive signal [Top Transistor]
	gate_v_n  : OUT std_logic; -- Phase V Gate Drive signal [Bottom Transistor]
	gate_w    : OUT std_logic; -- Phase W Gate Drive signal [Top Transistor]
	gate_w_n  : OUT std_logic -- Phase W Gate Drive signal [Bottom Transistor]
	);	
  end component;

  signal clk 		: std_logic;
  signal reset_n	: std_logic;
  signal ena 		: std_logic;
  signal fire_u    : std_logic_vector(31 downto 0);
  signal fire_v    : std_logic_vector(31 downto 0);
  signal fire_w    : std_logic_vector(31 downto 0);
  signal gate_u    : std_logic; -- Phase U Gate Drive signal [Top Transistor]
  signal gate_u_n  : std_logic; -- Phase U Gate Drive signal [Bottom Transistor]
  signal gate_v    : std_logic; -- Phase V Gate Drive signal [Top Transistor]
  signal gate_v_n  : std_logic; -- Phase V Gate Drive signal [Bottom Transistor]
  signal gate_w    : std_logic; -- Phase W Gate Drive signal [Top Transistor]
  signal gate_w_n  : std_logic; -- Phase W Gate Drive signal [Bottom Transistor]


  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: svpwm
    port map ( 
      clk  => clk,
	  reset_n => reset_n,
	  ena => ena,
	  fire_u => fire_u,
	  fire_v => fire_v,
	  fire_w => fire_w,
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
	ena <= '1'; 
	
	fire_u <= std_logic_vector(to_signed(100, fire_u'length)); 
	fire_v <= std_logic_vector(to_signed(200, fire_v'length)); 
	fire_w <= std_logic_vector(to_signed(250, fire_w'length)); 
	
	
    -- Keep running for 4500 seconds
    for I in 0 to 4500 loop
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
  