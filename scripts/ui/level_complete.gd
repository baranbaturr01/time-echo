extends Control

@onready var title_label: Label = $CenterContainer/Panel/MarginContainer/VBox/Title
@onready var subtitle_label: Label = $CenterContainer/Panel/MarginContainer/VBox/Subtitle
@onready var stats_label: Label = $CenterContainer/Panel/MarginContainer/VBox/Stats
@onready var next_button: BaseButton = $CenterContainer/Panel/MarginContainer/VBox/Buttons/NextButton
@onready var replay_button: BaseButton = $CenterContainer/Panel/MarginContainer/VBox/Buttons/ReplayButton
@onready var level_select_button: BaseButton = $CenterContainer/Panel/MarginContainer/VBox/Buttons/LevelSelectButton

var _completed_level: int = 1
var _completed_level_name: String = ""

func setup(level_num: int, level_name: String) -> void:
    _completed_level = level_num
    _completed_level_name = level_name
    _apply_content()

func _apply_content() -> void:
    if not is_node_ready():
        return
    title_label.text = "Level Complete! ✨"
    subtitle_label.text = "Level %d: %s" % [_completed_level, _completed_level_name]
    stats_label.text = "Moves: %d | Echoes Used: %d" % [GameManager.total_moves, GameManager.echo_count]

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    get_tree().paused = true
    if _completed_level_name == "":
        _completed_level_name = GameManager.get_level_name(_completed_level)
    _apply_content()
    next_button.pressed.connect(_go_next)
    replay_button.pressed.connect(_replay)
    level_select_button.pressed.connect(_level_select)
    var tween := create_tween().set_loops()
    tween.tween_property(title_label, "scale", Vector2(1.05, 1.05), 0.45)
    tween.tween_property(title_label, "scale", Vector2.ONE, 0.45)

func _go_next() -> void:
    get_tree().paused = false
    if GameManager.current_level > GameManager.TOTAL_LEVELS:
        GameManager.go_to_main_menu()
    else:
        GameManager.go_to_level(GameManager.current_level)

func _replay() -> void:
    get_tree().paused = false
    GameManager.go_to_level(_completed_level)

func _level_select() -> void:
    get_tree().paused = false
    GameManager.go_to_level_select()
