extends Node2D

const ECHO_SCENE: PackedScene = preload("res://scenes/echo.tscn")
const ECHO_SPAWN_EFFECT_SCENE: PackedScene = preload("res://scenes/effects/echo_spawn_effect.tscn")
const SOKOBAN_TILESET: TileSet = preload("res://assets/sokoban/sokoban_tileset.tres")
const LEVEL_COMPLETE_SCENE: PackedScene = preload("res://scenes/ui/level_complete.tscn")
const TUTORIAL_POPUP_SCENE: PackedScene = preload("res://scenes/ui/tutorial_popup.tscn")
const META_KEY := "recorded_histories_by_level"
const FLOOR_TILE_SOURCE_ID := 0
const FLOOR_TILE_COORDS := Vector2i(12, 6)
const WALL_TILE_SOURCE_ID := 0
const WALL_TILE_COORDS := Vector2i(7, 7)
const ROOM_SIZE := Vector2i(10, 8)
const ROOM_WALLS_BY_LEVEL := {
    "level_1.tscn": [Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3)],
    "level_2.tscn": [Vector2i(3, 5), Vector2i(4, 4)],
    "level_3.tscn": [Vector2i(4, 5), Vector2i(3, 4)],
    "level_4.tscn": [Vector2i(3, 5), Vector2i(4, 3), Vector2i(5, 3)],
    "level_5.tscn": [Vector2i(5, 5), Vector2i(4, 3), Vector2i(6, 3)],
}

var _level_complete_shown: bool = false
var _level_1_move_count: int = 0

@onready var player: Node = get_node_or_null("Player")
@onready var echoes_container: Node2D = get_node_or_null("Echoes")
@onready var floor_layer: TileMapLayer = get_node_or_null("Floor")
@onready var walls_layer: TileMapLayer = get_node_or_null("Walls")

func _ready() -> void:
    if not GameManager.has_meta(META_KEY):
        GameManager.set_meta(META_KEY, {})

    if player and player.has_signal("player_reset"):
        var reset_callback := Callable(self, "_on_player_reset")
        if not player.is_connected("player_reset", reset_callback):
            player.connect("player_reset", reset_callback)

    if player and player.has_signal("player_moved"):
        var moved_callback := Callable(self, "_on_player_moved")
        if not player.is_connected("player_moved", moved_callback):
            player.connect("player_moved", moved_callback)

    if not GameManager.level_completed.is_connected(_on_level_completed):
        GameManager.level_completed.connect(_on_level_completed)

    _setup_tilemap_layers()
    _spawn_saved_echoes()
    _setup_level_tutorial_hooks()
    _show_level_start_tutorials()

func _exit_tree() -> void:
    if GameManager.level_completed.is_connected(_on_level_completed):
        GameManager.level_completed.disconnect(_on_level_completed)

func _level_key() -> String:
    return scene_file_path

func _level_filename() -> String:
    return scene_file_path.get_file()

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

    var histories := _get_histories()
    for history in histories:
        if history is Array:
            var echo := ECHO_SCENE.instantiate()
            echo.position = player.position
            echo.move_queue = history.duplicate()
            echoes_container.add_child(echo)
            GameManager.register_echo()
            GameManager.echo_spawned.emit(echo)
            _spawn_echo_effect(echo.global_position)

    if _level_filename() == "level_2.tscn" and not histories.is_empty():
        _show_tutorial_once(
            "level_2_echo_spawn",
            "👻 Your Echo repeats your previous actions. Now find a new path to the exit while your Echo holds the button!"
        )

