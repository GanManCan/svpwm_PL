----------------------------------------------------------------------------------
-- Engineer: Matthew Gannon 
-- 
-- Create Date: 06/18/2021 11:17:38 PM
-- Design Name: svpwm.vhd
-- Module Name: svpwm - Behavioral
-- Project Name: 
-- Target Devices: Pynq Z2
-- Tool Versions: 2020.2
-- Description: 
--   This file implements the SVPWM logic. 
--   
--   Inputs:
--      Alpha, Beta
--   Outputs:
--      Three Phase PWM Signals
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
--use IEEE.FIXED_PKG.ALL; -- For fixed point calculations



entity svpwm is
  GENERIC(
    sys_clk         : INTEGER := 50_000_000; --system clock freq in Hz
    pwm_freq        : INTEGER := 3_000;    --PWM switching freq in Hz
    bits_resolution : INTEGER := 32;          --bits of resolution for duty cycle
    dead_time_ns   	: INTEGER := 800   -- Dead time in ns
  );         
  PORT ( 
    clk       : IN std_logic;
    reset_n   : IN std_logic;
    ena       : IN std_logic ;
	fire_u    : IN std_logic_vector(bits_resolution-1 downto 0);
	fire_v    : IN std_logic_vector(bits_resolution-1 downto 0);
	fire_w    : IN std_logic_vector(bits_resolution-1 downto 0);
	gate_u    : OUT std_logic; -- Phase U Gate Drive signal [Top Transistor]
	gate_u_l  : OUT std_logic; -- Phase U Gate Drive signal [Bottom Transistor]
	gate_v    : OUT std_logic; -- Phase V Gate Drive signal [Top Transistor]
	gate_v_l  : OUT std_logic; -- Phase V Gate Drive signal [Bottom Transistor]
	gate_w    : OUT std_logic; -- Phase W Gate Drive signal [Top Transistor]
	gate_w_l  : OUT std_logic -- Phase W Gate Drive signal [Bottom Transistor]
  );
end svpwm;

architecture rtl of svpwm is

  -- CONSTANT DECLARATION
  CONSTANT int_t0    : INTEGER   := sys_clk/pwm_freq/2; -- Period = number of clocks in SVPWM cycle
                                                        -- Note 2 SVPWM cycles per switching cycle
  CONSTANT dead_time_cnt  	: INTEGER := sys_clk/1000/1000*dead_time_ns/1000;
  CONSTANT dead_time_cnt_2  : INTEGER := dead_time_cnt/2; 
													
  signal count_dir 		: std_logic  := '1'; -- 1 to count up; 0 to count down  
  signal counter        : integer range -65533 to 65533  := 0;   
  
  signal sig_gate_u     : std_logic := '0'; 
  signal sig_gate_v		: std_logic := '0'; 
  


