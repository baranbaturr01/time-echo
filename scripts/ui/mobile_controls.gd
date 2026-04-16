extends CanvasLayer

@onready var up_button: BaseButton = $Panel/UpButton
@onready var down_button: BaseButton = $Panel/DownButton
@onready var left_button: BaseButton = $Panel/LeftButton
@onready var right_button: BaseButton = $Panel/RightButton
@onready var reset_button: BaseButton = $Panel/ResetButton
@onready var level_label: Label = $Panel/LevelLabel

func _ready() -> void:
    _bind_direction_button(up_button, "move_up")
    _bind_direction_button(down_button, "move_down")
    _bind_direction_button(left_button, "move_left")
    _bind_direction_button(right_button, "move_right")
    reset_button.pressed.connect(_on_reset_pressed)
    _update_level_label()
    if not GameManager.level_completed.is_connected(_update_level_label):
        GameManager.level_completed.connect(_update_level_label)

func _exit_tree() -> void:
    if GameManager.level_completed.is_connected(_update_level_label):
        GameManager.level_completed.disconnect(_update_level_label)

func _bind_direction_button(button: BaseButton, action_name: String) -> void:
    button.button_down.connect(func(): Input.action_press(action_name))
    button.button_up.connect(func(): Input.action_release(action_name))

func _on_reset_pressed() -> void:
    Input.action_press("reset")
    await get_tree().process_frame
    Input.action_release("reset")

func _update_level_label() -> void:
    level_label.text = "Level " + str(GameManager.current_level)
