extends Node2D
var client = load("res://tcp/client.tscn").instantiate()
var serveur = load("res://tcp/serveur.tscn").instantiate()


func _ready() -> void:
	print("a")
	add_child(serveur)
	
func _on_timer_timeout() -> void:
	add_child(client)
