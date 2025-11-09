extends Node2D

var server_ip = "192.168.1.20"
var server_port = 25566
var connection = StreamPeerTCP.new()	# ATTENTION doit être en dehors d'une fonction sinon ça coupe la connexion

func erreur(error:String):
	print("erreur client : " + error)
	
func envoyer_data(data:PackedByteArray):
	var err = null
	
	# calcul de la longueur
	var prefixe = str(data.size()) + "a"
	data = PackedByteArray(prefixe.to_utf8_buffer()) + data
	
	err = connection.connect_to_host(server_ip, server_port)
	if err != OK:
		erreur("connexion au serveur : " + error_string(err))
		return 0
	connection.poll()
	
	# on attend que la connexion soit établie (car connect_to_host n'est pas bloquante
	while not connection.get_status() == 2:
		connection.poll()
		if connection.get_status() in [0, 3]:
			erreur("pas réussi à se connecter")
			return 0
		
	err = connection.put_data(data)
	if err != OK:
		erreur("envoi données : " + error_string(err))
		
	connection.disconnect_from_host()

func _ready() -> void:
	# zone de tests
	envoyer_data("test".to_utf8_buffer())
