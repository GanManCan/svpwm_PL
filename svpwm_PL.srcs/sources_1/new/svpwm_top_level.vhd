----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/17/2021 06:10:23 PM
-- Design Name: 
-- Module Name: svpwm_top_level - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.FIXED_PKG.ALL;


entity svpwm_top_level is
  Port ( 
    clk 	  : in std_logic; 
	reset_n   : in std_logic; 
    v_alpha   : in std_logic_vector(31 downto 0); 
	v_beta    : in std_logic_vector(31 downto 0); 
	gate_u, gate_u_n : out std_logic;
	gate_v, gate_v_n : out std_logic; 
	gate_w, gate_w_n : out std_logic
  );
end svpwm_top_level;

architecture Behavioral of svpwm_top_level is
  
  -- firing_time_generator component descriptor
  component firing_time_generator
    generic(
	  sys_clk         : INTEGER := 50_000_000;  --system clock freq in Hz
      pwm_freq        : INTEGER := 3_000;      --PWM switching freq in Hz
      bits_resolution : INTEGER := 32;           --bits of resolution for duty cycle
	  v_dc            : INTEGER := 200
	); 
    port (
	  clk    		: IN std_logic;
	  reset_n		: IN std_logic;
	  ena 			: IN std_logic; 
	  fp_v_alpha 	: IN sfixed(20 downto -11); 
	  fp_v_beta   	: IN sfixed(20 downto -11);
	  -- Output firiing sectors 
	  fire_u 	: OUT std_logic_vector(bits_resolution-1 downto 0);
	  fire_v 	: OUT std_logic_vector(bits_resolution-1 downto 0);
	  fire_w 	: OUT std_logic_vector(bits_resolution-1 downto 0)
	); 
  end component; -- firing_time_generator 

  -- svpwm component descriptor 
  component svpwm
    generic(
	  sys_clk         	: INTEGER := 50_000_000; --system clock freq in Hz
      pwm_freq        	: INTEGER := 3_000;    --PWM switching freq in Hz
      bits_resolution 	: INTEGER := 32;          --bits of resolution for duty cycle
      dead_time_ns    	: INTEGER := 800   -- Dead time in ns  
	);
    port(
	  clk       : IN std_logic;
      reset_n   : IN std_logic;
      ena       : IN std_logic ;
	  fire_u    : IN std_logic_vector(bits_resolution-1 downto 0);
	  fire_v    : IN std_logic_vector(bits_resolution-1 downto 0);
	  fire_w    : IN std_logic_vector(bits_resolution-1 downto 0);
	  gate_u    : OUT std_logic; -- Phase U Gate Drive signal [Top Transistor]
	  gate_u_n  : OUT std_logic; -- Phase U Gate Drive signal [Bottom Transistor]
	  gate_v    : OUT std_logic; -- Phase V Gate Drive signal [Top Transistor]
	  gate_v_n  : OUT std_logic; -- Phase V Gate Drive signal [Bottom Transistor]
	  gate_w    : OUT std_logic; -- Phase W Gate Drive signal [Top Transistor]
	  gate_w_n  : OUT std_logic -- Phase W Gate Drive signal [Bottom Transistor]  
	);
  end component; 
  
  -- Signal Declarations
  signal ena 		: std_logic := '1'; 
  signal fp_v_alpha	: sfixed(20 downto -11);
  signal fp_v_beta	: sfixed(20 downto -11);  
  signal fire_u 	: std_logic_vector(31 downto 0);
  signal fire_v 	: std_logic_vector(31 downto 0);
  signal fire_w 	: std_logic_vector(31 downto 0);
begin

  fp_v_alpha <= to_sfixed(signed(v_alpha), fp_v_alpha);  
  fp_v_beta <= to_sfixed(signed(v_beta), fp_v_beta);  

  firing_time_generator_1:  firing_time_generator 
    port map(clk => clk, reset_n => reset_n, ena => ena, 
			 fp_v_alpha => fp_v_alpha, fp_v_beta => fp_v_beta,
			 fire_u => fire_u, fire_v => fire_v, fire_w => fire_w);
	  
   svpwm_1: svpwm
     port map(clk => clk, reset_n => reset_n, ena => ena,
			  fire_u => fire_u, fire_v => fire_v, fire_w => fire_w,
			  gate_u => gate_u, gate_u_n => gate_u_n, 
			  gate_v => gate_v, gate_v_n => gate_v_n, 
			  gate_w => gate_w, gate_w_n => gate_w_n);


end Behavioral;
