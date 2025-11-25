extends Control
signal ajouter_popup

func _on_rechercher_duo_bouton_pressed() -> void:
	var recherche = $"éléments texte/rechercher_duo_texte".text
	var resultat = Client.envoyer_data(["get questions reponses", Save.get_data("pseudo"), Global.temp_mdp, recherche])
	if not resultat:
		Client.back_to_lobby("oui")
		return
	
	# on supprime les potentiels éléments déjà présents
	for element in $"scrolling/liste questions_reponses".get_children():
		element.queue_free()
	
	ajouter_popup.emit("réponses récupérés")
	
	if resultat[0] == "":
		# pas de questions réponses
		return
		
	var i = 0
	var noeud_question_reponse = $question_reponse
	var new_noeud
	while i < len(resultat):
		new_noeud = noeud_question_reponse.duplicate()
		new_noeud.get_node("panel question/MarginContainer/question").text = resultat[i]
		new_noeud.get_node("panel reponse/MarginContainer/reponse").text = resultat[i + 1]
		$"scrolling/liste questions_reponses".add_child(new_noeud)
		i = i + 2
	
func _on_ajouter_duo_bouton_pressed() -> void:
	var question = $"éléments texte/ajouter_question_texte".text
	var reponse = $"éléments texte/ajouter_reponse_texte".text
	var is_file = $"éléments texte/is_file_bouton".button_pressed
	
	# on check si la question et la réponse ne sont pas vides
	if question == "" or reponse == "":
		ajouter_popup.emit("la question et la réponse ne doivent pas être vide")
		return
		
	if is_file:
		reponse = "&path&" + reponse
	
	var resultat = Client.envoyer_data(["ajouter reponse", Save.get_data("pseudo"), Global.temp_mdp, question, reponse])
	if not resultat:
		Client.back_to_lobby("oui")
		return
	
	if resultat[0] == "demande":
		ajouter_popup.emit("cette réponse est déjà dans les suggestions")
		return
	
	elif resultat[0] == "valide":
		ajouter_popup.emit("cette réponse est déja dans la liste des réponses valides")
		return
		
	# on ajoute l'élément en local
	var new_noeud = $question_reponse.duplicate()
	new_noeud.get_node("panel question/MarginContainer/question").text = question
	new_noeud.get_node("panel reponse/MarginContainer/reponse").text = reponse
	$"scrolling/liste questions_reponses".add_child(new_noeud)
	
	# on reset les champs de texte
	$"éléments texte/ajouter_question_texte".text = ""
	$"éléments texte/ajouter_reponse_texte".text = ""
	
	ajouter_popup.emit("réponse ajoutée")
