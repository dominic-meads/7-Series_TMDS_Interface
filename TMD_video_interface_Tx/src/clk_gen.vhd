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
-- Description: PLL instantiaion that generates a 25 MHz pixel clk (o_pclk), a 250 MHz clk (o_pclkx10),
--              and a "locked" output that is used as a reset in other logic
-- 
-- Dependencies: Input clk = 125 MHz
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


entity clk_gen is
  Port ( i_clk : in STD_LOGIC;
         i_rst_n : in STD_LOGIC;
         o_pclk : out STD_LOGIC;
         o_pclk_x10 : out STD_LOGIC;
         o_locked : out STD_LOGIC);
end clk_gen;

architecture rtl of clk_gen is
  
  -- feedback clock interconnect
  signal w_clkfb : STD_LOGIC;  
  
  -- clk buffer signals
  signal w_pclk : STD_LOGIC;
  signal w_pclk_x10 : STD_LOGIC;
  
  -- active low reset signal
  signal w_rst : STD_LOGIC;

begin

  -- default reset active high for PLL instantiation, but active low input to entity
  w_rst <= not i_rst_n;

  PLLE2_BASE_inst : PLLE2_BASE
  generic map (
    BANDWIDTH => "OPTIMIZED",  
    CLKFBOUT_MULT => 2,        
    CLKFBOUT_PHASE => 0.0,     
    CLKIN1_PERIOD => 8.0,      
    CLKOUT0_DIVIDE => 10,
    CLKOUT1_DIVIDE => 1,
    CLKOUT0_DUTY_CYCLE => 0.5,
    CLKOUT1_DUTY_CYCLE => 0.5,
    CLKOUT0_PHASE => 0.0,
    CLKOUT1_PHASE => 0.0,
    DIVCLK_DIVIDE => 1,       
    REF_JITTER1 => 0.0,        
    STARTUP_WAIT => "FALSE"    
  )
  port map (
    CLKOUT0 => w_pclk,   
    CLKOUT1 => w_pclk_x10,   
    CLKFBOUT => w_clkfb, 
    LOCKED => o_locked,     
    CLKIN1 => i_clk,     
    PWRDWN => '0',     
    RST => w_rst,
    CLKFBIN => w_clkfb  
  );
  
  
  pclk_buff : BUFG
  port map (
    O => o_pclk, 
    I => w_pclk  
  );
  
  
  pclk_x10_buff : BUFG
  port map (
    O => o_pclk_x10, 
    I => w_pclk_x10 
  );
   

end rtl;
