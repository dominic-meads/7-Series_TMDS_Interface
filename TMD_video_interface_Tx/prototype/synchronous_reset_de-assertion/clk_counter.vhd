----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads
-- 
-- Create Date: 05/04/2021 01:39:26 PM
-- Design Name: 
-- Module Name: clk_counter - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Acts as a delay from PLL "locked" signal to the synchronous " reset" signal. When the "locked" signal goes high, the counter counts 
--              for a defined number of clock cycles to allow for initialization of primitives such as OSERDESE2 blocks, before de-asserting reset
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
use IEEE.NUMERIC_STD.ALL;

entity clk_counter is
    generic (
      g_delay_clk_cycles : INTEGER := 2;
      g_counter_width : INTEGER := 2  -- instantiate as 2**(g_delay_clk_cycles - 1) - 1?
      );
    port ( 
      i_en : in STD_LOGIC;
      i_pclk : in STD_LOGIC;
      o_clk_counter : out STD_LOGIC_VECTOR (g_counter_width-1 downto 0)
      );
end clk_counter;

architecture rtl of clk_counter is

  signal r_clk_counter : UNSIGNED(g_counter_width-1 downto 0) := (others => '0');
 
begin

  CLK_COUNT_PROC : process(i_pclk)
  begin 
    
    if rising_edge(i_pclk) then 
      if i_en = '1' then 
        if r_clk_counter < g_delay_clk_cycles - 2 then 
          r_clk_counter <= r_clk_counter + 1;
        
        else 
          r_clk_counter <= (others => '0');
      
        end if;
        
      else 
        r_clk_counter <= (others => '0');
      
      end if;   
    end if;
  
  end process;
  
  -- output assignment
  o_clk_counter <= STD_LOGIC_VECTOR(r_clk_counter);

end rtl;
