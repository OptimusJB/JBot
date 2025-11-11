extends Node

# partie client
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

# partie serveur
var utilisateurs = {}	# pseudo:mdp
var stats_utilisateurs = {}	# pseudo:[trucs]
var questions_reponses = {} # question:reponse
var admins = []	# non inclus dans data pour que ce soi simple de changer

const serveur_dossier_save = "user://"	# si on ajoute un dossier, penser à le générer automatiquement
const serveur_fichier_save = "JBot_server_data.txt"
const serveur_fichier_admins = "JBot_server_admins.txt"

func serveur_sauvegarder():
	var fichier = FileAccess.open(serveur_dossier_save + serveur_fichier_save, FileAccess.WRITE)
	fichier.store_var(utilisateurs)
	fichier.store_var(stats_utilisateurs)
	fichier.store_var(questions_reponses)
	fichier.close()
	
func serveur_charger():
	var fichier = FileAccess.open(serveur_dossier_save + serveur_fichier_save, FileAccess.READ)
	utilisateurs = fichier.get_var()
	stats_utilisateurs = fichier.get_var()
	questions_reponses = fichier.get_var()
	fichier.close()
	
	# on récupère les admins
	admins = []
	fichier = FileAccess.open(serveur_dossier_save + serveur_fichier_admins, FileAccess.READ)
	var contenu_fichier = fichier.get_as_text()
	for index_element in range(len(contenu_fichier) - 1):	# le séparateur est \n
		admins.append(contenu_fichier[index_element + 1])	# +1 pour éviter de récupérer les instructions du début du fichier
	fichier.close()

func serveur_is_save_exist():
	var dossier = DirAccess.open(serveur_dossier_save)	# on regarde qu'un seul fichier
	return dossier.file_exists(fichier_save)

func serveur_auto_repare():
	# cette fonction permet de check les éléments absents de la save et des les remettres
	var dossier = DirAccess.open(serveur_dossier_save)	# on regarde qu'un seul fichier
	if not dossier.file_exists(serveur_fichier_save):
		serveur_sauvegarder()
		print("fichier sauvegarde principal créé car absent")
	if not dossier.file_exists(serveur_fichier_admins):
		var fichier = FileAccess.open(serveur_dossier_save + serveur_fichier_admins, FileAccess.WRITE)
		fichier.store_string("mettre ici les pseudos des admins de ce serveur (bouton admin dans JBot). 1 ligne = 1 pseudo")
		fichier.close()
		print("fichier admins créé car absent")

func serveur_reset_save():
	var dossier = DirAccess.open(serveur_dossier_save)
	if dossier.file_exists(serveur_fichier_save):
		dossier.remove(serveur_fichier_save)
	if dossier.file_exists(serveur_fichier_admins):
		dossier.remove(serveur_fichier_admins)
		
# partie commune au deux
func _ready() -> void:
	# on charge les données si elles existent
	if not OS.has_feature("dedicated_server"):
		if is_save_exist():
			charger()
	else:
		if serveur_is_save_exist():
			serveur_auto_repare()	# au cas où il y a des fichiers paumés
			serveur_charger()
