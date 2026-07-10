class_name CloudPlatform
extends StaticBody2D

enum State {
	SOLID,
	WARNING,
	HIDDEN
}

@export var platform_size := Vector2(180, 28)
@export var warning_delay := 0.8
@export var disappear_delay := 1.4
@export var restore_delay := 3.0
@export var cloud_texture_path := "res://assets/environment/cloud_platform_00.png"

var state: State = State.SOLID
var sequence_running := false
var blink_time := 0.0

var collision_shape: CollisionShape2D
var top_detector: Area2D
var sprite: Sprite2D


func _ready() -> void:
	_build_collision()
	_build_top_detector()
	_build_sprite()
	_set_state(State.SOLID)


func _process(delta: float) -> void:
	blink_time += delta

	if state == State.WARNING:
		var alpha: float = 0.45 + 0.45 * abs(sin(blink_time * 12.0))
		modulate.a = alpha
	else:
		modulate.a = 1.0

	queue_redraw()


func _build_collision() -> void:
	var shape := RectangleShape2D.new()
	shape.size = platform_size

	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	collision_shape.shape = shape
	add_child(collision_shape)


func _build_top_detector() -> void:
	top_detector = Area2D.new()
	top_detector.name = "TopDetector"
	top_detector.monitoring = true
	top_detector.monitorable = false

	var shape := RectangleShape2D.new()
	shape.size = Vector2(platform_size.x + 18.0, 16.0)

	var detector_collision := CollisionShape2D.new()
	detector_collision.shape = shape
	detector_collision.position = Vector2(0.0, -platform_size.y * 0.5 - 8.0)

	top_detector.add_child(detector_collision)
	add_child(top_detector)

	top_detector.body_entered.connect(_on_top_detector_body_entered)


func _build_sprite() -> void:
	if ResourceLoader.exists(cloud_texture_path):
		var texture := load(cloud_texture_path) as Texture2D
		if texture:
			sprite = Sprite2D.new()
			sprite.name = "CloudPlatformSprite"
			sprite.texture = texture
			sprite.z_index = 5
			var target_width := platform_size.x + 32.0
			var scale_value := target_width / float(texture.get_width())
			sprite.scale = Vector2(scale_value, scale_value)
			add_child(sprite)


func _on_top_detector_body_entered(body: Node) -> void:
	if state != State.SOLID:
		return

	if sequence_running:
		return

	if body is CharacterBody2D:
		_start_break_sequence()


func _start_break_sequence() -> void:
	sequence_running = true

	await get_tree().create_timer(warning_delay).timeout
	if not is_inside_tree():
		return
	_set_state(State.WARNING)

	await get_tree().create_timer(max(0.05, disappear_delay - warning_delay)).timeout
	if not is_inside_tree():
		return
	_set_state(State.HIDDEN)

	await get_tree().create_timer(restore_delay).timeout
	if not is_inside_tree():
		return
	_set_state(State.SOLID)
	sequence_running = false


func _set_state(next_state: State) -> void:
	state = next_state

	match state:
		State.SOLID:
			visible = true
			modulate.a = 1.0
			if collision_shape:
				collision_shape.set_deferred("disabled", false)
			if top_detector:
				top_detector.set_deferred("monitoring", true)

		State.WARNING:
			visible = true
			if collision_shape:
				collision_shape.set_deferred("disabled", false)

		State.HIDDEN:
			visible = false
			if collision_shape:
				collision_shape.set_deferred("disabled", true)
			if top_detector:
				top_detector.set_deferred("monitoring", false)


func _draw() -> void:
	if sprite:
		return

	if state == State.HIDDEN:
		return

	var fill := Color(0.88, 0.96, 1.0, 0.92)
	var shade := Color(0.48, 0.74, 1.0, 0.72)
	var outline := Color(0.12, 0.32, 0.56, 0.88)
	var half := platform_size * 0.5

	draw_rect(Rect2(Vector2(-half.x, -half.y + 6.0), Vector2(platform_size.x, platform_size.y * 0.55)), shade)
	draw_arc(Vector2(-platform_size.x * 0.32, -4), platform_size.y * 0.78, PI, TAU, 16, fill, 10.0)
	draw_arc(Vector2(0, -8), platform_size.y * 0.95, PI, TAU, 18, fill, 11.0)
	draw_arc(Vector2(platform_size.x * 0.32, -4), platform_size.y * 0.78, PI, TAU, 16, fill, 10.0)
	draw_line(Vector2(-half.x, half.y * 0.25), Vector2(half.x, half.y * 0.25), outline, 2.0)
