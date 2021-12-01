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
--   See clarke_transform vhdl lucid chart
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
    
	
	Port ( 
	  clk 			: in STD_LOGIC;
	  clarke_start 	: in STD_LOGIC; 
	  y_a 			: in STD_LOGIC_VECTOR
	  y_b 			: in 
	  y_c 			: in 
	  y_alpha 		: out
	  y_beta		: out
	  y_gamma		: out
	  clarke_done 	: out std_logic
	);
end clarke_transform;

architecture logic of clarke_transform is

begin


end logic;
