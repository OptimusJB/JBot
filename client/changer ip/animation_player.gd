extends AnimationPlayer

func _ready() -> void:
	play("apparition")


func _on_retour_pressed() -> void:
	play("disparition")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "disparition":
		get_tree().change_scene_to_file("res://client/connexion/connexion.tscn")
