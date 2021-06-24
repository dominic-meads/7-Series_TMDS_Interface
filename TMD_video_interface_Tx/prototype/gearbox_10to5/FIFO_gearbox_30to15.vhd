----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads
-- 
-- Create Date: 06/22/2021 07:58:10 PM
-- Design Name: 
-- Module Name: FIFO_gearbox_30to15 - rtl
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
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VComponents.all;
Library UNIMACRO;
use UNIMACRO.vcomponents.all;

entity FIFO_gearbox_30to15 is
  Port (
    i_pclk : in std_logic;
    i_pclk_x2 : in std_logic;
    i_rst : in std_logic;
    i_data : in std_logic_vector(29 downto 0);
    o_rd_err : out std_logic;
    o_wr_err : out std_logic;
    o_data : out std_logic_vector(14 downto 0)
  );
end FIFO_gearbox_30to15;

architecture rtl of FIFO_gearbox_30to15 is

  signal w_rd_en : std_logic;
  signal r_rd_en_toggle : std_logic := '0';  -- swaps once every two clk cycles of i_pclk_x2
--  signal w_not_rd_en_toggle : std_logic;
  signal w_wr_en : std_logic; 
  signal w_empty : std_logic;
  signal w_full : std_logic;
  signal w_FIFO_data_out : std_logic_vector(29 downto 0);
  signal w_sel : std_logic;
  signal w_mux : std_logic_vector(14 downto 0);
  signal r_data_out : std_logic_vector(14 downto 0) := (others => '0');
    
begin

  -- make sure no writing and reading when FULL and EMPTY flags
  w_rd_en <= r_rd_en_toggle when w_empty = '0' else '0';
  w_wr_en <= '1' when w_full = '0' else '0';
  
  -- toggle w_rd_en_toggle once every two i_pclk_x2 cycles 
  RDEN_TOGGLE_PROC : process(i_pclk)
  begin 
    if rising_edge(i_pclk) then 
      if r_rd_en_toggle = '0' then 
        r_rd_en_toggle <= '1';
      else 
        r_rd_en_toggle <= '0';
      end if;
    end if;
  end process;
  
 
 
   FIFO_DUALCLOCK_MACRO_0 : FIFO_DUALCLOCK_MACRO
   generic map (
      DEVICE => "7SERIES",            
      ALMOST_FULL_OFFSET => X"0080",  
      ALMOST_EMPTY_OFFSET => X"0080", 
      DATA_WIDTH => 30,   
      FIFO_SIZE => "18Kb",            
      FIRST_WORD_FALL_THROUGH => FALSE) 
   port map (
      ALMOSTEMPTY => open,   -- shallow FIFO so not using these flags
      ALMOSTFULL => open,     
      DO => w_FIFO_data_out,                     
      EMPTY => w_empty,               
      FULL => w_full,                 
      RDCOUNT => open,           
      RDERR => o_rd_err,             
      WRCOUNT => open,          
      WRERR => o_wr_err,               
      DI => i_data,                     
      RDCLK => i_pclk_x2,             
      RDEN => w_rd_en,    
      RST => i_rst,                 
      WRCLK => i_pclk,              
      WREN => w_wr_en                  
   );
   
   -- 30 to 15 mux sel toggle
  w_sel <= r_rd_en_toggle;
  w_mux <= w_FIFO_data_out(14 downto 0) when w_sel = '0' else w_FIFO_data_out(29 downto 15);
  
  -- register output of mux
  OUTPUT_REG_PROC : process(i_pclk_x2, i_rst)
  begin 
    if i_rst = '1' then 
      r_data_out <= (others => '0');
    else 
      if rising_edge(i_pclk_x2) then 
        r_data_out <= w_mux;
      end if;
    end if;
  end process;
  
  o_data <= r_data_out;


end rtl;
