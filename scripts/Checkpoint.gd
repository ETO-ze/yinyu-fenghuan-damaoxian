class_name Checkpoint
extends Area2D

signal checkpoint_activated(checkpoint_id: String, spawn_position: Vector2)

@export var checkpoint_id := "checkpoint"
@export var spawn_position_offset := Vector2(0, -36)

var is_activated := false
var pulse_time := 0.0
var sprite: Sprite2D


func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	_build_collision()
	_build_sprite()


func _process(delta: float) -> void:
	pulse_time += delta
	if sprite:
		sprite.modulate.a = 0.72 + 0.22 * sin(pulse_time * 4.0)
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if is_activated:
		return

	if not body.has_method("set_spawn_position"):
		return

	is_activated = true
	var spawn_position := global_position + spawn_position_offset
	body.call("set_spawn_position", spawn_position)
	checkpoint_activated.emit(checkpoint_id, spawn_position)
	_play_activate_visual()


func _build_collision() -> void:
	var shape := CircleShape2D.new()
	shape.radius = 36.0

	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)


func _build_sprite() -> void:
	var candidate_paths: Array[String] = [
		"res://assets/environment/marker_wind_ring_00.png",
		"res://assets/effects/fx_star_sparkle_00.png"
	]

	for path in candidate_paths:
		if ResourceLoader.exists(path):
			var texture := load(path) as Texture2D
			if texture:
				sprite = Sprite2D.new()
				sprite.name = "CheckpointSprite"
				sprite.texture = texture
				sprite.scale = Vector2(0.34, 0.34)
				sprite.z_index = 18
				add_child(sprite)
				return


func _play_activate_visual() -> void:
	if sprite:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale", sprite.scale * 1.28, 0.18)
		tween.tween_property(sprite, "modulate", Color(0.52, 0.86, 1.0, 1.0), 0.18)
		tween.chain().tween_property(sprite, "scale", Vector2(0.34, 0.34), 0.22)


func _draw() -> void:
	if sprite:
		return

	var glow := Color(0.45, 0.82, 1.0, 0.24 + 0.12 * sin(pulse_time * 4.0))
	var white := Color(0.92, 0.98, 1.0, 0.92)
	draw_arc(Vector2.ZERO, 30.0, 0.0, TAU, 48, glow, 5.0)
	draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 48, white, 3.0)
	draw_circle(Vector2.ZERO, 5.0, white)
