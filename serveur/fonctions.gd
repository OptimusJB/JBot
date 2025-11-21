extends Node

# version GDscript de fonctions.py de ChatJBT
# ne pas utiliser avec le client (le ready ne se fait pas)
var algos_pourcentage = []
var algo_used = 0	# 0 ou 1, c'est l'index de algos_pourcentage
var stopwords = []

func _ready() -> void:
	if not OS.has_feature("dedicated_server"):
		return
		
	# ATTENTION note importante : stopwords-fr.txt doit être mis comme un fichier non ressource pendant l'export
	algos_pourcentage = [get_ressemblance_pourcentage_single, get_ressemblance_pourcentage_double]
	
	# on met le bon algo par rapport aux settings
	algo_used = {"simple":0, "double":1}[Save.settings["algo ressemblance mot (simple/double)"]]
	print("algo utilisé : ", algos_pourcentage[algo_used])
	# on load les stopwords dans la variable
	var fichier_read = FileAccess.get_file_as_string("res://serveur/stopwords-fr.txt")
	if fichier_read == "":
		push_error("problème lors de la lecture du fichier stopwords")
	for element in fichier_read.split("\n"):
		stopwords.append(element)
	
	Save.serveur_charger()
	#print("résultat : ", get_phrase_ressemblance_pourcentage("", ""))

func remove_stopwords(chaine:String) -> String:
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
		if not index_element == len(liste_chaine) - 1:
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

func get_ressemblance_pourcentage_double(mot1:String, mot2:String):
	# cas où mot1 et mot2 ont tous les deux une seule lettre
	if len(mot1) <= 1 and len(mot2) <= 1:
		return float(mot1 == mot2)
		
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
			
	return float(compteur) / float(len(l1_comp))

func get_ressemblance_pourcentage_single(mot1:String, mot2:String):
	# cas où les deux chaines sont vides
	if mot1 == "" and mot2 == "":
		return 1.0
		
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
	
	var compteur = 0
	for element in l1:
		if element in l2:
			compteur = compteur + 1
			l2.erase(element)
	
	return float(compteur) / float(len(l1))

func get_phrase_ressemblance_pourcentage(chaine1:String, chaine2:String):
	chaine1 = chaine1.to_lower()
	chaine2 = chaine2.to_lower()
	chaine1 = remove_stopwords(chaine1)
	chaine2 = remove_stopwords(chaine2)
	var l1 = chaine1.split(" ")
	var l2 = chaine2.split(" ")
	var temoin = l1
	var autre = l2
	if len(l2) > len(l1):
		temoin = l2	# le témoin doit être la liste la plus grande
		autre = l1
		
	var found = ""
	var compteur = 0
	var mot_found = ""
	#print(temoin, autre)
	for mot1 in temoin:
		found = false
		for mot2 in autre:
			if algos_pourcentage[algo_used].call(mot1, mot2) >= float(Save.settings["pourcentage ressemblance mot pendant analyse des deux phrases"]):
				found = true
				mot_found = mot2
				break
		if found:
				compteur = compteur + 1
				autre.erase(mot_found)
	return float(compteur) / float(len(temoin))
	
func poser_question(pseudo:String, question:String):
	if is_blacklisted(pseudo):
		return 0
		
	
	return 1
