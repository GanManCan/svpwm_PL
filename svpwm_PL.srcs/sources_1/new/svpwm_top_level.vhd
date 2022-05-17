----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/17/2021 06:10:23 PM
-- Design Name: 
-- Module Name: svpwm_top_level - Behavioral
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


entity svpwm_top_level is
  Port ( 
    clk 	  : in std_logic;
		reset_n   : in std_logic; 
    --v_alpha   : in std_logic_vector(31 downto 0); 
		--v_beta    : in std_logic_vector(31 downto 0); 
		gate_u, gate_u_l : out std_logic;
		gate_v, gate_v_l : out std_logic; 
		gate_w, gate_w_l : out std_logic
  );
end svpwm_top_level;


architecture rtl of svpwm_top_level is
  
  -- --  open loop component descripor 
	component open_loop_ref is
		generic (
			sys_clk   : integer := 50_000_000;
			freq_bits : integer := 8
		);
		port (
			clk             : IN  std_logic;
			reset_n         : IN  std_logic;
			en              : IN  std_logic;
			freq            : IN  std_logic_vector(freq_bits-1 downto 0);
			fp_v_alpha_open : OUT sfixed (20 downto -11);
			fp_v_beta_open  : OUT sfixed (20 downto -11)
		);
	end component open_loop_ref;

  -- firing_time_generator component descriptor
	component firing_time_generator is
		generic (
			sys_clk         : INTEGER := 50_000_000;
			pwm_freq        : INTEGER := 3_000;
			bits_resolution : INTEGER := 32;
			v_dc            : INTEGER := 200
		);
		port (
			clk             : IN  std_logic;
			reset_n         : IN  std_logic;
			fire_time_start : IN  std_logic;
			fp_v_alpha      : IN  sfixed(20 downto -11);
			fp_v_beta       : IN  sfixed(20 downto -11);
			fire_time_done  : OUT std_logic;
			fire_u          : OUT std_logic_vector(bits_resolution-1 downto 0);
			fire_v          : OUT std_logic_vector(bits_resolution-1 downto 0);
			fire_w          : OUT std_logic_vector(bits_resolution-1 downto 0)
		);
	end component firing_time_generator; 	

  -- svpwm component descriptor 
	component svpwm is
		generic (
			sys_clk         : INTEGER := 50_000_000;
			pwm_freq        : INTEGER := 3_000;
			bits_resolution : INTEGER := 32;
			dead_time_ns    : INTEGER := 800
		);
		port (
			clk      : IN  std_logic;
			reset_n  : IN  std_logic;
			ena      : IN  std_logic;
			fire_u   : IN  std_logic_vector(bits_resolution-1 downto 0);
			fire_v   : IN  std_logic_vector(bits_resolution-1 downto 0);
			fire_w   : IN  std_logic_vector(bits_resolution-1 downto 0);
			gate_u   : OUT std_logic;
			gate_u_l : OUT std_logic;
			gate_v   : OUT std_logic;
			gate_v_l : OUT std_logic;
			gate_w   : OUT std_logic;
			gate_w_l : OUT std_logic
		);
	end component svpwm;  
  
  ------------------------------------------------------------------------------
  -- Constant Declaration
  ------------------------------------------------------------------------------
  constant freq_bits 				: integer := 8; 
  constant sys_clk					: integer := 50_000_000;
  constant dead_time_ns 		: integer := 10;
  constant v_dc							: integer := 200; 
  constant bits_resolution 	: integer := 32; 
  constant pwm_freq 				: integer := 3_000; 

  ------------------------------------------------------------------------------
	-- Signal Declarations
	------------------------------------------------------------------------------

	--  open_loop_ref signals
	signal en              : std_logic := '1';
	signal freq            : std_logic_vector(freq_bits-1 downto 0);
	signal fp_v_alpha_open : sfixed (20 downto -11);
	signal fp_v_beta_open  : sfixed (20 downto -11);	

	-- Open_loop_ref signals
	signal fp_v_alpha      : sfixed(20 downto -11);
	signal fp_v_beta       : sfixed(20 downto -11);
	signal fire_time_start : std_logic := '1';
	signal fire_time_done  : std_logic;
	signal fire_u          : std_logic_vector(bits_resolution-1 downto 0);
	signal fire_v          : std_logic_vector(bits_resolution-1 downto 0);
	signal fire_w          : std_logic_vector(bits_resolution-1 downto 0);	
 
  
	-- Temp signals
	signal v_alpha   : std_logic_vector(31 downto 0) := (OTHERS => '0'); 
	signal v_beta    : std_logic_vector(31 downto 0) := (OTHERS => '0'); 

---------------------------------------------------------------------------------
-- Begin
--------------------------------------------------------------------------------
begin

	freq <= std_logic_vector(to_unsigned(60, freq'length));

	open_loop_ref_1 : entity work.open_loop_ref
		generic map (
			sys_clk   => sys_clk,
			freq_bits => freq_bits
		)
		port map (
			clk             => clk,
			reset_n         => reset_n,
			en              => en,
			freq            => freq,
			fp_v_alpha_open => fp_v_alpha,
			fp_v_beta_open  => fp_v_beta
		);  

	firing_time_generator_1 : entity work.firing_time_generator
		generic map (
			sys_clk         => sys_clk,
			pwm_freq        => pwm_freq,
			bits_resolution => bits_resolution,
			v_dc            => v_dc
		)
		port map (
			clk             => clk,
			reset_n         => reset_n,
			fire_time_start => fire_time_start,
			fp_v_alpha      => fp_v_alpha,
			fp_v_beta       => fp_v_beta,
			fire_time_done  => fire_time_done,
			fire_u          => fire_u,
			fire_v          => fire_v,
			fire_w          => fire_w
		);	

		svpwm_1 : entity work.svpwm
			generic map (
				sys_clk         => sys_clk,
				pwm_freq        => pwm_freq,
				bits_resolution => bits_resolution,
				dead_time_ns    => dead_time_ns
			)
			port map (
				clk      => clk,
				reset_n  => reset_n,
				ena      => en,
				fire_u   => fire_u,
				fire_v   => fire_v,
				fire_w   => fire_w,
				gate_u   => gate_u,
				gate_u_l => gate_u_l,
				gate_v   => gate_v,
				gate_v_l => gate_v_l,
				gate_w   => gate_w,
				gate_w_l => gate_w_l
			);   


end rtl;
