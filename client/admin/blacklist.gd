extends Control
signal ajouter_popup

func _on_rechercher_banni_bouton_pressed() -> void:
	var recherche = $"éléments texte/rechercher_banni_texte".text
	var resultat = Client.envoyer_data(["get bannis", Save.get_data("pseudo"), Global.temp_mdp, recherche])
	if not resultat:
		Client.back_to_lobby("oui")
		return
	# on enlève les potentiels éléments déjà présents
	for element in $scrolling/bannis.get_children():
		element.queue_free()
	
	ajouter_popup.emit("bannis récupérés")
	if resultat[0] == "":
		# pas de résultat
		return
	
	# on ajoute les éléments
	var new_banni
	for element in resultat:
		new_banni = $banni.duplicate()
		new_banni.get_node("pseudo").text = element
		$scrolling/bannis.add_child(new_banni)
		
func _on_ajouter_banni_bouton_pressed() -> void:
	var pseudo_ban = $"éléments texte/ajouter_banni_texte".text
	
	# on check si le pseudo est vide
	if pseudo_ban == "":
		ajouter_popup.emit("le pseudo ne doit pas être vide")
		return
		
	var resultat = Client.envoyer_data(["bannir", Save.get_data("pseudo"), Global.temp_mdp, pseudo_ban])
	if not resultat:
		Client.back_to_lobby("oui")
		return
	
	if resultat[0] == "non":
		ajouter_popup.emit("pseudo déjà banni")
		return
	
	# on ajoute l'élément en local
	var new_banni = $banni.duplicate()
	new_banni.get_node("pseudo").text = pseudo_ban
	$scrolling/bannis.add_child(new_banni)
	
	ajouter_popup.emit(pseudo_ban + " banni")
	$"éléments texte/ajouter_banni_texte".text = ""
