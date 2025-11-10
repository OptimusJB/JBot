extends Node

var data = {}

func sauvegarder():
	var fichier = FileAccess.open("data.txt", FileAccess.WRITE)
	fichier.store_var(data)
	fichier.close()

func charger():
	var fichier = FileAccess.open("data.txt", FileAccess.READ)
	data = fichier.get_var()
	fichier.close()

func set_data(nom_data:String, valeur):
	data[nom_data] = valeur

func get_data(nom_data:String):
	if not data.find_key(nom_data):
		push_error(nom_data + " non trouvé")
	return data[nom_data]
