----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/17/2021 06:10:23 PM
-- Design Name: 
-- Module Name: firing_time_generator - Behavioral
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

entity firing_time_generator is
  GENERIC(
    sys_clk         : INTEGER := 50_000_000;  --system clock freq in Hz
    pwm_freq        : INTEGER := 3_000;      --PWM switching freq in Hz
    bits_resolution : INTEGER := 32;           --bits of resolution for duty cycle
	v_dc            : INTEGER := 200
    );         
	
  PORT (
    clk    		: IN std_logic;
	reset_n		: IN std_logic;
	ena 		: IN std_logic; 
	fp_v_alpha 	: IN sfixed(20 downto -11); 
	fp_v_beta   : IN sfixed(20 downto -11);
	-- Output firiing sectors 
	fire_u 	: OUT std_logic_vector(bits_resolution-1 downto 0);
	fire_v 	: OUT std_logic_vector(bits_resolution-1 downto 0);
	fire_w 	: OUT std_logic_vector(bits_resolution-1 downto 0)
	); 

end firing_time_generator;

architecture Behavioral of firing_time_generator is
  -- fp == fixed point
  
  -- CONSTANT DECCLARATIONS 
  CONSTANT fp_sqrt3 	: sfixed(2 downto -11)  := to_sfixed(1.732, 2, -11); -- sqrt(3) = 1.732
  CONSTANT fp_t0    	: sfixed(16 downto 0)   := to_sfixed(sys_clk/pwm_freq/2, 16, 0); -- Period = number of clocks in SVPWM cycle
                                                                                     -- Note 2 SVPWM cycles per switching cycle
  CONSTANT fp_0v5  		: sfixed(1 downto -1)   := to_sfixed(0.5, 1, -1); -- 0.5
  CONSTANT fp_sqrt3_vdc : sfixed(2 downto -20) := to_sfixed(1.732/real(v_dc), 2, -20); -- sqrt(3)/v_dc
  CONSTANT fp_sqrt3_2  	: sfixed(20 downto -11) := to_sfixed(1.732/2.0, 20, -11); -- sqrt(3)/2  
 
  -- Fixed Point Signals for Firinig Calculations 
  signal fp_fire_u_12 	: sfixed(20 downto -11);
  signal fp_fire_u_34 	: sfixed(20 downto -11);
  signal fp_fire_u_56 	: sfixed(20 downto -11);
  signal fp_fire_v_12 	: sfixed(20 downto -11);
  signal fp_fire_v_34 	: sfixed(20 downto -11);  
  signal fp_fire_v_56 	: sfixed(20 downto -11); 
  signal fp_fire_w_12 	: sfixed(20 downto -11); 
  signal fp_fire_w_34 	: sfixed(20 downto -11);  
  signal fp_fire_w_56 	: sfixed(20 downto -11);
  
  -- Fixed point signals for output;
  signal fp_sqrt3_v_alpha 	: sfixed(20 downto -11);  

