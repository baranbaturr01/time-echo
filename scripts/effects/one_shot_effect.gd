extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    if animated_sprite == null or animated_sprite.sprite_frames == null:
        queue_free()
        return

    if animated_sprite.sprite_frames.has_animation("default"):
        animated_sprite.play("default")
    else:
        animated_sprite.play()
    animated_sprite.animation_finished.connect(queue_free)
