extends AnimationPlayer

func _ready() -> void:
	play("intro")
	pass


func _on_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://client/connexion/connexion.tscn")
