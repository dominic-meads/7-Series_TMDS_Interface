----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dominic Meads
-- 
-- Create Date: 05/09/2021 10:02:26 AM
-- Design Name: 
-- Module Name: sync_rst_release - rtl
-- Project Name: TMDS Video Interface Tx
-- Target Devices: 7-Series FPGAs and SoCs
-- Tool Versions: 
-- Description: Uses the "locked" output from the PLL as a reset. By default, the "locked" output is not synchronous
--              with the output clocks of the PLL. This circuit takes in the "locked" signal fromm the PLL,
--              and synchronously de-asserts (after a defined number of clock cycles) a "locked_sync/reset" signal 
--              with respect to the slower output clk of the PLL. 
--
--             (Adapted from schematic by vivado forum user: stripline, with input from EEVblog users -- links below)
--             schematic link: https://forums.xilinx.com/t5/Virtex-Family-FPGAs-Archived/How-to-synchronize-LOCKED-output-of-PLL-for-use-as-reset/td-p/561924
--             EEVblog post: https://www.eevblog.com/forum/fpga/what-is-the-counter-for-in-this-synchronous-reset-circuit/new/#new
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


entity synch_rst_release is
  Port ( 
    i_locked : in STD_LOGIC;
    i_rst_n : in STD_LOGIC;
    i_pclk : in STD_LOGIC;
    o_rst_n : out STD_LOGIC
  );
end synch_rst_release;

architecture rtl of synch_rst_release is

  signal w_DFF1_to_DFF2 : STD_LOGIC;
  signal w_locked_sync : STD_LOGIC;
  signal w_delay_cntr : STD_LOGIC_VECTOR(3 downto 0);
  signal r_rst_n : STD_LOGIC := '0';
  
  type t_state is (WAITING_STATE, DELAY_STATE, RELEASE_STATE);
  signal STATE : t_state;
 
begin

   FDRE_1 : FDRE
   generic map (
      INIT => '0') 
   port map (
      Q => w_DFF1_to_DFF2,      
      C => i_pclk,      
      CE => '1',    
      R => '0',      
      D => i_locked       
   );
    
  FDRE_2 : FDRE
   generic map (
      INIT => '0') 
   port map (
      Q => w_locked_sync,      
      C => i_pclk,      
      CE => '1',    
      R => '0',      
      D => w_DFF1_to_DFF2      
   );
    
  delay_cntr_1 : entity work.delay_cntr(rtl)
  generic map(
    g_delay_cycles => 10,
    g_cntr_width => 4
    )
  port map(
    i_en => w_locked_sync,
    i_pclk => i_pclk,
    o_delay_cntr => w_delay_cntr
    );
    
    
  STATE_MACHINE_PROC : process(i_pclk)
  begin 
    if rising_edge(i_pclk) then 
      if i_rst_n = '0' then 
        r_rst_n <= '0';
        STATE <= WAITING_STATE;  -- default is waiting for "locked_sync"
      else 
        case STATE is 
          when WAITING_STATE =>  -- WAITING_STATE waits for the "locked_sync" signal to go high
            r_rst_n <= '0';
            if w_locked_sync = '1' then 
              STATE <= DELAY_STATE;
            else 
              STATE <= WAITING_STATE;
            end if;
          when DELAY_STATE =>  -- DELAY_STATE sees the high "locked_sync" signal, and enables the delay_cntr for the reset
            r_rst_n <= '0';
            if w_delay_cntr = "11" then 
              STATE <= RELEASE_STATE;
            else 
              STATE <= DELAY_STATE;
            end if;
          when RELEASE_STATE =>  -- after the delay, the RELEASE_STATE releases the output reset (unless input reset is active)
            r_rst_n <= '1';
        end case;
      end if;
    end if;  
  end process;
  
  o_rst_n <= r_rst_n;

end rtl;

