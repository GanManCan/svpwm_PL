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
		bits_res_low 	: integer := -11; 
	); 
	
	PORT( 
	  clk 			: in STD_LOGIC;
	  clarke_start 	: in STD_LOGIC; 
	  fp_y_a 		: in sfixed(bits_res_high downto bits_res_low);
	  fp_y_b 		: in sfixed(bits_res_high downto bits_res_low);
	  fp_y_c 		: in sfixed(bits_res_high downto bits_res_low); 
	  fp_y_alpha 	: out sfixed(bits_res_high downto bits_res_low);
	  fp_y_beta		: out sfixed(bits_res_high downto bits_res_low);
	  clarke_done 	: out std_logic
	);
end clarke_transform;

architecture logic of clarke_transform is

	-- Create State Machine Type
	type STATE_TYPE is (IDLE, MULT_Y_A, MULT_Y_B, DONE);
	signal state : STATE_TYPE; 
	
	-- Constant Declarations
	constant int_mult_conter : integer range 0 to 255 := 0; 
	
	-- Constants for math
	CONSTANT fp_2_3		: sfixed(1 downto bits_res_low) := to_sfixed(2.0/3.0, 1, bits_res_low);
	CONSTANT fp_1_3		: sfixed(1 downto bits_res_low) := to_sfixed(1.0/3.0, 1, bits_res_low);
	CONSTANT fp_2_sqrt3	: sfixed(1 downto bits_res_low) := to_sfixed(1.0/3.0, 1, bits_res_low);

	
	-- fixed point signal declaration
	fp_ya_min_yb	: sfixed(bits_res_high downto bits_res_low);

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
				
				when MULT_Y_A =>
					fp_ya_min_yb <= resize(fp_y_alpha - fp_y_beta,fp_ya_min_yb); 
					
				
				when MULT_Y_B =>
					fp_ya_min_yb <= resize(fp_y_alpha - fp_y_beta, fp_ya_min_yb); 
				
				when DONE =>
					clarke_done <= '1'; 
				
				when OTHERS => 
					-- Invalid State
					-- Stall state machine 
					clarke_done <= '0';
					fp_y_alpha <= (OTHERS => '0');
					fp_y_beta <= (OTHERS => '0'); 
			
			end case; -- case state
		
		end if; --if(reset_n=0)


end logic;
