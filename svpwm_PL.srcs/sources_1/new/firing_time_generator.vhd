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
    clk    			: IN std_logic;
	reset_n			: IN std_logic;
	ena 			: IN std_logic; 
	fire_time_start	: IN std_logic; 
	fp_v_alpha 	: IN sfixed(20 downto -11); 
	fp_v_beta   : IN sfixed(20 downto -11);
	fire_time_done	: OUT std_logic; 
	-- Output firiing sectors 
	fire_u 	: OUT std_logic_vector(bits_resolution-1 downto 0);
	fire_v 	: OUT std_logic_vector(bits_resolution-1 downto 0);
	fire_w 	: OUT std_logic_vector(bits_resolution-1 downto 0)
	); 

end firing_time_generator;

architecture Behavioral of firing_time_generator is
	-- fp == fixed point
	  
	-- Create State Machine type
	ype STATE_TYPE is (IDLE,MULTIPLY, DONE);
	signal state : STATE_TYPE; 
	  
	-- CONSTANT DECCLARATIONS 
	CONSTANT fp_sqrt3 	: sfixed(2 downto -11)  := to_sfixed(1.732, 2, -11); -- sqrt(3) = 1.732
	CONSTANT fp_t0    	: sfixed(16 downto 0)   := to_sfixed(sys_clk/pwm_freq/2, 16, 0); -- Period = number of clocks in SVPWM cycle
																						 -- Note 2 SVPWM cycles per switching cycle
	CONSTANT fp_0v5  		: sfixed(1 downto -1)   := to_sfixed(0.5, 1, -1); -- 0.5
	CONSTANT fp_sqrt3_vdc : sfixed(2 downto -20) := to_sfixed(1.732/real(v_dc), 2, -20); -- sqrt(3)/v_dc
	CONSTANT fp_sqrt3_2  	: sfixed(20 downto -11) := to_sfixed(1.732/2.0, 20, -11); -- sqrt(3)/2  
	 
	-- SIGNAL declaratrions 
	signal fire_time_start : std_logic_vector := '0'; 	
	
	-- Fixed Point Signals for Firinig Calculations 
	signal fp_fire_u_temp   : sfixed(20 downto -11); 
	signal fp_fire_v_temp   : sfixed(20 downto -11); 
	signal fp_fire_w_temp   : sfixed(20 downto -11); 
	 
	-- Fixed point signals for output;
	signal fp_sqrt3_v_alpha 	: sfixed(20 downto -11); 

    -- Simulation Signals for debuging 
	signal sim_Sector	: integer := 0; -- Output the sector 

