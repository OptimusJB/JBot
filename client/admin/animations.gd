extends AnimationPlayer
var type_disparition = "app"	# app ou connexion

func _ready() -> void:
	play("apparition")

func _on_retour_pressed() -> void:
	type_disparition = "app"
	play("disparition")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "disparition":
		if type_disparition == "app":
			get_tree().change_scene_to_file("res://client/App/App.tscn")
		elif type_disparition == "connexion":
			get_tree().change_scene_to_file("res://client/connexion/connexion.tscn")

func change_page(numero_page:int):
	var pages = $"../pages".get_children()
	for index_page in range(len(pages)):
		$"../pages".get_child(index_page).visible = false
	$"../pages".get_child(numero_page).visible = true

func _on_reponses_pressed() -> void:
	change_page(0)

func _on_suggestions_pressed() -> void:
	change_page(1)
	
func _on_blacklist_pressed() -> void:
	change_page(2)

func _on_stats_pressed() -> void:
	change_page(3)

func _on_arrêt_serveur_pressed() -> void:
	change_page(4)

func arrêt_serveur() -> void:
	var resultat = Client.envoyer_data(["arret serveur", Save.get_data("pseudo"), Global.temp_mdp])
	if not resultat:
		Client.back_to_lobby("oui")
		return
	Global.popup_switch.append("serveur éteint")
	type_disparition = "connexion"
	play("disparition")
	return
