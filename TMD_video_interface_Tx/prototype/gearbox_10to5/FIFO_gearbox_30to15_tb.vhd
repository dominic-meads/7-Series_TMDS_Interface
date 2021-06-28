----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads
-- 
-- Create Date: 06/23/2021 02:43:07 PM
-- Design Name: 
-- Module Name: FIFO_gearbox_30to15_tb - sim
-- Project Name: TMDS Video Interface Tx 
-- Target Devices: 7 Series FPGAs and SoCs
-- Tool Versions: 
-- Description: A combination of three 10-to-5 gearboxes using a Dual Clock FIFO
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

entity FIFO_gearbox_30to15_tb is
end FIFO_gearbox_30to15_tb;

architecture sim of FIFO_gearbox_30to15_tb is

  constant pclk_hz : integer := 25e6;
  constant pclk_period : time := 1 sec / pclk_hz;
  constant pclk_x2_hz : integer := 50e6;
  constant pclk_x2_period : time := 1 sec / pclk_x2_hz;

  signal i_pclk : std_logic := '1';
  signal i_pclk_x2 : std_logic := '1';
  signal i_rst : std_logic := '1';
  signal i_data : std_logic_vector(29 downto 0) := (others => '0');
  signal o_rd_err : std_logic;
  signal o_wr_err : std_logic;
  signal o_data : std_logic_vector(14 downto 0);

begin

  DUT : entity work.FIFO_gearbox_30to15(rtl)
  port map(
    i_pclk => i_pclk,
    i_pclk_x2 => i_pclk_x2,
    i_rst => i_rst,
    i_data => i_data,
    o_rd_err => o_rd_err,
    o_wr_err => o_wr_err,
    o_data => o_data
    );

  PCLK_PROC : process 
  begin 
    wait for pclk_period / 2;
    i_pclk <= not i_pclk;
  end process;
  
  PCLK_X2_PROC : process 
  begin 
    wait for pclk_x2_period / 2;
    i_pclk_x2 <= not i_pclk_x2;
  end process;
  
  STIM_PROC : process 
  begin 
    wait for pclk_period * 10;  -- wait for 10 cycles of pclk and then synchronously de-assert rst
    i_rst <= '0';
    i_data <= "11" & X"FFFFFFF";
    wait for pclk_period;
    i_data <= "00" & X"000FFFF";
    wait for pclk_period;
    i_data <= "11" & X"FFF0000";
    wait for pclk_period;
    i_data <= "11" & X"0F0F0F0";
    wait for pclk_period;
    i_data <= "00" & X"F0F0F0F";
    wait for pclk_period;
    i_data <= "00" & X"0FF00FF";
    wait for pclk_period;
    i_data <= "11" & X"F00FF00";
    wait for pclk_period;
    i_data <= "00" & X"000FFFF";
    wait for pclk_period;
    i_data <= "11" & X"FFF0000";
    wait for pclk_period;
    i_data <= "11" & X"0F0F0F0";
    wait for pclk_period;
    i_data <= "00" & X"F0F0F0F";
    wait for pclk_period;
    i_data <= "00" & X"0FF00FF";
    wait for pclk_period;
    i_data <= "11" & X"F00FF00";
    wait for pclk_period;
    i_data <= "00" & X"000FFFF";
    wait for pclk_period;
    i_data <= "11" & X"FFF0000";
    wait for pclk_period;
    i_data <= "11" & X"0F0F0F0";
    wait for pclk_period;
    i_data <= "00" & X"F0F0F0F";
    wait for pclk_period;
    i_data <= "00" & X"0FF00FF";
    wait for pclk_period;
    i_data <= "11" & X"F00FF00";
    wait for pclk_period;
    i_data <= "00" & X"0FF00FF";
    wait for pclk_period;
    i_data <= "11" & X"F00FF00";
    wait for pclk_period;
    i_data <= "00" & X"000FFFF";
    wait for pclk_period;
    i_data <= "11" & X"FFF0000";
    wait for pclk_period;
    i_data <= "11" & X"0F0F0F0";
    wait for pclk_period;
    i_data <= "00" & X"F0F0F0F";
    wait for pclk_period;
    i_data <= "00" & X"0FF00FF";
    wait for pclk_period;
    i_data <= "11" & X"F00FF00";
    wait for pclk_period;
    i_data <= "00" & X"000FFFF";
    wait for pclk_period;
    i_data <= "11" & X"FFF0000";
    wait for pclk_period;
    i_data <= "11" & X"0F0F0F0";
    wait for pclk_period;
    i_data <= "00" & X"F0F0F0F";
    wait for pclk_period;
    i_data <= "00" & X"0FF00FF";
    wait for pclk_period;
    i_data <= "11" & X"F00FF00";
    wait for 10 ns; -- asynchronously assert reset
    i_rst <= '1';
    wait for 30 ns;
    wait for pclk_period * 9; -- synchronously de-assert
    i_rst <= '0';
    i_data <= "11" & X"FF0FFF0";
    wait for pclk_period;
    i_data <= "00" & X"00F000F";
    wait for 200 ns;
    wait;
  end process;

end sim;

