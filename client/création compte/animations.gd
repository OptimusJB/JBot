extends AnimationPlayer

func _ready() -> void:
	play("apparition")

func _on_retour_pressed() -> void:
	play("disparition")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "disparition":
		get_tree().change_scene_to_file("res://client/connexion/connexion.tscn")


func _on_valider_pressed() -> void:
	# on envoie les infos au serveur
	var resultat = Client.envoyer_data(["creer compte", Save.get_data("pseudo"), Global.temp_mdp])
	if not resultat or resultat[0] != "réussi":
		Client.back_to_lobby("non")
		return
	
	# création de compte réussie
	Global.popup_switch.append("le compte a été créé")
	play("disparition")
	
