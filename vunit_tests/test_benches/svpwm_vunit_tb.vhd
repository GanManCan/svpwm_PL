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




entity svpwm_vunit_tb is
  generic(runner_cfg : string := runner_cfg_default);
end entity svpwm_vunit_tb;



architecture tb of svpwm_vunit_tb is

  --------------------------------------------------------------------------
  -- TYPES, RECORDS, INTERNAL SIGNALS, FSM, CONSTANTS DECLARATION.
  --------------------------------------------------------------------------
  -- CONSTANTS DECLARATION --


  -- simulation constants :
  constant c_clk_period : time := 20 ns;

  

  -- INTERNAL SIGNALS DECLARATION --
  -- DUT constants
  constant sys_clk         : INTEGER := 50_000_000;  
  constant pwm_freq        : INTEGER := 100_000;      
  constant bits_resolution : INTEGER := 32;           
  constant v_dc            : INTEGER := 200;
  constant dead_time_ns : INTEGER := 800; 
  CONSTANT dead_time_cnt    : INTEGER := sys_clk/1000/1000*dead_time_ns/1000;
  CONSTANT int_t0    : INTEGER   := sys_clk/pwm_freq/2; -- Period = number of clocks in SVPWM cycle
                                                        -- Note 2 SVPWM cycles per switching cycle



  -- DUT interface
  signal clk      : std_logic := '0';
  signal reset_n  : std_logic := '0';
  signal ena      : std_logic := '1';
  signal fire_u   : std_logic_vector(bits_resolution-1 downto 0) := (OTHERS => '0');
  signal fire_v   : std_logic_vector(bits_resolution-1 downto 0) := (OTHERS => '0');
  signal fire_w   : std_logic_vector(bits_resolution-1 downto 0) := (OTHERS => '0');
  signal gate_u   : std_logic;
  signal gate_u_l : std_logic;
  signal gate_v   : std_logic;
  signal gate_v_l : std_logic;
  signal gate_w   : std_logic;
  signal gate_w_l : std_logic;  
 
  -- Simulation Signals --
  signal sim_counter : INTEGER := 0; 
  signal sim_int_counter_period :INTEGER := sys_clk/pwm_freq/2;
  signal sim_counter_dir : std_logic := '1'; -- 1 is up direction
  signal sim_dead_count : integer := 0; 
  SIGNAL sim_fire_set : integer := 0; 

  -- Signals to read files
  file file_vectors : text; 

  -- Debug Read signals
  signal temp_read_gate_u : std_logic; 
  signal temp_read_gate_u_l : std_logic;
  -- Check stable signals
  --signal check_enable         : std_logic := '1'; 
  --signal gate_u_start_event   : std_logic := '0';
  --signal gate_u_end_event     : std_logic := '0';
  --signal gate_u_l_start_event : std_logic := '0';
  --signal gate_u_l_end_event   : std_logic := '0';
  --signal gate_v_start_event   : std_logic := '0';
  --signal gate_v_end_event     : std_logic := '0';
  --signal gate_v_l_start_event : std_logic := '0';
  --signal gate_v_l_end_event   : std_logic := '0';
  --signal gate_w_start_event   : std_logic := '0';
  --signal gate_w_end_event     : std_logic := '0';
  --signal gate_w_l_start_event : std_logic := '0';
  --signal gate_w_l_end_event   : std_logic := '0';


  -- Spy Signals
  alias spy_counter is 
   <<signal .svpwm_tb_inst.counter : integer range -65533 to 65533 >>; 

  alias spy_lock_fire_u is 
   <<signal .svpwm_tb_inst.lock_fire_u : std_logic_vector(bits_resolution-1 downto 0) >>;
  signal int_spy_lock_fire_u : integer;
  signal slv_temp: std_logic_vector(bits_resolution-1 downto 0);

  alias spy_lock_fire_v is 
   <<signal .svpwm_tb_inst.lock_fire_v : std_logic_vector(bits_resolution-1 downto 0) >>;
  alias spy_lock_fire_w is 
   <<signal .svpwm_tb_inst.lock_fire_w : std_logic_vector(bits_resolution-1 downto 0) >>;

  alias spy_count_dir is 
   <<signal .svpwm_tb_inst.count_dir : std_logic>>; 




  
  
