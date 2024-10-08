class_name Timeline
extends Node2D

const SUBMARINE_BEAT = 70
const DIVER_BEAT = 80
const WALKER_BEAT = 85
const BALLOON_BEAT = 156
const WALKER_2_BEAT = 160
const SPACESHIP_BEAT = 163
const SPACE_BEAT = 260

const FADE_OUT_BEAT = 240

@onready var camera_start := %CameraStart as Marker2D
@onready var camera_game := %CameraGame as Marker2D
@onready var camera_controller := %CameraController as CameraController

@onready var submarine := %SubmarineMarker as Marker2D
@onready var balloon := %BalloonMarker as Marker2D
@onready var start_marker := %StartMarker as Marker2D
@onready var spaceship_marker := %SpaceshipMarker as Marker2D

@onready var submarine_follow := %SubmarineFollow as PathFollow2D
@onready var diver_follow := %DiverFollow as PathFollow2D
@onready var walker_follow := %WalkerFollow as PathFollow2D
@onready var balloon_follow := %BalloonFollow as PathFollow2D
@onready var walker_follow_2 := %WalkerFollow2 as PathFollow2D
@onready var spaceship_follow := %SpaceshipFollow as PathFollow2D
@onready var space_follow := %SpaceFollow as PathFollow2D

@onready var hot_air_balloon := %HotAirBalloon as HotAirBalloon
@onready var spaceship := %Spaceship as Spaceship
@onready var moon := $Moon as Moon

var game_state: GameState

enum State { IDLE, SUBMARINE, DIVER, WALKER, BALLOON, WALKER_2, SPACESHIP, SPACE }
var previous_beat := 0
var current_beat := 0
var playing = false

var state := State.IDLE
var current_path: PathFollow2D
var timer := 0.0
var time := 0.0

func init(state: GameState) -> void:
	game_state = state
	camera_controller.init(state)
	moon.init(state)
	BeatManager.on_beat.connect(_on_beat)

func start_camera() -> void:
	await camera_controller.lerp_to(camera_game.global_position)

func start() -> void:
	playing = true
	current_beat = BeatManager.get_start_beat()
	game_state.player.start()
	submarine_state()
	#await submarine_async()
	#await dive_async()
	#await walk_async()
	#await balloon_async()
	#await walk_2_async()
	#await spaceship_async()
	#await space_async()
	#end_game()

func next_state() -> void:
	match(state):
		State.IDLE:
			submarine_state()
		State.SUBMARINE:
			diver_state()
		State.DIVER:
			walker_state()
		State.WALKER:
			balloon_state()
		State.BALLOON:
			walker_2_state()
		State.WALKER_2:
			spaceship_state()
		State.SPACESHIP:
			space_state()
		State.SPACE:
			end_game()

func submarine_state() -> void:
	# Entity Stuff
	state = State.SUBMARINE
	game_state.player.reparent(submarine_follow)
	game_state.player.position = Vector2.ZERO
	camera_controller.follow()
	
	# State Stuff
	timer = 0.0
	time = BeatManager.beats_to_seconds(SUBMARINE_BEAT - BeatManager.beats)
	current_path = submarine_follow
	
func diver_state() -> void:
	# Entity Stuff
	state = State.DIVER
	game_state.player.reparent(diver_follow)
	game_state.player.position = Vector2.ZERO
	game_state.player.fade_in()
	game_state.player.dive_anim()
	
	# State Stuff
	timer = 0.0
	time = BeatManager.beats_to_seconds(DIVER_BEAT - BeatManager.beats)
	current_path = diver_follow

func walker_state() -> void:
	# Entity Stuff
	state = State.WALKER
	game_state.player.reparent(walker_follow)
	game_state.player.position = Vector2.ZERO
	game_state.player.walk_anim()
	
	# State Stuff
	timer = 0.0
	time = BeatManager.beats_to_seconds(WALKER_BEAT - BeatManager.beats)
	current_path = walker_follow
	
func balloon_state() -> void:
	# Entity Stuff
	state = State.BALLOON
	game_state.player.fade_out()
	hot_air_balloon.activate()
	game_state.player.reparent(balloon_follow)
	game_state.player.position = Vector2.ZERO
	camera_controller.follow()
	camera_controller.zoom_to(2.0);
	
	# State Stuff
	timer = 0.0
	time = BeatManager.beats_to_seconds(BALLOON_BEAT - BeatManager.beats)
	current_path = balloon_follow

	
func walker_2_state() -> void:
	# Entity Stuff
	state = State.WALKER_2
	hot_air_balloon.deactivate()
	game_state.player.fade_in()
	game_state.player.reparent(walker_follow_2)
	game_state.player.position = Vector2.ZERO
	game_state.player.walk_anim()
	camera_controller.lerp_to(spaceship_marker.global_position)
	
	# State Stuff
	timer = 0.0
	time = BeatManager.beats_to_seconds(WALKER_2_BEAT - BeatManager.beats)
	current_path = walker_follow_2
	
	
func spaceship_state() -> void:
	# Entity Stuff
	state = State.SPACESHIP
	moon.scale_aync(1.6, 5.0)
	spaceship.activate()
	game_state.player.fade_out()
	game_state.player.reparent(spaceship_follow)
	game_state.player.position = Vector2(100.0, 0.0)
	camera_controller.follow()
	camera_controller.zoom_to(1.0)
	
	# State Stuff
	timer = 0.0
	time = BeatManager.beats_to_seconds(SPACESHIP_BEAT - BeatManager.beats)
	current_path = spaceship_follow
	
