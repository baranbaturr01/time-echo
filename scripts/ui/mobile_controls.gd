extends CanvasLayer

const PAUSE_MENU_SCENE: PackedScene = preload("res://scenes/ui/pause_menu.tscn")

@onready var up_button: BaseButton = $Panel/UpButton
@onready var down_button: BaseButton = $Panel/DownButton
@onready var left_button: BaseButton = $Panel/LeftButton
@onready var right_button: BaseButton = $Panel/RightButton
@onready var reset_button: BaseButton = $Panel/ResetButton
@onready var pause_button: BaseButton = $Panel/PauseButton
@onready var level_label: Label = $Panel/LevelLabel
@onready var move_label: Label = $Panel/MoveLabel
@onready var echo_label: Label = $Panel/EchoLabel

var _pause_menu: Control

func _ready() -> void:
    _bind_direction_button(up_button, "move_up")
    _bind_direction_button(down_button, "move_down")
    _bind_direction_button(left_button, "move_left")
    _bind_direction_button(right_button, "move_right")
    reset_button.pressed.connect(_on_reset_pressed)
    pause_button.pressed.connect(_toggle_pause_menu)
    _update_hud()

    if not GameManager.game_state_changed.is_connected(_update_hud):
        GameManager.game_state_changed.connect(_update_hud)
    if not GameManager.level_completed.is_connected(_update_hud):
        GameManager.level_completed.connect(_update_hud)

func _exit_tree() -> void:
    if GameManager.game_state_changed.is_connected(_update_hud):
        GameManager.game_state_changed.disconnect(_update_hud)
    if GameManager.level_completed.is_connected(_update_hud):
        GameManager.level_completed.disconnect(_update_hud)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        get_viewport().set_input_as_handled()
        _toggle_pause_menu()

func _bind_direction_button(button: BaseButton, action_name: String) -> void:
    button.button_down.connect(func(): Input.action_press(action_name))
    button.button_up.connect(func(): Input.action_release(action_name))

func _on_reset_pressed() -> void:
    Input.action_press("reset")
    await get_tree().process_frame
    Input.action_release("reset")

func _toggle_pause_menu() -> void:
    if _pause_menu and is_instance_valid(_pause_menu):
        get_tree().paused = false
        _pause_menu.queue_free()
        _pause_menu = null
        return

    if PAUSE_MENU_SCENE == null:
        return

    _pause_menu = PAUSE_MENU_SCENE.instantiate()
    add_child(_pause_menu)
    get_tree().paused = true

func _update_hud() -> void:
    var level_for_display := GameManager.current_level
    if GameManager.current_level > GameManager.TOTAL_LEVELS:
        level_for_display = GameManager.TOTAL_LEVELS
    level_label.text = "Level %d: %s" % [level_for_display, GameManager.get_level_name(level_for_display)]
    move_label.text = "Moves: %d" % GameManager.total_moves
    echo_label.text = "Echoes: %d/%d" % [GameManager.echo_count, GameManager.max_echoes]
