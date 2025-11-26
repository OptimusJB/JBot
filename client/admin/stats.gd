extends Control
signal ajouter_popup

func _on_rechercher_joueur_bouton_pressed() -> void:
	var recherche = $"rechercher_joueur_texte".text
	var resultat = Client.envoyer_data(["get stats", Save.get_data("pseudo"), Global.temp_mdp, recherche])
	if not resultat:
		Client.back_to_lobby("oui")
		return
		
	# on enlève les potentiels éléments déjà présents
	for element in $scrolling/stats.get_children():
		element.queue_free()
	
	ajouter_popup.emit("stats récupérées")
	if resultat[0] == "":
		# pas de résultat
		return
	
	# on ajoute les éléments
	var new_stats
	var i = 0
	while i < len(resultat):
		new_stats = $joueur.duplicate()
		new_stats.get_node("pseudo").text = resultat[i]
		new_stats.get_node("questions").text = resultat[i + 1]
		new_stats.get_node("suggestions").text = resultat[i + 2]
		new_stats.get_node("validées").text = resultat[i + 3]
		new_stats.get_node("refusées").text = resultat[i + 4]
		$scrolling/stats.add_child(new_stats)
		i = i + 5
