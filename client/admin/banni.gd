extends HBoxContainer
signal ajouter_popup

func _on_deban_pressed() -> void:
	var resultat = Client.envoyer_data(["deban", Save.get_data("pseudo"), Global.temp_mdp, $pseudo.text])
	if not resultat:
		Client.back_to_lobby("oui")
		return
	queue_free()
	ajouter_popup.emit($pseudo.text + " débanni")