begin
  process(clk,reset_n)
  begin
    
	if(reset_n = '0') then
	  -- Asynchronous reset
	  -- Set all PWM firing time calculation to 0 
	  fp_fire_u_12 <= (OTHERS => '0'); 
	  fp_fire_u_34 <= (OTHERS => '0'); 
	  fp_fire_u_56 <= (OTHERS => '0'); 
	  fp_fire_v_12 <= (OTHERS => '0'); 
	  fp_fire_v_34 <= (OTHERS => '0'); 
	  fp_fire_v_56 <= (OTHERS => '0');
	  fp_fire_w_12 <= (OTHERS => '0'); 
	  fp_fire_w_34 <= (OTHERS => '0'); 
	  fp_fire_w_56 <= (OTHERS => '0');
	  fire_u <= (OTHERS => '0');
	  fire_v <= (OTHERS => '0');
	  fire_w <= (OTHERS => '0');
	
	elsif(clk'event and clk = '1') then
	 
	
	  -- Phase U, Sector 1/2, Firing Signal Calc
	  fp_fire_u_12 <= resize(fp_t0 - (fp_sqrt3_vdc*fp_t0)
	                        *(fp_sqrt3_2*fp_v_alpha + fp_0v5*fp_v_beta), fp_fire_u_12);
	 
	  -- Phase U, Section 3/4, Firiing Signal Calc
	  -- fire_u_34 = t0
      fp_fire_u_34 <= resize(fp_t0, fp_fire_u_34);
	  
	  -- Phase U, Section 5/6 Firing Signal Calc
	  fp_fire_u_56 <= resize(fp_t0 - (fp_sqrt3_vdc*fp_t0)
	                        *(fp_sqrt3_2*fp_v_alpha - fp_0v5*fp_v_beta), fp_fire_u_56);
	  
	  -- Phase V, Section 1/2 Firing Signal Calc
	  fp_fire_v_12 <= resize(fp_t0 - fp_sqrt3_vdc*fp_t0*fp_v_beta, fp_fire_v_12);
	  
	  -- Phase V, Section 3/4 Firing Signal Calc
	  fp_fire_v_34 <= resize(fp_t0 - (fp_sqrt3_vdc*fp_t0)
	                        *(-fp_sqrt3_2*fp_v_alpha + fp_0v5*fp_v_beta), fp_fire_v_34);
	
	  -- Phase V, Section 5/6 Firing Signal Calc
	  fp_fire_v_56 <= resize(fp_t0, fp_fire_v_56);
	  
	  -- Phase W, Section 1/2 Firing Signal Calc
	  fp_fire_w_12 <= resize(fp_t0, fp_fire_w_12);
	  
	  -- Phase W, Section 3/4 Firing Signal Calc
	  fp_fire_w_34 <= resize(fp_t0 - (fp_sqrt3_vdc*fp_t0)
	                        *(-fp_sqrt3_2*fp_v_alpha - fp_0v5*fp_v_beta), fp_fire_w_34);
	  
	  -- Phase W, Section 5/6 Firing Signal Calc
	  fp_fire_w_56 <= resize(fp_t0 + fp_sqrt3_vdc*fp_t0*fp_v_beta, fp_fire_w_56);
	  
	  
	  -- 3:1 Mux to select the output depending on sector of signal
      -- Calc value need for if/then statments	  
	  fp_sqrt3_v_alpha <= resize(fp_sqrt3*fp_v_alpha, fp_sqrt3_v_alpha);  
	  
	  -- Begin 3:1 mux
	  if (fp_v_alpha >= 0 and 0 < fp_v_beta and fp_v_beta < fp_sqrt3_v_alpha) or
           (fp_v_beta >= 0 and fp_v_beta >= abs(fp_sqrt3_v_alpha)) then
	    
		-- Set fireing time calculation for Sectors 1/2
		fire_u <= std_logic_vector(to_signed(fp_fire_u_12, fire_u'length));
		fire_v <= std_logic_vector(to_signed(fp_fire_v_12, fire_v'length));
		fire_w <= std_logic_vector(to_signed(fp_fire_w_12, fire_w'length));
		
	  elsif (fp_v_alpha <= 0 and 0 <= fp_v_beta and fp_v_beta <= -fp_sqrt3_v_alpha) or
	          (fp_v_alpha <= 0 and fp_sqrt3_v_alpha <= fp_v_beta and fp_v_beta < 0) then
	    
		-- Set fireing time calculation for Sectors 3/4
		fire_u <= std_logic_vector(to_signed(fp_fire_u_34, fire_u'length));
		fire_v <= std_logic_vector(to_signed(fp_fire_v_34, fire_v'length));
		fire_w <= std_logic_vector(to_signed(fp_fire_w_34, fire_w'length));
	  
	  elsif  (fp_v_beta <= 0 and fp_v_beta <= -abs(fp_sqrt3_v_alpha)) or
	           (fp_v_alpha >= 0 and -fp_sqrt3_v_alpha <= fp_v_beta and fp_v_beta < 0) then
		
		-- Set fireing time calculation for Sectors 5/6
		fire_u <= std_logic_vector(to_signed(fp_fire_u_56, fire_u'length));
		fire_v <= std_logic_vector(to_signed(fp_fire_v_56, fire_v'length));
		fire_w <= std_logic_vector(to_signed(fp_fire_w_56, fire_w'length));	
		
	  else
	    -- Default output to 0's
	    fire_u <= (OTHERS => '0');
		fire_v <= (OTHERS => '0');
		fire_w <= (OTHERS => '0');
	  end if; -- End 3:1 mux  
	  
	end if; 
  end process; 

end Behavioral;
