extends Area2D

signal collected(feather_value: int, score_value: int)

@export var feather_value := 1
@export var score_value := 100

var taken := false
var bob_time := 0.0
var base_position := Vector2.ZERO
var generated_sprite: AnimatedSprite2D

func _ready() -> void:
	# A generated feather pickup with its own collision shape.
	base_position = position
	monitoring = true
	body_entered.connect(_on_body_entered)
	_build_generated_sprite()

	var shape := CircleShape2D.new()
	shape.radius = 18.0
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)


func _process(delta: float) -> void:
	bob_time += delta
	position.y = base_position.y + sin(bob_time * 4.0) * 5.0
	rotation = sin(bob_time * 3.0) * 0.08
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if taken:
		return

	if body.has_method("add_feather"):
		taken = true
		body.call("add_feather", feather_value, score_value)
		_play_sfx("collect_feather")
		collected.emit(feather_value, score_value)

		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2(1.9, 1.9), 0.18)
		tween.tween_property(self, "modulate:a", 0.0, 0.18)
		tween.chain().tween_callback(Callable(self, "queue_free"))


func _draw() -> void:
	if generated_sprite:
		return

	# Silver-blue feather, intentionally chunky for a 16-bit placeholder feel.
	var pale := Color(0.92, 0.97, 1.0)
	var blue := Color(0.25, 0.68, 1.0)
	var dark := Color(0.16, 0.25, 0.35)
	draw_polygon([
		Vector2(-4, 17), Vector2(13, -13), Vector2(5, -19),
		Vector2(-13, 4), Vector2(-16, 15)
	], [pale])
	draw_polygon([
		Vector2(-2, 12), Vector2(9, -9), Vector2(3, -12),
		Vector2(-10, 5)
	], [blue])
	draw_line(Vector2(-5, 17), Vector2(12, -13), dark, 2.0)


func _build_generated_sprite() -> void:
	var frames := SpriteFrames.new()
	var animation_name := "spin"
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, true)
	frames.set_animation_speed(animation_name, 10.0)

	var added := 0
	for i in range(6):
		var path := "res://assets/collectibles/collect_feather_spin_%02d.png" % i
		if not ResourceLoader.exists(path):
			continue
		var texture := load(path) as Texture2D
		if texture:
			frames.add_frame(animation_name, texture)
			added += 1

	if added == 0:
		var fallback_path := "res://assets/collectibles/collect_feather_generated.png"
		if not ResourceLoader.exists(fallback_path):
			return
		var fallback_texture := load(fallback_path) as Texture2D
		if fallback_texture:
			frames.add_frame(animation_name, fallback_texture)
			added += 1

	if added == 0:
		return

	generated_sprite = AnimatedSprite2D.new()
	generated_sprite.name = "GeneratedFeatherSprite"
	generated_sprite.sprite_frames = frames
	generated_sprite.animation = animation_name
	generated_sprite.scale = Vector2(0.36, 0.36)
	add_child(generated_sprite)
	generated_sprite.play(animation_name)


func _play_sfx(sound_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null:
		audio_manager.call("play_sfx", sound_name)
