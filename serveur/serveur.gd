extends Node2D

var serveur = TCPServer.new()
var server_port = 25566

func se_connecter():
	server_port = int(Save.settings["port"])
	var err = serveur.listen(server_port)
	if err != OK:
		Save.print_log("erreur lors de l'écoute : " +  error_string(err))
		return 0
	return 1
	
func _ready() -> void:
	if se_connecter():
		Save.print_log("serveur démarré sur le port " + str(serveur.get_local_port()))

func _process(_delta: float) -> void:
	while serveur.is_connection_available():
		var connection = serveur.take_connection()
		handle(connection)
		connection.disconnect_from_host()

func erreur(error:String): # fonction à appeller en cas d'erreur
	Save.print_log("erreur lors du handle : " + error)

func recv(connection:StreamPeerTCP):
	var duree_message = ""
	var requete = connection.get_data(1)
	if requete[0] != OK:
		erreur("requete 1 : " + error_string(requete[0]))
		return 0
		
	var actuel = PackedByteArray(requete[1]).get_string_from_utf8()

	var message = ""
	while not actuel == "a":
		duree_message = duree_message + actuel
		requete = connection.get_data(1)
		if requete[0] != OK:
			erreur("requete 2 : " + error_string(requete[0]))
			return 0
			
		actuel = PackedByteArray(requete[1]).get_string_from_utf8()
	
	duree_message = int(duree_message)
	var message_bytes = PackedByteArray()
	
	while len(message_bytes) < duree_message:
		requete = connection.get_data(connection.get_available_bytes())
		if requete[0] != OK:
			erreur("requete 3 : " + error_string(requete[0]))
			return 0
		message_bytes = message_bytes + PackedByteArray(requete[1])
	
	# on teste au cas où la taille du message n'est pas cohérente avec la durée
	if len(message_bytes) != duree_message:
		erreur("message_bytes pas de la même longueur que duree_message")
		return 0
		
	message = message_bytes.get_string_from_utf8()
	return str_to_list(message)

func send(connection:StreamPeerTCP, liste:Array):
	var message = list_to_str(liste)
	var message_bytes = message.to_utf8_buffer()
	var err
	
	# calcul de la longueur
	var prefixe = str(message_bytes.size()) + "a"
	message_bytes = PackedByteArray(prefixe.to_utf8_buffer()) + message_bytes
	
	err = connection.put_data(message_bytes)
	if err != OK:
		erreur("envoi données : " + error_string(err))
		return 0
	return 1

func list_to_str(liste:Array):
	# ATTENTION toutes les valeurs sont converties en str
	assert(typeof(liste) == TYPE_ARRAY, "liste n'est pas une liste")
	var texte = ""
	for index_liste in range(len(liste)):
		if index_liste == len(liste) - 1:
			texte = texte + str(liste[index_liste])
		else:
			texte = texte + str(liste[index_liste]) + "&slliste&"
	return texte

func str_to_list(texte:String):
	assert(typeof(texte) == TYPE_STRING, "texte doit être une chaine de caractères")
	var liste = texte.split("&slliste&")
	return liste

# fonctions réactions
func connexion(pseudo:String, mdp:String) -> Array:
	Save.print_log("tentative de connexion")
	if not pseudo in Save.utilisateurs.keys():
		# le compte n'existe pas
		Save.print_log("le compte n'existe pas")
		return ["creation compte"]
	
	if Save.utilisateurs[pseudo] == mdp:
		if is_admin(pseudo):
			Save.print_log("connexion admin réussie")
			return ["admin"]
		else:
			Save.print_log("connexion réussie")
			return ["oui"]
		
	Save.print_log("mauvais mot de passe")
	return ["non"]

func creer_compte(pseudo, mdp):
	Save.print_log("création de compte")
	if pseudo in Save.utilisateurs.keys():
		Save.print_log("fraude, le compte existe déjà")
		return ["fail"]
		
	Save.utilisateurs[pseudo] = mdp
	Save.print_log("compte créé")
	Save.serveur_sauvegarder()
	return ["réussi"]

func check_auth(pseudo, mdp):
	# permet de checker si la requête est légitime
	return Save.utilisateurs[pseudo] == mdp

func get_history(pseudo):
	if not pseudo in Save.history.keys():
		Save.history[pseudo] = []
		Save.serveur_sauvegarder()
		Save.print_log("première connexion")
	Save.print_log("historique récupéré")
	return Save.history[pseudo]

func clear_history(pseudo):
	Save.history[pseudo] = []
	Save.serveur_sauvegarder()
	Save.print_log("historique supprimé")
	return ["ok"]

