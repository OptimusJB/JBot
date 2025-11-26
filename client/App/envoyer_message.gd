extends Button

# script qui sert à récupérer l'input (pour entrée)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		if not disabled:
			pressed.emit()
