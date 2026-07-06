extends Area2D

signal victory_requested
signal locked_attempt(required: int, current: int)

@export var required_feathers := 5

var current_feathers := 0
var activated := false
var spin := 0.0
var bodies_in_range: Array[Node] = []
var generated_sprite: Sprite2D

func _ready() -> void:
	# Circular trigger area around the wind-ring portal.
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_build_generated_sprite()

	var shape := CircleShape2D.new()
	shape.radius = 82.0
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)


func _process(delta: float) -> void:
	spin += delta
	queue_redraw()


func update_feathers(value: int) -> void:
	current_feathers = value
	# 只记录数量，不在收集羽毛瞬间触发通关。
	# 通关必须由玩家主动进入右侧终点传送门触发。


func _on_body_entered(body: Node) -> void:
	if activated:
		return

	if not bodies_in_range.has(body):
		bodies_in_range.append(body)

	_try_activate(body)


func _on_body_exited(body: Node) -> void:
	bodies_in_range.erase(body)


func _try_activate(body: Node) -> bool:
	var count := current_feathers
	if body.has_method("get_feather_count"):
		count = body.call("get_feather_count")

	if count >= required_feathers:
		activated = true
		victory_requested.emit()
		return true

	locked_attempt.emit(required_feathers, count)
	return false


func _draw() -> void:
	if generated_sprite:
		return

	# Glowing wind ring with a simple white phoenix swirl in the middle.
	var glow := Color(0.85, 0.95, 1.0, 0.34 + 0.12 * sin(spin * 4.0))
	var white := Color(1.0, 1.0, 1.0)
	var blue := Color(0.30, 0.68, 1.0)
	var stone := Color(0.24, 0.28, 0.32)

	draw_arc(Vector2.ZERO, 76.0, 0.0, TAU, 96, stone, 18.0)
	draw_arc(Vector2.ZERO, 65.0, spin, spin + TAU * 0.82, 96, white, 7.0)
	draw_arc(Vector2.ZERO, 88.0, -spin * 0.7, -spin * 0.7 + TAU * 0.66, 96, glow, 9.0)
	draw_arc(Vector2.ZERO, 47.0, spin * 1.4, spin * 1.4 + TAU * 0.72, 64, blue, 4.0)

	draw_polygon([
		Vector2(-16, 22), Vector2(4, -35), Vector2(31, -7),
		Vector2(10, -4), Vector2(28, 20), Vector2(1, 11)
	], [white])
	draw_circle(Vector2(14, -15), 7.0, white)


func _build_generated_sprite() -> void:
	var path := "res://assets/environment/portal_next_level_idle_00.png"
	if not ResourceLoader.exists(path):
		return
	var texture: Texture2D = load(path) as Texture2D
	if not texture:
		return
	generated_sprite = Sprite2D.new()
	generated_sprite.name = "GeneratedNextLevelPortalSprite"
	generated_sprite.texture = texture
	generated_sprite.scale = Vector2(0.92, 0.92)
	add_child(generated_sprite)