func poser_question(pseudo, question):
	var reponse = Fonctions.poser_question(pseudo, question)
	var elements = []
	var retour = ""
	
	Save.print_log(pseudo + " a posé une question : " + question)
	Save.history[pseudo].append(question)
	
	if reponse[0] == 0:
		# pseudo banni
		Save.print_log("pseudo banni")
		elements = ["va voir sur google"]
		elements.shuffle()
		
		Save.history[pseudo].append(elements[0])
		retour = elements[0]
		
	elif reponse[0] == 1:
		Save.print_log("aucune réponse trouvée")
		elements = ["jsp", "aucune idée !"]
		elements.shuffle()
		Save.history[pseudo].append(elements[0])
		retour = elements[0]
	
	elif reponse[0] == 2:
		Save.print_log("fichier réponse requis non trouvé")
		Save.history[pseudo].append("la réponse semble être liée à un fichier, mais je ne le retrouve pas :/")
		retour = "la réponse semble être liée à un fichier, mais je ne le retrouve pas :/"
	else:
		Save.history[pseudo].append(reponse[1])
		Save.print_log("réponse : " + reponse[1])
		retour = reponse[1]
		
	Fonctions.change_stat(pseudo, "questions", 1)	# ça sauvegarde
	return retour

func proposer_reponse(pseudo, question, reponse):
	Save.print_log("proposition de réponse")
	if not Fonctions.is_blacklisted(pseudo):
		var liste = [pseudo, question, reponse]
		
		# on check si la liste n'est pas déjà dans les réponses
		var is_already_valid = false
		if question in Save.questions_reponses.keys():
			is_already_valid = reponse in Save.questions_reponses[question]
			
		if not liste in Save.demandes_reponses and not is_already_valid:
			Save.demandes_reponses.append(liste)
			Fonctions.change_stat(pseudo, "suggestions", 1, false)
			#Save.serveur_sauvegarder()	# pas besoin du sauvegarder ici (déjà dans change_stat)
		else:
			Save.print_log("ce pseudo a déjà proposé cette suggestion ou alors elle est déjà présente dans la liste des réponses")
		
	else:
		Save.print_log("pseudo banni")
		
	Save.history[pseudo].append("je propose la réponse : " + reponse)
	Save.history[pseudo].append("ta proposition a été envoyée, merci pour ta contribution !")
	Save.serveur_sauvegarder()
	return "ta proposition a été envoyée, merci pour ta contribution !"

func is_admin(pseudo):
	return pseudo in Save.admins
	
func arret_serveur():
	Save.print_log("arrêt du serveur en cours")
	serveur.stop()
	Save.print_log("serveur arrêté")
	Save.serveur_sauvegarder(true)
	get_tree().quit()

func accept(pseudo_suggestion, question, reponse):
	Save.print_log("acceptation de réponse : " + reponse)
	# on vérifie que la suggestion est toujours là (plusieurs admins en simultané)
	if not [pseudo_suggestion, question, reponse] in Save.demandes_reponses:
		Save.print_log("réponse inexistante")
		return ["non"]
		
	if not question in Save.questions_reponses.keys():
		Save.questions_reponses[question] = []
		
	Save.questions_reponses[question].append(reponse)
	Save.demandes_reponses.erase([pseudo_suggestion, question, reponse])
	Fonctions.change_stat(pseudo_suggestion, "accepts", 1)
	# pas besoin de serveur_sauvegarder (déjà dans change_stat
	return ["ok"]

func refuse(pseudo_suggestion, question, reponse, do_print_log=true):
	if do_print_log:
		Save.print_log("refus de réponse : " + reponse)
	# on vérifie que la suggestion est toujours là (plusieurs admins en simultané)
	if not [pseudo_suggestion, question, reponse] in Save.demandes_reponses:
		Save.print_log("réponse inexistante")
		return ["non"]
	
	Save.demandes_reponses.erase([pseudo_suggestion, question, reponse])
	Fonctions.change_stat(pseudo_suggestion, "refus", 1)
	# pas besoin de serveur_sauvegarder (déjà dans change_stat)
	return ["ok"]
	
func refuse_ban(pseudo_suggestion, question, reponse):
	Save.print_log("refus de réponse : " + reponse + " + ban de " + pseudo_suggestion)
	if refuse(pseudo_suggestion, question, reponse, false)[0] == "ok":
		if bannir(pseudo_suggestion, false)[0] == "ok":
			return ["ok"]
	return ["non"]
		
func deban(pseudo_deban):
	Save.print_log("deban de " + pseudo_deban)
	# on check si me pseudo est banni
	if not pseudo_deban in Save.blacklist:
		Save.print_log("pseudo déjà débanni")
		return ["non"]
	Save.blacklist.erase(pseudo_deban)
	Save.serveur_sauvegarder()
	return ["ok"]

func get_bannis(recherche):
	var new_liste = []
	for pseudo in Save.blacklist:
		if recherche in pseudo or recherche == "":
			new_liste.append(pseudo)
	Save.print_log("bannis récupérés")
	return new_liste
	