begin
  process(clk, reset_n)
  begin
    if(reset_n = '0') then
		  counter <= 0; -- Clear Counter
		  count_dir <= '1'; -- Set count direction up. 
		  gate_u <= '0'; 
		  gate_u_l <= '0';
		  gate_v <= '0'; 
		  gate_v_l <= '0';
		  gate_w <= '0'; 
		  gate_w_l <= '0';
	
		elsif(clk'event and clk = '1') then
	
      -- Increment/Decrement Counter logic
      if(count_dir = '1') then
	  	  
	  	  counter <= counter + 1; -- increment counter

				-- If counter reaches period, change decrement
				if(counter >= int_t0-1) then
		  		count_dir <= '0'; 
				end if; -- if(count > int_t0)
      
      else

        counter <= counter - 1; 
				
				-- If counter reaches period, change to increment
				if(counter <= 1) then
		  		count_dir <= '1'; 
				end if; -- if(count <= 0)
    	end if; -- if(count_dir = '1') 
	  
	  
		  -----------------------------------------------
	      -- Output Logic for Phase U
		  -----------------------------------------------
		  if (to_integer(signed(fire_u)) >= int_t0) then
		    -- If fireing phase = period -> always output 0
				gate_u <= '0';
				gate_u_l <= '1';
			
		  elsif (to_integer(signed(fire_u)) >= (counter-dead_time_cnt_2))
	             and (to_integer(signed(fire_u)) <= (counter+dead_time_cnt_2)) then	  
				-- Check if gate is in dead_time
				-- Output both switches to 0 during dead time
				gate_u <= '0';
				gate_u_l <= '0';
	      
		  elsif	((counter+dead_time_cnt_2) > to_integer(signed(fire_u))) then
	      -- Set output to 1 if counter is greater than fire signal. 
				gate_u <= '1';
	      gate_u_l <= '0';

	    elsif ((counter-dead_time_cnt_2) < to_integer(signed(fire_u))) then
	      -- Set output to 0 if counter is less than fire signal (and dead_time); 
	      gate_u <= '0';
	      gate_u_l <= '1';

	    else
	      -- Catch all, set to 'safe' 0/0 output.
	      gate_u <= '0'; 
	      gate_u_l <= '0'; 
	    end if; --if (to_integer(signed(fire_u) >= int_t0)		
		
		  -----------------------------------------------
	      -- Output Logic for Phase V
		  -----------------------------------------------
		  if (to_integer(signed(fire_v)) >= int_t0) then
		    -- If fireing phase = period -> always output 0
				gate_v <= '0';
				gate_v_l <= '1';
			
		  elsif (to_integer(signed(fire_v)) >= (counter-dead_time_cnt_2))
	             and (to_integer(signed(fire_v)) <= (counter+dead_time_cnt_2)) then	  
				-- Check if gate is in dead_time
				-- Output both switches to 0 during dead time
				gate_v <= '0';
				gate_v_l <= '0';
		      
		  elsif	((counter+dead_time_cnt_2) > to_integer(signed(fire_v))) then
	      -- Set output to 1 if counter is greater than fire signal. 
				gate_v <= '1';
	      gate_v_l <= '0';

	    elsif ((counter-dead_time_cnt_2) < to_integer(signed(fire_v))) then
	      -- Set output to 0 if counter is less than fire signal (and dead_time); 
	      gate_v <= '0';
	      gate_v_l <= '1';

	    else
	      -- Catch all, set to 'safe' 0/0 output.
	      gate_v <= '0'; 
	      gate_v_l <= '0'; 
	    end if; --if (to_integer(signed(fire_v) >= int_t0)
		  
		  -----------------------------------------------
	      -- Output Logic for Phase W
		  -----------------------------------------------
		  if (to_integer(signed(fire_w)) >= int_t0) then
		    -- If fireing phase = period -> always output 0
				gate_w <= '0';
				gate_w_l <= '1';
			
		  elsif (to_integer(signed(fire_w)) >= (counter-dead_time_cnt_2))
	             and (to_integer(signed(fire_w)) <= (counter+dead_time_cnt_2)) then	  
				-- Check if gate is in dead_time
				-- Output both switches to 0 during dead time
				gate_w <= '0';
				gate_w_l <= '0';
		      
		  elsif	((counter+dead_time_cnt_2) > to_integer(signed(fire_w))) then
	      -- Set output to 1 if counter is greater than fire signal. 
				gate_w <= '1';
	      gate_w_l <= '0';
	      
	    elsif ((counter-dead_time_cnt_2) < to_integer(signed(fire_w))) then
	      -- Set output to 0 if counter is less than fire signal (and dead_time); 
	      gate_w <= '0';
	      gate_w_l <= '1';

	    else
	      -- Catch all, set to 'safe' 0/0 output.
	      gate_w <= '0'; 
	      gate_w_l <= '0'; 
	    end if; --if (to_integer(signed(fire_w) >= int_t0)
		
	  end if; --if(reset_n = '0')	
  end process; --process(clk,reset_n)	
end rtl;
