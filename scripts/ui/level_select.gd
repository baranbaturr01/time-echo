extends Control

@onready var grid: GridContainer = $MarginContainer/VBox/Grid
@onready var back_button: BaseButton = $MarginContainer/VBox/BackButton

func _ready() -> void:
    _build_level_buttons()
    back_button.pressed.connect(func(): GameManager.go_to_main_menu())

func _build_level_buttons() -> void:
    for child in grid.get_children():
        child.queue_free()

    for level_num in range(1, GameManager.TOTAL_LEVELS + 1):
        var button := Button.new()
        button.custom_minimum_size = Vector2(180, 72)
        button.focus_mode = Control.FOCUS_NONE
        button.theme_type_variation = &"Button"
        var is_unlocked := level_num <= GameManager.levels_unlocked
        var is_completed := level_num in GameManager.levels_completed

        if not is_unlocked:
            button.text = "🔒 Level %d" % level_num
            button.disabled = true
        else:
            button.text = "Level %d" % level_num
            if is_completed:
                button.text += " ✅"
            button.pressed.connect(_on_level_button_pressed.bind(level_num))

        grid.add_child(button)

func _on_level_button_pressed(level_num: int) -> void:
    GameManager.go_to_level(level_num)
