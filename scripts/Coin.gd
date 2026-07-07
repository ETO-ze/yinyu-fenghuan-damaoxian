extends Area2D

@export var score_value := 25

var taken := false
var bob_time := 0.0
var base_position := Vector2.ZERO
var generated_sprite: AnimatedSprite2D

func _ready() -> void:
	base_position = position
	monitoring = true
	body_entered.connect(_on_body_entered)

	var shape := CircleShape2D.new()
	shape.radius = 14.0
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	_build_generated_sprite()


func _process(delta: float) -> void:
	bob_time += delta
	position.y = base_position.y + sin(bob_time * 5.0) * 4.0
	rotation = sin(bob_time * 4.0) * 0.10
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if taken:
		return

	if body.has_method("add_score"):
		taken = true
		body.call("add_score", score_value)
		_play_sfx("collect_coin")
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2(1.7, 1.7), 0.16)
		tween.tween_property(self, "modulate:a", 0.0, 0.16)
		tween.chain().tween_callback(Callable(self, "queue_free"))


func _build_generated_sprite() -> void:
	var frames := SpriteFrames.new()
	var animation_name := "spin"
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, true)
	frames.set_animation_speed(animation_name, 12.0)

	var added := 0
	for i in range(8):
		var path := "res://assets/collectibles/collect_coin_spin_%02d.png" % i
		if not ResourceLoader.exists(path):
			continue
		var texture := load(path) as Texture2D
		if texture:
			frames.add_frame(animation_name, texture)
			added += 1

	if added == 0:
		var fallback_path := "res://assets/collectibles/collect_coin_generated.png"
		if not ResourceLoader.exists(fallback_path):
			return
		var fallback_texture := load(fallback_path) as Texture2D
		if fallback_texture:
			frames.add_frame(animation_name, fallback_texture)
			added += 1

	if added == 0:
		return

	generated_sprite = AnimatedSprite2D.new()
	generated_sprite.name = "GeneratedCoinSprite"
	generated_sprite.sprite_frames = frames
	generated_sprite.animation = animation_name
	generated_sprite.scale = Vector2(0.34, 0.34)
	add_child(generated_sprite)
	generated_sprite.play(animation_name)


func _draw() -> void:
	if generated_sprite:
		return

	draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.76, 0.16))
	draw_circle(Vector2.ZERO, 6.0, Color(0.95, 0.55, 0.05))


func _play_sfx(sound_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null:
		audio_manager.call("play_sfx", sound_name)
