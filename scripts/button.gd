extends Area2D

@export var linked_door_path: NodePath

var _pressing_bodies_by_id: Dictionary = {}

@onready var _linked_door: Node = get_node_or_null(linked_door_path)

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _is_pressing_body(body: Node) -> bool:
    return body.is_in_group("player") or body.is_in_group("echo") or body.is_in_group("box")

func _on_body_entered(body: Node) -> void:
    if not _is_pressing_body(body):
        return
    _pressing_bodies_by_id[body.get_instance_id()] = body
    _update_door_state()

func _on_body_exited(body: Node) -> void:
    if _pressing_bodies_by_id.has(body.get_instance_id()):
        _pressing_bodies_by_id.erase(body.get_instance_id())

    _update_door_state()

func _has_valid_pressers() -> bool:
    var deduped: Dictionary = {}
    for body in _pressing_bodies_by_id.values():
        if is_instance_valid(body) and _is_pressing_body(body):
            deduped[body.get_instance_id()] = body

    if deduped.is_empty():
        for overlap in get_overlapping_bodies():
            if _is_pressing_body(overlap):
                deduped[overlap.get_instance_id()] = overlap
    _pressing_bodies_by_id = deduped
    return not _pressing_bodies_by_id.is_empty()

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
