extends Node2D

const ECHO_SCENE: PackedScene = preload("res://scenes/echo.tscn")
const META_KEY := "recorded_histories_by_level"

@onready var player: Node = get_node_or_null("Player")
@onready var echoes_container: Node2D = get_node_or_null("Echoes")

func _ready() -> void:
    if not GameManager.has_meta(META_KEY):
        GameManager.set_meta(META_KEY, {})

    if player and player.has_signal("player_reset"):
        var callback := Callable(self, "_on_player_reset")
        if not player.is_connected("player_reset", callback):
            player.connect("player_reset", callback)

    _spawn_saved_echoes()

func _level_key() -> String:
    return scene_file_path

func _get_histories() -> Array:
    var data: Dictionary = GameManager.get_meta(META_KEY, {})
    var histories = data.get(_level_key(), [])
    if histories is Array:
        return histories.duplicate(true)
    return []

func _set_histories(histories: Array) -> void:
    var data: Dictionary = GameManager.get_meta(META_KEY, {})
    data[_level_key()] = histories
    GameManager.set_meta(META_KEY, data)

func _on_player_reset(history: Array) -> void:
    if history.is_empty():
        return
    var histories := _get_histories()
    histories.append(history.duplicate())
    _set_histories(histories)

func _spawn_saved_echoes() -> void:
    if player == null or echoes_container == null:
        return

    for history in _get_histories():
        if history is Array:
            var echo := ECHO_SCENE.instantiate()
            echo.position = player.position
            echo.move_queue = history.duplicate()
            echoes_container.add_child(echo)
            GameManager.register_echo()
            GameManager.echo_spawned.emit(echo)
