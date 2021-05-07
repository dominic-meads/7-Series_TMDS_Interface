----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads
-- 
-- Create Date: 05/01/2021 10:10:30 PM
-- Design Name: 
-- Module Name: clk_gen - rtl
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
  
  signal w_rst_n : STD_LOGIC;

begin

  w_rst_n <= not i_rst_n;

  PLLE2_BASE_inst : PLLE2_BASE
  generic map (
    BANDWIDTH => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
    CLKFBOUT_MULT => 2,        -- Multiply value for all CLKOUT, (2-64)
    CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
    CLKIN1_PERIOD => 8.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
    -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
    CLKOUT0_DIVIDE => 10,
    CLKOUT1_DIVIDE => 1,
    -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
    CLKOUT0_DUTY_CYCLE => 0.5,
    CLKOUT1_DUTY_CYCLE => 0.5,
    -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
    CLKOUT0_PHASE => 0.0,
    CLKOUT1_PHASE => 0.0,
    DIVCLK_DIVIDE => 1,        -- Master division value, (1-56)
    REF_JITTER1 => 0.0,        -- Reference input jitter in UI, (0.000-0.999).
    STARTUP_WAIT => "FALSE"    -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
  )
  port map (
    -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
    CLKOUT0 => w_pclk,   -- 1-bit output: CLKOUT0
    CLKOUT1 => w_pclk_x10,   -- 1-bit output: CLKOUT1
    -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
    CLKFBOUT => w_clkfb, -- 1-bit output: Feedback clock
    LOCKED => o_locked,     -- 1-bit output: LOCK
    CLKIN1 => i_clk,     -- 1-bit input: Input clock
     -- Control Ports: 1-bit (each) input: PLL control ports
    PWRDWN => '0',     -- 1-bit input: Power-down
    RST => w_rst_n,           -- 1-bit input: Reset
    -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
    CLKFBIN => w_clkfb    -- 1-bit input: Feedback clock
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
