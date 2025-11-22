extends MarginContainer
# ce fichier sert à mettre en place un autowrap si c'est trop grand

func _process(delta: float) -> void:
	if size.x > 500:
		$texte.autowrap_mode = 3
		$texte.custom_minimum_size.x = 500
	else:
		$texte.autowrap_mode = 0
		$texte.custom_minimum_size.x = 0
