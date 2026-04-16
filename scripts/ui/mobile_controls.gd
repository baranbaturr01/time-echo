extends CanvasLayer

@onready var up_button: Button = $Panel/UpButton
@onready var down_button: Button = $Panel/DownButton
@onready var left_button: Button = $Panel/LeftButton
@onready var right_button: Button = $Panel/RightButton
@onready var reset_button: Button = $Panel/ResetButton
@onready var level_label: Label = $Panel/LevelLabel

func _ready() -> void:
    _bind_direction_button(up_button, "move_up")
    _bind_direction_button(down_button, "move_down")
    _bind_direction_button(left_button, "move_left")
    _bind_direction_button(right_button, "move_right")
    reset_button.pressed.connect(_on_reset_pressed)
    level_label.text = "Level " + str(GameManager.current_level)

func _bind_direction_button(button: Button, action_name: String) -> void:
    button.button_down.connect(func(): Input.action_press(action_name))
    button.button_up.connect(func(): Input.action_release(action_name))

func _on_reset_pressed() -> void:
    Input.action_press("reset")
    Input.action_release("reset")
