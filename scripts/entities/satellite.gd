class_name Satellite
extends Enemy

@export var orbit_radius := 500.0
@export var orbit_period := 10.0
@export var speed := 200.0
@export var laser_damage := 5.0

const LASER = preload("res://scenes/projectiles/laser.tscn")

func _ready() -> void:
	on_init.connect(_on_init)
	
func _on_init() -> void:
	await lerp_async()
	orbit_async()
	shoot_async()

func lerp_async() -> void:
	var start_pos := global_position
	var player_pos := game_state.player.global_position
	var direction := (player_pos - start_pos).normalized()
	var target_pos := player_pos - direction * orbit_radius
	var time_to_target := (start_pos - target_pos).length() / speed
	var timer := 0.0
	
	while timer < time_to_target:
		var time := timer / time_to_target
		position = start_pos.lerp(target_pos, Global.ease_out_sin(time))
		timer += get_process_delta_time()
		await Global.frame()
	
	position = target_pos

func orbit_async() -> void:
	var player_pos := game_state.player.global_position
	var difference := global_position - player_pos
	var current_angle := atan2(difference.y, difference.x)
	var angle_increment := 2 * PI / orbit_period
	print(str("Current angle is: ", rad_to_deg(current_angle)))
	while(true):
		var x := orbit_radius * cos(current_angle)
		var y := orbit_radius * sin(current_angle)
		position = Vector2(x, y)
		current_angle += angle_increment * get_process_delta_time()
		await Global.frame()

func shoot_async() -> void:
	while(true):
		await Global.seconds(1.0)
		var laser := LASER.instantiate() as Laser
		add_child(laser)
		laser.activate(self, game_state.player, 0.2)
		game_state.player.damage(laser_damage)
