extends VBoxContainer
var popup = load("res://client/popup/popup.tscn")

func ajouter_popup(texte):
	var new_popup = popup.instantiate()
	new_popup.get_node("popup/marges/texte").text = texte
	add_child(new_popup)
