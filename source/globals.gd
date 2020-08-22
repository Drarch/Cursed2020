extends Node

var cityView: Node2D

var navigation: Navigation2D

func _ready() -> void:
	if not OS.has_feature("editor"):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
