----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: open_loop_ref
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 		Creates the open loop reference wavefor for the function. 
--		
--		En
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity open_loop_ref is
	generic(
		sys_clk		: integer := 50_000_000
	);
    port(
		clk 				: IN std_logic;
		reset_n				: IN std_logic;
		en					: IN std_logic;
		freq				: IN std_logic_vector(7 downto 0); 
		fp_v_alpha_open		: OUT sfixed (20 downto -11);  
		fp_v_beta_open		: OUT sfixed (20 downto -11)
	);
end open_loop_ref;

architecture behavioral of open_loop_ref is
	
	-- sine lookup table component descriptor
	component sine_lookup
		port(
			i_clk          : in  std_logic;
			i_addr         : in  std_logic_vector(7 downto 0);
			o_data         : out std_logic_vector(15 downto 0));
		); 
	end component; -- sine_lookup

	-- State Machine Declarations
	type STATE_TYPE is (IDLE, CALC_FREQ_COUNTER, V_ALPHA_LOOKUP, V_BETA_LOOKUP)
	signal state	: STATE_TYPE; 
	
	
	
	-- Signal Declarations
	signal saved_freq		: std_logic_vector(7 downto 0); 
	signal rtc_clk_counter	: integer range 0 to 16777215 := 0;
	signal rtc_clk_setpoint : integer := sys_clk/60;  -- default to 60 Hz setpoitn. 
	signal temp_fp_v_alpha	: sfixed (20 downto -11); 
	signal temp_fp_v_beta	: sfixed (20 downto -11);



begin

-- fast process
system_clk : process(clk)
begin
	if(reset_n = '0') then 
		-- Asynchronious reset
		saved_freq <= conv_std_logic_vector(60, saved_freq'length); -- Set to 60 Hz default value. 
		rtc_clk_counter <= 0; -- Reset RTC Counter
		rtc_clk_setpoint <= sys_clk/60; -- Set RTC counter to default 60 Hz
	
	else if(clk'event and clk = '1')
		
		-- RTC Counter Description
		-- If enabled, increment counter every clock cycle 
		if(en = '1') then
			rtc_clk_counter <= rtc_clk_counter + 1;
		end if; --if(en = '1')
		
		-- Check if RTC clk is above setpoing
		if (rtc_clk_counter >= rtc_clk_setpoint) then
			rtc_clk_enable <= '1';
		else
			rtc_clk_enable <= '0';
		end if; -- if(rtc_clk_counter = 0)
	
		-- Create State machine
		case STATE is
			
			when CALC_FREQ_COUNTER =>
				-- Calculate new frequency counter setpoint
				-- Move to Idle state
				rtc_clk_setpoint <= sys_clk/saved_freq;
				state <= IDLE;
				
			when IDLE =>
			
				-- Check for new frequency setpoint,
				-- if new, update saved_setpoint and calc new conutner
				if (freq != saved_freq) then
					saved_freq <= freq;
					state <= CALC_FREQ_COUNTER; 
				end if; --if(freq != prev_freq
				
				if(rtc_clk_counter >= rtc_clk_setpoint) then
					-- reset counter, lookup value 
					rtc_clk_counter <= 0; 
					state <= V_ALPHA_LOOKUP; 
				
			when V_ALPHA_LOOKUP =>
				
			
			when V_BETA_LOOKUP =>
			
			when OTHERS =>
				-- Invalid State
				-- Set outputs to 0, stall in state; 
		end case; -- case state
	
	end if; -- if(reset_n = '0'); 

end process system_clk;

-- slow process
open_loop_clk: process(clk)
begin
	
	if(reset_n = '0') then
		-- reset_stuff
	elsif(clk'event and clk = '1' and rtc_clk_enable = '1') then
		-- do rtc clk process
	end if; -- if(reset_n = '0'); 
	
end process open_loop_clk; 


end behavioral;
