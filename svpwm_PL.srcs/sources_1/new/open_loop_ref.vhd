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
--		Output: 
--  		-Fixed Point V_alpha and V_Beta reference wave form
--			  at the selected frequency. 
--			- Done Signal
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
		sys_clk		: integer := 50_000_000;
		freq_bits	: integer := 8
	);
    port(
		clk 				: IN std_logic;
		reset_n				: IN std_logic;
		en					: IN std_logic;
		freq				: IN std_logic_vector(freq_bits-1 downto 0); 
		fp_v_alpha_open		: OUT sfixed (20 downto -11);  
		fp_v_beta_open		: OUT sfixed (20 downto -11)
	);
end open_loop_ref;

architecture rtl of open_loop_ref is
	
	-- sine lookup table component descriptor
	component sine_lookup
		port(
			i_clk          : in  std_logic;
			i_addr         : in  std_logic_vector(15 downto 0);
			o_data         : out std_logic_vector(18 downto 0)
		); 
	end component; -- sine_lookup

	-- State Machine Declarations
	type STATE_TYPE is (IDLE, CALC_FREQ_COUNTER, V_ALPHA_LOOKUP, V_BETA_LOOKUP);
	signal state	: STATE_TYPE; 
	
	-- Constant Declarations
	constant TABLE_SIZE_SIN : integer range 0 to 255 := 251;  -- Table size defined in sine_lookup for 1/4 wave
	constant TABLE_SIZE_FULL: integer range 0 to 1024 := 1000; 
	constant SIN_SCALE_FACTOR : sfixed(20 downto -11) := to_sfixed(65535, 20, -11);
	
	
	-- Signal Declarations
	signal int_saved_freq		: integer; --range 0 to 2**(freq_bits); 
	signal int_rtc_clk_counter	: integer range 0 to 16777215 := 0;
	signal int_rtc_clk_setpoint : integer := sys_clk/60/TABLE_SIZE_FULL;  -- default to 60 Hz setpoitn. 
	signal int_v_alpha_counter	: integer range 0 to TABLE_SIZE_SIN*4 := 0; 
	signal int_v_beta_counter   : integer range 0 to TABLE_SIZE_SIN*4 := TABLE_SIZE_SIN;
	signal temp_fp_v_alpha	: sfixed(20 downto -11); 
	signal temp_fp_v_beta	: sfixed(20 downto -11);
	signal temp_o_data 		: std_logic_vector(18 downto 0); 
	signal sine_table_addr	: std_logic_vector(15 downto 0); 



begin 

	-- Comonent Declarations
	sine_lookup_1: sine_lookup
		port map(i_clk => clk, i_addr => sine_table_addr, o_data => temp_o_data);

	-- fast process
	system_clk : process(reset_n,clk)
	-- System_clk variable declarations
	
	begin
		if(reset_n = '0') then 
			-- Asynchronious reset
			int_saved_freq <= 1000; -- Set to 60 Hz default value. 
			int_rtc_clk_counter <= 0; -- Reset RTC Counter
			int_rtc_clk_setpoint <= 0; 
			fp_v_alpha_open <= (OTHERS => '0');
			fp_v_beta_open <= (OTHERS => '0');

			state <= IDLE;
			--int_rtc_clk_setpoint <= sys_clk/60; -- Set RTC counter to default 60 Hz
		
		elsif(clk'event and clk = '1') then
			
			-- RTC Counter Description
			-- If enabled, increment counter every clock cycle 
			if(en = '1') then
				int_rtc_clk_counter <= int_rtc_clk_counter + 1;
			end if; --if(en = '1')
				
			-- Create State machine
			case STATE is
				
				when CALC_FREQ_COUNTER =>
					-- Calculate new frequency counter setpoint
					-- Move to Idle state
					int_rtc_clk_setpoint <= sys_clk/int_saved_freq/TABLE_SIZE_FULL;
					state <= IDLE;
					
				when IDLE =>	
					-- output wave to from temp_wave
					fp_v_alpha_open <= temp_fp_v_alpha;
					fp_v_beta_open <= temp_fp_v_beta;
					
					-- Check for new frequency setpoint,
					-- if new, update saved_setpoint and calc new conutner
					if (to_integer(unsigned(freq)) /= int_saved_freq) then
					
						int_saved_freq <= to_integer(unsigned(freq));
						state <= CALC_FREQ_COUNTER; 					
					
					-- Check frequeny counter and move if counter is high enough
					elsif(int_rtc_clk_counter >= int_rtc_clk_setpoint) then
						-- reset counter, lookup value 
						int_rtc_clk_counter <= 0; 
						state <= V_ALPHA_LOOKUP; 
						
						-- increment v_alpha and v_beta pointers
						
						sine_table_addr <= std_logic_vector(to_signed((int_v_alpha_counter + 1), sine_table_addr'length)); 
						int_v_alpha_counter <= int_v_alpha_counter + 1;
						int_v_beta_counter <= int_v_beta_counter + 1;
						
						-- Range check pointer counters
						if(int_v_alpha_counter >= (TABLE_SIZE_SIN*4-4)) then
							int_v_alpha_counter <= 0; 
						end if; --if(int_v_alpha_counter ...) 
						
						if(int_v_beta_counter >= (TABLE_SIZE_SIN*4-4)) then
							int_v_beta_counter <= 0; 
						end if; --if(int_v_alpha_counter ...) 
						
					end if; --if (to_integer(signed(freq)) /= int_saved_freq)
					
					
					
				when V_ALPHA_LOOKUP =>
				-- Lookup V_Alpha from Sine table 
					
					-- Output v_alpha from lookup table 
					-- Change from std_logic_vector to sfixed
					temp_fp_v_alpha <= resize(to_sfixed(temp_o_data, temp_o_data'length-1, 0)/SIN_SCALE_FACTOR, temp_fp_v_alpha);
					
					-- Set next sine_save table for v_beta and move to next stae. 
					sine_table_addr <= std_logic_vector(to_signed(int_v_beta_counter, sine_table_addr'length));  
					state <= V_BETA_LOOKUP;
				
				when V_BETA_LOOKUP =>
					-- Lookup V_Beta from Sine Table
					
					-- Output v_beta from lookup table
					-- Change from std_logic_vector to sfixed
					temp_fp_v_beta <= resize(to_sfixed(temp_o_data, temp_o_data'length-1, 0)/SIN_SCALE_FACTOR, temp_fp_v_alpha);
					
					state <= IDLE; 
				
				when OTHERS =>
					-- Invalid State
					-- Set outputs to 0, stall in state; 
					fp_v_alpha_open <= (OTHERS => '0');
					fp_v_beta_open <= (OTHERS => '0');
					
			end case; -- case state
		
		end if; -- if(reset_n = '0'); 

	end process system_clk;
end rtl;