func get_suggestions(recherche):
	var liste_finale = []
	for element in Save.demandes_reponses:
		if recherche in element[0] or recherche in element[1] or recherche in element[2] or recherche == "":
			liste_finale = liste_finale + element
	Save.print_log("suggestions récupérées")
	return liste_finale	# ça renvoie une liste de base avec les éléments les uns à la suite des autres

func bannir(pseudo_ban, do_print_log=true):
	if do_print_log:
		Save.print_log("ban de " + pseudo_ban)
		
	# on check si le pseudo est déjà banni
	if pseudo_ban in Save.blacklist:
		Save.print_log("pseudo déjà banni")
		return ["non"]
	Save.blacklist.append(pseudo_ban)
	Save.serveur_sauvegarder()
	return ["ok"]

func get_questions_reponses(recherche):
	var liste_questions_reponses = []
	for question in Save.questions_reponses.keys():
		for reponse in Save.questions_reponses[question]:
			if recherche in question or recherche in reponse or recherche == "":
				liste_questions_reponses = liste_questions_reponses + [question, reponse]
	
	Save.print_log("liste questions réponses récupérée")
	return liste_questions_reponses

func supprimer_question_reponse(question, reponse):
	Save.print_log("suppression de réponse : " + reponse)
	# on vérifie que la question et la réponse existent
	if not question in Save.questions_reponses.keys():
		Save.print_log("la question n'existe pas")
		return ["non"]
	elif not reponse in Save.questions_reponses[question]:
		Save.print_log("la réponse n'existe pas")
		return ["non"]
	
	Save.questions_reponses[question].erase(reponse)
	if len(Save.questions_reponses[question]) == 0:
		# on supprime la clé de la question
		Save.questions_reponses.erase(question)
	
	Save.serveur_sauvegarder()
	return ["ok"]

func ajouter_reponse(question, reponse):
	Save.print_log("ajout de réponse : " + reponse)
	
	# on check si la réponse n'est pas déjà présent
	for element in Save.demandes_reponses:
		if element[1] == question and element[2] == reponse:
			Save.print_log("déjà présente dans les demandes")
			return ["demande"]
		
	if question in Save.questions_reponses.keys():
		if reponse in Save.questions_reponses[question]:
			Save.print_log("déjà présente dans les réponses valides")
			return ["valide"]
	
	# on ajoute la réponse
	if not question in Save.questions_reponses.keys():
		Save.questions_reponses[question] = []
		
	Save.questions_reponses[question].append(reponse)
	Save.serveur_sauvegarder()
	return ["ok"]
	
func handle(connection:StreamPeerTCP):
	var resultat
	# on récupère les infos
	var data = recv(connection)
	if not data:	# au cas où ça a crash
		return 0
		
	Save.print_log("nouvelle requête par " + data[1] + " (" + str(connection.get_connected_host()) + ")", true)
	if data[0] == "connexion":
		resultat = connexion(data[1], data[2])	# retourne une liste
	
	elif data[0] == "creer compte":
		resultat = creer_compte(data[1], data[2])	# retourne une liste
	
	else:
		# requêtes qui nécessitent que le compte soit connecté (donc le 2e et 3e élément de la liste sont le pseudo et le mot de passe)
		if not check_auth(data[1], data[2]):
			Save.print_log("fraude : le mot de passe fourni ne correspond pas")
			return
		
		if data[0] == "get history":
			resultat = get_history(data[1])	# renvoie une liste
		
		elif data[0] == "clear history":
			resultat = clear_history(data[1])	# renvoie une liste
		
		elif data[0] == "poser question":
			resultat = [poser_question(data[1], data[3])]
		
		elif data[0] == "proposer reponse":
			resultat = [proposer_reponse(data[1], data[3], data[4])]
			
		else:
			# requêtes qui nécessitent les droits admins
			if not is_admin(data[1]):
				Save.print_log("requête invalide")
				return 0
			
			if data[0] == "arret serveur":
				send(connection, ["ok"])
				arret_serveur()
				return
			
			elif data[0] == "accept":
				resultat = accept(data[3], data[4], data[5])
			
			elif data[0] == "refuse":
				resultat = refuse(data[3], data[4], data[5])
			
			elif data[0] == "refuse ban":
				resultat = refuse_ban(data[3], data[4], data[5])
			
			elif data[0] == "get suggestions":
				resultat = get_suggestions(data[3])
			
			elif data[0] == "deban":
				resultat = deban(data[3])
			
			elif data[0] == "get bannis":
				resultat = get_bannis(data[3])
			
			elif data[0] == "bannir":
				resultat = bannir(data[3])
			
			elif data[0] == "get questions reponses":
				resultat = get_questions_reponses(data[3])
			
			elif data[0] == "supprimer question reponse":
				resultat = supprimer_question_reponse(data[3], data[4])
			
			elif data[0] == "ajouter reponse":
				resultat = ajouter_reponse(data[3], data[4])
				
			else:
				Save.print_log("requête invalide")
				return 0
		
	if not send(connection, resultat):
		return 0
