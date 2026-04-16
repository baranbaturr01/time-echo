extends Area2D

@onready var ray: RayCast2D = $RayCast2D
@onready var beam: Line2D = $Line2D

func _ready() -> void:
    add_to_group("laser")
    _update_beam()

func _physics_process(_delta: float) -> void:
    _update_beam()

func _update_beam() -> void:
    ray.force_raycast_update()

    var end_point: Vector2 = ray.target_position
    if ray.is_colliding():
        end_point = to_local(ray.get_collision_point())
        var collider := ray.get_collider()
        if collider and (collider.is_in_group("player") or collider.is_in_group("echo")):
            if collider.has_method("die") and collider.visible:
                collider.die()

    beam.clear_points()
    beam.add_point(Vector2.ZERO)
    beam.add_point(end_point)
