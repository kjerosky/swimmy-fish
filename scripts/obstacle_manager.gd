class_name ObstacleManager
extends Node

@export var obstacle_scene: PackedScene

@onready var spawn_point := $ObstacleSpawnPoint
@onready var highest_spawn_point := $ObstacleSpawnPoint/HighestSpawnPoint
@onready var lowest_spawn_point := $ObstacleSpawnPoint/LowestSpawnPoint
@onready var destroy_point := $ObstacleDestroyPoint
@onready var obstacles_node := $Obstacles
@onready var spawn_timer := $SpawnTimer

signal player_collided_with_obstacle

# ---------------------------------------------------------------------------

func restart() -> void:
	for obstacle_node in obstacles_node.get_children():
		obstacle_node.queue_free()

# ---------------------------------------------------------------------------

func start_playing() -> void:
	spawn_timer.start()

# ---------------------------------------------------------------------------

func spawn_obstacle() -> void:
	var initial_position := Vector2(
		spawn_point.global_position.x,
		randi_range(highest_spawn_point.global_position.y, lowest_spawn_point.global_position.y)
	)
	var initial_velocity := Vector2(-200, 0)
	
	var new_obstacle = obstacle_scene.instantiate() as Obstacle
	new_obstacle.initialize(initial_position, initial_velocity, destroy_point.global_position.x)
	new_obstacle.collided_with_player.connect(_on_player_collided_with_obstacle)
	
	obstacles_node.add_child(new_obstacle)

# ---------------------------------------------------------------------------

func _on_spawn_timer_timeout() -> void:
	spawn_obstacle()

# ---------------------------------------------------------------------------

func _on_player_collided_with_obstacle() -> void:
	spawn_timer.stop()
	
	for obstacles_child_node in obstacles_node.get_children():
		var obstacle := obstacles_child_node as Obstacle
		obstacle.stop_movement()
	
	player_collided_with_obstacle.emit()
