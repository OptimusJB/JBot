extends Node2D
var client = load("res://client/client.tscn").instantiate()
var serveur = load("res://serveur/serveur.tscn").instantiate()


func _ready() -> void:
	add_child(serveur)
	
func _on_timer_timeout() -> void:
	add_child(client)
