library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all ; 
use IEEE.std_logic_unsigned.all;


-- POUR UTILISER ANALYSEUR LOGIQUE :

-- 1-      Tools -> Reveal INSERTER 
-- 2-      Ajouter/Supprimer/modifier les signaux  observer 
-- 3-      Cliquer sur INSERT DEBUG ( petite icone verte  droite des paramtres)
-- 4-      Re-compiler le projet entier 
-- 5-      Flasher le FPGA
-- 6-      Ouvrir le reveal analyseur ( Tools -> Reveal Analyseur -> Create new file -> REMPLIR TOUS LES CHAMPS avec le chemin du projet et le chemin du reveal inserter )
-- 7-      Observer les signaux



-- Etapes de vrification du projet :

--   1- Verifier que les PLL1 et PLL2 et fonctionnent 
--   2- Verifier que le PCSB fonctionne
--   3- Verifier que l'IP SDI fonctionne 


-- INFOS COMPLEMENTAIRES : 

-- A chaque pull de GitHub, regnrer les IP. ( double click sur les fichier .ipx du projet)
-- Verifier les signaux des IP PCS et SDI, je n'ai pas trop creuser la dessus.
-- Les fichier .vhd des IP ne DOIVENT PAS Etre dans le projet mais uniquement les .ipx des IP gnrs
-- A chaque compilation du projet, vrifier les warning, cela peut montrer l'inactivit de certains signaux utiles.
-- Essayez de tenir le projet propre ( mettre les IPs dans un meme rpertoires, les fichiers sources dans un autre etc ...)



entity TOP_LEVEL is 
	port (
	----input 		
DE : in std_logic ; 
Vsync : in std_logic ; 
Hsync : in std_logic ; 
ODCK : in std_logic ;
---------output 
Hdisp : out std_logic_vector ( 15 downto 0);
Vdisp : out std_logic_vector ( 15 downto 0);
Hblank: out std_logic_vector ( 15 downto 0);
Vblank: out std_logic_vector ( 15 downto 0)

		);
end TOP_LEVEL;

architecture arc of TOP_LEVEL is

signal sig_Hdisp :  std_logic_vector(15 downto 0)  := (others =>'0') ; 
signal sig_Vdisp : std_logic_vector(15 downto 0)  := (others =>'0') ; 

begin 

hor_disp : process( ODCK ) 

begin 
	if ( ODCK'event  and ODCK= '1' ) then 
		if ( DE = '1') then 
			sig_Hdisp <= sig_Hdisp +1 ; 
		elsif( falling_edge (DE) ) then 
		end if ; 
	end if  ; 
end process ;

Hdisp <= sig_Hdisp; 


ver_disp : process ( ODCK) 
begin 
	if ( ODCK'event  and ODCK= '1' ) then 
		if ( falling_edge ( DE) ) then 
			sig_Vdisp <= sig_Vdisp +1 ; 
		end if ; 
		if( Vsync <= '1' ) then 
			sig_Vdisp <= sig_Vdisp ; 
		end if ; 
	end if ; 
end process ; 

Vdisp <= sig_Vdisp ; 


end arc;