extends Node2D

var connection = StreamPeerTCP.new()	# ATTENTION doit être en dehors d'une fonction sinon ça coupe la connexion
var serveur = load("res://serveur/serveur.gd").new()	# pour récupérer les fonctions d'envoi

func erreur(error:String):
	print("erreur client : " + error)
	
func envoyer_data(liste:Array):
	var err = null
	
	print("avant connect")
	err = connection.connect_to_host(Save.get_data("ip"), Save.get_data("port"))
	print("après connect")
	if err != OK:
		erreur("connexion au serveur : " + error_string(err))
		return 0
	connection.poll()
	
	# on attend que la connexion soit établie (car connect_to_host n'est pas bloquante
	print("avant status")
	while not connection.get_status() == 2:
		connection.poll()
		if connection.get_status() in [0, 3]:
			erreur("pas réussi à se connecter")
			connection.disconnect_from_host()
			return 0
	
	# on envoie les infos
	print("avant send")
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

func _ready() -> void:
	# zone de tests
	pass
