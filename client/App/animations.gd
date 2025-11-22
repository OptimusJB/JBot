extends AnimationPlayer
var popup = load("res://client/popup/popup.tscn")
var texte_envoi = ""	# pour garder en mémoire la question (enlevée du champs de texte)
var scrolled_down = false

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
	if not resultat[0] == "":
		for index in range(len(resultat)):
			if index%2 == 0:
				# c'est une question
				new_question = $"../types messages/question".duplicate()
				new_question.get_node("fond/marges/texte").text = resultat[index]
				new_question.size_flags_horizontal = 8
				$"../éléments ui/ScrollContainer/messages".add_child(new_question)
			else:
				# c'est une réponse
				new_reponse = $"../types messages/reponse".duplicate()
				new_reponse.get_node("fond/marges/texte").text = resultat[index]
				new_reponse.size_flags_horizontal = 0
				$"../éléments ui/ScrollContainer/messages".add_child(new_reponse)
	
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


func _on_envoyer_message_pressed() -> void:
	# on check si le message n'est pas vide
	if $"../éléments ui/fond 2/champs de texte".text == "":
		var nouveau_popup
		nouveau_popup = popup.instantiate()
		nouveau_popup.get_node("popup/marges/texte").text = "le message ne peut pas être vide"
		$"../centre/popup".add_child(nouveau_popup)
		return
	
	# on désactive l'envoi
	$"../éléments ui/fond 2/envoyer message".disabled = true
	
	# on ajoute le nouveau noeud message
	var nouveau_message = $"../types messages/question".duplicate()
	nouveau_message.get_node("fond/marges/texte").text = $"../éléments ui/fond 2/champs de texte".text
	nouveau_message.size_flags_horizontal = 8	# on le colle à droite
	nouveau_message.modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	"""
	var scroll = create_tween()
	scroll.tween_property($"../éléments ui/ScrollContainer", "scroll_vertical", $"../éléments ui/ScrollContainer".get_v_scroll_bar().max_value, 0)
	"""
	#print($"../éléments ui/ScrollContainer".get_v_scroll_bar().max_value)
	$"../éléments ui/ScrollContainer/messages".add_child(nouveau_message)
	#print($"../éléments ui/ScrollContainer".get_v_scroll_bar().max_value)

	# on descend la scrollbar au max
	var scroll = create_tween()
	scroll.tween_property($"../éléments ui/ScrollContainer", "scroll_vertical", $"../éléments ui/ScrollContainer".get_v_scroll_bar().max_value, 0.5)
	
	# on supprime le contenu de la zone de texte (après l'avoir sauvegardé
	texte_envoi = $"../éléments ui/fond 2/champs de texte".text
	$"../éléments ui/fond 2/champs de texte".text = ""
	
	# animation
	var apparition_message = create_tween()
	apparition_message.tween_property(nouveau_message, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	
	$"../Timer apparition message".start()


func _on_timer_apparition_message_timeout() -> void:
	#print.call_deferred($"../éléments ui/ScrollContainer".get_v_scroll_bar().value)
	# on envoie un message au serveur
	var resultat = Client.envoyer_data(["poser question", Save.get_data("pseudo"), Global.temp_mdp, texte_envoi])
	if not resultat:
		Client.back_to_lobby("oui")
		return
	
	# on a reçu une réponse
	# on crée le nouveau noeud
	var noeud_reponse = $"../types messages/reponse".duplicate()
	noeud_reponse.size_flags_horizontal = 0 # pour le mettre sur la gauche
	
	# on met en place la réponse
	Global.noeud_concerne = noeud_reponse
	Global.reponse_finale = resultat[0]
	Global.index_reponse = 0
	
	$"../éléments ui/ScrollContainer/messages".add_child(noeud_reponse)
	
	# on descend la scrollbar au max
	var scroll = create_tween()
	scroll.tween_property($"../éléments ui/ScrollContainer", "scroll_vertical", $"../éléments ui/ScrollContainer".get_v_scroll_bar().max_value, 0.5)
	
	var apparition = create_tween()
	var temps = 0.02*float(len(Global.reponse_finale))
	apparition.tween_property(Global, "index_reponse", len(Global.reponse_finale) - 1, temps)
	
	$"../Timer apparition reponse".wait_time = temps
	$"../Timer apparition reponse".start()

func _on_timer_apparition_reponse_timeout() -> void:
	$"../éléments ui/fond 2/envoyer message".disabled = false
