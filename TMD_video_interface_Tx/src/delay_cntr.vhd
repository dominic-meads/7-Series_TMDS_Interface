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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delay_cntr is
    generic (
      g_delay_cycles : integer := 10;  -- default 10 pclk cycle delay (400 ns)
      g_cntr_width : integer := 4  -- 4 bits encodes >= 10 values
      );
    port ( 
      i_en : in std_logic;  -- counter enable
      i_pclk : in std_logic; 
      o_delay_cntr : out std_logic_vector(g_cntr_width-1 downto 0)
      );
end delay_cntr;

architecture rtl of delay_cntr is

  signal r_delay_cntr : unsigned(g_cntr_width-1 downto 0) := (others => '0');
 
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
  
  o_delay_cntr <= std_logic_vector(r_delay_cntr);

end rtl;
