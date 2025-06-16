class_name Player
extends CharacterBody2D

const SWIM_UP_VELOCITY = -600.0

enum PlayerState {
	WAITING_TO_START,
	PLAYING,
	DEAD,
}

var state := PlayerState.WAITING_TO_START
var new_game_position: Vector2

# ---------------------------------------------------------------------------

func _ready() -> void:
	new_game_position = global_position

# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("debug-quit"):
		get_tree().quit()
	
	velocity += get_gravity() * delta
	
	match state:
		PlayerState.WAITING_TO_START:
			velocity = Vector2.ZERO
		
		PlayerState.PLAYING:
			if Input.is_action_just_pressed("swim"):
				velocity.y = SWIM_UP_VELOCITY
		
		PlayerState.DEAD:
			pass # nothing to do for now
	
	move_and_slide()

# ---------------------------------------------------------------------------

func restart():
	state = PlayerState.WAITING_TO_START
	global_position = new_game_position

# ---------------------------------------------------------------------------

func start_playing():
	state = PlayerState.PLAYING
	velocity.y = SWIM_UP_VELOCITY

# ---------------------------------------------------------------------------

func die() -> void:
	state = PlayerState.DEAD
	velocity = Vector2.ZERO
