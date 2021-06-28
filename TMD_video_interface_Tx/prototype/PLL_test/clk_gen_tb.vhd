----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads
-- 
-- Create Date: 05/08/2021 04:36:09 PM
-- Design Name: 
-- Module Name: clk_gen_tb - sim
-- Project Name: TMDS Video Interface Tx
-- Target Devices: 7-Series FPGAs and SoCs
-- Tool Versions: 
-- Description: PLL instantiaion that generates a 25 MHz pixel clk (o_pclk), a 50 MHz clk (o_pclk_x2), 
--              a 250 MHz clk (o_pclkx10), and a "locked" output that is used as a reset in other logic
--  
-- Dependencies: Input clk = 125 MHz
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity clk_gen_tb is
end clk_gen_tb;

architecture sim of clk_gen_tb is

  constant clk_hz : integer := 125e6;
  constant clk_period : time := 1 sec / clk_hz;
  
  signal i_clk : std_logic := '1';
  signal i_rst : std_logic := '1';
  signal o_pclk : std_logic;
  signal o_pclk_x2 : std_logic;
  signal o_pclk_x10 : std_logic;
  signal o_locked : std_logic;

begin

  DUT : entity work.clk_gen(rtl)
  port map(
    i_clk => i_clk,
    i_rst => i_rst,
    o_pclk => o_pclk,
    o_pclk_x2 => o_pclk_x2,
    o_pclk_x10 => o_pclk_x10,
    o_locked => o_locked
    );
    
  CLK_PROC : process 
  begin 
    wait for clk_period / 2;
    i_clk <= not i_clk;
  end process;
  
  STIM_PROC : process 
  begin 
    wait for 50 ns;
    i_rst <= '0';
    wait for 1000 ns;
    i_rst <= '1';
    wait for 50 ns;
    wait;
  end process;
  
end sim;
© 2021 GitHub, Inc.
