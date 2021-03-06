----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads
-- 
-- Create Date: 05/03/2021 09:33:41 PM
-- Design Name: 
-- Module Name: top - rtl
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


entity top is
  Port ( 
    i_clk : in STD_LOGIC;
    i_rst_n : in STD_LOGIC;
    o_pclk : out STD_LOGIC;
    o_pclk_x10 : out STD_LOGIC;
    o_rst_n : out STD_LOGIC 
  );
end top;

architecture rtl of top is

  signal w_locked : STD_LOGIC;
  signal w_pclk : STD_LOGIC;
  signal w_i_rst_n : STD_LOGIC;

begin

  w_i_rst_n <= i_rst_n;

  clk_gen1 : entity work.clk_gen(rtl)
  port map(
    i_clk => i_clk,
    i_rst_n => w_i_rst_n,
    o_pclk => w_pclk,
    o_pclk_x10 => o_pclk_x10,
    o_locked => w_locked
    );
    
  sync_release1 : entity work.synchronous_reset_release(rtl)
  port map(
    i_locked => w_locked,
    i_rst_n => w_i_rst_n,
    i_pclk => w_pclk,
    o_rst_n => o_rst_n
    );

  o_pclk <= w_pclk;

end rtl;















