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

  -- state machine signals (two different state machines -- one in WRCLK domain and one in RDCLK domain)
  type t_state is (RST_WR, RST_RD, EN_WAIT_WR, EN_WAIT_RD, FILL, RD, RD_WAIT, WR);
  signal WR_STATE : t_state := RST_WR;
  signal RD_STATE : t_state := RST_RD;
  
  -- clk cycle counters
  signal r_rd_clk_cntr : unsigned(1 downto 0) := "00";
  signal r_rd_clk_cntr_en : std_logic := '0';
  signal r_wr_clk_cntr : unsigned(1 downto 0) := "00";
  signal r_wr_clk_cntr_en : std_logic := '0';
  
  -- FIFO signals
  signal w_empty : std_logic;
  signal w_full : std_logic; 
  signal w_almost_full : std_logic;
  signal r_rd_en : std_logic := '0';
  signal r_wr_en : std_logic := '0';
  signal w_FIFO_data_out : std_logic_vector(29 downto 0);
  
  -- mux signals (2 to 1, 15 bits wide)
  signal w_sel : std_logic;
  signal w_mux : std_logic_vector(14 downto 0);
  signal r_data_out : std_logic_vector(14 downto 0) := (others => '0');
  
    
begin

  -- counts number of clk cycles in i_pclk domain (needed to for EN_WAIT_WR state)
  WR_CLK_COUNTER_PROC : process(i_pclk, i_rst)
  begin
    if rising_edge(i_pclk) then 
      if i_rst = '1' then
        r_wr_clk_cntr <= "00";
      else
        if r_wr_clk_cntr_en = '1' then 
          if r_wr_clk_cntr < "10" then 
            r_wr_clk_cntr <= r_wr_clk_cntr + 1;
          else 
            r_wr_clk_cntr <= "00";
          end if;
        else 
          r_wr_clk_cntr <= "00";
        end if;
      end if;
    end if;
  end process;
  
    -- counts number of clk cycles in i_pclk_x2 domain (needed to for EN_WAIT_RD state)
  RD_CLK_COUNTER_PROC : process(i_pclk_x2, i_rst)
  begin
    if rising_edge(i_pclk_x2) then 
      if i_rst = '1' then
        r_rd_clk_cntr <= "00";
      else
        if r_rd_clk_cntr_en = '1' then 
          if r_rd_clk_cntr < "10" then 
            r_rd_clk_cntr <= r_rd_clk_cntr + 1;
          else 
            r_rd_clk_cntr <= "00";
          end if;
        else 
          r_rd_clk_cntr <= "00";
        end if;
      end if;
    end if;
  end process;

  -- Write domain of FIFO
  WR_STATE_MACHINE_PROC : process(i_pclk, i_rst)
  begin
    if i_rst = '1' then 
      r_wr_en <= '0';
      r_wr_clk_cntr_en <= '0';
      WR_STATE <= RST_WR;
    else 
      if rising_edge(i_pclk) then 
        case WR_STATE is 
          when RST_WR => 
            if i_rst = '1' then 
              r_wr_en <= '0';
              r_wr_clk_cntr_en <= '0';
              WR_STATE <= RST_WR;              
            else 
              r_wr_en <= '0';
              r_wr_clk_cntr_en <= '1';
              WR_STATE <= EN_WAIT_WR;
            end if;
          
          -- "EN_WAIT_WR" delays WREN two WRCLK cycles after negedge RST (needed to guarantee timing -- stated in UG473 pg. 51)
          when EN_WAIT_WR => 
            if r_wr_clk_cntr < "10" then 
              r_wr_en <= '0';
              r_wr_clk_cntr_en <= '1';
              WR_STATE <= EN_WAIT_WR;
            else 
              r_wr_en <= '1';
              r_wr_clk_cntr_en <= '0';
              WR_STATE <= FILL;
            end if;
           
          -- "FILL" Fills up the FIFO with some data so not reading from an empty FIFO
          when FILL =>  
            if w_almost_full = '0' then 
              r_wr_en <= '1';
              r_wr_clk_cntr_en <= '0';
              WR_STATE <= FILL;
            else 
              r_wr_en <= '1';
              r_wr_clk_cntr_en <= '0';
              WR_STATE <= WR;
            end if;
          
          -- "WR" monitors rst and status flag. If any are active, returns to "RST_WR" state
          when WR =>
            if i_rst = '0' or w_full = '0' then
              r_wr_en <= '1';
              r_wr_clk_cntr_en <= '0';
              WR_STATE <= WR;
            else 
              r_wr_en <= '0';
              r_wr_clk_cntr_en <= '0';
              WR_STATE <= RST_WR;
            end if;

          when others =>
            r_wr_en <= 'X';
            r_wr_clk_cntr_en <= 'X';
            WR_STATE <= RST_WR; 
        end case;
      end if;      
    end if;   
  end process;
  
  -- Read domain of FIFO
  RD_STATE_MACHINE_PROC : process(i_pclk_x2, i_rst)
  begin
    if i_rst = '1' then 
      r_rd_en <= '0';
      r_rd_clk_cntr_en <= '0';
      RD_STATE <= RST_RD;
    else 
      if rising_edge(i_pclk_x2) then
        case RD_STATE is 
          when RST_RD => 
            if i_rst = '1' then 
              r_rd_en <= '0';
              r_rd_clk_cntr_en <= '0';
              RD_STATE <= RST_RD;              
            else 
              r_rd_en <= '0';
              r_rd_clk_cntr_en <= '1';
              RD_STATE <= EN_WAIT_RD;
            end if;
          
          -- "EN_WAIT_RD" delays RDEN at least two RDCLK cycles after negedge RST (needed to guarantee timing -- stated in UG473 pg. 51)
          when EN_WAIT_RD => 
            if r_rd_clk_cntr < "10" then 
              r_rd_en <= '0';
              r_rd_clk_cntr_en <= '1';
              RD_STATE <= EN_WAIT_RD;
            else 
              r_rd_en <= '0';  -- in this case, don't pull RDEN high yet
              r_rd_clk_cntr_en <= '0';
              RD_STATE <= RD_WAIT;
            end if;
           
          -- "RD_WAIT" waits for the FIFO to fill up with some data so not reading from an empty FIFO
          when RD_WAIT =>  
            if w_almost_full = '0' then 
              r_rd_en <= '0';
              r_rd_clk_cntr_en <= '0';
              RD_STATE <= RD_WAIT;
            else 
              r_rd_en <= '1';
              r_rd_clk_cntr_en <= '0';
              RD_STATE <= RD;
            end if;
          
          -- "RD" monitors rst and status flag. If any are active, returns to "RST_RD" state
          when RD =>
            if i_rst = '0' or w_empty = '0' then 
              if r_rd_en = '0' then  -- toggles RDEN, only active once every two RDCLK cycles to keep up with WRCLK and WREN speed
                r_rd_en <= '1';
              else 
                r_rd_en <= '0';
              end if;
              r_rd_clk_cntr_en <= '0';
              RD_STATE <= RD;
            else 
              r_rd_en <= '0';
              r_rd_clk_cntr_en <= '0';
              RD_STATE <= RST_RD;
            end if;
            
          when others =>
            r_rd_en <= 'X';
            r_rd_clk_cntr_en <= 'X';
            RD_STATE <= RST_RD;            
        end case;
      end if;      
    end if;   
  end process;
  
  -- FIFO instance
   FIFO_DUALCLOCK_MACRO_0 : FIFO_DUALCLOCK_MACRO
   generic map (
      DEVICE => "7SERIES",            
      ALMOST_FULL_OFFSET => X"001F4",  
      ALMOST_EMPTY_OFFSET => X"0005", 
      DATA_WIDTH => 30,   
      FIFO_SIZE => "18Kb",            
      FIRST_WORD_FALL_THROUGH => TRUE) 
   port map (
      ALMOSTEMPTY => open,
      ALMOSTFULL => w_almost_full,     
      DO => w_FIFO_data_out,                     
      EMPTY => w_empty,               
      FULL => w_full,                 
      RDCOUNT => open,           
      RDERR => o_rd_err,             
      WRCOUNT => open,          
      WRERR => o_wr_err,               
      DI => i_data,                     
      RDCLK => i_pclk_x2,             
      RDEN => r_rd_en,    
      RST => i_rst,                 
      WRCLK => i_pclk,              
      WREN => r_wr_en                  
   );
   
  -- 30 to 15 mux sel toggle
  w_sel <= r_rd_en;
  w_mux <= w_FIFO_data_out(14 downto 0) when w_sel = '0' else w_FIFO_data_out(29 downto 15);
  
  -- register output of mux
  OUTPUT_REG_PROC : process(i_pclk_x2, i_rst)
  begin  
    if rising_edge(i_pclk_x2) then
      if i_rst = '1' then 
        r_data_out <= (others => '0');
      else 
        r_data_out <= w_mux;
      end if;
    end if;
  end process;
  
  o_data <= r_data_out;

end rtl;






