extends Area2D

func _ready() -> void:
    add_to_group("exit")
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        GameManager.complete_level()
