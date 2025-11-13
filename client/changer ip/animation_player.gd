extends AnimationPlayer
var scene_popup : PackedScene = load("res://client/popup/popup.tscn")

func _ready() -> void:
	play("apparition")

func _on_retour_pressed() -> void:
	play("disparition")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "disparition":
		get_tree().change_scene_to_file("res://client/connexion/connexion.tscn")

func _on_valider_pressed() -> void:
	# on teste si les valeurs entrées sont correctes
	if $"../éléments ui/CenterContainer/VBoxContainer/port serveur".text.is_valid_int():
		# sauvegarde des valeurs
		Save.set_data("ip", $"../éléments ui/CenterContainer/VBoxContainer/ip serveur".text)
		Save.set_data("port", int($"../éléments ui/CenterContainer/VBoxContainer/port serveur".text))
		Save.sauvegarder()
		play("disparition")
	else:
		# on met un message d'avertissement
		var nouveau_popup = scene_popup.instantiate()
		nouveau_popup.get_node("popup/marges/texte").text = "port invalide"
		$"../centre/popup".add_child(nouveau_popup)
