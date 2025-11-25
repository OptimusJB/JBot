extends HBoxContainer
signal ajouter_popup

func _on_supprimer_pressed() -> void:
	var question = $"panel question/MarginContainer/question".text
	var reponse = $"panel reponse/MarginContainer/reponse".text
	var resultat = Client.envoyer_data(["supprimer question reponse", Save.get_data("pseudo"), Global.temp_mdp, question, reponse])
	
	if not resultat:
		Client.back_to_lobby("oui")
		return
	
	ajouter_popup.emit("réponse supprimée")
	# on supprime l'élément
	queue_free()
