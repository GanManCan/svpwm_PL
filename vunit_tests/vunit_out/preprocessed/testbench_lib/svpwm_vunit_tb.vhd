----------------------------------------------------------------------------
--  % NAME        : svpwm_vunit_tb %                                 --
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




entity svpwm_vunit_tb is
  generic(runner_cfg : string := runner_cfg_default);
end entity svpwm_vunit_tb;



architecture tb of svpwm_vunit_tb is

  --------------------------------------------------------------------------
  -- TYPES, RECORDS, INTERNAL SIGNALS, FSM, CONSTANTS DECLARATION.
  --------------------------------------------------------------------------
  -- CONSTANTS DECLARATION --

  -- spy signals

  -- simulation constants :
  constant c_clk_period : time := 20 ns;
  

  -- INTERNAL SIGNALS DECLARATION --
  -- DUT constants
  constant sys_clk         : INTEGER := 50_000_000;  
  constant pwm_freq        : INTEGER := 3_000;      
  constant bits_resolution : INTEGER := 32;           
  constant v_dc            : INTEGER := 200;
  constant dead_time_ns : INTEGER := 800; 

  -- DUT interface
  signal clk      : std_logic := '0';
  signal reset_n  : std_logic := '0';
  signal ena      : std_logic := '1';
  signal fire_u   : std_logic_vector(bits_resolution-1 downto 0);
  signal fire_v   : std_logic_vector(bits_resolution-1 downto 0);
  signal fire_w   : std_logic_vector(bits_resolution-1 downto 0);
  signal gate_u   : std_logic;
  signal gate_u_l : std_logic;
  signal gate_v   : std_logic;
  signal gate_v_l : std_logic;
  signal gate_w   : std_logic;
  signal gate_w_l : std_logic;  
 
  -- Simulation Signals --



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
        info("--------------------------------------------------------------------------------", line_num => 167, file_name => "svpwm_vunit_tb.vhd");
        info("TEST CASE: svpwm_check_reset_values", line_num => 168, file_name => "svpwm_vunit_tb.vhd");
        info("--------------------------------------------------------------------------------", line_num => 169, file_name => "svpwm_vunit_tb.vhd");
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait for 1 ps;
        check(gate_u = '0',   "gate_u reset check", line_num => 173, file_name => "svpwm_vunit_tb.vhd");
        check(gate_u_l = '0', "gate_u_l reset check", line_num => 174, file_name => "svpwm_vunit_tb.vhd");
        check(gate_v = '0',   "gate_v reset check", line_num => 175, file_name => "svpwm_vunit_tb.vhd");
        check(gate_v_l = '0', "gate_v_l reset check", line_num => 176, file_name => "svpwm_vunit_tb.vhd");
        check(gate_w = '0',   "gate_w reset check", line_num => 177, file_name => "svpwm_vunit_tb.vhd");
        check(gate_w_l = '0', "gate_w_l reset check", line_num => 178, file_name => "svpwm_vunit_tb.vhd");

        wait for 100 ns;
        
        info("==== TEST CASE FINISHED =====", line_num => 182, file_name => "svpwm_vunit_tb.vhd");  


      ----------------------------------------------------------------------
      -- TEST CASE DESCRIPTION:
      -- Check that out of bounds values go to default state
      -- Expected Result:
        -- 
      --------------------------------------------------------------------
      --ELSIF run("out_of_bounds_check") THEN
      --  info("--------------------------------------------------------------------------------", line_num => 192, file_name => "svpwm_vunit_tb.vhd");
      --  info("TEST CASE: out_of_bounds_check", line_num => 193, file_name => "svpwm_vunit_tb.vhd");
      --  info("--------------------------------------------------------------------------------", line_num => 194, file_name => "svpwm_vunit_tb.vhd");
      --  wait until reset_n = '1';

      end if; -- for test_suite
    end loop test_cases_loop;

    wait for 20 ns;
    test_runner_cleanup(runner); -- end of simulation 
  end process test_runner; 

end architecture tb; 