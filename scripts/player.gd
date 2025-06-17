class_name Player
extends CharacterBody2D

@onready var sprite := $CollisionShape2D/AnimatedSprite2D

signal player_hit_floor_during_play

const SWIM_UP_VELOCITY := -600.0

# The magic number here is just to make the visual rotation not so extreme.
const VIRTUAL_HORIZONTAL_VELOCITY := -Constants.SCROLL_VELOCITY * 4.0

enum PlayerState {
	WAITING_TO_START,
	PLAYING,
	DYING,
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
	var visual_direction := Vector2(VIRTUAL_HORIZONTAL_VELOCITY, velocity.y)
	
	match state:
		PlayerState.WAITING_TO_START:
			velocity = Vector2.ZERO
			visual_direction = Vector2.RIGHT
		
		PlayerState.PLAYING:
			if Input.is_action_just_pressed("swim"):
				velocity.y = SWIM_UP_VELOCITY
		
		PlayerState.DYING:
			pass # nothing to do for now
		
		PlayerState.DEAD:
			visual_direction = Vector2.RIGHT
	
	var hit_floor := move_and_slide()
	if hit_floor:
		if state == PlayerState.PLAYING:
			player_hit_floor_during_play.emit()
		
		if state == PlayerState.DYING:
			visual_direction = Vector2.RIGHT
			state = PlayerState.DEAD
	
	sprite.rotation = atan2(visual_direction.y, visual_direction.x)

# ---------------------------------------------------------------------------

func restart():
	state = PlayerState.WAITING_TO_START
	global_position = new_game_position
	sprite.set_animation("swim")

# ---------------------------------------------------------------------------

func start_playing():
	state = PlayerState.PLAYING
	velocity.y = SWIM_UP_VELOCITY

# ---------------------------------------------------------------------------

func die() -> void:
	state = PlayerState.DYING
	velocity = Vector2.ZERO
	sprite.set_animation("dead")
