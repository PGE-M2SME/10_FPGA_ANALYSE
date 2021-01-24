# TEST SDI_IP (Ne fonctionne pas encore)
Premier test de l'IP SDI

## CONFIGURATION

- Configuration de SDI_IP
- Configuration de PCS_IP pour les liens SERDES
- Configuration de la PLL 125 MHz --> 148.5 MHz

## TOP_LEVEL DESIGN
Le fichier principal se trouve dans le répertoire "TOP_LEVEL".
On a instancié chacun des composants ci-dessus.

## PROBLÈMES
On ne voit pas trop la raison pour laquelle le programme ne fonctionne pas.
- PLL ... OK (validée)
- SDI_IP ... OK (tout semble correct, mais aucun moyen de valider son bon fonctionnement car elle dépend du reste du code)
- SERDES/PCS ... ?
	- Les port semblent être assignés automatiquement (d'aprés le rapport de compilation)
	- Peut être faut-il initialiser le composant SFP EB30CSRT-LM (datasheet introuvable. Il faut la demander chez le constructeur directement, on attend donc les conseils de Tachyssema)