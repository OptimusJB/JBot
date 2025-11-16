extends Area2D
var mouse_in = false
var display = false

func _input(event: InputEvent) -> void:
	if event.is_action_released("clic droit") and mouse_in:
		display = true
		$"../menu".global_position = get_global_mouse_position()
		$"../menu".visible = true
		
	elif event.is_action_released("clic gauche") and display:
		display = false
		$"../menu".visible = false

func _on_mouse_entered() -> void:
	mouse_in = true

func _on_mouse_exited() -> void:
	mouse_in = false
