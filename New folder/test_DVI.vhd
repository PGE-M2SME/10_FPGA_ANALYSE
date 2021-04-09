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



entity test_DVI is 
	port (
	----input 		
DE : in std_logic ; 
Vsync : in std_logic ; 
Hsync : in std_logic ; 
ODCK : in std_logic ;
---------output 
Hdisp : out std_logic_vector ( 15 downto 0);--hresoltion
Vdisp : out std_logic_vector ( 15 downto 0);--Vresolution 
Hblank: out std_logic_vector ( 15 downto 0);
Vblank: out std_logic_vector ( 15 downto 0); 
Hsync_out : out std_logic_vector ( 15 downto 0) ; --comptage de la duree du signal hsync 
Vsync_out : out std_logic_vector ( 15 downto 0)  --- comptage de la duree du signal vsync 

		);
end test_DVI;

architecture arc of test_DVI is
signal sig_Hdisp :  std_logic_vector(15 downto 0)  := (others =>'0') ; 
signal sig_Hdisp_cpt :  std_logic_vector(15 downto 0)  := (others =>'0') ; 
signal sig_Vdisp : std_logic_vector(15 downto 0)  := (others =>'0') ;
signal sig_Hsync : std_logic_vector(15 downto 0)  := (others =>'0') ;
signal sig_Hsync_cpt : std_logic_vector(15 downto 0) := (others =>'0') ; 
signal sig_Vsync : std_logic_vector(15 downto 0)  := (others =>'0') ; 
signal sig_Hblank : std_logic_vector(15 downto 0 ) := ( others =>'0') ;
signal sig_Vblank : std_logic_vector(15 downto 0 ) := ( others =>'0') ;  
signal sig_compt_front_Hsync : std_logic_vector(15 downto 0 ) := ( others =>'0') ; 
signal out_comp : std_logic :='0' ; 
signal rising_Hsync : std_logic := '0' ; 
signal falling_DE : std_logic := '0' ; 
signal detect : std_logic :='0' ; 
signal D_detect : std_logic :='0' ; 
signal detect_DE : std_logic := '0' ; 
signal D_detect_DE :std_logic := '0' ; 

begin 
--------------------comptage nb pixel horizontaux 
hor_disp : process( ODCK) 
begin 

if ( ODCK'event and ODCK = '1'  ) then 
	if ( DE = '1') then 
		sig_Hdisp_cpt <= sig_Hdisp_cpt +1 ; 
	elsif( DE= '0'and  Hsync = '0') then 
  		sig_Hdisp_cpt <= sig_Hdisp_cpt ;
		sig_Hdisp <= sig_Hdisp_cpt ;  
	elsif( Hsync = '1' and DE = '0') then 
		sig_Hdisp_cpt <= ( others => '0') ; 
 	 end if ; 
end if ; 
end process ;
Hdisp <= sig_Hdisp; 
--------comptage nb pixels verticaux 
ver_disp : process (ODCK) 
begin 
if ( ODCK'event and ODCK = '1') then 
if ( falling_DE = '1'  ) then 
sig_Vdisp <= sig_Vdisp +1 ; 
elsif( DE = '1' and Vsync = '0') then 
sig_Vdisp <= sig_Vdisp ; 
elsif( Vsync = '1' and DE = '0' ) then 
sig_Vdisp <= (others => '0')  ; 
end if ;  
end if ; 
end process ; 
Vdisp <= sig_Vdisp ; 
----------------------- comptage Hsync 
Hor_sync : process ( ODCK ) 
begin 
if( ODCK'event and ODCK = '1') then 
	if ( DE = '0' and Hsync = '1') then 
		sig_Hsync <= sig_Hsync +1 ;  
	elsif( DE= '1' and Hsync = '0') then 
		sig_Hsync <= sig_Hsync ; 
		
	elsif ( DE ='0' and Hsync = '0' ) then  
		sig_Hsync <= (others =>'0') ; 
	end if ; 
end if ; 
end process ; 
Hsync_out <= sig_Hsync ; 
----------------------------comptage Vsync 
ver_sync : process ( ODCK) 
begin 
if( ODCK'event and ODCK = '1') then 
	if ( DE = '0' and Vsync = '1') then 
		sig_Vsync <= sig_Vsync+1 ; 
	elsif( DE= '1' and Vsync = '0') then 
		sig_Vsync <= (others => '0') ; 
	elsif ( DE ='0' and Vsync = '0' ) then 
		sig_Vsync <= (others => '0') ; 
	end if ; 
end if ; 
end process ; 
Vsync_out <= sig_Vsync ; 
----------------------------comptage Hblank 
H_blanking : process ( ODCK) 
begin 
 if( ODCK'event and ODCK = '1') then 
	if ( DE = '0') then 
	 sig_Hblank <= sig_Hblank +1 ; 
	elsif( DE = '1' ) then 
	sig_Hblank <= (others => '0') ;
	end if 	; 
end if ;  
 end process; 
Hblank <= sig_Hblank ; 
-------------------------comptage du nombre de front Hsync chaque ligne 
compteur_front_Hsync : process( ODCK) 
begin 
	if ( ODCK'event and ODCK = '1') then 
	if( DE = '0' and rising_Hsync = '1') then 
		sig_compt_front_Hsync <= sig_compt_front_Hsync + 1 ; 
	elsif( DE = '1' ) then 
	 	sig_compt_front_Hsync <= (others => '0')  ; 
	end if ;  
	end if ; 
end process ; 
----------------------------------comparaison +
comparateur : process(ODCK) 
begin  
if ( ODCK'event and ODCK = '1') then 
	if( sig_compt_front_Hsync >= X"0001" and DE ='0') then 
		out_comp <='1' ; 
	elsif( DE = '1'  ) then 
		out_comp <= '0' ; 
	end if  ; 
end if ; 
end process ; 
-----------------------------------calcul Vblank 

V_blank : process(ODCK) 
begin  
	if ( ODCK'event and ODCK = '1') then 
	if( out_comp = '1' and rising_Hsync= '1') then 
		sig_Vblank <= sig_Vblank + 1 ; 
	elsif( out_comp = '0' and DE ='1') then 
		sig_Vblank <= (others => '0') ; 
	end if ; 
end if ;  

end process ; 
Vblank <= sig_Vblank ; 
----------------------detecteur de front montant Hsync 
detect_front_montant_Hsync : process(ODCK) 
begin 
if ( ODCK'event and ODCK = '1') then 
	detect <= Hsync ; 
	D_detect <= detect ; 
	end if ; 
if( D_detect = '0' and detect = '1') then 
	rising_Hsync <= '1' ; 
else 
	rising_Hsync <= '0' ; 
end if ; 
	end process ; 
--------------------- detecteur front descendant DE 
detect_front_descendant_DE : process(ODCK) 
begin 
if ( ODCK'event and ODCK = '1') then 
	detect_DE <= DE; 
	D_detect_DE <= detect_DE ; 
	end if ; 
if( D_detect_DE = '1' and detect_DE = '0') then 
	falling_DE <= '1' ; 
else 
	falling_DE <= '0' ; 
end if ; 
	end process ; 
----------------------La fin 

end arc;

