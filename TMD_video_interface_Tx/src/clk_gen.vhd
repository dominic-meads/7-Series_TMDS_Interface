----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads
-- 
-- Create Date: 05/08/2021 04:26:16 PM
-- Design Name: 
-- Module Name: clk_gen - rtl
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
library UNISIM;
use UNISIM.VComponents.all;


entity clk_gen is
  Port ( i_clk : in std_logic;
         i_rst : in std_logic;
         o_pclk : out std_logic;
         o_pclk_x2 : out std_logic;
         o_pclk_x10 : out std_logic;
         o_locked : out std_logic);
end clk_gen;

architecture rtl of clk_gen is
  
  -- feedback clock interconnect
  signal w_clkfb : std_logic;  
  
  -- clk buffer signals
  signal w_pclk : std_logic;
  signal w_pclk_x2 : std_logic;
  signal w_pclk_x10 : std_logic;

begin

  PLLE2_BASE_inst : PLLE2_BASE
  generic map (
    BANDWIDTH => "OPTIMIZED",  
    CLKFBOUT_MULT => 2,        
    CLKFBOUT_PHASE => 0.0,     
    CLKIN1_PERIOD => 8.0,      
    CLKOUT0_DIVIDE => 10,
    CLKOUT1_DIVIDE => 1,
    CLKOUT2_DIVIDE => 1,
    CLKOUT0_DUTY_CYCLE => 0.5,
    CLKOUT1_DUTY_CYCLE => 0.5,
    CLKOUT2_DUTY_CYCLE
    CLKOUT0_PHASE => 0.0,
    CLKOUT1_PHASE => 0.0,
    CLKOUT2_PHASE =>
    DIVCLK_DIVIDE => 1,       
    REF_JITTER1 => 0.0,        
    STARTUP_WAIT => "FALSE"    
  )
  port map (
    CLKOUT0 => w_pclk,
    CLKOUT1 => w_pclk_x2,
    CLKOUT2 => w_pclk_x10,   
    CLKFBOUT => w_clkfb, 
    LOCKED => o_locked,     
    CLKIN1 => i_clk,     
    PWRDWN => '0',     
    RST => i_rst,
    CLKFBIN => w_clkfb  
  );
  
  
  pclk_buff : BUFG
  port map (
    O => o_pclk, 
    I => w_pclk  
  );
  
  pclk_x2_buff : BUFG
  port map (
    O => o_pclk_x2, 
    I => w_pclk_x2  
  );
  
  pclk_x10_buff : BUFG
  port map (
    O => o_pclk_x10, 
    I => w_pclk_x10 
  );
   

end rtl;
