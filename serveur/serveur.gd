extends Node2D

var serveur = TCPServer.new()
var server_port = 25566

func se_connecter():
	var err = serveur.listen(server_port)
	if err != OK:
		print("erreur lors de l'écoute : ", error_string(err))
		return 0
	return 1
	
func _ready() -> void:
	if se_connecter():
		print("serveur démarré sur le port " + str(serveur.get_local_port()))

func _process(_delta: float) -> void:
	while serveur.is_connection_available():
		var connection = serveur.take_connection()
		handle(connection)
		connection.disconnect_from_host()

func erreur(error:String): # fonction à appeller en cas d'erreur
	print("erreur lors du handle : ", error)

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
	print("tentative de connexion :")
	if not pseudo in Save.utilisateurs.keys():
		# le compte n'existe pas
		print("le compte n'existe pas")
		return ["creation compte"]
	
	if Save.utilisateurs[pseudo] == mdp:
		print("connexion réussie")
		return ["oui"]
		
	print("mauvais mot de passe")
	return ["non"]

func creer_compte(pseudo, mdp):
	print("création de compte")
	if pseudo in Save.utilisateurs.keys():
		print("fraude, le compte existe déjà")
		return ["fail"]
		
	Save.utilisateurs[pseudo] = mdp
	Save.serveur_sauvegarder()
	print("compte créé")
	return ["réussi"]

func check_auth(pseudo, mdp):
	# permet de checker si la requête est légitime
	return Save.utilisateurs[pseudo] == mdp
	
func handle(connection:StreamPeerTCP):
	var resultat
	# on récupère les infos
	var data = recv(connection)
	if not data:	# au cas où ça a crash
		return 0
		
	print("\nnouvelle requête par " + data[1] + " (" + str(connection.get_connected_host()) + ")")
	if data[0] == "connexion":
		resultat = connexion(data[1], data[2])	# retourne une liste
	
	elif data[0] == "creer compte":
		resultat = creer_compte(data[1], data[2])	# retourne une liste
	
	else:
		# requêtes qui nécessitent que le compte soit connecté (donc le 2e et 3e élément de la liste sont le pseudo et le mot de passe)
		if not check_auth(data[1], data[2]):
			print("fraude : le mot de passe fourni ne correspond pas")
			return
			
		print("requête invalide")
		return 0
		
	if not send(connection, resultat):
		return 0
