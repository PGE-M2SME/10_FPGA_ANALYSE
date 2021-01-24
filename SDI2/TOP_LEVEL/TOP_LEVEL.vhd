library ieee;
use ieee.std_logic_1164.all;

entity TOP_LEVEL is 
	port (
			hdinp_ch3 : in	std_logic;
			hdinn_ch3 : in	std_logic;
			clk		: in	std_logic;
      vid_format  : out std_logic_vector(1 downto 0)
		);
end TOP_LEVEL;

architecture arc of TOP_LEVEL is
component PLL_IP
    port (
        CLK: in std_logic; 
        CLKOP: out std_logic; 
        LOCK: out std_logic);
end component;

component PCS_IP
GENERIC (USER_CONFIG_FILE    :  String := "PCS_IP.txt");
port (
------------------
    refclkp, refclkn  :   in std_logic;
-- CH0 --
-- CH1 --
-- CH2 --
-- CH3 --
    hdinp_ch3, hdinn_ch3    :   in std_logic;
    rxiclk_ch3    :   in std_logic;
    rx_full_clk_ch3   :   out std_logic;
    rx_half_clk_ch3   :   out std_logic;
    fpga_rxrefclk_ch3    :   in std_logic;
    rxdata_ch3   :   out std_logic_vector (19 downto 0);
    rx_pwrup_ch3_c    :   in std_logic;
    rx_los_low_ch3_s   :   out std_logic;
    rx_cdr_lol_ch3_s   :   out std_logic;
    rxd_ldr_ch3   :   out std_logic;
    rx_div11_mode_ch3_c   : in std_logic;
    rx_div2_mode_ch3_c   : in std_logic;
---- Miscillaneous ports
    refclk2fpga   :   out std_logic;
    rst_n      :   in std_logic;
    serdes_rst_qd_c    :   in std_logic);

end component;

component SDI_IP_top 
port (
      --=====INPUTS
      --===== global input signals 
      --===== transmitter input signals 

      --===== receiver input signals 
            rx_clk      : in std_logic;                      -- receive clock input synchronous with rxdata
            rxdata      : in std_logic_vector(19 downto 0);  -- parallel data received from SERDES
            rx_rate     : in std_logic_vector(2 downto 0);   -- receiver scan control: {3G enable, HD enable, SD enable}

      --=====OUTPUTS
      --===== transmitter output signals 

      --===== receiver output signals 
            pd_out      : out std_logic_vector(19 downto 0); -- parralel output data from the receiver
            vid_active  : out std_logic;                     -- Indicates the receiver is locked to a valid video
            trs_out     : out std_logic;                     -- TRS (either EAV or SAV) output
            rx_tg_hdn   : out std_logic;                     -- indicates whether 3G or HD is being received
            rx_hd_sdn   : out std_logic;                     -- indicates whether Hd or SD is being received
            vid_format  : out std_logic_vector(1 downto 0);  -- Video format (0-SD, 1-1280x720, 2-1920x1035, 3-1920x1080)
            frame_format: out std_logic_vector(2 downto 0);  -- Frame format (0,1,,7 ---> res,24p,25p,30p,50i,60i,50p,60p)
            field       : out std_logic;                     -- field 
            vblank      : out std_logic;                     -- vertical blanking
            hblank      : out std_logic;                     -- horizontal blanking
            ln1_out     : out std_logic_vector(10 downto 0); -- line number output for stream1
            eav_error   : out std_logic;                     -- EAV error
            sav_error   : out std_logic;                     -- SAV error
            y1_crc_error: out std_logic;                     -- CRC error for y channel of stream1
            c1_crc_error: out std_logic;                     -- CRC error for c channel of stream1

      --===== global input signal 
            rstn        : in  std_logic                      -- system reset
      );

end component;

signal CLKOP, PLL_LOCK : std_logic;
signal rx_clk, rstn : std_logic;
signal rxdata : std_logic_vector(19 downto 0);
signal rx_hlfClk, pcs_rstn : std_logic;
begin

  PLL1 : PLL_IP
  port map(
      CLK     =>  clk, 
      CLKOP   =>  CLKOP, 
      LOCK    =>  open   
    );

  SDI : SDI_IP_top
  port map(
    rx_clk    =>  rx_clk,
    rxdata    =>  rxdata,
    rx_rate   =>  "010",
    vid_format  =>  vid_format,
    rstn      =>  rstn
    );

  PCS : PCS_IP
  port map(
    hdinn_ch3         => hdinn_ch3,
    hdinp_ch3         => hdinp_ch3,
    rxdata_ch3        => rxdata,
    fpga_rxrefclk_ch3 => CLKOP,
    rxiclk_ch3        => rx_hlfClk,
    rx_half_clk_ch3   => rx_hlfClk,
    rx_pwrup_ch3_c    => '1',
    rx_div2_mode_ch3_c  => '1',
    rx_div11_mode_ch3_c => '0',  --- modified; initially 1
    rst_n                => pcs_rstn,
    serdes_rst_qd_c   => pcs_rstn, 

    refclkp           => '0',
    refclkn           => '0' 
    );

  pcs_rstn <= '1';
  rstn     <= '1';
  rx_clk   <= rx_hlfClk;


end arc;