func _setup_tilemap_layers() -> void:
    if floor_layer == null or walls_layer == null or SOKOBAN_TILESET == null:
        return

    floor_layer.tile_set = SOKOBAN_TILESET
    walls_layer.tile_set = SOKOBAN_TILESET
    floor_layer.clear()
    walls_layer.clear()

    for x in range(ROOM_SIZE.x):
        for y in range(ROOM_SIZE.y):
            floor_layer.set_cell(Vector2i(x, y), FLOOR_TILE_SOURCE_ID, FLOOR_TILE_COORDS, 0)

    for x in range(ROOM_SIZE.x):
        walls_layer.set_cell(Vector2i(x, 0), WALL_TILE_SOURCE_ID, WALL_TILE_COORDS, 0)
        walls_layer.set_cell(Vector2i(x, ROOM_SIZE.y - 1), WALL_TILE_SOURCE_ID, WALL_TILE_COORDS, 0)
    for y in range(1, ROOM_SIZE.y - 1):
        walls_layer.set_cell(Vector2i(0, y), WALL_TILE_SOURCE_ID, WALL_TILE_COORDS, 0)
        walls_layer.set_cell(Vector2i(ROOM_SIZE.x - 1, y), WALL_TILE_SOURCE_ID, WALL_TILE_COORDS, 0)

    var interior_walls: Array = ROOM_WALLS_BY_LEVEL.get(_level_filename(), [])
    for cell in interior_walls:
        walls_layer.set_cell(cell, WALL_TILE_SOURCE_ID, WALL_TILE_COORDS, 0)

func _spawn_echo_effect(spawn_position: Vector2) -> void:
    if ECHO_SPAWN_EFFECT_SCENE == null:
        return
    var effect := ECHO_SPAWN_EFFECT_SCENE.instantiate()
    effect.global_position = spawn_position
    add_child(effect)

func _on_level_completed() -> void:
    if _level_complete_shown:
        return
    _level_complete_shown = true

    if LEVEL_COMPLETE_SCENE == null:
        return

    var completed_level := maxi(GameManager.current_level - 1, 1)
    var panel := LEVEL_COMPLETE_SCENE.instantiate()
    add_child(panel)
    if panel.has_method("setup"):
        panel.setup(completed_level, GameManager.get_level_name(completed_level))

func _show_level_start_tutorials() -> void:
    match _level_filename():
        "level_1.tscn":
            _show_tutorial_once("level_1_start", "🎮 Use WASD or Arrow Keys to move")
        "level_2.tscn":
            _show_tutorial_once("level_2_start", "🔴 The door is locked. You need to press the button to open it.")
        "level_3.tscn":
            _show_tutorial_once("level_3_start", "📦 Push the box onto the button to keep the door open permanently!")
        "level_4.tscn":
            _show_tutorial_once("level_4_start", "👻👻 Some puzzles need multiple Echoes. Press R again to create another!")
        "level_5.tscn":
            _show_tutorial_once("level_5_start", "⚠️ Lasers are deadly! Push a box to block the beam.")

func _setup_level_tutorial_hooks() -> void:
    if _level_filename() != "level_2.tscn":
        return
    var level_button := get_node_or_null("Button") as Area2D
    if level_button:
        if not level_button.body_entered.is_connected(_on_level_2_button_entered):
            level_button.body_entered.connect(_on_level_2_button_entered)
        if not level_button.body_exited.is_connected(_on_level_2_button_exited):
            level_button.body_exited.connect(_on_level_2_button_exited)

func _on_level_2_button_entered(body: Node) -> void:
    if body and body.is_in_group("player"):
        _show_tutorial_once("level_2_button_press", "✅ The button opens the door! But it closes when you leave...")

func _on_level_2_button_exited(body: Node) -> void:
    if body and body.is_in_group("player"):
        _show_tutorial_once("level_2_button_leave", "💡 Press R to RESET. Your past self (Echo) will replay your moves!")

func _on_player_moved(_direction: String) -> void:
    if _level_filename() != "level_1.tscn":
        return
    _level_1_move_count += 1
    if _level_1_move_count >= 2:
        _show_tutorial_once("level_1_goal", "🎯 Reach the glowing exit to complete the level!")

func _show_tutorial_once(tutorial_id: String, message: String) -> void:
    if GameManager.has_seen_tutorial(tutorial_id):
        return
    if TUTORIAL_POPUP_SCENE == null:
        GameManager.mark_tutorial_seen(tutorial_id)
        return

    var popup := TUTORIAL_POPUP_SCENE.instantiate() as Node
    add_child(popup)
    if popup.has_method("set_message"):
        popup.call("set_message", message)
    if popup.has_signal("dismissed"):
        popup.connect("dismissed", func(): GameManager.mark_tutorial_seen(tutorial_id), CONNECT_ONE_SHOT)
