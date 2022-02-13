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
  CONSTANT dead_time_compare  	: INTEGER := sys_clk/1000/1000*dead_time_ns/1000;
  CONSTANT dead_time_cnt  	: INTEGER := sys_clk/1000/1000*dead_time_ns/1000;
  CONSTANT dead_time_cnt_2  : INTEGER := dead_time_cnt/2; 
													
  signal count_dir 			: std_logic  := '1'; -- 1 to count up; 0 to count down  
  signal counter        : integer range -65533 to 65533  := 0;   
  
  signal lock_fire_u   : std_logic_Vector(bits_resolution-1 downto 0) := (OTHERS => '1');
  signal lock_fire_v   : std_logic_Vector(bits_resolution-1 downto 0) := (OTHERS => '1');
  signal lock_fire_w   : std_logic_Vector(bits_resolution-1 downto 0) := (OTHERS => '1');

  signal dead_time_flag_u : std_logic := '0'; 
  signal dead_time_cnt_u 	: integer range 0 to 8191 := 0; 
  signal dead_time_flag_v : std_logic := '0'; 
  signal dead_time_cnt_v	: integer range 0 to 8191 := 0; 
  signal dead_time_flag_w : std_logic := '0'; 
  signal dead_time_cnt_w 	: integer range 0 to 8191 := 0; 


