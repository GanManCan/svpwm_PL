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

use std.textio.all;
use ieee.std_logic_textio.all;




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
  --signal test_fp_fire_u  : sfixed(20 downto -11) := (OTHERS => '1');
  --signal test_fp_fire_v  : sfixed(20 downto -11) := (OTHERS => '1');
  --signal test_fp_fire_w  : sfixed(20 downto -11) := (OTHERS => '1');
  signal test_real_fire_u  : real := 0.0;
  signal test_real_fire_v  : real := 0.0;
  signal test_real_fire_w  : real := 0.0;

  -- Signals to read files 
  file file_vectors : text; 
  file file_results : text; 
  signal temp_read1, temp_read2, temp_read3 : real; 
  signal read_fu, read_fv, read_fw          : real;


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

    ------------------------------------------------------------------------
    -- test_runner variables 
    ------------------------------------------------------------------------
    variable v_ILINE     : line;
    variable v_OLINE     : line;
    variable read_v_alpha : real;
    variable read_v_beta  : real;
    variable temp_read_fu, temp_read_fv, temp_read_fw  : real;
    variable v_SPACE     : character;

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
      if run("ftg_check_reset_values") then
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: switches_off_output_check");
        info("--------------------------------------------------------------------------------");
        test_fire <= (OTHERS => '1');
        wait until rising_edge(clk);
        check(fire_u = test_fire, "fire_u equals 1");
        check(fire_v = test_fire, "fire_v equals 1");
        check(fire_w = test_fire, "fire_w equals 1");
        check(fire_time_done = '0', "fire_time_done equals 0");
        check(spy_sim_sector = 0, "spy_sim_sector equals 0");
        check(spy_state = IDLE, "spy_state is IDLE");
        wait for 1 ps; 
        info("==== TEST CASE FINISHED =====");

      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- Check each state in single calulation
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      ELSIF run("ftg_single_calculation_state_check") THEN
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: single_calculation_state_check");
        info("--------------------------------------------------------------------------------");
        wait until reset_n = '1';
        wait for c_clk_period;
        fire_time_start <= '1';

        
        wait until rising_edge(clk);
        fire_time_start <= '0';

        wait for c_clk_period;
        check(spy_state = MULTIPLY, "spy_state is MULTIPLY");

        -- wait for multiplier delay
        wait for 3*c_clk_period;
        check(spy_state = DONE, "spy_state is done");

        wait for c_clk_period;
        check(spy_state = IDLE, "spy_state resets to idle");
        check(fire_time_done = '1', "fire_time_done_flag raised");

        wait for c_clk_period;
        check(spy_state = IDLE, "spy_state is still idle");
        check(fire_time_done = '0', "fire_time_done_flag raised");        


        info("==== TEST CASE FINISHED =====");

      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- Check the output of a single calculation
        -- 
      --------------------------------------------------------------------
      --ELSIF run("ftg_single_calculation_check") THEN
      --  info("--------------------------------------------------------------------------------");
      --  info("TEST CASE: single_calculation_check");
      --  info("--------------------------------------------------------------------------------");
        
      --  fp_v_alpha <= to_sfixed(1.731, 20, -11);
      --  fp_v_alpha <= to_sfixed(10, 20, -11);
      --  wait until reset_n = '1';


     
      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- Check each outputs of inputs and outputs form file
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      ELSIF run("ftg_many_calculation_check") THEN
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: many_calculation_check");
        info("--------------------------------------------------------------------------------");
        wait until reset_n = '1';

        file_open(file_VECTORS, "C:\Users\mgann\Xilinix_Projects\svpwm_PL\vunit_tests\python\fire_time_generator_test_cases.txt",  read_mode);
           
        while not endfile(file_VECTORS) loop
          readline(file_VECTORS, v_ILINE);
          read(v_ILINE, read_v_alpha);
          read(v_ILINE, v_SPACE);   -- read in the space character
          read(v_ILINE, read_v_beta);
          read(v_ILINE, v_SPACE);   
          read(v_ILINE, temp_read_fu);
          read(v_ILINE, v_SPACE);   
          read(v_ILINE, temp_read_fv);
          read(v_ILINE, v_SPACE);   
          read(v_ILINE, temp_read_fw);  
          
          wait until rising_edge(clk);
          wait for 1 ps; 
          fp_v_alpha <= to_sfixed(read_v_alpha, 20, -11);
          fp_v_beta  <= to_sfixed(read_v_beta, 20, -11); 
          fire_time_start <= '1'; 

          read_fu <= temp_read_fu;
          read_fw <= temp_read_fw;
          read_fv <= temp_read_fv;

          wait until rising_edge(clk);
          wait for 1 ps; 
          fire_time_start <= '0';

          wait until fire_time_done = '0';
          wait for 1 ps; 
          test_real_fire_u <= real(to_integer(signed(fire_u)));
          test_real_fire_v <= real(to_integer(signed(fire_v)));
          test_real_fire_w <= real(to_integer(signed(fire_w)));
          --test_real_fire_w <= to_real(to_sfixed(110.1,10,-10));

          wait until rising_edge(clk);
          wait for 1 ps; 
          check_equal(test_real_fire_u, read_fu, max_diff => 4.0);
          check_equal(test_real_fire_v, read_fv, max_diff => 4.0);
          check_equal(test_real_fire_w, read_fw, max_diff => 4.0);
          
     
          wait for 60 ns;
        end loop; -- while noe endfile(file_vectors)
     
        file_close(file_VECTORS);

       ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
        -- Check that out of bounds values go to default state
      -- Expected Result:
        -- 
      --------------------------------------------------------------------  
      ELSIF run("ftg_debug") THEN
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: ftg_debug");
        info("--------------------------------------------------------------------------------");
        
        fp_v_alpha <= to_sfixed(100.0,20,-11);
        fp_v_beta <= to_sfixed(20.0,20,-11);
        fire_time_start <= '1';
        wait until reset_n = '1';

        for i in 0 to 100_000   loop
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

      end if; -- for test_suite
    end loop test_cases_loop;

    wait for 20 ns;
    test_runner_cleanup(runner); -- end of simulation 
  end process test_runner; 

end architecture tb; 