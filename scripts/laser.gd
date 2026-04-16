extends Area2D

const LASER_HIT_EFFECT_SCENE: PackedScene = preload("res://scenes/effects/laser_hit_effect.tscn")

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
                _spawn_hit_effect(ray.get_collision_point())
                collider.die()

    beam.clear_points()
    beam.add_point(Vector2.ZERO)
    beam.add_point(end_point)

func _spawn_hit_effect(hit_position: Vector2) -> void:
    if LASER_HIT_EFFECT_SCENE == null:
        return
    var effect := LASER_HIT_EFFECT_SCENE.instantiate()
    effect.global_position = hit_position
    get_tree().current_scene.add_child(effect)
