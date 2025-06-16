class_name MainLevel
extends Node2D

@onready var obstacle_manager := $ObstacleManager
@onready var scrolling_floor := $Floor
@onready var player := $Player

const MOVING_HORIZONTAL_SCROLL_SPEED := -200.0

enum GameState {
	WAITING_TO_START,
	PLAYING,
}

var state: GameState

var current_score := 0

# ---------------------------------------------------------------------------

func _ready() -> void:
	obstacle_manager.set_horizontal_scroll_speed(MOVING_HORIZONTAL_SCROLL_SPEED)
	
	restart()

# ---------------------------------------------------------------------------

func restart() -> void:
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
