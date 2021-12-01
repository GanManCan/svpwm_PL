-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity pwm_test_tb is
end;

architecture bench of pwm_test_tb is

  component pwm_test
    GENERIC(
      sys_clk         : INTEGER := 50_000_000;
      pwm_freq        : INTEGER := 100_000;
      bits_resolution : INTEGER := 8;
      phases          : INTEGER := 1);
    PORT ( 
      clk       : IN std_logic;
      reset_n   : IN std_logic;
      ena       : IN std_logic ; 
      duty      : IN std_logic_vector(bits_resolution-1 downto 0);
      pwm_out   : OUT std_logic_vector(phases-1 downto 0);
      pwm_n_out : OUT std_logic_vector(phases-1 downto 0));
  end component;

  constant bits_resolution :INTEGER := 8; 
  constant phases : INTEGER := 1; 
  signal clk: std_logic;
  signal reset_n: std_logic;
  signal ena: std_logic;
  signal duty: std_logic_vector(bits_resolution-1 downto 0);
  signal pwm_out: std_logic_vector(phases-1 downto 0);
  signal pwm_n_out: std_logic_vector(phases-1 downto 0);

  constant clock_freq : INTEGER := 50_000_000;
  constant clock_period: time := 1000 ms/clock_freq;
  signal stop_the_clock: boolean;

begin

  -- Insert values for generic parameters !!
  uut: pwm_test generic map ( sys_clk         => clock_freq,
                              pwm_freq        => 10_000,
                              bits_resolution => 8,
                              phases          =>  1)
                   port map ( clk             => clk,
                              reset_n         => reset_n,
                              ena             => ena,
                              duty            => duty,
                              pwm_out         => pwm_out,
                              pwm_n_out       => pwm_n_out );


  stimulus: process
  begin
    
    -- Put initialisation code here
    --clk <= '0';
    reset_n <= '0';
    ena <= '0'; 
    duty <= std_logic_vector(to_UNSIGNED(200,8));
    
    wait for clock_period*2;
    reset_n <= '1';
    
    wait for clock_period * 2; 
    ena <= '1';
    
    wait for clock_period*2;
    ena <= '0';
    
    wait for 1000 ms; 
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
  