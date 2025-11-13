extends AnimationPlayer
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
