----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/04/2021 02:01:31 PM
-- Design Name: 
-- Module Name: clk_counter_tb - sim
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

entity clk_counter_tb is
end clk_counter_tb;

architecture sim of clk_counter_tb is

  constant pclk_hz : integer := 25e6;
  constant pclk_period : time := 1 sec / pclk_hz;
  
  signal i_pclk : STD_LOGIC := '1';
  signal o_locked_sync : STD_LOGIC := '0';  -- coming from PLL
  signal o_clk_counter : STD_LOGIC_VECTOR(1 downto 0);

begin

  DUT : entity work.clk_counter(rtl)
  generic map(
    g_delay_clk_cycles => 2,
    g_counter_width => 2
    )
  port map (
    i_pclk => i_pclk,
    i_en => o_locked_sync,
    o_clk_counter => o_clk_counter
    );
    

  PCLK_PROC : process 
  begin 
  
    wait for pclk_period / 2;
    i_pclk <= not i_pclk;
    
  end process;
  
  STIM_PROC : process 
  begin 
  
    wait for 300 ns;
    o_locked_sync <= '1';
    wait for 450 ns;
    o_locked_sync <= '0';
    wait for 450 ns;
    wait;
    
  end process;


end sim;
