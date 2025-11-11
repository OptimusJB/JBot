extends AnimationPlayer
var change_scene = "jbot"	# = jbot ou changeip ou création
var popup = load("res://client/popup/popup.tscn")

func _ready() -> void:
	if Global.retour_lobby_anim == "rien":
		play("apparition")
	else:
		if Global.retour_lobby_anim == "oui":
			play("apparition")
		else:
			play("spawn")
		var nouveau_popup = popup.instantiate()
		nouveau_popup.get_node("marges/texte").text = "échec de la connexion au serveur"
		$"../centre/popup".add_child(nouveau_popup)
		
		# on reset le Global
		Global.retour_lobby_anim = "rien"


func _on_changer_ip_pressed() -> void:
	change_scene = "changerip"
	play("disparition")


func _on_se_connecter_pressed() -> void:
	# on regarde si le pseudo et le mot de passe sont valides
	if $"../éléments ui/container champs/pseudo".text == "" or $"../éléments ui/container champs/mot de passe".text == "":
		var new_popup = popup.instantiate()
		new_popup.get_node("marges/texte").text = "le pseudo et le mot de passe ne doivent pas être vides"
		$"../centre/popup".add_child(new_popup)
		return
		
	# on check si le pseudo existe
	var resultat = Client.envoyer_data(["connexion", $"../éléments ui/container champs/pseudo".text, $"../éléments ui/container champs/mot de passe".text])	# = 0 si ça a fail
	if not resultat:
		Client.back_to_lobby("non")
		return
	
	if resultat[0] == "creation compte":
		# le pseudo n'existe pas, création de compte + on sauvegarde le pseudo
		Save.set_data("pseudo", $"../éléments ui/container champs/pseudo".text)
		Save.sauvegarder()
		change_scene = "creation"
		play("disparition")
		return
	
	# le pseudo existe
	

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "disparition":
		if change_scene == "changerip":
			get_tree().change_scene_to_file("res://client/changer ip/changer ip.tscn")
		elif change_scene == "creation":
			get_tree().change_scene_to_file("res://client/création compte/création compte.tscn")
