----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads (adapted from schematic by vivado forum user: stripline, with input from EEVblog users -- link below)
--           schematic link: https://forums.xilinx.com/t5/Virtex-Family-FPGAs-Archived/How-to-synchronize-LOCKED-output-of-PLL-for-use-as-reset/td-p/561924
--           EEVblog post: https://www.eevblog.com/forum/fpga/what-is-the-counter-for-in-this-synchronous-reset-circuit/new/#new
-- 
-- Create Date: 05/02/2021 08:21:48 PM
-- Design Name: 
-- Module Name: synchronous_reset_release - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: The purpose of this entity is to use the "locked" output from the PLL as a reset. By default, the "locked" output is not synchronous
--              with the output clocks of the PLL. This circuit takes in the "locked" signal fromm the PLL,
--              and synchronously de-assert a "locked_sync/reset" signal with respect to a 25 MHz. 
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
use IEEE.NUMERIC_STD.all;


entity synchronous_reset_release is
  Port ( 
    i_locked : in STD_LOGIC;
    i_rst_n : in STD_LOGIC;
    i_pclk : in STD_LOGIC;
    o_rst_n : out STD_LOGIC
  );
end synchronous_reset_release;

architecture rtl of synchronous_reset_release is

  signal w_DFF1_to_DFF2 : STD_LOGIC;
  signal w_locked_sync : STD_LOGIC;
  signal w_clk_counter : STD_LOGIC_VECTOR(1 downto 0);
  signal r_rst_n : STD_LOGIC := '0';
  
  type t_state is (WAITING_STATE, DELAY_STATE, RELEASE_STATE);
  signal STATE : t_state;
 

begin

  DFF1 : entity work.DFF(rtl)
  port map(
    clk => i_pclk,
    D => i_locked,
    Q => w_DFF1_to_DFF2
    );
    
    
  DFF2 : entity work.DFF(rtl)
  port map(
    clk => i_pclk,
    D => w_DFF1_to_DFF2,
    Q => w_locked_sync
    );
    
    
  clk_counter1 : entity work.clk_counter(rtl)
  generic map(
    g_delay_clk_cycles => 5,
    g_counter_width => 2
    )
  port map(
    i_en => w_locked_sync,
    i_pclk => i_pclk,
    o_clk_counter => w_clk_counter
    );
    
    
  STATE_MACHINE_PROC : process(i_pclk)
  begin 
    if rising_edge(i_pclk) then 
      if i_rst_n = '0' then 
        r_rst_n <= '0';
        STATE <= WAITING_STATE;
      else 
        case STATE is 
          when WAITING_STATE => 
            r_rst_n <= '0';
            if w_locked_sync = '1' then 
              STATE <= DELAY_STATE;
            else 
              STATE <= WAITING_STATE;
            end if;
            
          when DELAY_STATE =>
            r_rst_n <= '0';
            if w_clk_counter = "11" then 
              STATE <= RELEASE_STATE;
            else 
              STATE <= DELAY_STATE;
            end if;
            
          when RELEASE_STATE =>
            r_rst_n <= '1';
            
        end case;
      end if;
    end if;  
  end process;
  
  o_rst_n <= r_rst_n;

end rtl;









