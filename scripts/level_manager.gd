extends Node2D

const ECHO_SCENE: PackedScene = preload("res://scenes/echo.tscn")
const ECHO_SPAWN_EFFECT_SCENE: PackedScene = preload("res://scenes/effects/echo_spawn_effect.tscn")
const SOKOBAN_TILESET: TileSet = preload("res://assets/sokoban/sokoban_tileset.tres")
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

@onready var player: Node = get_node_or_null("Player")
@onready var echoes_container: Node2D = get_node_or_null("Echoes")
@onready var floor_layer: TileMapLayer = get_node_or_null("Floor")
@onready var walls_layer: TileMapLayer = get_node_or_null("Walls")

func _ready() -> void:
    if not GameManager.has_meta(META_KEY):
        GameManager.set_meta(META_KEY, {})

    if player and player.has_signal("player_reset"):
        var callback := Callable(self, "_on_player_reset")
        if not player.is_connected("player_reset", callback):
            player.connect("player_reset", callback)

    _setup_tilemap_layers()
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
            _spawn_echo_effect(echo.global_position)

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

    var level_name := scene_file_path.get_file()
    var interior_walls: Array = ROOM_WALLS_BY_LEVEL.get(level_name, [])
    for cell in interior_walls:
        walls_layer.set_cell(cell, WALL_TILE_SOURCE_ID, WALL_TILE_COORDS, 0)

func _spawn_echo_effect(spawn_position: Vector2) -> void:
    if ECHO_SPAWN_EFFECT_SCENE == null:
        return
    var effect := ECHO_SPAWN_EFFECT_SCENE.instantiate()
    effect.global_position = spawn_position
    add_child(effect)
