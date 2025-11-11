extends Node

# le fichier sert à lancer le serveur ou le client selon le tag
func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		# lancement du serveur
		get_tree().change_scene_to_file.call_deferred("res://serveur/serveur.tscn")	# call_deferred sinon erreur (l'erreur semble apparaitre seulement sur le premier _ready du jeu)
	else:
		get_tree().change_scene_to_file.call_deferred("res://client/intro/intro.tscn")
