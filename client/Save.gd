extends Node

var data = {"ip":"", "port":0, "pseudo":""}
const dossier_save = "user://"
const fichier_save = "JBot_data.txt"

func sauvegarder():
	var fichier = FileAccess.open(dossier_save + fichier_save, FileAccess.WRITE)
	fichier.store_var(data)
	fichier.close()

func charger():
	var fichier = FileAccess.open(dossier_save + fichier_save, FileAccess.READ)
	data = fichier.get_var()
	fichier.close()

func set_data(nom_data:String, valeur, ignore_type=false):
	if not nom_data in data.keys():
		push_error(nom_data + " n'est pas une donnée valide")
		return 0
	
	if not typeof(valeur) == typeof(data[nom_data]) and not ignore_type:
		push_error("la valeur de " + nom_data + " n'est pas du même type que la valeur actuelle")
		return 0
	data[nom_data] = valeur
	return 1

func get_data(nom_data:String):
	if not nom_data in data.keys():
		push_error(nom_data + " non trouvé")
	return data[nom_data]

func is_save_exist():
	var dossier = DirAccess.open(dossier_save)
	return dossier.file_exists(fichier_save)
		

func reset_save():
	if is_save_exist():
		var dossier = DirAccess.open(dossier_save)
		dossier.remove(fichier_save)
		print("save supprimée")
	else:
		print("save non supprimée")

func _ready() -> void:
	# on charge les données si elles existent
	if is_save_exist():
		charger()
