library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.FIXED_PKG.ALL;

entity sine_lookup_tb is
end;
--test
architecture bench of sine_lookup_tb is

	component sine_lookup
	port (
	  i_clk          : in  std_logic;
	  i_addr         : in  std_logic_vector(15 downto 0);
	  o_data         : out std_logic_vector(18 downto 0)
	);	
	end component;

	signal i_clk 	: std_logic;
	signal i_addr	: std_logic_vector(15 downto 0); 
	signal o_data	: std_logic_vector(18 downto 0); 


  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: sine_lookup 
    port map ( 
		i_clk => i_clk,
		i_addr => i_addr,
		o_data => o_data
	);

  stimulus: process
  begin
    stop_the_clock <= false;
	
	wait for clock_period*2;
	
	
    -- Put initialisation code here
    for I in 0 to 1500 loop
		i_addr <= std_logic_vector(to_unsigned(I, i_addr'length));
		wait for clock_period*4; 
	end loop; 

    -- Put test bench stimulus code here

    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      i_clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
  