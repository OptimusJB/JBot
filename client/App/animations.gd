extends AnimationPlayer
var popup = load("res://client/popup/popup.tscn")

func _ready() -> void:
	var nouveau_popup
	# on check les potentiels popup à mettre
	if len(Global.popup_switch) > 0:
		for element in Global.popup_switch:
			nouveau_popup = popup.instantiate()
			nouveau_popup.get_node("popup/marges/texte").text = element
			$"../centre/popup".add_child(nouveau_popup)
		Global.popup_switch = []

	# on récupère les potentiels messages déjà envoyés
	var resultat = Client.envoyer_data(["get history", Save.get_data("pseudo"), Global.temp_mdp])
	if not resultat:
		Client.back_to_lobby("oui")
		return
		
	# historique de la forme [question, reponse, question, reponse...]
	var new_question
	var new_reponse
	for index in range(len(resultat) - 1):
		if index%2 == 0:
			# c'est une question
			new_question = $"../types messages/question".duplicate()
			new_question.get_node("fond/marges/texte").text = resultat[index]
			$"../éléments ui/messages".add_child(new_question)
		else:
			# c'est une réponse
			new_reponse = $"../types messages/reponse".duplicate()
			new_reponse.get_node("fond/marges/texte").text = resultat[index]
			$"../éléments ui/messages".add_child(new_reponse)
	
	# apparition des éléments
	play("apparition")

func _on_se_déconnecter_pressed() -> void:
	play("disparition")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "disparition":
		get_tree().change_scene_to_file("res://client/connexion/connexion.tscn")


func _on_supprimer_historique_pressed() -> void:
	var resultat = Client.envoyer_data(["clear history", Save.get_data("pseudo"), Global.temp_mdp])
	if not resultat:
		Client.back_to_lobby("oui")
		return
	
	# on vide l'historique
	for element in $"../éléments ui/ScrollContainer/messages".get_children():
		element.queue_free()
	
	# on affiche le popup
	var new_popup = popup.instantiate()
	new_popup.get_node("popup/marges/texte").text = "historique supprimé"
	$"../centre/popup".add_child(new_popup)
