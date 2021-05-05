----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads
-- 
-- Create Date: 05/02/2021 08:28:16 PM
-- Design Name: 
-- Module Name: DFF - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: basic postive edge D flip flop 
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

entity DFF is
  Port ( 
    clk : in STD_LOGIC;
    D : in STD_LOGIC;
    Q : out STD_LOGIC
  );
end DFF;

architecture rtl of DFF is
    
    -- output register
    signal r_Q : STD_LOGIC := '0';

begin

  FF_PROC : process(clk) 
  begin 
    if rising_edge(clk) then 
      r_Q <= D;
    end if;
  end process;
  
  -- output assignment
  Q <= r_Q;

end rtl;




















