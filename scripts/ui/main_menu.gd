extends Control

const LEVEL_SELECT_SCENE := "res://scenes/ui/level_select.tscn"
const HOW_TO_PLAY_SCENE := "res://scenes/ui/how_to_play.tscn"

@onready var title_label: Label = $MarginContainer/VBox/Title
@onready var play_button: BaseButton = $MarginContainer/VBox/Buttons/PlayButton
@onready var level_select_button: BaseButton = $MarginContainer/VBox/Buttons/LevelSelectButton
@onready var how_to_play_button: BaseButton = $MarginContainer/VBox/Buttons/HowToPlayButton
@onready var settings_button: BaseButton = $MarginContainer/VBox/Buttons/SettingsButton
@onready var settings_note: Label = $SettingsNote

func _ready() -> void:
    get_tree().paused = false
    settings_note.visible = false
    _animate_title()
    _animate_buttons()
    _bind_hover(play_button)
    _bind_hover(level_select_button)
    _bind_hover(how_to_play_button)
    _bind_hover(settings_button)
    play_button.pressed.connect(_on_play_pressed)
    level_select_button.pressed.connect(_on_level_select_pressed)
    how_to_play_button.pressed.connect(_on_how_to_play_pressed)
    settings_button.pressed.connect(_on_settings_pressed)

func _animate_title() -> void:
    var tween := create_tween().set_loops()
    tween.tween_property(title_label, "modulate:a", 1.0, 1.2)
    tween.tween_property(title_label, "modulate:a", 0.8, 1.2)

func _animate_buttons() -> void:
    var buttons := [play_button, level_select_button, how_to_play_button, settings_button]
    for i in range(buttons.size()):
        var button: CanvasItem = buttons[i]
        button.modulate.a = 0.0
        var tween := create_tween()
        tween.tween_interval(0.1 * i)
        tween.tween_property(button, "modulate:a", 1.0, 0.25)

func _bind_hover(button: BaseButton) -> void:
    button.mouse_entered.connect(func(): _tween_button_scale(button, Vector2(1.04, 1.04)))
    button.mouse_exited.connect(func(): _tween_button_scale(button, Vector2.ONE))

func _tween_button_scale(button: BaseButton, target: Vector2) -> void:
    var tween := create_tween()
    tween.tween_property(button, "scale", target, 0.1)

func _on_play_pressed() -> void:
    var level_to_play := mini(GameManager.current_level, GameManager.levels_unlocked)
    level_to_play = clampi(level_to_play, 1, GameManager.TOTAL_LEVELS)
    GameManager.go_to_level(level_to_play)

func _on_level_select_pressed() -> void:
    GameManager.go_to_scene(LEVEL_SELECT_SCENE)

func _on_how_to_play_pressed() -> void:
    GameManager.go_to_scene(HOW_TO_PLAY_SCENE)

func _on_settings_pressed() -> void:
    settings_note.visible = true
    settings_note.modulate.a = 0.0
    var tween := create_tween()
    tween.tween_property(settings_note, "modulate:a", 1.0, 0.15)
    tween.tween_interval(1.2)
    tween.tween_property(settings_note, "modulate:a", 0.0, 0.2)
    tween.finished.connect(func(): settings_note.visible = false)
