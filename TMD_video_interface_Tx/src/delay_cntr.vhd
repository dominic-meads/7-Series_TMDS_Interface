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
-- Description: Counts 9 clk cycles in the "pclk" domain. This counter
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
    port ( 
      i_en : in std_logic;
      i_pclk : in std_logic; 
      o_delay_cntr : out std_logic_vector(2 downto 0)
      );
end delay_cntr;

architecture rtl of delay_cntr is

  signal r_delay_cntr : unsigned(2 downto 0) := (others => '0');
 
begin

  CLK_COUNT_PROC : process(i_pclk, i_en)
  begin
    if i_en = '0' then 
      r_delay_cntr <= (others => '0');
    else 
      if rising_edge(i_pclk) then  
        if r_delay_cntr < "101" then            -- why "5" in the counter and not 9? Upstream latency.
          r_delay_cntr <= r_delay_cntr + 1;
        else 
          r_delay_cntr <= (others => '0');
        end if; 
      end if;
    end if;
  end process;
  
  o_delay_cntr <= std_logic_vector(r_delay_cntr);

end rtl;
