extends AspectRatioContainer

func _process(delta: float) -> void:
	if Global.noeud_concerne == self:
		$fond/marges/texte.text = Global.reponse_finale.substr(0, Global.index_reponse + 1)
