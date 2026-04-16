extends CharacterBody2D

const TILE_SIZE: int = 64
const MOVE_SPEED: float = 200.0

var target_pos: Vector2 = Vector2.ZERO
var is_moving: bool = false

@onready var ray: RayCast2D = $RayCast2D

func _ready() -> void:
    add_to_group("box")
    target_pos = position

func _process(delta: float) -> void:
    if not is_moving:
        return

    position = position.move_toward(target_pos, MOVE_SPEED * delta)
    if position.distance_to(target_pos) < 1.0:
        position = target_pos
        is_moving = false

func try_push(direction: Vector2i) -> bool:
    if is_moving:
        return false

    ray.target_position = Vector2(direction) * TILE_SIZE
    ray.force_raycast_update()

    if ray.is_colliding():
        return false

    is_moving = true
    target_pos = position + Vector2(direction) * TILE_SIZE
    return true
