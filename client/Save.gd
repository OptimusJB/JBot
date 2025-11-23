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
	sauvegarder()
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
var stats_utilisateurs = {}	# pseudo:[questions, suggestions, accepts, refus]
var questions_reponses = {} # question:[reponse1, reponse2...]
var demandes_reponses = []	# listes dans liste : [pseudo, question, reponse]
var history = {}	# pseudo:[question, reponse, question, reponse]
var admins = []	# non inclus dans data pour que ce soi simple de changer
var blacklist = []	# non inclus dans data non plus
var settings = {}	# setting:valeur

var settings_base = """
port=25566
algo ressemblance mot (simple/double)=simple
pourcentage ressemblance mot pendant analyse des deux phrases=0.7
pourcentage pour réponse appropriée=0.65
différence pourcentage admis pour aléatoire=0.05
sauvegarde automatique=1
"""

const serveur_dossier_save = "user://JBot_server/"	# si on ajoute un dossier, penser à le générer automatiquement
const serveur_fichier_save = "data.txt"
const serveur_fichier_admins = "admins.txt"
const serveur_fichier_settings = "settings.txt"
const serveur_fichier_blacklist = "blacklist.txt"
#const mots_interdits = ["\n"]

func serveur_sauvegarder(manual=false):
	if manual or int(Save.settings["sauvegarde automatique"]):
		var fichier = FileAccess.open(serveur_dossier_save + serveur_fichier_save, FileAccess.WRITE)
		fichier.store_var(utilisateurs)
		fichier.store_var(stats_utilisateurs)
		fichier.store_var(questions_reponses)
		fichier.store_var(history)
		fichier.store_var(blacklist)
		fichier.store_var(demandes_reponses)
		fichier.close()
		print_log("serveur sauvegardé")
		
func serveur_charger():
	var fichier = FileAccess.open(serveur_dossier_save + serveur_fichier_save, FileAccess.READ)
	var contenu_fichier
	utilisateurs = fichier.get_var()
	stats_utilisateurs = fichier.get_var()
	questions_reponses = fichier.get_var()
	history = fichier.get_var()
	blacklist = fichier.get_var()
	demandes_reponses = fichier.get_var()
	fichier.close()
	
	# on récupère les admins
	admins = []
	fichier = FileAccess.open(serveur_dossier_save + serveur_fichier_admins, FileAccess.READ)
	contenu_fichier = fichier.get_as_text().split("\n")
	for index_element in range(len(contenu_fichier) - 1):	# le séparateur est \n
		admins.append(contenu_fichier[index_element + 1])	# +1 pour éviter de récupérer les instructions du début du fichier
	fichier.close()
	
	# on récupère les settings
	settings = {}
	var elements
	fichier = FileAccess.open(serveur_dossier_save + serveur_fichier_settings, FileAccess.READ)
	contenu_fichier = fichier.get_as_text().split("\n")
	for index_element in range(len(contenu_fichier)):	# le séparateur est \n
		if not contenu_fichier[index_element] == "":
			elements = contenu_fichier[index_element].split("=")
			settings[elements[0]] = elements[1]
	fichier.close()
	
func serveur_is_save_exist():
	var dossier = DirAccess.open(serveur_dossier_save)	# on regarde qu'un seul fichier
	return dossier.file_exists(fichier_save)

func serveur_auto_repare():
	# cette fonction permet de check les éléments absents de la save et des les remettres

	# on check d'abord si les dossiers racines sont présents
	if not DirAccess.dir_exists_absolute("user://JBot_server/"):
		DirAccess.make_dir_absolute("user://JBot_server/")
		print("dossier JBot_server créé")
	if not DirAccess.dir_exists_absolute("user://JBot_server/logs"):
		DirAccess.make_dir_absolute("user://JBot_server/logs")
		print("dossier logs créé")
	
	
	var dossier = DirAccess.open(serveur_dossier_save)	# on regarde qu'un seul fichier
	var fichier
	if not dossier.file_exists(serveur_fichier_save):
		serveur_sauvegarder(true)
		print("fichier sauvegarde principal créé car absent")
		
	if not dossier.file_exists(serveur_fichier_admins):
		fichier = FileAccess.open(serveur_dossier_save + serveur_fichier_admins, FileAccess.WRITE)
		fichier.store_string("mettre ici les pseudos des admins de ce serveur (bouton admin dans JBot). 1 ligne = 1 pseudo")
		fichier.close()
		print("fichier admins créé car absent")
	
	if not dossier.file_exists(serveur_fichier_settings):
		fichier = FileAccess.open(serveur_dossier_save + serveur_fichier_settings, FileAccess.WRITE)
		fichier.store_string(settings_base)
		fichier.close()
		print("fichier settings créé car absent")

func serveur_reset_save():
	DirAccess.remove_absolute(serveur_dossier_save)

func zfill(texte:String, taille:int) -> String:
	var texte_final = ""
	var nombre_0 = taille - len(texte)
	if nombre_0 < 0:
		return texte
	for i in range(nombre_0):
		texte_final = texte_final + "0"
	return texte_final + texte
	
func print_log(texte:String, passer_une_ligne=false):
	var temps = Time.get_datetime_dict_from_system()
	var temps_affichage = "[" + zfill(str(temps.hour), 2) + ":" + zfill(str(temps.minute), 2) + ":" + zfill(str(temps.second), 2) + "]"
	var texte_final = temps_affichage + " : " + texte
	var fichier
	
	if passer_une_ligne:
		texte_final = "\n" + texte_final
	
	# on enregistre le texte dans le fichier log
	var nom_fichier = zfill(str(temps.day), 2) + "-" + zfill(str(temps.month), 2) + "-" + str(temps.year) + ".txt"
	if not FileAccess.file_exists(serveur_dossier_save + "logs/" + nom_fichier):
		fichier = FileAccess.open(serveur_dossier_save + "logs/" + nom_fichier, FileAccess.WRITE)
	else:
		fichier = FileAccess.open(serveur_dossier_save + "logs/" + nom_fichier, FileAccess.READ_WRITE)
	fichier.seek_end()
	fichier.store_string(texte_final + "\n")
	fichier.close()
	
	# on affiche le message dans la console
	print(texte_final)
	
# partie commune au deux
func _ready() -> void:
	# on charge les données si elles existent
	if not OS.has_feature("dedicated_server"):
		if is_save_exist():
			charger()
	else:
		serveur_auto_repare()	# au cas où il y a des fichiers paumés
		serveur_charger()
