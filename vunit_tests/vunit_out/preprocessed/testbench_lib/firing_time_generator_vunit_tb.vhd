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

LIBRARY TESTBENCH_LIB;
--USE TB_LIB.MOTOR_TB_PKG.ALL;

library modelsim_lib;
use modelsim_lib.util.all;




entity firing_time_generator_vunit_tb is
  generic(runner_cfg : string := runner_cfg_default);
end entity firing_time_generator_vunit_tb;



architecture tb of firing_time_generator_vunit_tb is

  --------------------------------------------------------------------------
  -- TYPES, RECORDS, INTERNAL SIGNALS, FSM, CONSTANTS DECLARATION.
  --------------------------------------------------------------------------
  -- CONSTANTS DECLARATION --

  -- spy signals

  -- DUT constants
  constant sys_clk         : INTEGER := 50_000_000;  
  constant pwm_freq        : INTEGER := 3_000;      
  constant bits_resolution : INTEGER := 32;           
  constant v_dc            : INTEGER := 200;

  -- simulation constants :
  constant c_clk_period : time := 20 ns;
  constant temp_sl : std_logic := '1'; 

  -- INTERNAL SIGNALS DECLARATION --
  -- DUT interface
  signal clk             : std_logic := '0';
  signal reset_n         : std_logic := '0';
  signal fire_time_start : std_logic := '0';
  signal fp_v_alpha      : sfixed(20 downto -11);
  signal fp_v_beta       : sfixed(20 downto -11);
  signal fire_time_done  : std_logic := '0';
  signal fire_u          : std_logic_vector(bits_resolution-1 downto 0);
  signal fire_v          : std_logic_vector(bits_resolution-1 downto 0);
  signal fire_w          : std_logic_vector(bits_resolution-1 downto 0); 

  -- Simulation Signals --
  signal test_fire       : std_logic_vector(bits_resolution-1 downto 0);

  -- Spy Signal
  type STATE_TYPE is (IDLE,MULTIPLY, DONE);

  alias spy_sim_sector is 
   <<signal .firing_time_generator_tb_inst.sim_sector : integer >>;

  alias spy_state is
    <<signal .firing_time_generator_tb_inst.state : STATE_TYPE >>;

begin -- start of architecture -- 
  -------------------------------------------------------------------------- 
  -- DUT INSTANTIATION.
  --------------------------------------------------------------------------
  

  firing_time_generator_tb_inst : entity DESIGN_LIB.firing_time_generator
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

    test_cases_loop : while test_suite loop
      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- check output when design all switches are OFF.
      -- Expected Result:
        --  fire_u/v/w = '111..111'
      ----------------------------------------------------------------------
      if run("check_reset_values") then
        info("--------------------------------------------------------------------------------", line_num => 157, file_name => "firing_time_generator_vunit_tb.vhd");
        info("TEST CASE: switches_off_output_check", line_num => 158, file_name => "firing_time_generator_vunit_tb.vhd");
        info("--------------------------------------------------------------------------------", line_num => 159, file_name => "firing_time_generator_vunit_tb.vhd");
        test_fire <= (OTHERS => '1');
        wait until rising_edge(clk);
        check(fire_u = test_fire, "fire_u equals 1", line_num => 162, file_name => "firing_time_generator_vunit_tb.vhd");
        check(fire_v = test_fire, "fire_v equals 1", line_num => 163, file_name => "firing_time_generator_vunit_tb.vhd");
        check(fire_w = test_fire, "fire_w equals 1", line_num => 164, file_name => "firing_time_generator_vunit_tb.vhd");
        check(fire_time_done = '0', "fire_time_done equals 0", line_num => 165, file_name => "firing_time_generator_vunit_tb.vhd");
        check(spy_sim_sector = 0, "spy_sim_sector equals 0", line_num => 166, file_name => "firing_time_generator_vunit_tb.vhd");
        check(spy_state = IDLE, "spy_state is IDLE", line_num => 167, file_name => "firing_time_generator_vunit_tb.vhd");
        wait for 1 ps; 
        info("==== TEST CASE FINISHED =====", line_num => 169, file_name => "firing_time_generator_vunit_tb.vhd");

      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- Check each state in single calulation
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      ELSIF run("single_calculation_state_check") THEN
        info("--------------------------------------------------------------------------------", line_num => 178, file_name => "firing_time_generator_vunit_tb.vhd");
        info("TEST CASE: single_calculation_state_check", line_num => 179, file_name => "firing_time_generator_vunit_tb.vhd");
        info("--------------------------------------------------------------------------------", line_num => 180, file_name => "firing_time_generator_vunit_tb.vhd");
        wait until reset_n = '1';
        wait for c_clk_period;
        fire_time_start <= '1';

        
        wait until rising_edge(clk);
        fire_time_start <= '0';

        wait for c_clk_period;
        check(spy_state = MULTIPLY, "spy_state is MULTIPLY", line_num => 190, file_name => "firing_time_generator_vunit_tb.vhd");

        -- wait for multiplier delay
        wait for 3*c_clk_period;
        check(spy_state = DONE, "spy_state is done", line_num => 194, file_name => "firing_time_generator_vunit_tb.vhd");

        wait for c_clk_period;
        check(spy_state = IDLE, "spy_state resets to idle", line_num => 197, file_name => "firing_time_generator_vunit_tb.vhd");
        check(fire_time_done = '1', "fire_time_done_flag raised", line_num => 198, file_name => "firing_time_generator_vunit_tb.vhd");

        wait for c_clk_period;
        check(spy_state = IDLE, "spy_state is still idle", line_num => 201, file_name => "firing_time_generator_vunit_tb.vhd");
        check(fire_time_done = '0', "fire_time_done_flag raised", line_num => 202, file_name => "firing_time_generator_vunit_tb.vhd");        


        info("==== TEST CASE FINISHED =====", line_num => 205, file_name => "firing_time_generator_vunit_tb.vhd");


      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- Check each outputs of inputs and outputs form file
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      --ELSIF run("many_calculation_check") THEN
      --  info("--------------------------------------------------------------------------------", line_num => 215, file_name => "firing_time_generator_vunit_tb.vhd");
      --  info("TEST CASE: many_calculation_check", line_num => 216, file_name => "firing_time_generator_vunit_tb.vhd");
      --  info("--------------------------------------------------------------------------------", line_num => 217, file_name => "firing_time_generator_vunit_tb.vhd");
      --  wait until reset_n = '1';

      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- Check that out of bounds values go to default state
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      --ELSIF run("out_of_bounds_check") THEN
      --  info("--------------------------------------------------------------------------------", line_num => 227, file_name => "firing_time_generator_vunit_tb.vhd");
      --  info("TEST CASE: out_of_bounds_check", line_num => 228, file_name => "firing_time_generator_vunit_tb.vhd");
      --  info("--------------------------------------------------------------------------------", line_num => 229, file_name => "firing_time_generator_vunit_tb.vhd");
      --  wait until reset_n = '1';

      end if; -- for test_suite
    end loop test_cases_loop;

    wait for 20 ns;
    test_runner_cleanup(runner); -- end of simulation 
  end process test_runner; 

end architecture tb; 