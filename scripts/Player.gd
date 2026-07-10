extends CharacterBody2D

signal stats_changed(lives: int, wing_energy: float)
signal inventory_changed(score: int, feathers: int)
signal defeated(score: int, feathers: int)

const MOVE_SPEED := 190.0
const CROUCH_SPEED := 82.0
const DASH_SPEED := 330.0
const DASH_ENERGY_DRAIN := 13.0
const JUMP_VELOCITY := -530.0
const COYOTE_TIME := 0.10
const JUMP_BUFFER_TIME := 0.12
const JUMP_CUT_MULTIPLIER := 0.48
const GRAVITY := 1080.0
const GLIDE_GRAVITY := 280.0
const GLIDE_MAX_FALL_SPEED := 95.0
const MAX_FALL_SPEED := 720.0
const STAND_RADIUS := 13.0
const STAND_HEIGHT := 38.0
const CROUCH_RADIUS := 12.0
const CROUCH_HEIGHT := 26.0
const SPRITE_BASE_SCALE := 0.21
const SPRITE_BASE_POSITION := Vector2(0, -12)

var lives := 3
var wing_energy := 100.0
var score := 0
var feathers := 0
var spawn_position := Vector2.ZERO
var facing := 1.0
var is_gliding := false
var is_dashing := false
var is_crouching := false
var celebrating := false
var defeated_state := false
var input_locked := false
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var generated_sprite: AnimatedSprite2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# The character is made from simple draw calls, so no external sprite files are required.
	spawn_position = global_position
	_build_collision()
	_build_generated_sprite()
	stats_changed.emit(lives, wing_energy)
	inventory_changed.emit(score, feathers)


func _physics_process(delta: float) -> void:
	if input_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_sprite_animation()
		return

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer = max(0.0, jump_buffer_timer - delta)

	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(0.0, coyote_timer - delta)

	var input_axis := Input.get_axis("move_left", "move_right")
	if input_axis != 0.0:
		facing = sign(input_axis)

	is_crouching = is_on_floor() and Input.is_action_pressed("crouch")
	_update_collision_pose()

	var was_dashing := is_dashing
	var wants_dash := Input.is_action_pressed("dash") and input_axis != 0.0 and not is_crouching and wing_energy > 0.0
	is_dashing = wants_dash
	if is_dashing and not was_dashing:
		_play_sfx("dash")

	var move_speed := MOVE_SPEED
	if is_crouching:
		move_speed = CROUCH_SPEED
	if is_dashing:
		move_speed = DASH_SPEED
	velocity.x = input_axis * move_speed

	if is_dashing:
		wing_energy = max(0.0, wing_energy - DASH_ENERGY_DRAIN * delta)

	if is_on_floor():
		is_gliding = false
		if not is_dashing:
			var regen_rate := 64.0 if is_crouching else 45.0
			wing_energy = min(100.0, wing_energy + regen_rate * delta)

	var can_jump := not is_crouching and jump_buffer_timer > 0.0 and coyote_timer > 0.0
	if can_jump:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		is_gliding = false
		_play_sfx("jump")
	elif not is_on_floor():
		var wants_glide := Input.is_action_pressed("glide") or Input.is_action_pressed("jump")
		is_gliding = wants_glide and velocity.y > 0.0 and wing_energy > 0.0
		if is_gliding:
			velocity.y += GLIDE_GRAVITY * delta
			velocity.y = min(velocity.y, GLIDE_MAX_FALL_SPEED)
			wing_energy = max(0.0, wing_energy - 42.0 * delta)
		else:
			velocity.y += GRAVITY * delta
			velocity.y = min(velocity.y, MAX_FALL_SPEED)

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	var was_grounded := is_on_floor()
	var previous_vertical_velocity := velocity.y
	move_and_slide()

	if not was_grounded and is_on_floor() and previous_vertical_velocity > 150.0:
		_play_sfx("land")

	# Falling below the cloud layer costs one life and returns the hero to the start.
	if global_position.y > 1060.0:
		_respawn()

	stats_changed.emit(lives, wing_energy)
	_update_sprite_animation()
	queue_redraw()


func add_feather(amount: int, score_value: int) -> void:
	# Collectibles call this when the player overlaps them.
	feathers += amount
	score += score_value
	inventory_changed.emit(score, feathers)


func add_score(amount: int) -> void:
	score += amount
	inventory_changed.emit(score, feathers)


func restore_energy(amount: float) -> void:
	wing_energy = min(100.0, wing_energy + amount)
	stats_changed.emit(lives, wing_energy)


func get_feather_count() -> int:
	return feathers


func set_spawn_position(pos: Vector2) -> void:
	spawn_position = pos


