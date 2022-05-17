----------------------------------------------------------------------------
--  % NAME        : svpwm_vunit_tb %                                 --
--  % PROJECT     : SVPWM_PL      %                                 --
--  % VERSION     :                  %                                 --
--  % CREATED_BY  : Matt Gannon      %                                 --
--  % DATE_CREATED: 2021-02-07        %                                 --
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
--  Test value lock in at top/bottom of counter
--  Test dead time 
--                                          --
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

LIBRARY TESTBENCH_LIB;
USE TESTBENCH_LIB.SVPWM_PL_TB_PKG.ALL;
--USE TB_LIB.MOTOR_TB_PKG.ALL;

library modelsim_lib;
use modelsim_lib.util.all;

use std.textio.all;
use ieee.std_logic_textio.all;




entity open_loop_vunit_tb is
  generic(runner_cfg : string := runner_cfg_default);
end entity open_loop_vunit_tb;



architecture tb of open_loop_vunit_tb is

  --------------------------------------------------------------------------
  -- TYPES, RECORDS, INTERNAL SIGNALS, FSM, CONSTANTS DECLARATION.
  --------------------------------------------------------------------------
  -- CONSTANTS DECLARATION --


  -- simulation constants :
  constant c_clk_period : time := 20 ns;
  

  -- INTERNAL SIGNALS DECLARATION --
  -- DUT constants
  constant sys_clk    : INTEGER := 50_000_000;  
  constant freq_bits  : INTEGER := 8;      

  -- DUT interface
  signal clk             : std_logic := '0';
  signal reset_n         : std_logic := '0';
  signal en              : std_logic := '1';
  signal freq            : std_logic_vector(freq_bits-1 downto 0);
  signal fp_v_alpha_open : sfixed (20 downto -11);
  signal fp_v_beta_open  : sfixed (20 downto -11);  
 
  -- Simulation Signals --
  signal sim_counter : INTEGER := 0; 
 -- signal sim_int_counter_period :INTEGER := sys_clk/pwm_freq/2;
  signal sim_counter_dir : std_logic := '1'; -- 1 is up direction

  -- Spy Signals  
  type STATE_TYPE is (IDLE, CALC_FREQ_COUNTER, V_ALPHA_LOOKUP, V_BETA_LOOKUP);

  alias spy_state is
    <<signal .open_loop_ref_inst.state : STATE_TYPE >>;

  alias spy_rtc_counter is
    <<signal .open_loop_ref_inst.int_rtc_clk_counter : INTEGER range 0 to 16777215 >>;

  alias spy_rtc_setpoint is
    <<signal .open_loop_ref_inst.int_rtc_clk_setpoint : INTEGER >>;

  
begin -- start of architecture -- 
  -------------------------------------------------------------------------- 
  -- DUT INSTANTIATION.
  --------------------------------------------------------------------------
  open_loop_ref_inst : entity DESIGN_LIB.open_loop_ref
    generic map (
      sys_clk   => sys_clk,
      freq_bits => freq_bits
    )
    port map (
      clk             => clk,
      reset_n         => reset_n,
      en              => en,
      freq            => freq,
      fp_v_alpha_open => fp_v_alpha_open,
      fp_v_beta_open  => fp_v_beta_open
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
    ------------------------------------------------------------------------
    -- test_runner variables 
    ------------------------------------------------------------------------

  begin
    -- setup VUnit
    test_runner_setup(runner, runner_cfg);
    -- enable logging for passing check
    show(get_logger(default_checker), display_handler, pass); 

    test_cases_loop : while test_suite loop
      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- check output when design all switches are OFF.
      -- Expected Result:
        --  fire_u/v/w = '111..111'
      ----------------------------------------------------------------------
      if run("open_loop_check_reset_values") then
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: open_loop_check_reset_values");
        info("--------------------------------------------------------------------------------");

        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait for 1 ps;

        check(fp_v_alpha_open = to_sfixed(0.0,20,-11), "Check v_alpha reset value");
        check(fp_v_beta_open = to_sfixed(0.0,20,-11), "Check v_beta reset value");
        check(spy_state = IDLE, "Check reset state");
        
        info("==== TEST CASE FINISHED =====");  

      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
        -- Check that out of bounds values go to default state
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      ELSIF run("open_loop_check_states") THEN
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: open_loop_check_states");
        info("--------------------------------------------------------------------------------");
        
        freq <= std_logic_vector(to_unsigned(60, freq'length));

        wait until reset_n = '1';
        wait for 1 ps;

        --check(spy_state = CALC_FREQ_COUNTER, "Check state enters CALC_FREQ_COUNTER 1");

        wait until rising_edge(clk);
        wait for 1 ps;

        --check(spy_state = IDLE, "Check state enters IDLE"); 

        wait until rising_edge(clk); 
        wait for 1 ps; 
        
        --check(spy_state = CALC_FREQ_COUNTER, "Check state enters CALC_FREQ_COUNTER 2");
         

        wait until rising_edge(clk);
        wait until rising_edge(clk);

        for i in 0 to 1_000_000   loop
          wait until rising_edge(clk);   
        end loop ;        
        wait for 1 ps;

   








        info("==== TEST CASE FINISHED ====="); 


      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- Check that out of bounds values go to default state
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      --ELSIF run("out_of_bounds_check") THEN
      --  info("--------------------------------------------------------------------------------");
      --  info("TEST CASE: out_of_bounds_check");
      --  info("--------------------------------------------------------------------------------");
      --  wait until reset_n = '1';

      --  info("==== TEST CASE FINISHED ====="); 

      end if; -- for test_suite
    end loop test_cases_loop;

    wait for 20 ns;
    test_runner_cleanup(runner); -- end of simulation 
  end process test_runner; 

end architecture tb; 