@tool
class_name EditableLevelPoint
extends Marker2D

@export_enum("player_start", "portal", "wind_ring", "feather", "coin", "checkpoint") var point_type := "feather":
	set(value):
		point_type = value
		queue_redraw()

@export var point_id := "":
	set(value):
		point_id = value
		queue_redraw()


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var color := _point_color()
	draw_circle(Vector2.ZERO, 10.0, Color(color.r, color.g, color.b, 0.22))
	draw_arc(Vector2.ZERO, 13.0, 0.0, TAU, 32, color, 2.0)
	draw_line(Vector2(-16, 0), Vector2(16, 0), color, 1.5)
	draw_line(Vector2(0, -16), Vector2(0, 16), color, 1.5)


func _point_color() -> Color:
	match point_type:
		"player_start":
			return Color(0.35, 1.0, 0.62, 0.95)
		"portal":
			return Color(0.34, 0.75, 1.0, 0.95)
		"wind_ring":
			return Color(0.85, 0.95, 1.0, 0.95)
		"coin":
			return Color(1.0, 0.78, 0.18, 0.95)
		"checkpoint":
			return Color(0.64, 0.86, 1.0, 0.95)
		_:
			return Color(0.72, 0.86, 1.0, 0.95)
