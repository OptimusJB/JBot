extends Node2D

var connection = StreamPeerTCP.new()	# ATTENTION doit être en dehors d'une fonction sinon ça coupe la connexion
var serveur = load("res://serveur/serveur.gd").new()	# pour récupérer les fonctions d'envoi

func erreur(error:String):
	print("erreur client : " + error)
	
func envoyer_data(liste:Array):
	var err = null
	
	err = connection.connect_to_host(Save.get_data("ip"), Save.get_data("port"))
	if err != OK:
		erreur("connexion au serveur : " + error_string(err))
		return 0
	connection.poll()
	
	# on attend que la connexion soit établie (car connect_to_host n'est pas bloquante
	while not connection.get_status() == 2:
		connection.poll()
		if connection.get_status() in [0, 3]:
			erreur("pas réussi à se connecter")
			connection.disconnect_from_host()
			return 0
	
	# on envoie les infos
	if not serveur.send(connection, liste):
		connection.disconnect_from_host()
		return 0
	
	# on récupère les infos
	var data = serveur.recv(connection)
	if not data:
		connection.disconnect_from_host()
		return 0
	
	connection.disconnect_from_host()
	return data

func back_to_lobby(type_back:String):
	# fonction qui permet de retourner à l'écran de connexion lorsqu'il y a une perte de connexion
	assert(type_back == "oui" or type_back == "non", "type_back invalide")
	Global.retour_lobby_anim = type_back
	get_tree().change_scene_to_file("res://client/connexion/connexion.tscn")
	
func _ready() -> void:
	# zone de tests
	pass
