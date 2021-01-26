-------------------------------------------------------------------------------
-- Copyright(c) 2009 Lattice Semiconductor Corporation. All rights reserved.
-- WARNING - Changes to this file should be performed by re-running IPexpress
-- or modifying the .LPC file and regenerating the core.  Other changes may lead
-- to inconsistent simulation and/or implemenation results
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
entity SDI_IP_top is port (
      --=====INPUTS
      --===== global input signals 
      --===== transmitter input signals 

      --===== receiver input signals 
            rx_clk      : in std_logic;                      -- receive clock input synchronous with rxdata
            rxdata      : in std_logic_vector(19 downto 0);  -- parallel data received from SERDES
            rx_rate     : in std_logic_vector(2 downto 0);   -- receiver scan control: {3G enable, HD enable, SD enable}
            rx_full_clk : in std_logic;                      -- 27 MHz SD clock when 10-bits Rx mode is used

      --=====OUTPUTS
      --===== transmitter output signals 

      --===== receiver output signals 
            pd_out      : out std_logic_vector(19 downto 0); -- parralel output data from the receiver
            vid_active  : out std_logic;                     -- Indicates the receiver is locked to a valid video
            trs_out     : out std_logic;                     -- TRS (either EAV or SAV) output
            ychannel    : out std_logic;                     -- y channel output indicator
            rx_lb_lan   : out std_logic;                     -- indicates if output is 3G Level-B or not
            rx_tg_hdn   : out std_logic;                     -- indicates whether 3G or HD is being received
            rx_hd_sdn   : out std_logic;                     -- indicates whether Hd or SD is being received
            vid_format  : out std_logic_vector(1 downto 0);  -- Video format (0-SD, 1-1280x720, 2-1920x1035, 3-1920x1080)
            frame_format: out std_logic_vector(2 downto 0);  -- Frame format (0,1,,7 ---> res,24p,25p,30p,50i,60i,50p,60p)
            field       : out std_logic;                     -- field 
            vblank      : out std_logic;                     -- vertical blanking
            hblank      : out std_logic;                     -- horizontal blanking
            ln1_out     : out std_logic_vector(10 downto 0); -- line number output for stream1
            ln2_out     : out std_logic_vector(10 downto 0); -- line number output for stream2
            eav_error   : out std_logic;                     -- EAV error
            sav_error   : out std_logic;                     -- SAV error
            y1_crc_error: out std_logic;                     -- CRC error for y channel of stream1
            c1_crc_error: out std_logic;                     -- CRC error for c channel of stream1
            y2_crc_error: out std_logic;                     -- CRC error for y channel of stream2
            c2_crc_error: out std_logic;                     -- CRC error for c channel of stream2

            pdo_clk     : out std_logic;                     -- Multiplexed output clock synchronous with output data
      --===== global input signal 
            rstn        : in  std_logic                      -- system reset
      );

end SDI_IP_top;

architecture arch of SDI_IP_top is
component SDI_IP
   port (
      --=====INPUTS
      --===== global input signals 
      --===== transmitter input signals 

      --===== receiver input signals 
            rx_clk      : in std_logic;                      -- receive clock input synchronous with rxdata
            rxdata      : in std_logic_vector(19 downto 0);  -- parallel data received from SERDES
            rx_rate     : in std_logic_vector(2 downto 0);   -- receiver scan control: {3G enable, HD enable, SD enable}
            rx_full_clk : in std_logic;                      -- 27 MHz SD clock when 10-bits Rx mode is used

      --=====OUTPUTS
      --===== transmitter output signals 

      --===== receiver output signals 
            pd_out      : out std_logic_vector(19 downto 0); -- parralel output data from the receiver
            vid_active  : out std_logic;                     -- Indicates the receiver is locked to a valid video
            trs_out     : out std_logic;                     -- TRS (either EAV or SAV) output
            ychannel    : out std_logic;                     -- y channel output indicator
            rx_lb_lan   : out std_logic;                     -- indicates if output is 3G Level-B or not
            rx_tg_hdn   : out std_logic;                     -- indicates whether 3G or HD is being received
            rx_hd_sdn   : out std_logic;                     -- indicates whether Hd or SD is being received
            vid_format  : out std_logic_vector(1 downto 0);  -- Video format (0-SD, 1-1280x720, 2-1920x1035, 3-1920x1080)
            frame_format: out std_logic_vector(2 downto 0);  -- Frame format (0,1,,7 ---> res,24p,25p,30p,50i,60i,50p,60p)
            field       : out std_logic;                     -- field 
            vblank      : out std_logic;                     -- vertical blanking
            hblank      : out std_logic;                     -- horizontal blanking
            ln1_out     : out std_logic_vector(10 downto 0); -- line number output for stream1
            ln2_out     : out std_logic_vector(10 downto 0); -- line number output for stream2
            eav_error   : out std_logic;                     -- EAV error
            sav_error   : out std_logic;                     -- SAV error
            y1_crc_error: out std_logic;                     -- CRC error for y channel of stream1
            c1_crc_error: out std_logic;                     -- CRC error for c channel of stream1
            y2_crc_error: out std_logic;                     -- CRC error for y channel of stream2
            c2_crc_error: out std_logic;                     -- CRC error for c channel of stream2

            pdo_clk     : out std_logic;                     -- Multiplexed output clock synchronous with output data
      --===== global input signal 
            rstn        : in  std_logic                      -- system reset
      );
end component;

begin
   SDI_IP_inst : SDI_IP
   port map (
      --=====INPUTS
      --===== global input signals 
      --===== transmitter input signals 

      --===== receiver input signals 
            rx_clk       => rx_clk,
            rxdata       => rxdata,
            rx_rate      => rx_rate,
            rx_full_clk  => rx_full_clk,

      --=====OUTPUTS
      --===== transmitter output signals 

      --===== receiver output signals 
            pd_out       => pd_out,
            vid_active   => vid_active,
            trs_out      => trs_out,
            ychannel     => ychannel,
            rx_lb_lan    => rx_lb_lan,
            rx_tg_hdn    => rx_tg_hdn,
            rx_hd_sdn    => rx_hd_sdn,
            vid_format   => vid_format,
            frame_format => frame_format,
            field        => field, 
            vblank       => vblank,
            hblank       => hblank,
            ln1_out      => ln1_out,
            ln2_out      => ln2_out,
            eav_error    => eav_error,
            sav_error    => sav_error,
            y1_crc_error => y1_crc_error,
            c1_crc_error => c1_crc_error,
            y2_crc_error => y2_crc_error,
            c2_crc_error => c2_crc_error,
            pdo_clk      => pdo_clk,
      --===== global input signal 
            rstn         => rstn
   );

end arch;
