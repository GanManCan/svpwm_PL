----------------------------------------------------------------------------------
-- Engineer: Matthew Gannon 
-- 
-- Create Date: 06/06/2021 08:57:04 PM
-- Design Name: 
-- Module Name: pwm_test - Behavioral
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY pwm_test is
  GENERIC(
    sys_clk         : INTEGER := 50_000_000; --system clock freq in Hz
    pwm_freq        : INTEGER := 100_000;    --PWM switching freq in Hz
    bits_resolution : INTEGER := 8;          --bits of resolution for duty cycle
    phases          : INTEGER := 1);         --number of PWM output phases
  PORT ( 
    clk       : IN std_logic;
    reset_n   : IN std_logic;
    ena       : IN std_logic ; 
    duty      : IN std_logic_vector(bits_resolution-1 downto 0);
    pwm_out   : OUT std_logic_vector(phases-1 downto 0);
    pwm_n_out : OUT std_logic_vector(phases-1 downto 0));
END pwm_test;

ARCHITECTURE logic of pwm_test is
  CONSTANT period    : INTEGER := sys_clk/pwm_freq; --number of clocks in one pwm period
  TYPE counters IS ARRAY (0 to phases-1) OF INTEGER RANGE 0 TO period - 1; --data type for array of period counters
  SIGNAL count          : counters := (OTHERS => 0);  -- array of period counters
  SIGNAL half_duty_new  : INTEGER RANGE 0 TO period/2 := 0; --number f lcoks in 1/2 duty cycle
  TYPE half_duties IS ARRAY (0 to phases-1) OF INTEGER RANGE 0 TO period/2;
  SIGNAL half_duty    : half_duties := (OTHERS => 0); --array of half duty values  
BEGIN
  PROCESS(clk,reset_n)
  BEGIN
    IF(reset_n = '0') THEN                     --asynchronous reset
      count <= (OTHERS  => 0);                 --clear counter
      pwm_out <= (OTHERS  => '0');               --clear PWM outputs
      pwm_n_out <= (OTHERS => '0'); 
    ELSIF(clk'EVENT AND clk = '1') THEN
      IF(ena = '1') THEN --latch in new duty cycle
        half_duty_new <= conv_integer(duty)*period/(2**bits_resolution)/2; --determine clocks in 1/2 duty cycle
      END IF; 
      FOR i IN 0 TO phases-1 LOOP  -- create a counter for each phase
        IF(count(0) = period -1 -i*period/phases) THEN   --end of period reached
          count(i) <= 0;  --reset counter
          half_duty(i) <= half_duty_new; --set most recent duty cyle value
        ELSE
          count(i) <= count(i)+1; --increment counter
        END IF;
      END LOOP;
      FOR i IN 0 TO phases -1 LOOP  --control outputs for each phase
       IF(count(i) = half_duty(i)) THEN
         pwm_out(i) <= '0';
         pwm_n_out(i) <= '1';
       ELSIF(count(i) = period - half_duty(i)) THEN
         pwm_out(i) <= '1';
         pwm_n_out(i) <= '0'; 
       END IF;      
      END LOOP; 
    END IF;
  END PROCESS;
END  logic; 

