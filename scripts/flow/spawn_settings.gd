class_name SpawnSettings
extends Resource

@export var start_beat := 0
@export var end_beat := 100
@export var bpm := 100.0

const PREFIX = "res://scenes/spawn_groups/"

func beat() -> float:
	return 60 / bpm

func spawn(current_beat: int) -> SpawnGroup:
	var path := str(PREFIX, current_beat, ".tscn")
	if not ResourceLoader.exists(path):
		return
	var resource := load(path)
	if resource:
		var scene = resource.instantiate() as SpawnGroup
		return scene
	return null
