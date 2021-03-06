----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/19/2021 09:21:18 AM
-- Design Name: 
-- Module Name: clarke_transform - logic
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--   See clarke_transform
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

entity clarke_transform is
	GENERIC(
		bits_res_high	: integer := 20;
		bits_res_low 	: integer := -11 
	); 
	
	PORT( 
	  clk 			: in STD_LOGIC;
	  clarke_start 	: in STD_LOGIC; 
	  reset_n		: in std_logic; 
	  fp_y_a 		: in sfixed(bits_res_high downto bits_res_low);
	  fp_y_b 		: in sfixed(bits_res_high downto bits_res_low);
	  fp_y_c 		: in sfixed(bits_res_high downto bits_res_low); 
	  fp_y_alpha 	: out sfixed(bits_res_high downto bits_res_low);
	  fp_y_beta		: out sfixed(bits_res_high downto bits_res_low);
	  clarke_done 	: out std_logic
	);
end clarke_transform;

architecture rtl of clarke_transform is

	-- Create State Machine Type
	type STATE_TYPE is (IDLE, MULT_Y_ALPHA, MULT_Y_BETA, DONE);
	signal state : STATE_TYPE; 
	
	-- Constant Declarations
	CONSTANT int_mult_delay : integer range 0 to 7 := 2; 
	
	-- Constants for math
	CONSTANT fp_2_3		: sfixed(1 downto bits_res_low) := to_sfixed(2.0/3.0, 1, bits_res_low);
	CONSTANT fp_1_3		: sfixed(1 downto bits_res_low) := to_sfixed(1.0/3.0, 1, bits_res_low);
	CONSTANT fp_2_sqrt3	: sfixed(1 downto bits_res_low) := to_sfixed(1.0/3.0, 1, bits_res_low);

	-- signal declarations
	signal int_mult_count : integer range 0 to 255 := 0; 
	
	-- fixed point signal declaration
	signal fp_y_a_hold, fp_y_b_hold, fp_y_c_hold : sfixed(bits_res_high downto bits_res_low); 
	signal fp_yb_min_yc	: sfixed(bits_res_high downto bits_res_low);

begin
	process(clk,reset_n)
	begin
	
		if(reset_n = '0') then
			
			fp_y_alpha <= (OTHERS => '0');
			fp_y_beta <= (OTHERS => '0'); 
			clarke_done <= '0'; 
			state <= IDLE; 
		
		elsif(clk'event and clk = '1') then
		
			
			case state is
			
				when IDLE =>
					clarke_done <= '0'; 
								
					if(clarke_start = '1') then
						-- Lock in y_alpha and y_beta for calculations
						fp_y_a_hold <= fp_y_a; 
						fp_y_b_hold <= fp_y_b;
						fp_y_c_hold <= fp_y_c; 
						
						-- Calculate subtraction used for this and next multiplication
						fp_yb_min_yc <= resize(fp_y_b- fp_y_c, fp_yb_min_yc);
						
						-- Move to next state
						state <= MULT_Y_ALPHA; 
						
					end if; --if(clark_starte = 1)
				when MULT_Y_ALPHA =>
					
					 
					-- Calcualte y_alpha
					fp_y_alpha <= resize(fp_2_3*fp_y_a_hold - fp_1_3*fp_yb_min_yc, fp_y_a_hold);
					
					-- Increment multiply counter and check for next state; 
					int_mult_count <= int_mult_count + 1; 
					if(int_mult_count >= int_mult_delay) then
						int_mult_count <= 0;  
						state <= MULT_Y_BETA;  
					end if; -- end if(int_mult_count>- int_mult_delay); 
					
				
				when MULT_Y_BETA =>
					
							
					-- Calcualte y_alpha
					fp_y_beta <= resize(fp_2_sqrt3*fp_yb_min_yc, fp_y_b_hold);
					
					-- Increment multiply counter and check for next state; 
					int_mult_count <= int_mult_count + 1; 
					if(int_mult_count >= int_mult_delay) then
						int_mult_count <= 0;  
						state <= DONE;  
					end if; -- end if(int_mult_count>- int_mult_delay); 
				
				when DONE =>
					-- Raise clarke_done flag for one clock cyle 
					--  and move to IDLE state
					clarke_done <= '1'; 
					state <= IDLE; 
					
				when OTHERS => 
					-- Invalid State
					-- Stall state machine 
					clarke_done <= '0';
					fp_y_alpha <= (OTHERS => '0');
					fp_y_beta <= (OTHERS => '0'); 
			
			end case; -- case state
		end if; --if(reset_n=0)
	end process; 
end rtl;