func space_state() -> void:
	# Entity Stuff
	state = State.SPACE
	spaceship.reparent(space_follow)
	game_state.player.reparent(space_follow)
	game_state.player.position = Vector2(100.0, 0.0)
	camera_controller.follow()
	
	# State Stuff
	timer = 0.0
	time = BeatManager.beats_to_seconds(SPACE_BEAT - BeatManager.beats)
	current_path = space_follow
	
func _process(delta: float) -> void:
	if timer < time and playing:
		var t :=  timer / time
		current_path.progress_ratio = t
		#print(str(current_path.name, " ", t))
		timer += delta
		if timer >= time:
			next_state()

func submarine_async() -> void:
	if current_beat >= SUBMARINE_BEAT: return
	if not playing: return
	
	previous_beat = 0
	# Reparent the player to the submarine and start camera tracking
	game_state.player.reparent(submarine_follow)
	game_state.player.position = Vector2.ZERO
	camera_controller.follow()
	
	# Lerp the submarine path
	await lerp_path(submarine_follow, 0, SUBMARINE_BEAT)

func dive_async() -> void:
	if current_beat >= DIVER_BEAT: return
	if not playing: return
	previous_beat = SUBMARINE_BEAT
	# Reparent the player to the dive, but lerp camera to balloon
	game_state.player.reparent(diver_follow)
	game_state.player.position = Vector2.ZERO
	game_state.player.fade_in()
	game_state.player.dive_anim()
	
	camera_controller.lerp_to(submarine.global_position)
	# Lerp the diver path
	await lerp_path(diver_follow, SUBMARINE_BEAT, DIVER_BEAT)

func walk_async() -> void:
	if current_beat >= WALKER_BEAT: return
	if not playing: return
	
	previous_beat = DIVER_BEAT
	# Reparent the player to the dive, and keep camera tracking
	print("Start Walking")
	game_state.player.reparent(walker_follow)
	game_state.player.position = Vector2.ZERO
	game_state.player.walk_anim()
	
	camera_controller.lerp_to(balloon.global_position)
	
	# Lerp the diver path
	await lerp_path(walker_follow, DIVER_BEAT, WALKER_BEAT)

func balloon_async() -> void:
	if current_beat >= BALLOON_BEAT: return
	if not playing: return
	previous_beat = WALKER_BEAT
	# Reparent the player to the dive, and keep camera tracking
	
	game_state.player.fade_out()
	hot_air_balloon.activate()
	game_state.player.reparent(balloon_follow)
	game_state.player.position = Vector2.ZERO
	camera_controller.follow()
	camera_controller.zoom_to(2.0);
	
	# Lerp the diver path
	await lerp_path(balloon_follow, WALKER_BEAT, BALLOON_BEAT)

func walk_2_async() -> void:
	if current_beat >= WALKER_2_BEAT: return
	if not playing: return

	previous_beat = BALLOON_BEAT
	hot_air_balloon.deactivate()
	game_state.player.fade_in()
	game_state.player.reparent(walker_follow_2)
	game_state.player.position = Vector2.ZERO
	game_state.player.walk_anim()
	camera_controller.lerp_to(spaceship_marker.global_position)
	
	await lerp_path(walker_follow_2, BALLOON_BEAT, WALKER_2_BEAT)

func spaceship_async() -> void:
	if current_beat >= SPACESHIP_BEAT: return
	if not playing: return

	previous_beat = WALKER_2_BEAT
	moon.scale_aync(1.6, 5.0)
	spaceship.activate()
	game_state.player.fade_out()
	game_state.player.reparent(spaceship_follow)
	game_state.player.position = Vector2(100.0, 0.0)
	camera_controller.follow()
	camera_controller.zoom_to(1.0)
	
	await lerp_path(spaceship_follow, WALKER_2_BEAT, SPACESHIP_BEAT)

func space_async() -> void:
	if current_beat >= SPACE_BEAT: return
	if not playing: return

	previous_beat = SPACESHIP_BEAT
	spaceship.reparent(space_follow)
	game_state.player.reparent(space_follow)
	game_state.player.position = Vector2(100.0, 0.0)
	camera_controller.follow()
	#moon.scale = Vector2(1.6, 1.6)
	#camera_controller.zoom = Vector2(1.0, 1.0)
	#Global.zoom = 1.0
	
	await lerp_path(space_follow, SPACESHIP_BEAT, SPACE_BEAT)

func lerp_path(path_follow: PathFollow2D, start_beat: int, end_beat: int) -> void:
	var start_pos := float(current_beat - start_beat) / (end_beat - previous_beat)
	var total_time := BeatManager.beats_to_seconds(end_beat - start_beat)
	var timer := start_pos * total_time
	while timer < total_time and playing:
		var t := timer / total_time
		path_follow.progress_ratio = t
		timer += get_process_delta_time()
		await Global.frame()
	previous_beat = start_beat
	current_beat = end_beat

func _on_beat(beat: int) -> void:
	if beat == FADE_OUT_BEAT:
		BoidManager.restart()
		EntityManager.restart()
		game_state.clear()
		moon.scale_aync(0.0, 5.0)
	
func end_game() -> void:
	state = State.IDLE
	if playing:
		game_state.end_game()

func restart() -> void:
	state = State.IDLE
	playing = false
	moon.restart()
	await game_state.player.fade_out()
	submarine_follow.progress_ratio = 0.0
	diver_follow.progress_ratio = 0.0
	balloon_follow.progress_ratio = 0.0
	walker_follow.progress_ratio = 0.0
	walker_follow_2.progress_ratio = 0.0
	spaceship_follow.progress_ratio = 0.0
	space_follow.progress_ratio = 0.0
	camera_controller.reset_zoom()
	await camera_controller.lerp_to(camera_controller.original_pos)
