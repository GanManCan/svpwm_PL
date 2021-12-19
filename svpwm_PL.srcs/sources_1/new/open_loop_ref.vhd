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
	temp_fp_v_alpha	: sfixed (20 downto -11); 
	temp_fp_v_beta	: sfixed (20 downto -11);



begin

-- fast process
system_clk : process(clk)
begin
	if(reset_n = '0') then 
		-- Asynchronious reset
	else if(clk'event and clk = '1')
		
		-- RTC Counter Description
		-- Every clock cycle incremnet the counter, 
		rtc_clk_counter <= rtc_clk_counter + 1;
		
		if (rtc_clk_counter = 0) then
			rtc_clk_enable <= '1';
		else
			rtc_clk_enable <= '0';
		end if; -- if(rtc_clk_counter = 0)
	
		-- Create State machine
		case STATE is
			when IDLE =>
			
			when CALC_FREQ_COUNTER =>
			
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
