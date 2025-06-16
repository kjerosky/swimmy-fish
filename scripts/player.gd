class_name Player
extends CharacterBody2D

const SWIM_UP_VELOCITY = -600.0

# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("debug-quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("swim"):
		velocity.y = SWIM_UP_VELOCITY
	else:
		velocity += get_gravity() * delta
	
	move_and_slide()
