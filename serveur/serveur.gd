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
	se_connecter()
	print("serveur démarré sur le port " + str(serveur.get_local_port()))

func _process(delta: float) -> void:
	#print(serveur.is_connection_available())
	if serveur.is_connection_available():
		handle(serveur.take_connection())

func erreur(error:String): # fonction à appeller en cas d'erreur
	print("erreur lors du handle : ", error)

func handle(connection:StreamPeerTCP):
		
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
		
	message = message_bytes.get_string_from_utf8()
	
	connection.disconnect_from_host()
	print(message)
