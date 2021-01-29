library ieee;
use ieee.std_logic_1164.all;


-- POUR UTILISER ANALYSEUR LOGIQUE :

-- 1-      Tools -> Reveal INSERTER -- 2-      Ajouter/Supprimer/modifier les signaux à observer 
-- 3-      Cliquer sur INSERT DEBUG ( petite icone verte à droite des paramètres)
-- 4-      Re-compiler le projet entier 
-- 5-      Flasher le FPGA
-- 6-      Ouvrir le reveal analyseur ( Tools -> Reveal Analyseur -> Create new file -> REMPLIR TOUS LES CHAMPS avec le chemin du projet et le chemin du reveal inserter )
-- 7-      Observer les signaux



-- Etapes de vérification du projet :

--   1- Verifier que les PLL1 et PLL2 et fonctionnent 
--   2- Verifier que le PCSB fonctionne
--   3- Verifier que l'IP SDI fonctionne 


-- INFOS COMPLEMENTAIRES : 

-- A chaque pull de GitHub, regénérer les IP. ( double click sur les fichier .ipx du projet)
-- Verifier les signaux des IP PCS et SDI, je n'ai pas trop creuser la dessus.
-- Les fichier .vhd des IP ne DOIVENT PAS Etre dans le projet mais uniquement les .ipx des IP générés
-- A chaque compilation du projet, vérifier les warning, cela peut montrer l'inactivité de certains signaux utiles.
-- Essayez de tenir le projet propre ( mettre les IPs dans un meme répertoires, les fichiers sources dans un autre etc ...)



entity TOP_LEVEL is 
	port (
			hdinp_ch3 : in	std_logic;
			hdinn_ch3 : in	std_logic;
			clk_125M		: in	std_logic;
            
			vid_format  : out std_logic_vector(1 downto 0)
		);
end TOP_LEVEL;

architecture arc of TOP_LEVEL is
component PLL_1
    port (
        CLK: in std_logic; 
        CLKOP: out std_logic; 
        LOCK: out std_logic);
end component;


component PLL_2
    port (
        CLK: in std_logic; 
        CLKOP: out std_logic; 
        LOCK: out std_logic);
end component;

component PCS_IP is
   GENERIC (USER_CONFIG_FILE    :  String := "PCS_IP.txt");
 port (
------------------
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
    fpga_txrefclk  :   in std_logic;
    refclk2fpga   :   out std_logic;
    rst_n      :   in std_logic;
    serdes_rst_qd_c    :   in std_logic);

end component;

component SDI_IP
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

signal Clk148_5Mhz      : std_logic;
signal CLKOP1, PLL_LOCK : std_logic;
signal rx_clk, rstn : std_logic;
signal rxdata : std_logic_vector(19 downto 0);
signal rx_hlfClk, pcs_rstn : std_logic;
signal lol, los   : std_logic;
begin

  PLL1 : PLL_1
  port map(
      CLK     =>  clk_125M, 
      CLKOP   =>  CLKOP1, 
      LOCK    =>  open   
    );
	
  PLL2 : PLL_2
  port map(
      CLK     =>  CLKOP1, 
      CLKOP   =>  Clk148_5Mhz, 
      LOCK    =>  open   
    );


  PCS : PCS_IP
  port map(
    hdinn_ch3         => hdinn_ch3,
    hdinp_ch3         => hdinp_ch3,
    rxdata_ch3        => rxdata,
    fpga_rxrefclk_ch3 => Clk148_5Mhz,
	fpga_txrefclk =>    Clk148_5Mhz,
    rxiclk_ch3        => rx_hlfClk,
	 rx_los_low_ch3_s  =>  los, 
    rx_cdr_lol_ch3_s   =>  lol,
    rx_half_clk_ch3   => open ,
    rx_pwrup_ch3_c    => '1',
    rx_div2_mode_ch3_c  => '1',
    rx_div11_mode_ch3_c => '1',  --- modified; initially 1
    rst_n                => pcs_rstn,
    serdes_rst_qd_c   => '0'

  
    );


  SDI : SDI_IP
  port map(
    rx_clk    =>  rx_clk,
    rxdata    =>  rxdata,
    rx_rate   =>  "010",
    vid_format  =>  vid_format,
    rstn      =>  rstn
    );

  pcs_rstn <= '1';
  rstn     <= '1';
  rx_clk   <= rx_hlfClk;


end arc;