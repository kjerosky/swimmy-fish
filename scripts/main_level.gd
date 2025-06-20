class_name MainLevel
extends Node2D

@onready var parallax_background := $ParallaxBackground
@onready var obstacle_manager := $ObstacleManager
@onready var scrolling_floor := $Floor
@onready var player := $Player
@onready var scored_point_sound := $ScoredPointSound
@onready var high_score_sound := $HighScoreSound
@onready var dead_sound := $DeadSound
@onready var pre_game_display := $CanvasLayer/PreGameDisplay
@onready var high_score_label := $CanvasLayer/PreGameDisplay/HighScoreLabel
@onready var in_game_display := $CanvasLayer/InGameDisplay
@onready var current_score_label := $CanvasLayer/InGameDisplay/CurrentScore
@onready var high_score_achieved_label := $CanvasLayer/InGameDisplay/HighScoreAchievedLabel
@onready var post_game_display := $CanvasLayer/PostGameDisplay
@onready var final_score_label := $CanvasLayer/PostGameDisplay/FinalScoreLabel
@onready var high_score_status_label := $CanvasLayer/PostGameDisplay/HighScoreStatusLabel

const MOVING_HORIZONTAL_SCROLL_SPEED := Constants.SCROLL_VELOCITY
const SAVE_FILE_PATH := "user://scores.data"

enum GameState {
	WAITING_TO_START_GAME,
	PLAYING_GAME,
	GAME_ENDED,
}

var state: GameState

var current_score := 0
var high_score := 0

var is_parallax_scroll_on := true

# ---------------------------------------------------------------------------

func _ready() -> void:
	load_scores()
	restart()

# ---------------------------------------------------------------------------

func restart() -> void:
	state = GameState.WAITING_TO_START_GAME
	current_score = 0
	
	is_parallax_scroll_on = true
	obstacle_manager.restart()
	scrolling_floor.set_horizontal_scroll_speed(MOVING_HORIZONTAL_SCROLL_SPEED)
	player.restart()
	
	high_score_label.text = "High Score: " + str(high_score)
	
	pre_game_display.visible = true
	in_game_display.visible = false
	post_game_display.visible = false


# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	current_score_label.text = str(current_score)
	current_score_label.modulate = Color.WHITE if current_score <= high_score else Color.GOLD
	
	if is_parallax_scroll_on:
		parallax_background.scroll_offset += Vector2(Constants.SCROLL_VELOCITY * delta, 0.0)
	
	match state:
		GameState.WAITING_TO_START_GAME:
			if Input.is_action_just_pressed("swim"):
				state = GameState.PLAYING_GAME
				
				obstacle_manager.start_playing()
				player.start_playing()
				
				pre_game_display.visible = false
				in_game_display.visible = true
				post_game_display.visible = false
		
		GameState.PLAYING_GAME:
			pass # nothing to do for now
		
		GameState.GAME_ENDED:
			if Input.is_action_just_pressed("swim"):
				restart()

# ---------------------------------------------------------------------------

func _on_obstacle_manager_player_collided_with_obstacle() -> void:
	stop_game()

# ---------------------------------------------------------------------------

func _on_player_player_hit_floor_during_play() -> void:
	stop_game()

# ---------------------------------------------------------------------------

func stop_game() -> void:
	dead_sound.play()
	
	is_parallax_scroll_on = false
	obstacle_manager.stop_moving_and_spawning_obstacles()
	scrolling_floor.set_horizontal_scroll_speed(0.0)
	player.die()
	
	await get_tree().create_timer(2.0).timeout
	state = GameState.GAME_ENDED
	
	final_score_label.text = "Final Score: " + str(current_score)
	final_score_label.modulate = Color.GOLD if current_score > high_score else Color.WHITE
	
	if current_score > high_score:
		high_score_status_label.text = "Your score is now the high score!"
		high_score_status_label.modulate = Color.GOLD
	else:
		var points_to_high_score := high_score - current_score + 1
		high_score_status_label.text = \
			"You were " + str(points_to_high_score) + " " + \
			("points" if points_to_high_score > 1 else "point") + \
			" away from holding the high score."
		high_score_status_label.modulate = Color.WHITE
	
	pre_game_display.visible = false
	in_game_display.visible = false
	post_game_display.visible = true
	
	if current_score > high_score:
		high_score = current_score
		save_scores()

# ---------------------------------------------------------------------------

func _on_point_scored() -> void:
	current_score += 1
	
	if current_score == high_score + 1:
		high_score_sound.play()
		
		high_score_achieved_label.scale = Vector2.ZERO
		high_score_achieved_label.visible = true
		var label_tween := create_tween()
		label_tween.tween_property(high_score_achieved_label, "scale", Vector2.ONE, 1.0) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_ELASTIC)
		label_tween.tween_property(high_score_achieved_label, "scale", Vector2.ZERO, 0.5) \
			.set_delay(0.5) \
			.set_ease(Tween.EASE_IN) \
			.set_trans(Tween.TRANS_QUAD)
		label_tween.tween_callback(func(): high_score_achieved_label.visible = false)
	else:
		scored_point_sound.play()

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