begin
  process(clk, reset_n)
  	-- PROCESS VARIABLE
  	variable var_gate_u		: std_logic := '0';
  	variable var_gate_u_l	: std_logic := '0';
  	variable var_gate_v		: std_logic := '0';
  	variable var_gate_v_l	: std_logic := '0';
  	variable var_gate_w		: std_logic := '0';
  	variable var_gate_w_l	: std_logic := '0';
  begin
    if(reset_n = '0') then
		  counter 		<= 0; -- Clear Counter
		  count_dir 	<= '1'; -- Set count direction up. 
		  gate_u 			<= '0'; 
		  gate_u_l 		<= '0';
		  gate_v 			<= '0'; 
		  gate_v_l 		<= '0';
		  gate_w 			<= '0'; 
		  gate_w_l 		<= '0';
		  lock_fire_u <= fire_u; 
		  lock_fire_v <= fire_v;
		  lock_fire_w <= fire_w; 

		  dead_time_flag_u <= '0'; 
		  dead_time_cnt_u <= 0; 
		  var_gate_u 		:= '0';
		  var_gate_u_l 	:= '0'; 

		  dead_time_flag_v <= '0'; 
		  dead_time_cnt_v <= 0; 
		  var_gate_v 		:= '0';
		  var_gate_v_l 	:= '0';

		  dead_time_flag_w <= '0'; 
		  dead_time_cnt_w <= 0; 
		  var_gate_w 		:= '0';
		  var_gate_w_l 	:= '0';
	
		elsif(clk'event and clk = '1') then
	
      -- Increment/Decrement Counter logic
      if(count_dir = '1') then
	  	  
	  	  counter <= counter + 1; -- increment counter

				-- If counter reaches period, change decrement, lock in fire value
				if(counter >= int_t0-1) then
		  		count_dir <= '0'; 
		  		lock_fire_u <= fire_u; 
		  		lock_fire_v <= fire_v;
		  		lock_fire_w <= fire_w;
				end if; -- if(count > int_t0)
      
      else

        counter <= counter - 1; 
				
				-- If counter reaches period, change to increment, lock in fire value
				if(counter <= 1) then
		  		count_dir <= '1'; 
		  		lock_fire_u <= fire_u; 
		  		lock_fire_v <= fire_v;
		  		lock_fire_w <= fire_w;
				end if; -- if(count <= 0)
    	end if; -- if(count_dir = '1') 
	  
	  
		  -----------------------------------------------
	      -- Output Logic for Phase U
		  -----------------------------------------------
		  if(dead_time_flag_u = '1') then
		  	gate_u <= '0'; 
	      gate_u_l <= '0'; 
	      var_gate_u := '0';
	      var_gate_u_l := '0';

		  elsif(counter <= to_integer(signed(lock_fire_u))) then
		    -- If fireing phase = period -> always output 0
				gate_u_l <= '1';
				var_gate_u_l := '1';
			
		  elsif (counter > to_integer(signed(lock_fire_u))) then
	      -- Set output to 0 if counter is less than fire signal (and dead_time); 
	      gate_u <= '1';
	      var_gate_u := '1';

	    else
	      -- Catch all, set to 'safe' 0/0 output.
	      gate_u <= '0'; 
	      gate_u_l <= '0'; 
	      var_gate_u := '0';
	      var_gate_u_l := '0';

	    end if; --if (dead_time_flag_u = '1')		
		
		  -----------------------------------------------
	      -- Output Logic for Phase V
		  -----------------------------------------------
		  if(dead_time_flag_v = '1') then
		  	gate_v <= '0'; 
	      gate_v_l <= '0'; 
	      var_gate_v := '0';
	      var_gate_v_l := '0';

		  elsif(counter <= to_integer(signed(lock_fire_v))) then
		    -- If fireing phase = period -> always output 0
				gate_v_l <= '1';
				var_gate_v_l := '1';
			
		  elsif (counter > to_integer(signed(lock_fire_v))) then
	      -- Set output to 0 if counter is less than fire signal (and dead_time); 
	      gate_v <= '1';
	      var_gate_v := '1';

	    else
	      -- Catch all, set to 'safe' 0/0 output.
	      gate_v <= '0'; 
	      gate_v_l <= '0'; 
	      var_gate_v := '0';
	      var_gate_v_l := '0';

	    end if; --if (dead_time_flag_v = '1')	
		  
		  -----------------------------------------------
	      -- Output Logic for Phase W
		  -----------------------------------------------
		  if(dead_time_flag_w = '1') then
		  	gate_w <= '0'; 
	      gate_w_l <= '0'; 
	      var_gate_w := '0';
	      var_gate_w_l := '0';

		  elsif(counter <= to_integer(signed(lock_fire_w))) then
		    -- If fireing phase = period -> always output 0
				gate_w_l <= '1';
				var_gate_w_l := '1';
			
		  elsif (counter > to_integer(signed(lock_fire_w))) then
	      -- Set output to 0 if counter is less than fire signal (and dead_time); 
	      gate_w <= '1';
	      var_gate_w := '1';

	    else
	      -- Catch all, set to 'safe' 0/0 output.
	      gate_w <= '0'; 
	      gate_w_l <= '0'; 
	      var_gate_w := '0';
	      var_gate_w_l := '0';

	    end if; --if (dead_time_flag_w = '1')		

	    --------------------------------------------------------------------------
	    -- Dead Time Logic: Phase U
	    --------------------------------------------------------------------------
	    if(var_gate_u = '1' and var_gate_u_l = '1') then
	   		gate_u <= '0'; 
	   		gate_u_l <= '0'; 
	   		var_gate_u := '0';
	   		var_gate_u_l := '0';
	   		dead_time_flag_u <= '1'; 
	   		dead_time_cnt_u <= 1; 
	   	end if; -- if(var_gate_u = '1'...

	   	if(dead_time_flag_u = '1') then

	   		dead_time_cnt_u <= dead_time_cnt_u+1;

	   		if(dead_time_cnt_u >= dead_time_compare) then
	   			dead_time_flag_u <= '0';
	   			dead_time_cnt_u <= 0; 
	   		end if; --if(dead_time_cnt_u >= dead_time_compare)

	   	end if; --if(dead_time_flag_u = '1')

	   	--------------------------------------------------------------------------
	    -- Dead Time Logic: Phase V
	    --------------------------------------------------------------------------
	    if(var_gate_v = '1' and var_gate_v_l = '1') then
	   		gate_v <= '0'; 
	   		gate_v_l <= '0'; 
	   		var_gate_v := '0';
	   		var_gate_v_l := '0';
	   		dead_time_flag_v <= '1'; 
	   		dead_time_cnt_v <= 1; 
	   	end if; -- if(var_gate_v = '1'...

	   	if(dead_time_flag_v = '1') then

	   		dead_time_cnt_v <= dead_time_cnt_v+1;

	   		if(dead_time_cnt_v >= dead_time_compare) then
	   			dead_time_flag_v <= '0';
	   			dead_time_cnt_v <= 0; 
	   		end if; --if(dead_time_cnt_v >= dead_time_compare)

	   	end if; --if(dead_time_flag_v = '1')

	   	--------------------------------------------------------------------------
	    -- Dead Time Logic: Phase W
	    --------------------------------------------------------------------------
	    if(var_gate_w = '1' and var_gate_w_l = '1') then
	   		gate_w <= '0'; 
	   		gate_w_l <= '0'; 
	   		var_gate_w := '0';
	   		var_gate_w_l := '0';
	   		dead_time_flag_w <= '1'; 
	   		dead_time_cnt_w <= 1; 
	   	end if; -- if(var_gate_w = '1'...

	   	if(dead_time_flag_w = '1') then

	   		dead_time_cnt_w <= dead_time_cnt_w+1;

	   		if(dead_time_cnt_w >= dead_time_compare) then
	   			dead_time_flag_w <= '0';
	   			dead_time_cnt_w <= 0; 
	   		end if; --if(dead_time_cnt_w >= dead_time_compare)

	   	end if; --if(dead_time_flag_w = '1')
	





	  end if; --if(reset_n = '0')	
  end process; --process(clk,reset_n)	

end rtl;
