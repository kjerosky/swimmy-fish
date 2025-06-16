class_name Obstacle
extends Node2D

@onready var point_gate_collider = $PointGate/CollisionShape2D

var velocity := Vector2.ZERO
var destruction_position_x := 0

# ---------------------------------------------------------------------------

func _ready() -> void:
	point_gate_collider.set_deferred("disabled", false)

# ---------------------------------------------------------------------------

func initialize(initial_position: Vector2, initial_velocity: Vector2, destroy_position_x: int):
	global_position = initial_position
	velocity = initial_velocity
	destruction_position_x = destroy_position_x

# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if global_position.x <= destruction_position_x:
		queue_free()
		return
	
	global_position += velocity * delta

# ---------------------------------------------------------------------------

func stop_movement() -> void:
	velocity = Vector2.ZERO

# ---------------------------------------------------------------------------

func _on_point_gate_body_entered(body: Node2D) -> void:
	if body is Player:
		pass#TODO signal point scored
		
		point_gate_collider.set_deferred("disabled", true)
