extends Area2D

@export var linked_door_path: NodePath

var _pressing_bodies: Dictionary = {}

@onready var _linked_door: Node = get_node_or_null(linked_door_path)

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _is_pressing_body(body: Node) -> bool:
    return body.is_in_group("player") or body.is_in_group("echo") or body.is_in_group("box")

func _on_body_entered(body: Node) -> void:
    if not _is_pressing_body(body):
        return
    _pressing_bodies[body.get_instance_id()] = body
    _update_door_state()

func _on_body_exited(body: Node) -> void:
    if _pressing_bodies.has(body.get_instance_id()):
        _pressing_bodies.erase(body.get_instance_id())

    for overlap in get_overlapping_bodies():
        if _is_pressing_body(overlap):
            _pressing_bodies[overlap.get_instance_id()] = overlap

    _update_door_state()

func _has_valid_pressers() -> bool:
    for body in _pressing_bodies.values():
        if is_instance_valid(body):
            return true
    return false

func _update_door_state() -> void:
    if _linked_door == null:
        _linked_door = get_node_or_null(linked_door_path)
    if _linked_door == null:
        return

    if _has_valid_pressers():
        if _linked_door.has_method("open"):
            _linked_door.open()
    else:
        if _linked_door.has_method("close"):
            _linked_door.close()