func _play_sfx(sound_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null:
		audio_manager.call("play_sfx", sound_name)


func celebrate() -> void:
	# Called by the portal when the level is cleared.
	velocity = Vector2.ZERO
	celebrating = true
	input_locked = true
	_update_sprite_animation()
	queue_redraw()


func _respawn() -> void:
	_play_sfx("fall_respawn")
	velocity = Vector2.ZERO
	lives -= 1
	if lives <= 0:
		lives = 0
		global_position = spawn_position
		defeated_state = true
		input_locked = true
		is_gliding = false
		is_dashing = false
		is_crouching = false
		_update_collision_pose()
		stats_changed.emit(lives, wing_energy)
		defeated.emit(score, feathers)
		_update_sprite_animation()
		return

	global_position = spawn_position
	wing_energy = 100.0
	is_gliding = false
	is_dashing = false
	is_crouching = false
	_update_collision_pose()
	stats_changed.emit(lives, wing_energy)


func _build_collision() -> void:
	var shape := CapsuleShape2D.new()
	shape.radius = STAND_RADIUS
	shape.height = STAND_HEIGHT
	collision_shape.shape = shape


func _update_collision_pose() -> void:
	var shape := collision_shape.shape as CapsuleShape2D
	if not shape:
		return
	if is_crouching:
		shape.radius = CROUCH_RADIUS
		shape.height = CROUCH_HEIGHT
		collision_shape.position = Vector2(0, 7)
	else:
		shape.radius = STAND_RADIUS
		shape.height = STAND_HEIGHT
		collision_shape.position = Vector2.ZERO


func _build_generated_sprite() -> void:
	var frames := SpriteFrames.new()
	var loaded := false
	loaded = _add_sprite_animation(frames, "idle", [
		"res://assets/characters/hero_silverwing_idle_00.png",
		"res://assets/characters/hero_silverwing_idle_01.png"
	], 4.0) or loaded
	_add_sprite_animation(frames, "run", [
		"res://assets/characters/hero_silverwing_run_00.png",
		"res://assets/characters/hero_silverwing_run_01.png",
		"res://assets/characters/hero_silverwing_run_02.png",
		"res://assets/characters/hero_silverwing_run_03.png",
		"res://assets/characters/hero_silverwing_run_04.png",
		"res://assets/characters/hero_silverwing_run_05.png",
		"res://assets/characters/hero_silverwing_run_06.png",
		"res://assets/characters/hero_silverwing_run_07.png",
		"res://assets/characters/hero_silverwing_run_08.png",
		"res://assets/characters/hero_silverwing_run_09.png",
		"res://assets/characters/hero_silverwing_run_10.png",
		"res://assets/characters/hero_silverwing_run_11.png"
	], 18.0)
	_add_sprite_animation(frames, "dash", [
		"res://assets/characters/hero_silverwing_dash_00.png",
		"res://assets/characters/hero_silverwing_dash_01.png",
		"res://assets/characters/hero_silverwing_dash_02.png",
		"res://assets/characters/hero_silverwing_dash_03.png",
		"res://assets/characters/hero_silverwing_dash_04.png",
		"res://assets/characters/hero_silverwing_dash_05.png"
	], 20.0)
	_add_sprite_animation(frames, "crouch", [
		"res://assets/characters/hero_silverwing_crouch_00.png",
		"res://assets/characters/hero_silverwing_crouch_01.png",
		"res://assets/characters/hero_silverwing_crouch_02.png",
		"res://assets/characters/hero_silverwing_crouch_03.png"
	], 6.0)
	_add_sprite_animation(frames, "jump", [
		"res://assets/characters/hero_silverwing_jump_00.png",
		"res://assets/characters/hero_silverwing_jump_01.png",
		"res://assets/characters/hero_silverwing_jump_02.png",
		"res://assets/characters/hero_silverwing_jump_03.png"
	], 8.0)
	_add_sprite_animation(frames, "fall", [
		"res://assets/characters/hero_silverwing_fall_00.png",
		"res://assets/characters/hero_silverwing_fall_01.png",
		"res://assets/characters/hero_silverwing_fall_02.png",
		"res://assets/characters/hero_silverwing_fall_03.png"
	], 8.0)
	_add_sprite_animation(frames, "glide", [
		"res://assets/characters/hero_silverwing_glide_00.png",
		"res://assets/characters/hero_silverwing_glide_01.png",
		"res://assets/characters/hero_silverwing_glide_02.png",
		"res://assets/characters/hero_silverwing_glide_03.png",
		"res://assets/characters/hero_silverwing_glide_04.png"
	], 8.0)
	_add_sprite_animation(frames, "celebrate", ["res://assets/characters/hero_silverwing_celebrate_00.png"], 1.0)
	_add_sprite_animation(frames, "fail", [
		"res://assets/characters/hero_silverwing_fail_00.png",
		"res://assets/characters/hero_silverwing_fail_01.png",
		"res://assets/characters/hero_silverwing_fail_02.png",
		"res://assets/characters/hero_silverwing_fail_03.png"
	], 5.0)

	if not loaded:
		return

	generated_sprite = AnimatedSprite2D.new()
	generated_sprite.name = "HeroGeneratedSprite"
	generated_sprite.sprite_frames = frames
	generated_sprite.animation = "idle"
	generated_sprite.scale = Vector2.ONE * SPRITE_BASE_SCALE
	generated_sprite.position = SPRITE_BASE_POSITION
	generated_sprite.z_index = 30
	generated_sprite.centered = true
	add_child(generated_sprite)
	generated_sprite.play("idle")


func _add_sprite_animation(frames: SpriteFrames, animation_name: String, paths: Array, speed: float) -> bool:
	if not frames.has_animation(animation_name):
		frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, speed)
	frames.set_animation_loop(animation_name, ["idle", "run", "dash", "crouch", "glide"].has(animation_name))

	var loaded := false
	for path in paths:
		if not ResourceLoader.exists(path):
			continue
		var texture: Texture2D = load(path) as Texture2D
		if texture:
			frames.add_frame(animation_name, texture)
			loaded = true
	return loaded


