----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads
-- 
-- Create Date: 05/01/2021 10:40:47 PM
-- Design Name: 
-- Module Name: TEST_rst_top_tb - sim
-- Project Name: TMDS Video Interface Tx
-- Target Devices: 7-Series FPGAs and SoCs
-- Tool Versions: 
-- Description: This is a testbench only used for testing the asynchronous assertion and 
--              synchronous de-assertion of the o_rst_sync output in the entity "sync_rst_release"
--              A test top module is used to connect the "clk_gen" and "delay_cntr" entities to 
--              "sync_rst_release"
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity TEST_rst_top_tb is
end TEST_rst_top_tb;

architecture sim of TEST_rst_top_tb is

  constant clk_hz : integer := 125e6;
  constant clk_period : time := 1 sec / clk_hz;
  
  signal i_clk : std_logic := '1';
  signal i_rst : std_logic := '1';
  signal o_pclk : std_logic;
  signal o_pclk_x2 : std_logic;
  signal o_pclk_x10 : std_logic;
  signal o_rst_sync : std_logic;

begin

  DUT : entity work.TEST_rst_top(rtl)
  port map(
    i_clk => i_clk,
    i_rst => i_rst,
    o_pclk => o_pclk,
    o_pclk_x2 => o_pclk_x2,
    o_pclk_x10 => o_pclk_x10,
    o_rst_sync => o_rst_sync
    );
    
  CLK_PROC : process 
  begin 
    wait for clk_period / 2;
    i_clk <= not i_clk;
  end process;
  
  STIM_PROC : process 
  begin 
    wait for 150 ns;
    i_rst <= '0';
    wait for 1058 ns;  -- wait semi-random amount of time before asynchronously asserting rst
    i_rst <= '1';
    wait for 200 ns;
    i_rst <= '0';
    wait for 800 ns;
    wait;
  end process;
  
end sim;
