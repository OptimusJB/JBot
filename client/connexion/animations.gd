extends AnimationPlayer
var change_scene = "jbot"	# = jbot ou changeip

func _ready() -> void:
	play("apparition")


func _on_changer_ip_pressed() -> void:
	change_scene = "changerip"
	play("disparition")


func _on_se_connecter_pressed() -> void:
	print("se connecter")
	print("se connecter2")
	if Client.envoyer_data(["test"]):
		# connexion réussie
		print("connexion réussie")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "disparition":
		if change_scene == "changerip":
			get_tree().change_scene_to_file("res://client/changer ip/changer ip.tscn")
