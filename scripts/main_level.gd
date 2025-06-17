class_name MainLevel
extends Node2D

@onready var obstacle_manager := $ObstacleManager
@onready var scrolling_floor := $Floor
@onready var player := $Player

const MOVING_HORIZONTAL_SCROLL_SPEED := Constants.SCROLL_VELOCITY
const SAVE_FILE_PATH := "user://scores.data"

enum GameState {
	WAITING_TO_START,
	PLAYING,
}

var state: GameState

var current_score := 0
var high_score := 0

# ---------------------------------------------------------------------------

func _ready() -> void:
	load_scores()
	restart()

# ---------------------------------------------------------------------------

func restart() -> void:
	if current_score > high_score:
		high_score = current_score
		save_scores()
	
	state = GameState.WAITING_TO_START
	current_score = 0
	
	obstacle_manager.restart()
	scrolling_floor.set_horizontal_scroll_speed(MOVING_HORIZONTAL_SCROLL_SPEED)
	player.restart()

# ---------------------------------------------------------------------------

func _physics_process(_delta: float) -> void:
	match state:
		GameState.WAITING_TO_START:
			if Input.is_action_just_pressed("swim"):
				state = GameState.PLAYING
				
				obstacle_manager.start_playing()
				player.start_playing()
		
		GameState.PLAYING:
			pass # nothing to do for now

# ---------------------------------------------------------------------------

func _on_obstacle_manager_player_collided_with_obstacle() -> void:
	stop_game()

# ---------------------------------------------------------------------------

func _on_player_player_hit_floor_during_play() -> void:
	stop_game()

# ---------------------------------------------------------------------------

func stop_game() -> void:
	obstacle_manager.stop_moving_and_spawning_obstacles()
	scrolling_floor.set_horizontal_scroll_speed(0.0)
	player.die()
	
	await get_tree().create_timer(2.0).timeout
	restart()

# ---------------------------------------------------------------------------

func _on_point_scored() -> void:
	current_score += 1

# ---------------------------------------------------------------------------

func save_scores() -> void:
	var save_data := {}
	save_data.high_score = high_score
	
	var save_file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file == null:
		print("[ERROR] Could not save high score: ", FileAccess.get_open_error())
		return
	
	var save_data_json := JSON.stringify(save_data)
	save_file.store_string(save_data_json)

# ---------------------------------------------------------------------------

func load_scores() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("[WARN] Scores file not found")
		return
	
	var save_file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var save_file_contents := save_file.get_as_text()
	
	var json := JSON.new()
	var parsed_file_contents := json.parse(save_file_contents)
	if not parsed_file_contents == OK:
		print("[ERROR] JSON parse error: ", json.get_error_message(), " on line ", json.get_error_line())
		return
	
	var save_data = json.data
	if "high_score" in save_data:
		high_score = save_data.high_score
