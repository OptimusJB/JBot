extends Node

var retour_lobby_anim = "rien"	# = rien, oui, non
var popup_switch = []	# liste de textes, pour connexion, affichage des textes à l'intérieur lors de ready

var temp_mdp = ""	# permet de récupérer le mot de passe

# pour l'animation d'arrivée de la réponse
var reponse_finale = ""
var index_reponse = 0
var noeud_concerne
