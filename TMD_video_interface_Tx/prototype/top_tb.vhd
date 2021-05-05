----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads
-- 
-- Create Date: 05/01/2021 10:40:47 PM
-- Design Name: 
-- Module Name: top_tb - sim
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
library UNISIM;
use UNISIM.VComponents.all;

entity top_tb is
end top_tb;

architecture sim of top_tb is

  constant clk_hz : integer := 125e6;
  constant clk_period : time := 1 sec / clk_hz;
  
  signal i_clk : std_logic := '1';
  signal i_rst_n : std_logic := '0';
  signal o_pclk : std_logic;
  signal o_pclk_x10 : std_logic;
  signal o_locked_sync : std_logic;

begin

  DUT : entity work.top(rtl)
  port map(
    i_clk => i_clk,
    i_rst_n => i_rst_n,
    o_pclk => o_pclk,
    o_pclk_x10 => o_pclk_x10,
    o_locked_sync => o_locked_sync
    );
    
  CLK_PROC : process 
  begin 
    wait for clk_period / 2;
    i_clk <= not i_clk;
  end process;
  
  STIM_PROC : process 
  begin 
    wait for 50 ns;
    i_rst_n <= '1';
    wait for 250 ns;
    wait;
  end process;
  
end sim;
