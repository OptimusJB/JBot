extends VBoxContainer

func _ready() -> void:
	$"ip serveur".text = Save.get_data("ip")
	$"port serveur".text = str(Save.get_data("port"))
