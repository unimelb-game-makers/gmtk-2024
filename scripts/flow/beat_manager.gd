extends Node2D

const CONFIG = preload("res://resources/spawn_settings.tres")

var beats := 0

signal on_beat(num: int)
	
func start() -> void:
	while(beats <= CONFIG.end_beat):
		print(str("Beat: ", beats))
		on_beat.emit(beats)
		beats += 1
		await Global.seconds(CONFIG.beat())

func beats_to_seconds(beat: int) -> float:
	return beat * CONFIG.beat()
