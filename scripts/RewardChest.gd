extends Area2D

signal reward_claimed(score_value: int, energy_value: float)

@export var score_value := 300
@export var energy_value := 45.0

const CLOSED_SPRITE_Y := -8.0
const OPEN_SPRITE_Y := -22.0

var opened := false
var sprite: Sprite2D
var bob_time := 0.0


func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	_build_collision()
	_build_sprite()


func _process(delta: float) -> void:
	bob_time += delta
	if sprite and not opened:
		sprite.position.y = CLOSED_SPRITE_Y + sin(bob_time * 3.2) * 1.5


func _on_body_entered(body: Node) -> void:
	if opened:
		return

	if body.has_method("add_score"):
		opened = true
		body.call("add_score", score_value)
		if body.has_method("restore_energy"):
			body.call("restore_energy", energy_value)
		_set_open_sprite()
		_spawn_reward_sparkles()
		reward_claimed.emit(score_value, energy_value)


func _build_collision() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(78, 54)

	var collision := CollisionShape2D.new()
	collision.position = Vector2(0, -24)
	collision.shape = shape
	add_child(collision)


func _build_sprite() -> void:
	sprite = Sprite2D.new()
	sprite.name = "RewardChestSprite"
	sprite.scale = Vector2(0.50, 0.50)
	sprite.position = Vector2(0, CLOSED_SPRITE_Y)
	sprite.z_index = 12
	add_child(sprite)
	_set_closed_sprite()


func _set_closed_sprite() -> void:
	_set_sprite_texture("res://assets/collectibles/chest_reward_closed_02.png")
	sprite.position.y = CLOSED_SPRITE_Y


func _set_open_sprite() -> void:
	_set_sprite_texture("res://assets/collectibles/chest_reward_open_01.png")
	sprite.position.y = OPEN_SPRITE_Y


func _set_sprite_texture(path: String) -> void:
	if not sprite or not ResourceLoader.exists(path):
		return
	var texture := load(path) as Texture2D
	if texture:
		sprite.texture = texture


func _spawn_reward_sparkles() -> void:
	var colors := [
		Color(1.0, 0.84, 0.24),
		Color(0.36, 0.78, 1.0),
		Color(1.0, 1.0, 1.0)
	]
	for i in range(16):
		var bit := _make_reward_particle("res://assets/effects/fx_reward_sparkle_%02d.png" % (i % 4), colors[i % colors.size()])
		bit.position = Vector2(randf_range(-26, 26), randf_range(-58, -20))
		bit.z_index = 20
		add_child(bit)

		var target := bit.position + Vector2(randf_range(-45, 45), randf_range(-55, -18))
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(bit, "position", target, 0.58).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(bit, "modulate:a", 0.0, 0.58)
		tween.chain().tween_callback(Callable(bit, "queue_free"))


func _make_reward_particle(path: String, fallback_color: Color) -> Node2D:
	if ResourceLoader.exists(path):
		var texture := load(path) as Texture2D
		if texture:
			var sparkle := Sprite2D.new()
			sparkle.name = "RewardSparkle"
			sparkle.texture = texture
			sparkle.scale = Vector2(1.25, 1.25)
			return sparkle

	var bit := Polygon2D.new()
	var half := 3.0
	bit.polygon = PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half),
		Vector2(half, half), Vector2(-half, half)
	])
	bit.color = fallback_color
	return bit
