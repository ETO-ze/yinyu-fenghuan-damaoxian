@tool
class_name EditablePlatform
extends Marker2D

@export var platform_name := "platform":
	set(value):
		platform_name = value
		queue_redraw()

@export var platform_size := Vector2(200, 30):
	set(value):
		platform_size = value
		queue_redraw()

@export var route_platform := true


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var half := platform_size * 0.5
	var rect := Rect2(-half, platform_size)
	var fill := Color(0.25, 0.72, 1.0, 0.16)
	var outline := Color(0.9, 0.98, 1.0, 0.82)
	draw_rect(rect, fill, true)
	draw_rect(rect, outline, false, 2.0)
	draw_line(Vector2(-half.x, -half.y), Vector2(half.x, -half.y), Color(1.0, 0.9, 0.35), 3.0)
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.9, 0.35, 0.95))
