----------------------------------------------------------------------------
--  % NAME        : firing_time_generator_tb_vunit %                                 --
--  % PROJECT     : SVPWM_PL      %                                 --
--  % VERSION     :                  %                                 --
--  % CREATED_BY  : Matt Gannon      %                                 --
--  % DATE_CREATED: 2021-01-23        %                                 --
--                                                                        --
--  DESCRIPTION:                                                          --
--                                                                        --
----------------------------------------------------------------------------
--  REVISION HISTORY                                                      --
--                                                                        --
--  VERSION    DATE        SIGN      CHANGE DESCRIPTION                   --
--  ------- ----------  ----------   ------------------                   --
--                      --
--                                                                        --
----------------------------------------------------------------------------
--  TODO LIST                                                             --
--  Test reset
--  Test Initialization 
--  Test Do Nothin Until Receive Start Signal
-- 	Test Outputs for correct values
--     Test values for each sector 
--  Test out-of-bounds values
--  T                                         --
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- CONFIGURATION DECLARATION.
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- LIBRARY DECLARATION.
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.FIXED_PKG.ALL; 

LIBRARY VUNIT_LIB;
CONTEXT VUNIT_LIB.VUNIT_CONTEXT;

LIBRARY DESIGN_LIB;
--USE DESIGN_LIB.MOTOR_PKG.ALL;

LIBRARY TB_LIB;
--USE TB_LIB.MOTOR_TB_PKG.ALL;



entity firing_time_generator_tb_vunit is
  generic(runner_cfg : string := runner_cfg_default);
end entity firing_time_generator_tb_vunit;



architecture tb of firing_time_generator_tb_vunit is

  --------------------------------------------------------------------------
  -- TYPES, RECORDS, INTERNAL SIGNALS, FSM, CONSTANTS DECLARATION.
  --------------------------------------------------------------------------
  -- CONSTANTS DECLARATION --
  -- simulation constants
  constant c_clk_period : time := 10 ns; 

  -- DUT constants
  constant sys_clk         : INTEGER := 50_000_000;  
  constant pwm_freq        : INTEGER := 3_000;      
  constant bits_resolution : INTEGER := 32;           
  constant v_dc            : INTEGER := 200

  -- INTERNAL SIGNALS DECLARATION --
  -- DUT interface
  signal sys_clk         : i
  signal clk             : std_logic := 0;
  signal reset_n         : std_logic := 0;
  signal fire_time_start : std_logic := 0;
  signal fp_v_alpha      : sfixed(20 downto -11);
  signal fp_v_beta       : sfixed(20 downto -11);
  signal fire_time_done  : std_logic;
  signal fire_u          : std_logic_vector(bits_resolution-1 downto 0);
  signal fire_v          : std_logic_vector(bits_resolution-1 downto 0);
  signal fire_w          : std_logic_vector(bits_resolution-1 downto 0);  

begin -- start of architecture -- 
  -------------------------------------------------------------------------- 
  -- DUT INSTANTIATION.
  --------------------------------------------------------------------------
  

  firing_time_generator_tb_inst : entity work.firing_time_generator
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

  --------------------------------------------------------------------------
  -- CLOCK AND RESET.
  --------------------------------------------------------------------------
  clk   <= NOT clk after C_CLK_PERIOD / 2;
  reset_n <= '1' after 5 * (C_CLK_PERIOD / 2);

  --------------------------------------------------------------------------
  --------------------------------------------------------------------------
  -------------------------- TEST_RUNNER PROCESS ---------------------------
  --------------------------------------------------------------------------
  --------------------------------------------------------------------------

  test_runner : process
  begin
    -- setup VUnit
    test_runner_setup(runner, runner_cfg);
    -- enable logging for passing check
    show(get_logger(default_checker), display_handler, pass); 
    show(get_logger(RED_CHECKER), display_handler, pass); 

    test_cases_loop : while test_suite loop
      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- check output when design all switches are OFF.
      -- Expected Result:
        -- RED_LED    ==> '0'
        -- YELLOW_LED ==> '0' 
        -- GREEN_LED  ==> '0'
      ----------------------------------------------------------------------
      if run("check_reset_values") then
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: switches_off_output_check");
        info("--------------------------------------------------------------------------------");
        wait for 2*C_CLK_PERIOD;
      end if; -- for test_suite
    end loop test_cases_loop;

    wait for 20 ns;
    test_runner_cleanup(runner); -- end of simulation 
  end process test_runner; 

    
