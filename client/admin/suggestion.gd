extends HBoxContainer
signal ajouter_popup

func _on_oui_pressed() -> void:
	var resultat = Client.envoyer_data(["accept", Save.get_data("pseudo"), Global.temp_mdp, $"stockage pseudo".text, $"panel question/MarginContainer/question".text, $"panel reponse/MarginContainer/reponse".text])
	if not resultat:
		Client.back_to_lobby("oui")
		return
	
	queue_free()
	ajouter_popup.emit("suggestion acceptée")
	
func _on_non_pressed() -> void:
	var resultat = Client.envoyer_data(["refuse", Save.get_data("pseudo"), Global.temp_mdp, $"stockage pseudo".text, $"panel question/MarginContainer/question".text, $"panel reponse/MarginContainer/reponse".text])
	if not resultat:
		Client.back_to_lobby("oui")
		return
	
	queue_free()
	ajouter_popup.emit("suggestion refusée")
	
func _on_non__ban_pressed() -> void:
	var resultat = Client.envoyer_data(["refuse ban", Save.get_data("pseudo"), Global.temp_mdp, $"stockage pseudo".text, $"panel question/MarginContainer/question".text, $"panel reponse/MarginContainer/reponse".text])
	if not resultat:
		Client.back_to_lobby("oui")
		return
	
	queue_free()
	ajouter_popup.emit("suggestion refusée et " + $"stockage pseudo".text + " banni")
