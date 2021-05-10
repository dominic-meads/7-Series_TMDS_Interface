----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads
-- 
-- Create Date: 05/08/2021 04:59:03 PM
-- Design Name: 
-- Module Name: delay_cntr - rtl
-- Project Name: TMDS Video Interface Tx
-- Target Devices: 
-- Tool Versions: 
-- Description: Counts a defined number of clock cycles in the "pclk" domain. This counter
--              is used to delay the reset release for a certain amount of time. 
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

entity delay_cntr is
    generic (
      g_delay_cycles : INTEGER := 10;  -- default 10 pclk cycle delay (400 ns)
      g_cntr_width : INTEGER := 4  -- 4 bits encodes > 10 values
      );
    port ( 
      i_en : in STD_LOGIC;  -- counter enable
      i_pclk : in STD_LOGIC;
      o_delay_cntr : out STD_LOGIC_VECTOR (g_cntr_width-1 downto 0)
      );
end delay_cntr;

architecture rtl of delay_cntr is

  signal r_delay_cntr : UNSIGNED(g_cntr_width-1 downto 0) := (others => '0');
 
begin

  CLK_COUNT_PROC : process(i_pclk)
  begin 
    if rising_edge(i_pclk) then 
      if i_en = '1' then 
        if r_delay_cntr < g_delay_cycles - 2 then  -- why "g_delay_cycles - 2" in the counter? Because state machine in sync_rst_release.vhd has latency of 1 clk cycle.
          r_delay_cntr <= r_delay_cntr + 1;
        else 
          r_delay_cntr <= (others => '0');
        end if;
      else 
        r_delay_cntr <= (others => '0');
      end if;   
    end if;
  end process;
  
  o_delay_cntr <= STD_LOGIC_VECTOR(r_delay_cntr);

end rtl;
