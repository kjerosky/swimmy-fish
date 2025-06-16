class_name Floor
extends StaticBody2D

@onready var segment1 := $Segment1
@onready var segment2 := $Segment2

var horizontal_scroll_speed := 0.0

var segment_horizontal_spacing := 0.0

# ---------------------------------------------------------------------------

func _ready() -> void:
	segment_horizontal_spacing = (segment1.global_position - segment2.global_position).abs().x

# ---------------------------------------------------------------------------

func set_horizontal_scroll_speed(speed: float) -> void:
	horizontal_scroll_speed = speed

# ---------------------------------------------------------------------------

func _process(delta: float) -> void:
	segment1.global_position.x += horizontal_scroll_speed * delta
	segment2.global_position.x += horizontal_scroll_speed * delta
	
	var leftmost_segment := segment1 if segment1.global_position.x < segment2.global_position.x else segment2
	if leftmost_segment.global_position.x <= 0:
		leftmost_segment.global_position.x += segment_horizontal_spacing * 2.0
