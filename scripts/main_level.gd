class_name MainLevel
extends Node2D

@onready var obstacle_manager := $ObstacleManager
@onready var player := $Player

enum GameState {
	WAITING_TO_START,
	PLAYING,
}

var state: GameState

# ---------------------------------------------------------------------------

func _ready() -> void:
	restart()

# ---------------------------------------------------------------------------

func restart() -> void:
	state = GameState.WAITING_TO_START
	
	obstacle_manager.restart()
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
	player.die()
	
	await get_tree().create_timer(1.0).timeout
	restart()
