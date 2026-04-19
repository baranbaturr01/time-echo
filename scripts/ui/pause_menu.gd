extends Control

@onready var resume_button: BaseButton = $CenterContainer/Panel/MarginContainer/VBox/ResumeButton
@onready var restart_button: BaseButton = $CenterContainer/Panel/MarginContainer/VBox/RestartButton
@onready var level_select_button: BaseButton = $CenterContainer/Panel/MarginContainer/VBox/LevelSelectButton
@onready var main_menu_button: BaseButton = $CenterContainer/Panel/MarginContainer/VBox/MainMenuButton

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    resume_button.pressed.connect(_on_resume)
    restart_button.pressed.connect(_on_restart)
    level_select_button.pressed.connect(_on_level_select)
    main_menu_button.pressed.connect(_on_main_menu)

func _on_resume() -> void:
    get_tree().paused = false
    queue_free()

func _on_restart() -> void:
    get_tree().paused = false
    GameManager.go_to_level(GameManager.current_level)

func _on_level_select() -> void:
    get_tree().paused = false
    GameManager.go_to_level_select()

func _on_main_menu() -> void:
    get_tree().paused = false
    GameManager.go_to_main_menu()
