extends Button

func _ready() -> void:
	visible = false
	if Global.is_admin:
		visible = true
