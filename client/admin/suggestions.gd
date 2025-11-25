extends Control
signal ajouter_popup

func _on_rechercher_bouton_pressed() -> void:
	var recherche = $rechercher_texte.text
	var resultat = Client.envoyer_data(["get suggestions", Save.get_data("pseudo"), Global.temp_mdp, recherche])
	if not resultat:
		Client.back_to_lobby("oui")
		return
	
	# on enlève les potentiels éléments déjà présents
	for element in $scrolling/questions_reponses.get_children():
		element.queue_free()
	
	ajouter_popup.emit("suggestions récupérées")
	
	if len(resultat) == 1:
		# pas de résultat
		return
		
	# ATTENTION resultat est de la forme [pseudo, question, reponse, pseudo, question, reponse...]
	var new_suggestion
	var i = 0
	while i < len(resultat):
		new_suggestion = $suggestion.duplicate()
		new_suggestion.get_node("VBoxContainer/pseudo").text = "par " + resultat[i]
		new_suggestion.get_node("stockage pseudo").text = resultat[i]
		new_suggestion.get_node("panel question/MarginContainer/question").text = resultat[i + 1]
		new_suggestion.get_node("panel reponse/MarginContainer/reponse").text = resultat[i + 2]
		$scrolling/questions_reponses.add_child(new_suggestion)
		i = i + 3
