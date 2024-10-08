class_name Shark
extends Enemy

@export var bite_range := 100.0
@export var speed := 75.0
@export var retreat_speed := 25.0
@export var bite_time := 2.0
@export var bite_damage := 10.0
@onready var anim := %AnimatedSprite2D as AnimatedSprite2D

enum State {SWIMMING, BITING, RETREATING}
var state := State.SWIMMING

func _process(delta: float) -> void:
	if completed:
		return
	if not game_state:
		return
	if state == State.SWIMMING:
		swim()
	elif state == State.BITING:
		bite()
	elif state == State.RETREATING:
		retreat()

func swim() -> void:
	anim.play("swim")
	var start_pos := global_position
	var player_pos := game_state.player.global_position
	var difference := player_pos - start_pos
	if difference.length() <= bite_range:
		bite_async()
		return
	move_to_player()

func move_to_player() -> void:
	var start_pos := global_position
	var player_pos := game_state.player.global_position
	var difference := player_pos - start_pos
	var direction := difference.normalized()
	var angle := atan2(direction.y, direction.x)
	rotation = angle
	anim.flip_v = Global.flip_v(angle)
	if difference.length() <= bite_range:
		return
	global_position += direction * speed * get_process_delta_time()

func bite_async() -> void:
	state = State.BITING
	await Global.seconds(bite_time - 0.1)
	anim.play("bite")
	await Global.seconds(0.1)
	if completed:
		return
	game_state.player.damage(bite_damage)
	state = State.RETREATING

func bite() -> void:
	move_to_player()

func retreat() -> void:
	var start_pos := global_position
	var player_pos := game_state.player.global_position
	var difference := start_pos - player_pos
	var direction := difference.normalized()
	global_position += direction * retreat_speed * get_process_delta_time()
	#var angle := atan2(direction.y, direction.x)
	#rotation = angle
	#sprite.flip_v = Global.flip_v(angle)