begin -- start of architecture -- 
  -------------------------------------------------------------------------- 
  -- DUT INSTANTIATION.
  --------------------------------------------------------------------------
  

  svpwm_tb_inst : entity DESIGN_LIB.svpwm
    generic map (
      sys_clk         => sys_clk,
      pwm_freq        => pwm_freq,
      bits_resolution => bits_resolution,
      dead_time_ns    => dead_time_ns
    )
    port map (
      clk      => clk,
      reset_n  => reset_n,
      ena      => ena,
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
    variable read_ftg_u, read_ftg_v, read_ftg_w : integer;
    variable read_lock_ftg_u, read_lock_ftg_v, read_lock_ftg_w : integer;
    variable read_gate_u, read_gate_u_l : std_logic; 
    variable read_gate_v, read_gate_v_l : std_logic; 
    variable read_gate_w, read_gate_w_l : std_logic; 
    variable read_counter : integer; 
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
      if run("svpwm_check_reset_values") then
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: svpwm_check_reset_values");
        info("--------------------------------------------------------------------------------");
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait for 1 ps;
        check(gate_u = '0',   "gate_u reset check");
        check(gate_u_l = '0', "gate_u_l reset check");
        check(gate_v = '0',   "gate_v reset check");
        check(gate_v_l = '0', "gate_v_l reset check");
        check(gate_w = '0',   "gate_w reset check");
        check(gate_w_l = '0', "gate_w_l reset check");
        
        info("==== TEST CASE FINISHED =====");  

      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- Check that out of bounds values go to default state
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      ELSIF run("svpwm_counter_check") THEN
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: svpwm_counter_check");
        info("--------------------------------------------------------------------------------");
        
        wait until reset_n = '1';
        sim_counter <= 0;

        -- Loop through and check the counter up and down
        for i in 0 to 3*sim_int_counter_period loop

          if(sim_counter_dir = '1') then
            sim_counter <= sim_counter + 1;
            if(sim_counter = (sim_int_counter_period-2)) then
              sim_counter_dir <= '0';
            end if; -- if(sim_counter = sim_int_counter_period)

          elsif(sim_counter_dir = '0') then
            sim_counter <= sim_counter - 1;
            if(sim_counter = 1) then
              sim_counter_dir <= '1';
            end if; -- if(sim_counter = sim_int_counter_period)
          end if; 

          wait for 1 ps; 
          check_equal(spy_counter, sim_counter, result("Check spy_counter equal sim_counter"));

          wait until rising_edge(clk);

        end loop; -- for i in 0 to 4*sim_int_countperiod; 

      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      --   Checks when gates turn on
      --   During up cont - check low gate
      --   During down cnt -- checks high gate
      --   Only checks values that do not cause gates to be either always on or always off
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      ELSIF run("svpwm_gate_pulse_on_off_check") THEN
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: svpwm_gate_pulse_on_off_check");
        info("--------------------------------------------------------------------------------");
        
        fire_u <= std_logic_vector(to_signed(dead_time_cnt, fire_u'length));
        fire_v <= std_logic_vector(to_signed(dead_time_cnt, fire_v'length));
        fire_w <= std_logic_vector(to_signed(dead_time_cnt, fire_w'length));
        sim_fire_set <= dead_time_cnt;
        wait until reset_n = '1';
        wait for 1 ps; 

        check(dead_time_cnt < (int_t0 - dead_time_cnt), "Check loop is able to run");

        -- Loop through various in range firme time values
        for ii in dead_time_cnt to (int_t0 - dead_time_cnt) loop

          ------------------------------------------------------------------------
          -- On up count, check gate_ul tranistions at right value
          ------------------------------------------------------------------------
          wait until (spy_counter = (sim_fire_set+1)); 
          wait for 1 ps;
          
          check_equal(got=>spy_count_dir, expected=>'1', 
                    msg=>result("Check counter is coutning up (count_dir = 1"));
          check(gate_u_l = '1', "On up count: check gate_u_l is high berfore fire value"); 
          check(gate_u = '0', "On up count: check gate_u is low berfore fire value");
          check(gate_v_l = '1', "On up count: check gate_v_l is high berfore fire value"); 
          check(gate_v = '0', "On up count: check gate_v is low berfore fire value");
          check(gate_w_l = '1', "On up count: check gate_w_l is high berfore fire value"); 
          check(gate_w = '0', "On up count: check gate_w is low berfore fire value");

          --set next value
          fire_u <= std_logic_vector(to_signed(ii+1, fire_u'length)); 
          fire_v <= std_logic_vector(to_signed(ii+1, fire_v'length));
          fire_w <= std_logic_vector(to_signed(ii+1, fire_w'length));
          sim_fire_set <= ii+1;
          wait for 1 ps; 


          wait until rising_edge(clk);
          wait for 1 ps; 

          check_equal(got=>spy_count_dir, expected=>'1', 
                    msg=>result("Check counter is coutning up (count_dir = 1"));
          check(gate_u_l = '0', "On up count: check gate_u_l is low after fire value"); 
          check(gate_u = '0', "On up count: check gate_u is low after fire value (in dead band)");
          check(gate_v_l = '0', "On up count: check gate_v_l is low after fire value"); 
          check(gate_v = '0', "On up count: check gate_v is low after fire value (in dead band)");
          check(gate_w_l = '0', "On up count: check gate_w_l is low after fire value"); 
          check(gate_w = '0', "On up count: check gate_w is low after fire value (in dead band)");

          ------------------------------------------------------------------------
          -- On down count, check gate_u tranistions at right value
          ------------------------------------------------------------------------
          wait until (spy_counter = (sim_fire_set)); 
          wait for 1 ps;
          
          check_equal(got=>spy_count_dir, expected=>'0', 
                    msg=>result("Check counter is coutning down (count_dir = 0"));
          check(gate_u_l = '0', "On down count: check gate is low berfore fire value"); 
          check(gate_u = '1', "On down count: check gate is high berfore fire value");
          check(gate_v_l = '0', "On down count: check gate is low berfore fire value"); 
          check(gate_v = '1', "On down count: check gate is high berfore fire value");
          check(gate_w_l = '0', "On down count: check gate is low berfore fire value"); 
          check(gate_w = '1', "On down count: check gate is high berfore fire value");

          --set next value
          fire_u <= std_logic_vector(to_signed(ii, fire_u'length)); 
          fire_v <= std_logic_vector(to_signed(ii, fire_v'length));
          fire_w <= std_logic_vector(to_signed(ii, fire_w'length));
          sim_fire_set <= ii;
          wait for 1 ps; 

          wait until rising_edge(clk);
          wait for 1 ps; 

          check_equal(got=>spy_count_dir, expected=>'0', 
                    msg=>result("Check counter is coutning down (count_dir = 0"));
          check(gate_u_l = '0', "On down count: check gate is low after fire value"); 
          check(gate_u = '0', "On down count: check gate is low after fire value (in dead band)");
          check(gate_v_l = '0', "On down count: check gate is low after fire value"); 
          check(gate_v = '0', "On down count: check gate is low after fire value (in dead band)");
          check(gate_w_l = '0', "On down count: check gate is low after fire value"); 
          check(gate_w = '0', "On down count: check gate is low after fire value (in dead band)");

        end loop; --for ii in dead_time_cnt



      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
        -- Check the Gate U pulse width is as expected for given Fire_u input 
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      ELSIF run("svpwm_gate_u_dead_band_check") THEN
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: svpwm_gate_u_dead_band_check");
        info("--------------------------------------------------------------------------------");
        
        wait until reset_n = '1';
        wait for 1 ps; 

        for ii in 1 to int_t0-10 loop

          fire_u <= std_logic_vector(to_signed(ii, fire_u'length));

          wait until ((gate_u_l = '0') and (gate_u = '0')); 
          wait for 1 ps; 
          sim_dead_count <= 0; -- Reset sim dead count
          check(gate_u = '0', "Check Gate_u is set to '0' in the deadband");
          check(gate_u_l = '0', "Check Gate_u is set to '0' in the deadband");


          -- Increment counter while in dead band
          while(gate_u_l = '0' and gate_u = '0') loop
            wait until rising_edge (clk);
            wait for 1 ps; 
            sim_dead_count <= sim_dead_count + 1;
          end loop;

          wait for 1 ps; 
          sim_dead_count <= sim_dead_count - 1; -- decrement count to correct for extra add
          wait for 1 ps; 
          check_equal(ii,ii, "Print ii");
          check_equal(got=>sim_dead_count, expected=>dead_time_cnt, 
                  msg=>result("Check sim_dead count = dead_time_cnt"));


        end loop; -- for ii in 

      --------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
        -- Check that fire time signals that are high have correct output
      -- Expected Result:
        -- Gate_u(_l) will remain on or off for the entire duration
      --------------------------------------------------------------------
      --ELSIF run("svpwm_deadband_overlap_high_check") THEN
      --  info("--------------------------------------------------------------------------------");
      --  info("TEST CASE: svpwm_deadband_overlap_high_check");
      --  info("--------------------------------------------------------------------------------");
      --  wait until reset_n = '1';
        
        
      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- Check that out of bounds values go to default state
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      --ELSIF run("gate_checks") THEN
      --  info("--------------------------------------------------------------------------------");
      --  info("TEST CASE: out_of_bounds_check");
      --  info("--------------------------------------------------------------------------------");
      --  wait until reset_n = '1';

      end if; -- for test_suite
    end loop test_cases_loop;

    wait for 20 ns;
    test_runner_cleanup(runner); -- end of simulation 
  end process test_runner; 


  ------------------------------------------------------------------------------
  -- Sim Counter Procss
  ------------------------------------------------------------------------------
  --sim_dead_counter_inc : process
  --begin
  --  wait until clk'event and clk ='1';
  --  sim_dead_count <= sim_dead_count + 1;
  --end process sim_dead_counter_inc; 
  --------------------------------------------------------------------------------
  -- Gate signal stability checker
  ------------------------------------------------------------------------------

  -- gate_u stability check is high 
  --check_stable(clock       => clk, 
  --             en          => check_enable,
  --             start_event => gate_u_start_event,
  --             end_event   => gate_u_end_event,
  --             expr        => gate_u,
  --             msg         => result("Gate_U switched incorrectly"),
  --             active_clock_edge => rising_edge,
  --             allow_restart     => false);

--  -- gate_u_l stability check is high 
--  check_stable(clock       => clk, 
--               en          => check_enable,
--               start_event => gate_u_l_start_event,
--               end_event   => gate_u_l_end_event,
--               expr        => gate_u_l,
--               msg         => result("Gate_U_L switched incorrectly"),
--               active_clock_edge => rising_edge,
--               allow_restart     => false);

--  -- gate_v stability check is high 
--  check_stable(clock       => clk, 
--               en          => check_enable,
--               start_event => gate_v_start_event,
--               end_event   => gate_v_end_event,
--               expr        => gate_v,
--               msg         => result("Gate_V switched incorrectly"),
--               active_clock_edge => rising_edge,
--               allow_restart     => false);

--  -- gate_v_l stability check is high 
--  check_stable(clock       => clk, 
--               en          => check_enable,
--               start_event => gate_v_l_start_event,
--               end_event   => gate_v_l_end_event,
--               expr        => gate_v_l,
--               msg         => result("Gate_V_L switched incorrectly"),
--               active_clock_edge => rising_edge,
--               allow_restart     => false);

---- gate_w stability check is high 
--  check_stable(clock       => clk, 
--               en          => check_enable,
--               start_event => gate_w_start_event,
--               end_event   => gate_w_end_event,
--               expr        => gate_w,
--               msg         => result("Gate_W switched incorrectly"),
--               active_clock_edge => rising_edge,
--               allow_restart     => false);

--  -- gate_u_l stability check is high 
--  check_stable(clock       => clk, 
--               en          => check_enable,
--               start_event => gate_w_l_start_event,
--               end_event   => gate_w_l_end_event,
--               expr        => gate_w_l,
--               msg         => result("Gate_W_L switched incorrectly"),
--               active_clock_edge => rising_edge,
--               allow_restart     => false);



end architecture tb; 