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

  signal check_enable         : std_logic := '1'; 
  signal gate_u_start_event   : std_logic := '0';
  signal gate_u_end_event     : std_logic := '0';
  signal gate_u_l_start_event : std_logic := '0';
  signal gate_u_l_end_event   : std_logic := '0';
  signal gate_v_start_event   : std_logic := '0';
  signal gate_v_end_event     : std_logic := '0';
  signal gate_v_l_start_event : std_logic := '0';
  signal gate_v_l_end_event   : std_logic := '0';
  signal gate_w_start_event   : std_logic := '0';
  signal gate_w_end_event     : std_logic := '0';
  signal gate_w_l_start_event : std_logic := '0';
  signal gate_w_l_end_event   : std_logic := '0';


  -- Spy Signals
  alias spy_counter is 
   <<signal .svpwm_tb_inst.counter : integer range -65533 to 65533 >>; 
  
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
            if(sim_counter = (sim_int_counter_period-1)) then
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
      -- 
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      ELSIF run("svpwm_gate_pulse_width_check") THEN
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: svpwm_gate_pulse_width_check");
        info("--------------------------------------------------------------------------------");
        
        fire_u <= std_logic_vector(to_signed(100,fire_u'length));

        wait until reset_n = '1';
        wait until rising_edge(clk); 

        fire_u <= std_logic_vector(to_signed(250,fire_u'length));
        

        wait for C_CLK_PERIOD*sim_int_counter_period*2;


        check(1 = 0, result("1 equals 0"));

        
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


  --------------------------------------------------------------------------------
  -- Gate signal stability checker
  ------------------------------------------------------------------------------

  -- gate_u stability check is high 
  check_stable(clock       => clk, 
               en          => check_enable,
               start_event => gate_u_start_event,
               end_event   => gate_u_end_event,
               expr        => gate_u,
               msg         => result("Gate_U switched incorrectly"),
               active_clock_edge => rising_edge,
               allow_restart     => false);

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