func _update_sprite_animation() -> void:
	if not generated_sprite:
		return

	generated_sprite.flip_h = facing < 0.0
	var next_animation := "idle"
	if defeated_state:
		next_animation = "fail"
	elif celebrating:
		next_animation = "celebrate"
	elif is_dashing:
		next_animation = "dash"
	elif is_crouching:
		next_animation = "crouch"
	elif is_gliding:
		next_animation = "glide"
	elif not is_on_floor() and velocity.y < 0.0:
		next_animation = "jump"
	elif not is_on_floor() and velocity.y >= 0.0:
		next_animation = "fall"
	elif abs(velocity.x) > 1.0:
		next_animation = "run"

	if generated_sprite.animation != next_animation:
		generated_sprite.play(next_animation)
	_apply_animation_visual_pose(next_animation)


func _apply_animation_visual_pose(animation_name: String) -> void:
	var scale_value := SPRITE_BASE_SCALE
	var sprite_position := SPRITE_BASE_POSITION

	match animation_name:
		"run":
			scale_value = 0.22
			sprite_position = Vector2(0, -13)
		"dash":
			scale_value = 0.31
			sprite_position = Vector2(0, -22)
		"glide":
			scale_value = 0.26
			sprite_position = Vector2(0, -20)
		"jump", "fall":
			scale_value = 0.22
			sprite_position = Vector2(0, -14)
		"crouch":
			scale_value = 0.22
			sprite_position = Vector2(0, -4)
		_:
			scale_value = SPRITE_BASE_SCALE
			sprite_position = SPRITE_BASE_POSITION

	generated_sprite.scale = Vector2.ONE * scale_value
	generated_sprite.position = sprite_position


func _draw() -> void:
	if generated_sprite:
		return

	# Pixel-style silver phoenix adventurer: white wings, dark cloak, gold trim.
	var flip := float(facing)
	var wing_color := Color(0.86, 0.91, 0.95)
	var wing_shadow := Color(0.55, 0.63, 0.70)
	var cloak := Color(0.05, 0.06, 0.09)
	var gold := Color(1.0, 0.78, 0.25)
	var beak := Color(1.0, 0.66, 0.18)

	if is_gliding:
		draw_polygon([
			Vector2(-8 * flip, -12), Vector2(-55 * flip, -30), Vector2(-48 * flip, -4),
			Vector2(-22 * flip, 10)
		], [wing_color])
		draw_polygon([
			Vector2(8 * flip, -12), Vector2(52 * flip, -26), Vector2(43 * flip, -1),
			Vector2(20 * flip, 10)
		], [wing_shadow])
	else:
		draw_polygon([
			Vector2(-4 * flip, -8), Vector2(-35 * flip, -23), Vector2(-28 * flip, 3),
			Vector2(-13 * flip, 12)
		], [wing_color])
		draw_polygon([
			Vector2(4 * flip, -8), Vector2(31 * flip, -20), Vector2(24 * flip, 4),
			Vector2(13 * flip, 12)
		], [wing_shadow])

	draw_polygon([Vector2(-12, 5), Vector2(13, 5), Vector2(9, 31), Vector2(-9, 31)], [cloak])
	draw_line(Vector2(-13, 8), Vector2(-4, 30), gold, 2.0)
	draw_line(Vector2(13, 8), Vector2(4, 30), gold, 2.0)
	draw_circle(Vector2(0, -16), 15.0, wing_color)
	draw_polygon([Vector2(12 * flip, -17), Vector2(25 * flip, -12), Vector2(12 * flip, -7)], [beak])
	draw_circle(Vector2(5 * flip, -20), 2.2, Color.BLACK)
	draw_polygon([Vector2(-8, -29), Vector2(-2, -43), Vector2(4, -29)], [wing_color])
	draw_line(Vector2(-7, -29), Vector2(0, -38), wing_shadow, 2.0)

	if celebrating:
		draw_line(Vector2(7, 1), Vector2(22, -51), gold, 4.0)
		draw_circle(Vector2(23, -56), 7.0, Color(0.35, 0.85, 1.0))
		draw_arc(Vector2(23, -56), 13.0, 0.0, TAU, 24, Color(1.0, 1.0, 1.0), 2.0)
