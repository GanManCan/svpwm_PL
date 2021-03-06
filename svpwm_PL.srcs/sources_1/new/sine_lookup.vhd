library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sine_lookup is
port (
  i_clk          : in  std_logic;
  i_addr         : in  std_logic_vector(15 downto 0);
  o_data         : out std_logic_vector(18 downto 0));
end sine_lookup;

architecture rtl of sine_lookup is
type t_sin_table is array(0 to 250) of integer range 0 to 65535;

-- Constant declaration
constant TABLE_SIZE	: integer range 0 to 255 := 251; 

-- Signal Declaration


-- Sine Lookup Table with 251 entires
-- Lookup table represents sine 0 to pi/2
constant C_SIN_TABLE  : t_sin_table := (
0,412,824,1235,1647,2059,2470,2881,3293,3704,4115,4526,4937,5347,5757,6167,6577,6987,7396,7805,8214,8622,9030,9438,9845,10252,10658,
11064,11470,11875,12280,12684,13088,13491,13894,14296,14698,15099,15499,15899,16298,16696,17094,17491,17888,18284,18679,19073,19467,
19859,20251,20643,21033,21423,21811,22199,22586,22972,23357,23742,24125,24507,24889,25269,25649,26027,26404,26781,27156,27530,27903,
28275,28646,29016,29385,29752,30119,30484,30848,31210,31572,31932,32291,32649,33005,33360,33714,34066,34417,34767,35115,35462,35808,
36152,36495,36836,37176,37514,37851,38187,38521,38853,39184,39513,39841,40167,40491,40814,41136,41455,41774,42090,42405,42718,43029,
43339,43647,43953,44258,44561,44862,45161,45459,45754,46048,46340,46630,46919,47205,47490,47773,48054,48333,48610,48885,49159,49430,
49699,49967,50232,50496,50757,51017,51274,51529,51783,52034,52283,52531,52776,53019,53260,53499,53736,53970,54203,54433,54661,54887,
55111,55333,55553,55770,55985,56198,56409,56617,56823,57027,57229,57429,57626,57821,58014,58204,58392,58578,58761,58943,59121,59298,
59472,59644,59813,59980,60145,60307,60467,60625,60780,60933,61083,61231,61377,61520,61661,61799,61935,62068,62199,62327,62454,62577,
62698,62817,62933,63046,63158,63266,63372,63476,63577,63676,63772,63866,63957,64045,64131,64215,64296,64374,64450,64523,64594,64662,
64728,64791,64852,64910,64965,65018,65069,65116,65162,65204,65244,65282,65317,65349,65379,65406,65430,65452,65472,65488,65503,65514,
65523,65530,65534,65535
);


begin

--------------------------------------------------------------------

p_table : process(i_clk)
	-- p_table variables
	variable int_i_addr_temp 	: integer := 0; 

begin
  if(rising_edge(i_clk)) then
  	
		-- Map the output 0 to pi/2 to entire sine wave 
		-- 0 to pi/2 output 
		if(to_integer(unsigned(i_addr)) >= 0 and to_integer(unsigned(i_addr)) < (TABLE_SIZE)) then
			-- output 
			-- if i_add is in range output data		
			o_data  <= std_logic_vector(to_signed(C_SIN_TABLE(to_integer(unsigned(i_addr))),o_data'length));
		
		-- pi/2 to pi output 
		elsif((to_integer(unsigned(i_addr)) >= TABLE_SIZE) and (to_integer(unsigned(i_addr)) < 2*TABLE_SIZE-1)) then
			
			-- calclate MOD value to keep in range of 0 to pi/2
			int_i_addr_temp := 2*TABLE_SIZE - to_integer(unsigned(i_addr))-2; 
			o_data <= std_logic_vector(to_signed(C_SIN_TABLE(int_i_addr_temp), o_data'length)); 
		
		-- pi to 3*pi/2
		elsif((to_integer(unsigned(i_addr)) >= 2*TABLE_SIZE-1) and (to_integer(unsigned(i_addr)) < 3*TABLE_SIZE-2)) then
			
			int_i_addr_temp := to_integer(unsigned(i_addr)) - 2*TABLE_SIZE+2; 
			o_data <= std_logic_vector(to_signed(-1*C_SIN_TABLE(int_i_addr_temp), o_data'length)); 
		
		-- 3*pi/2 to 2*p
		elsif((to_integer(unsigned(i_addr)) >= 3*TABLE_SIZE-2) and (to_integer(unsigned(i_addr)) < 4*TABLE_SIZE-4)) then
			int_i_addr_temp := 4*TABLE_SIZE-to_integer(unsigned(i_addr))-4; 
			o_data <= std_logic_vector(to_signed(-1*C_SIN_TABLE(int_i_addr_temp), o_data'length));
		else
			-- Add input checking to i_addr value to hard coded sine table size
			-- Default output 0 
			o_data <= (others => '0'); 
		end if; -- range check 
  end if; --rising_edge(i_clk)
end process p_table;

end rtl;