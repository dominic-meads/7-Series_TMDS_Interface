----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads
-- 
-- Create Date: 06/21/2021 09:59:51 PM
-- Design Name: 
-- Module Name: TEST_rst_top - rtl
-- Project Name: TMDS Video Interface Tx
-- Target Devices: 7-Series FPGAs and SoCs
-- Tool Versions: 
-- Description: This is a top module only used for testing the asynchronous assertion and 
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
use ieee.std_logic_1164.ALL;


entity TEST_rst_top is
  Port ( 
    i_clk : in std_logic;
    i_rst : in std_logic;
    o_pclk : out std_logic;
    o_pclk_x2 : out std_logic;
    o_pclk_x10 : out std_logic;
    o_rst_sync : out std_logic 
  );
end TEST_rst_top;

architecture rtl of TEST_rst_top is

  signal w_locked : std_logic;
  signal w_pclk : std_logic;

begin

  clk_gen_0 : entity work.clk_gen(rtl)
  port map(
    i_clk => i_clk,
    i_rst => i_rst,
    o_pclk => w_pclk,
    o_pclk_x2 => o_pclk_x2,
    o_pclk_x10 => o_pclk_x10,
    o_locked => w_locked
    );
    
  sync_rst_release_0 : entity work.sync_rst_release(rtl)
  port map(
    i_locked => w_locked,
    i_rst => i_rst,
    i_pclk => w_pclk,
    o_rst_sync => o_rst_sync
    );

  o_pclk <= w_pclk;

end rtl;
