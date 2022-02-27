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
use IEEE.MATH_REAL.ALL;

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




entity sin_lookup_vunit_tb is
  generic(runner_cfg : string := runner_cfg_default);
end entity sin_lookup_vunit_tb;



architecture tb of sin_lookup_vunit_tb is

  --------------------------------------------------------------------------
  -- TYPES, RECORDS, INTERNAL SIGNALS, FSM, CONSTANTS DECLARATION.
  --------------------------------------------------------------------------
  -- CONSTANTS DECLARATION --


  -- simulation constants :
  constant c_clk_period : time := 20 ns;
  

  -- INTERNAL SIGNALS DECLARATION --
  -- DUT constants

  -- DUT interface
  signal i_clk  : std_logic := '0';
  signal i_addr : std_logic_vector(15 downto 0);
  signal o_data : std_logic_vector(18 downto 0);  


  -- Simulation Constants
  constant TABLE_SIZE : INTEGER := 251; 
  constant MIN_INDEX  : INTEGER := 0; 
  constant MAX_INDEX  : INTEGER := 1000; 
  constant SIM_OUT_OF_BOUNDS : std_logic_vector(18 downto 0) := (OTHERS => '0'); 

  -- Simulation Signals --
  signal step_size  : real := MATH_PI/(real((TABLE_SIZE-1))*2.0);
  signal step_var   : real := 0.0;  
  signal temp_sin_out : real := 0.0; 
  signal temp_scale_sin_out : real := 0.0; 
  signal sim_sine : INTEGER := 0; 
  signal next_sim_sine : INTEGER := 0;
 
  -- Spy Signals  
  
begin -- start of architecture -- 
  -------------------------------------------------------------------------- 
  -- DUT INSTANTIATION.
  --------------------------------------------------------------------------
  sine_lookup_inst : entity DESIGN_LIB.sine_lookup
    port map (
      i_clk  => i_clk,
      i_addr => i_addr,
      o_data => o_data
    );  


  --------------------------------------------------------------------------
  -- CLOCK AND RESET.
  --------------------------------------------------------------------------
  i_clk   <= NOT i_clk after C_CLK_PERIOD / 2;

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
        -- Ceck all in range outputs
      -- Expected Result:
      ----------------------------------------------------------------------
      if run("sine_lookup_table_value_check") then
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: sine_lookup_table_value_check");
        info("--------------------------------------------------------------------------------");

        wait until rising_edge(i_clk);

        -- Loop through two sine waves
        for i in 0 to MAX_INDEX loop

          sim_sine <= next_sim_sine; -- Add delay to simulate flip flop

          wait for 1 ps; 
          check_equal(got => to_integer(signed(o_data)), 
                      expected => sim_sine,
                      msg =>  "Sine Lookup output equals sim");

          wait for 1 ps;
          i_addr <= std_logic_vector(to_signed(i,i_addr'length));
          temp_sin_out <= round(65535.0*sin(step_var)); 
          wait for 1 ps; 
          
          next_sim_sine <= integer(temp_sin_out);
          --wait for 1 ps;
          
          step_var <= step_var +step_size; 


          wait until rising_edge(i_clk);

        end loop;

        wait for 1 ps;
        
        info("==== TEST CASE FINISHED =====");  


      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- Check that out of bounds values go to default state
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      ELSIF run("sine_lookup_out_of_bounds_check") THEN
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: sine_lookup_out_of_bounds_check");
        info("--------------------------------------------------------------------------------");
      
        wait until rising_edge(i_clk); 
        wait for 1 ps; 
        i_addr <= std_logic_vector(to_signed((MIN_INDEX-1),i_addr'length));

        wait until rising_edge(i_clk);
        wait for 1 ps; 
        check_equal(got => o_data, 
                    expected => SIM_OUT_OF_BOUNDS,
                    msg =>  "Check out of bounds reuturnes default");

        wait until rising_edge(i_clk); 
        wait for 1 ps; 
        i_addr <= std_logic_vector(to_signed((MIN_INDEX-23452),i_addr'length));

        wait until rising_edge(i_clk);
        wait for 1 ps; 
        check_equal(got => o_data, 
                    expected => SIM_OUT_OF_BOUNDS,
                    msg =>  "Check out of bounds reuturnes default");

        wait until rising_edge(i_clk); 
        wait for 1 ps; 
        i_addr <= std_logic_vector(to_signed((MAX_INDEX+1),i_addr'length));

        wait until rising_edge(i_clk);
        wait for 1 ps; 
        check_equal(got => o_data, 
                    expected => SIM_OUT_OF_BOUNDS,
                    msg =>  "Check out of bounds reuturnes default");

        wait until rising_edge(i_clk); 
        wait for 1 ps; 
        i_addr <= std_logic_vector(to_signed((MAX_INDEX+123214),i_addr'length));

        wait until rising_edge(i_clk);
        wait for 1 ps; 
        check_equal(got => o_data, 
                    expected => SIM_OUT_OF_BOUNDS,
                    msg =>  "Check out of bounds reuturnes default");



        info("==== TEST CASE FINISHED ====="); 

      end if; -- for test_suite
    end loop test_cases_loop;

    wait for 20 ns;
    test_runner_cleanup(runner); -- end of simulation 
  end process test_runner; 

end architecture tb; 