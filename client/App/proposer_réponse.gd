extends Button
signal changer_proposition

func reset():
	Global.proposition = false
	Global.question_proposition = ""
	changer_proposition.emit("entrez votre question", "envoyer")
	
func _on_pressed() -> void:
	# on met / enlève le mode proposition
	if Global.proposition and Global.question_proposition == $"../marges/texte".text:
		reset()
	else:
		Global.proposition = true
		Global.question_proposition = $"../marges/texte".text
		changer_proposition.emit("réponse à : " + Global.question_proposition, "proposer")
