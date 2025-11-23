extends Panel

func _on_proposer_réponse_changer_proposition(texte, texte_bouton) -> void:
	$"champs de texte".placeholder_text = texte
	$"envoyer message".text = texte_bouton
