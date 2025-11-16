extends Node

# version GDscript de fonctions.py de ChatJBT
var stopwords = []

func _ready() -> void:
	# ATTENTION note importante : stopwords-fr.txt doit être mis comme un fichier non ressource pendant l'export
	
	# on load les stopwords dans la variable
	var fichier_read = FileAccess.get_file_as_string("res://serveur/stopwords-fr.txt")
	if fichier_read == "":
		push_error("problème lors de la lecture du fichier stopwords")
	for element in fichier_read.split("\n"):
		stopwords.append(element)

func remove_stopwords(chaine:String):
	# retourne la chaine sans les stopwords
	var liste_chaine = chaine.split(" ")
	var a_supprimer = []
	var new_chaine = ""
	for element in liste_chaine:
		for stopword in stopwords:
			if element == stopword:
				a_supprimer.append(element)
				break
	
	for element in a_supprimer:
		liste_chaine.erase(element)
	
	for index_element in range(len(liste_chaine)):
		new_chaine = new_chaine + liste_chaine[index_element]
		if not index_element == len(chaine) - 1:
			new_chaine = new_chaine + " "
	return new_chaine
	
func is_blacklisted(pseudo:String):
	return pseudo in Save.blacklist

func add_to_blacklist(pseudo):
	if not is_blacklisted(pseudo):
		Save.blacklist.append(pseudo)
		Save.serveur_sauvegarder()

func get_stat(pseudo:String, stat:String):
	"""
    argument stat :
    0:nb questions
    1:nb suggestions
    2:nb suggestions acceptées
    3:nb suggestions refusées
    """
	assert(stat in ["questions", "suggestions", "accepts", "refus"], "stat invalide")
	var stat_choisie = {"questions":0, "suggestions":1, "accepts":2, "refus":3}[stat]
	if not pseudo in Save.stats_utilisateurs.keys():
		Save.stats_utilisateurs[pseudo] = [0, 0, 0, 0]
	return Save.stats_utilisateurs[pseudo][stat_choisie]

func change_stat(pseudo:String, stat:String, incrementation:int):
	assert(stat in ["questions", "suggestions", "accepts", "refus"], "stat invalide")
	var stat_choisie = {"questions":0, "suggestions":1, "accepts":2, "refus":3}[stat]
	if not pseudo in Save.stats_utilisateurs.keys():
		Save.stats_utilisateurs[pseudo] = [0, 0, 0, 0]
	Save.stats_utilisateurs[pseudo][stat_choisie] += incrementation
	Save.serveur_sauvegarder()

func demande_ajout_reponse(pseudo:String, question:String, reponse:String):
	if is_blacklisted(pseudo):
		return 0
	
	# on check s'il n'y a pas déjà cette suggestion
	question = question.to_lower()
	if not [pseudo, question, reponse] in Save.demandes_reponses:
		Save.demandes_reponses.append([pseudo, question, reponse])
		change_stat(pseudo, "suggestions", 1)
		Save.serveur_sauvegarder()
	return 1

func get_difference_pourcentage(mot1:String, mot2:String):
	# on crée les deux listes (même longueur (\n rajouté si caractère manquant dans le mot le plus petit))
	var l1 = []
	var l2 = []
	var taille = max(len(mot1), len(mot2))
	
	for duo in [[l1, mot1], [l2, mot2]]:
		for i in range(taille):
			if not i < len(duo[1]):
				duo[0].append("\n")
			else:
				duo[0].append(duo[1][i])
	
	var l1_comp = []	# contient des duos de caractères
	var l2_comp = []
	
	for duo in [[l1_comp, l1], [l2_comp, l2]]:
		for i in range(len(duo[1]) - 1):	# on ne prend pas le dernier caractère
			duo[0].append(duo[1][i] + duo[1][i + 1])
	
	# on compare les deux listes pour voir si elles se ressemblent
	# on suppose que les potentiels \n sont dans une seule liste (l'utilisateur ne peut pas en mettre quoi)
	var compteur = 0
	for element in l1_comp:
		if element in l2_comp:
			compteur = compteur + 1
			l2_comp.erase(element)
	
	return compteur / taille
	
func poser_question(pseudo:String, question:String):
	if is_blacklisted(pseudo):
		return 0
		
	
	return 1