begin
  process(clk,reset_n)
  begin
    
	if(reset_n = '0') then
		-- Asynchronous reset
		-- Set all PWM firing time calculation to 1 to ensure outputs are '0'
		fp_fire_u_temp <= (OTHERS => '1'); 
		fp_fire_u_temp <= (OTHERS => '1'); 
		fp_fire_u_temp <= (OTHERS => '1'); 
		fire_u <= (OTHERS => '1');
		fire_v <= (OTHERS => '1');
		fire_w <= (OTHERS => '1');
		sim_sector <= 0; 
	
	elsif(clk'event and clk = '1') then
		case state is
			-- Start of state machine 
			when IDLE =>
				-- State: IDLE
				-- Output: 
				--    Multiplication from previous firing time calculation
				--    fire_time_done = 0
				--
				--  Transistion: 
				-- Move to multiply state on next clock signal after recieving firing_time_generator_start
				
				fire_time_done <= '0'; 
				
				if(fire_time_start = 0) then
			  
				end if; --if(firing_time_start = 0); 
			
			when MULTIPLY =>
								  
				-- 3:1 Mux to select the output depending on sector of signal
				-- Calc value need for if/then statments	  
				fp_sqrt3_v_alpha <= resize(fp_sqrt3*fp_v_alpha, fp_sqrt3_v_alpha);  
			  
				-- Begin 3:1 mux
				if (fp_v_alpha >= 0 and 0 < fp_v_beta and fp_v_beta < fp_sqrt3_v_alpha) or
				     (fp_v_beta >= 0 and fp_v_beta >= abs(fp_sqrt3_v_alpha)) then
					
					-- Sector 1/2, Firing Signal Calc
					fp_fire_u_temp <= resize(fp_t0 - (fp_sqrt3_vdc*fp_t0)
									        *(fp_sqrt3_2*fp_v_alpha + fp_0v5*fp_v_beta), fp_fire_u_temp);
					
					fp_fire_v_temp <= resize(fp_t0 - fp_sqrt3_vdc*fp_t0*fp_v_beta, fp_fire_v_temp);
					
					fp_fire_w_temp <= resize(fp_t0, fp_fire_w_temp);
					
					-- For simulation: set sector 
					sim_Sector <= 1; 
					
				elsif (fp_v_alpha <= 0 and 0 <= fp_v_beta and fp_v_beta <= -fp_sqrt3_v_alpha) or
				    	(fp_v_alpha <= 0 and fp_sqrt3_v_alpha <= fp_v_beta and fp_v_beta < 0) then
					
					-- Sector 3/4 Firiing Signal Calc
					fp_fire_u_temp <= resize(fp_t0, fp_fire_u_temp);
					
					fp_fire_v_temp <= resize(fp_t0 - (fp_sqrt3_vdc*fp_t0)
									        *(-fp_sqrt3_2*fp_v_alpha + fp_0v5*fp_v_beta), fp_fire_v_temp);
					
					fp_fire_w_temp <= resize(fp_t0 - (fp_sqrt3_vdc*fp_t0)
									        *(-fp_sqrt3_2*fp_v_alpha - fp_0v5*fp_v_beta), fp_fire_w_temp);
				
					-- For simulation: set sector 
					sim_Sector <= 3; 
					
				elsif  (fp_v_beta <= 0 and fp_v_beta <= -abs(fp_sqrt3_v_alpha)) or
					     (fp_v_alpha >= 0 and -fp_sqrt3_v_alpha <= fp_v_beta and fp_v_beta < 0) then
				
					-- Sector 5/6 Firing signal Calc
					fp_fire_u_temp <= resize(fp_t0 - (fp_sqrt3_vdc*fp_t0)
									        *(fp_sqrt3_2*fp_v_alpha - fp_0v5*fp_v_beta), fp_fire_u_temp);
					
					fp_fire_v_temp <= resize(fp_t0, fp_fire_v_temp);
					
					fp_fire_w_temp <= resize(fp_t0 + fp_sqrt3_vdc*fp_t0*fp_v_beta, fp_fire_w_temp);
				
					-- For simulation: set sector 
					sim_Sector <= 5; 
				
				else
					-- Default output to 0's
					fire_u <= (OTHERS => '1');
					fire_v <= (OTHERS => '1');
					fire_w <= (OTHERS => '1');
					
					-- For simulation: set sector 
					sim_Sector <= -;  
				end if; -- End 3:1 mux  
				
				
				-- Each clock cycle increment multiply counter and
				--   check if it is greater than the delay constant
				-- Set output if count is greater than delay 
				int_mult_delay <= int_mult_delay + 1; 
				if int_mult_count >= int_mult_delay then
					-- Output fireing time calculation for Sectors 1/2
					-- Set the output after the fp_fire_X_temp value has been calcualted
					fire_u <= std_logic_vector(to_signed(fp_fire_u_temp, fire_u'length));
					fire_v <= std_logic_vector(to_signed(fp_fire_v_temp, fire_v'length));
					fire_w <= std_logic_vector(to_signed(fp_fire_w_temp, fire_w'length));
					
					-- Move to next state
					state <= DONE; 
					
					-- reset multiply counter
					int_mult_cont <= 0; 
										
				end if; -- end if int_mult_count >= int_mult_delay; 
			
			when DONE =>
			
				-- Need to verify if transition same cycle or next cycle. 
				-- Raise done flag for 1 cycle
				-- Move to next state 
				fire_time_done <= '1';
				state <= IDLE; 
			
			when OTHERS =>
			  -- Invalid State
			  -- Set outputs to 0; stall state;
					fire_u <= (OTHERS => '1');
					fire_v <= (OTHERS => '1');
					fire_w <= (OTHERS => '1');
							
		end case; --end case state
	end if; -- end if(reset_n=0) 
  end process; 

end Behavioral;
