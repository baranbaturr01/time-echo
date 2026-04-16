extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func open() -> void:
    if collision_shape:
        collision_shape.disabled = true
    modulate = Color(1, 1, 1, 0.3)

func close() -> void:
    if collision_shape:
        collision_shape.disabled = false
    modulate = Color(1, 1, 1, 1)
