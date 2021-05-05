----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads (adapted from schematic by vivado forum user: stripline, with input from EEVblog users -- link below)
--           schematic link: https://forums.xilinx.com/t5/Virtex-Family-FPGAs-Archived/How-to-synchronize-LOCKED-output-of-PLL-for-use-as-reset/td-p/561924
--           EEVblog post: https://www.eevblog.com/forum/fpga/what-is-the-counter-for-in-this-synchronous-reset-circuit/new/#new
-- 
-- Create Date: 05/02/2021 08:21:48 PM
-- Design Name: 
-- Module Name: synchronous_reset_release - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: The purpose of this entity is to use the "locked" output from the PLL as a reset. By default, the "locked" output is not synchronous
--              with the output clocks of the PLL. This circuit takes in the "locked" signal fromm the PLL,
--              and synchronously de-assert a "locked_sync/reset" signal with respect to a 25 MHz. 
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
use IEEE.NUMERIC_STD.all;


entity synchronous_reset_release is
  Port ( 
    i_locked : in STD_LOGIC;
    i_pclk : in STD_LOGIC;
    o_rst_n : out STD_LOGIC
  );
end synchronous_reset_release;

architecture rtl of synchronous_reset_release is

  signal w_DFF1_to_DFF2 : STD_LOGIC;
  signal w_locked_sync : STD_LOGIC;

begin

  DFF1 : entity work.DFF(rtl)
  port map(
    clk => i_pclk,
    D => i_locked,
    Q => w_DFF1_to_DFF2
    );
    
  DFF2 : entity work.DFF(rtl)
  port map(
    clk => i_pclk,
    D => w_DFF1_to_DFF2,
    Q => w_locked_sync
    );

end rtl;









