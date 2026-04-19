extends CharacterBody2D

const TILE_SIZE: int = 64
const MOVE_SPEED: float = 200.0

@export var move_queue: Array = []

var move_index: int = 0
var is_moving: bool = false
var target_pos: Vector2 = Vector2.ZERO
var current_direction: String = "down"
var is_alive: bool = true
var _processed_area_ids: Dictionary = {}
var _last_processed_area_frame: int = -1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray: RayCast2D = $RayCast2D
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
    modulate = Color(1, 1, 1, 0.5)
    target_pos = position
    update_animation("idle")
    if hurtbox:
        hurtbox.area_entered.connect(_on_hurtbox_area_entered)
    if not GameManager.turn_advanced.is_connected(_on_turn_advanced):
        GameManager.turn_advanced.connect(_on_turn_advanced)

func _exit_tree() -> void:
    if GameManager.turn_advanced.is_connected(_on_turn_advanced):
        GameManager.turn_advanced.disconnect(_on_turn_advanced)

func _physics_process(delta: float) -> void:
    if is_moving:
        position = position.move_toward(target_pos, MOVE_SPEED * delta)
        if position.distance_to(target_pos) < 1.0:
            position = target_pos
            is_moving = false
            update_animation("idle")
            call_deferred("_check_hurtbox_overlaps")

func _on_turn_advanced(_step: int) -> void:
    if not is_alive or is_moving:
        return
    if move_index >= move_queue.size():
        return

    var dir_name: String = str(move_queue[move_index])
    move_index += 1
    var direction := _direction_from_name(dir_name)
    if direction == Vector2i.ZERO:
        return

    current_direction = dir_name
    ray.target_position = Vector2(direction) * TILE_SIZE
    ray.force_raycast_update()

    if ray.is_colliding():
        var collider := ray.get_collider()
        if collider and collider.is_in_group("box") and collider.has_method("try_push"):
            if collider.try_push(direction):
                _start_move(direction)
        return

    _start_move(direction)

func _start_move(direction: Vector2i) -> void:
    is_moving = true
    target_pos = position + Vector2(direction) * TILE_SIZE
    update_animation("walk")

func _direction_from_name(dir_name: String) -> Vector2i:
    match dir_name:
        "up":
            return Vector2i(0, -1)
        "down":
            return Vector2i(0, 1)
        "left":
            return Vector2i(-1, 0)
        "right":
            return Vector2i(1, 0)
        _:
            return Vector2i.ZERO

func update_animation(state: String) -> void:
    var anim_name := state + "_" + current_direction
    if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
        sprite.play(anim_name)
    elif sprite.sprite_frames and sprite.sprite_frames.has_animation(state):
        sprite.play(state)

func die() -> void:
    is_alive = false
    visible = false
    process_mode = Node.PROCESS_MODE_DISABLED

func _on_hurtbox_area_entered(area: Area2D) -> void:
    _process_area_contact(area)

func _check_hurtbox_overlaps() -> void:
    if not hurtbox:
        return
    for area in hurtbox.get_overlapping_areas():
        _process_area_contact(area)

func _process_area_contact(area: Area2D) -> void:
    if not area:
        return
    var frame := Engine.get_physics_frames()
    if frame != _last_processed_area_frame:
        _last_processed_area_frame = frame
        _processed_area_ids.clear()
    var area_id := area.get_instance_id()
    if _processed_area_ids.has(area_id):
        return
    _processed_area_ids[area_id] = true
    if area.is_in_group("laser"):
        die()
