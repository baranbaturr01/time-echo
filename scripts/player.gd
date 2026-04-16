extends CharacterBody2D

const TILE_SIZE: int = 64
const MOVE_SPEED: float = 200.0

var grid_pos: Vector2i = Vector2i.ZERO
var target_pos: Vector2 = Vector2.ZERO
var is_moving: bool = false
var move_history: Array = []
var current_direction: String = "down"
var is_alive: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray: RayCast2D = $RayCast2D
@onready var hurtbox: Area2D = $Hurtbox

signal player_moved(direction: String)
signal player_reset(history: Array)

func _ready():
	add_to_group("player")
	grid_pos = Vector2i(position / TILE_SIZE)
	target_pos = position
	update_animation("idle")
	if hurtbox:
		hurtbox.area_entered.connect(_on_area_entered)

func _process(delta):
	if is_moving:
		position = position.move_toward(target_pos, MOVE_SPEED * delta)
		if position.distance_to(target_pos) < 1.0:
			position = target_pos
			is_moving = false
			grid_pos = Vector2i(position / TILE_SIZE)
			update_animation("idle")
			GameManager.advance_turn()
	elif is_alive:
		handle_input()

func handle_input():
	var direction = Vector2i.ZERO
	var dir_name = ""
	
	if Input.is_action_just_pressed("move_up"):
		direction = Vector2i(0, -1)
		dir_name = "up"
	elif Input.is_action_just_pressed("move_down"):
		direction = Vector2i(0, 1)
		dir_name = "down"
	elif Input.is_action_just_pressed("move_left"):
		direction = Vector2i(-1, 0)
		dir_name = "left"
	elif Input.is_action_just_pressed("move_right"):
		direction = Vector2i(1, 0)
		dir_name = "right"
	
	if direction != Vector2i.ZERO:
		try_move(direction, dir_name)
	
	if Input.is_action_just_pressed("reset"):
		do_reset()

func try_move(direction: Vector2i, dir_name: String):
	current_direction = dir_name
	
	# Raycast to check for walls/obstacles
	ray.target_position = Vector2(direction) * TILE_SIZE
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider and collider.is_in_group("box"):
			if try_push_box(collider, direction):
				execute_move(direction, dir_name)
			return
		elif collider and (collider.is_in_group("wall") or collider.is_in_group("door")):
			return
	
	execute_move(direction, dir_name)

func execute_move(direction: Vector2i, dir_name: String):
	is_moving = true
	target_pos = position + Vector2(direction) * TILE_SIZE
	move_history.append(dir_name)
	update_animation("walk")
	emit_signal("player_moved", dir_name)

func try_push_box(box: Node2D, direction: Vector2i) -> bool:
	if box.has_method("try_push"):
		return box.try_push(direction)
	return false

func do_reset():
	if GameManager.can_spawn_echo():
		emit_signal("player_reset", move_history.duplicate())
		move_history.clear()
		GameManager.reset_level()

func update_animation(state: String):
	var anim_name = state + "_" + current_direction
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	elif sprite.sprite_frames and sprite.sprite_frames.has_animation(state):
		sprite.play(state)

func die():
	is_alive = false
	visible = false

func _on_area_entered(area):
	if area.is_in_group("exit"):
		GameManager.complete_level()
	elif area.is_in_group("laser"):
		die()
