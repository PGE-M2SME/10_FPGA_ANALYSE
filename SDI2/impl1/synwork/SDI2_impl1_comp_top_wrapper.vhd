--
-- Synopsys
-- Vhdl wrapper for top level design, written on Tue Jan 26 07:54:51 2021
--
library ieee;
use ieee.std_logic_1164.all;

entity wrapper_for_TOP_LEVEL is
   port (
      hdinp_ch3 : in std_logic;
      hdinn_ch3 : in std_logic;
      clk_125M : in std_logic;
      vid_format : out std_logic_vector(1 downto 0)
   );
end wrapper_for_TOP_LEVEL;

architecture arc of wrapper_for_TOP_LEVEL is

component TOP_LEVEL
 port (
   hdinp_ch3 : in std_logic;
   hdinn_ch3 : in std_logic;
   clk_125M : in std_logic;
   vid_format : out std_logic_vector (1 downto 0)
 );
end component;

signal tmp_hdinp_ch3 : std_logic;
signal tmp_hdinn_ch3 : std_logic;
signal tmp_clk_125M : std_logic;
signal tmp_vid_format : std_logic_vector (1 downto 0);

begin

tmp_hdinp_ch3 <= hdinp_ch3;

tmp_hdinn_ch3 <= hdinn_ch3;

tmp_clk_125M <= clk_125M;

vid_format <= tmp_vid_format;



u1:   TOP_LEVEL port map (
		hdinp_ch3 => tmp_hdinp_ch3,
		hdinn_ch3 => tmp_hdinn_ch3,
		clk_125M => tmp_clk_125M,
		vid_format => tmp_vid_format
       );
end arc;
