extends AnimationPlayer
var change_scene = "jbot"	# = jbot ou changeip ou création
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
		
	if Global.retour_lobby_anim == "rien":
		play("apparition")
	else:
		if Global.retour_lobby_anim == "oui":
			play("apparition")
		else:
			play("spawn")
		nouveau_popup = popup.instantiate()
		nouveau_popup.get_node("popup/marges/texte").text = "échec de la connexion au serveur"
		$"../centre/popup".add_child(nouveau_popup)
		
		# on reset le Global
		Global.retour_lobby_anim = "rien"


func _on_changer_ip_pressed() -> void:
	change_scene = "changerip"
	play("disparition")


func _on_se_connecter_pressed() -> void:
	var nouveau_popup
	
	# on regarde si le pseudo et le mot de passe sont valides
	if $"../éléments ui/container champs/pseudo".text == "" or $"../éléments ui/container champs/mot de passe".text == "":
		var new_popup = popup.instantiate()
		new_popup.get_node("popup/marges/texte").text = "le pseudo et le mot de passe ne doivent pas être vides"
		$"../centre/popup".add_child(new_popup)
		return
	
	# on check si le timer est fini
	if not $"../cooldown connexion".is_stopped():
		nouveau_popup = popup.instantiate()
		nouveau_popup.get_node("popup/marges/texte").text = "cooldown de connection"
		$"../centre/popup".add_child(nouveau_popup)
		return
		
	# on check si le pseudo existe
	var resultat = Client.envoyer_data(["connexion", $"../éléments ui/container champs/pseudo".text, $"../éléments ui/container champs/mot de passe".text])	# = 0 si ça a fail
	if not resultat:
		Client.back_to_lobby("non")
		return
	
	Global.temp_mdp = $"../éléments ui/container champs/mot de passe".text
	if resultat[0] == "creation compte":
		# le pseudo n'existe pas, création de compte + on sauvegarde le pseudo
		Save.set_data("pseudo", $"../éléments ui/container champs/pseudo".text)
		Save.sauvegarder()
		change_scene = "creation"
		play("disparition")
		return
	
	# le pseudo existe
	elif resultat[0] == "non":
		nouveau_popup = popup.instantiate()
		nouveau_popup.get_node("popup/marges/texte").text = "le mot de passe est incorrect"
		$"../centre/popup".add_child(nouveau_popup)
		$"../cooldown connexion".start()
	
	elif resultat[0] == "oui":
		# on sauvegarde le pseudo
		Save.set_data("pseudo", $"../éléments ui/container champs/pseudo".text)
		
		Global.popup_switch.append("Bienvenue " + Save.get_data("pseudo") + " !")
		change_scene = "jbot"
		play("disparition")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "disparition":
		if change_scene == "changerip":
			get_tree().change_scene_to_file("res://client/changer ip/changer ip.tscn")
		elif change_scene == "creation":
			get_tree().change_scene_to_file("res://client/création compte/création compte.tscn")
		elif change_scene == "jbot":
			get_tree().change_scene_to_file("res://client/App/App.tscn")
