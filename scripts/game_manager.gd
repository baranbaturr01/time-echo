extends Node

const TOTAL_LEVELS: int = 5
const MAIN_MENU_SCENE := "res://scenes/ui/main_menu.tscn"
const LEVEL_SELECT_SCENE := "res://scenes/ui/level_select.tscn"
const TRANSITION_SCENE: PackedScene = preload("res://scenes/ui/transition.tscn")
const LEVEL_NAMES := {
    1: "First Steps",
    2: "Time Split",
    3: "Weight of the Past",
    4: "Double Take",
    5: "Laser Focus",
}

# Game state
var current_level: int = 1
var max_echoes: int = 3
var echo_count: int = 0
var is_resetting: bool = false
var turn_step: int = 0
var levels_unlocked: int = 1
var levels_completed: Array = []
var tutorials_seen: Array = []
var total_moves: int = 0
var last_completed_level: int = 0

# Signals
signal echo_spawned(echo)
signal level_completed
signal level_reset
signal turn_advanced(step: int)
signal game_state_changed

var _transition: CanvasLayer
var _completing_level: bool = false

func _ready() -> void:
    if LEVEL_NAMES.size() != TOTAL_LEVELS:
        push_warning("LEVEL_NAMES count does not match TOTAL_LEVELS.")
    _ensure_transition()

func _ensure_transition() -> void:
    if _transition and is_instance_valid(_transition):
        return
    if TRANSITION_SCENE == null:
        return
    _transition = TRANSITION_SCENE.instantiate()
    if _transition:
        get_tree().root.call_deferred("add_child", _transition)

func reset_level() -> void:
    var tree := get_tree()
    is_resetting = true
    echo_count = 0
    turn_step = 0
    total_moves = 0
    _completing_level = false
    emit_signal("level_reset")
    emit_signal("game_state_changed")
    var current_scene := tree.current_scene
    if current_scene and current_scene.scene_file_path != "":
        _change_scene(current_scene.scene_file_path)
    else:
        tree.reload_current_scene()

func advance_turn() -> void:
    turn_step += 1
    emit_signal("turn_advanced", turn_step)
    emit_signal("game_state_changed")

func register_move() -> void:
    total_moves += 1
    emit_signal("game_state_changed")

func complete_level() -> void:
    if _completing_level:
        return
    _completing_level = true

    var completed_level := current_level
    last_completed_level = completed_level
    if completed_level not in levels_completed:
        levels_completed.append(completed_level)

    current_level += 1
    if current_level > levels_unlocked:
        levels_unlocked = clampi(current_level, 1, TOTAL_LEVELS)

    emit_signal("level_completed")
    emit_signal("game_state_changed")

func register_echo() -> void:
    echo_count += 1
    emit_signal("game_state_changed")

func can_spawn_echo() -> bool:
    return echo_count < max_echoes

func has_seen_tutorial(tutorial_id: String) -> bool:
    return tutorial_id in tutorials_seen

func mark_tutorial_seen(tutorial_id: String) -> void:
    if tutorial_id not in tutorials_seen:
        tutorials_seen.append(tutorial_id)

func get_level_name(level_num: int = current_level) -> String:
    return LEVEL_NAMES.get(level_num, "Unknown")

func go_to_main_menu() -> void:
    get_tree().paused = false
    _completing_level = false
    _change_scene(MAIN_MENU_SCENE)

func go_to_level_select() -> void:
    get_tree().paused = false
    _completing_level = false
    _change_scene(LEVEL_SELECT_SCENE)

func go_to_scene(path: String) -> void:
    get_tree().paused = false
    _completing_level = false
    _change_scene(path)

func go_to_level(level_num: int) -> void:
    current_level = clampi(level_num, 1, TOTAL_LEVELS)
    echo_count = 0
    turn_step = 0
    total_moves = 0
    is_resetting = false
    _completing_level = false
    _clear_level_histories(current_level)
    emit_signal("game_state_changed")
    var path := "res://scenes/levels/level_" + str(current_level) + ".tscn"
    if ResourceLoader.exists(path):
        _change_scene(path)

func _change_scene(path: String) -> void:
    _ensure_transition()
    if _transition and _transition.has_method("change_scene_to_file"):
        _transition.call("change_scene_to_file", path)
    else:
        get_tree().change_scene_to_file(path)

func _clear_level_histories(level_num: int) -> void:
    if not has_meta("recorded_histories_by_level"):
        return
    var data: Dictionary = get_meta("recorded_histories_by_level", {})
    var key := "res://scenes/levels/level_" + str(level_num) + ".tscn"
    if data.has(key):
        data.erase(key)
        set_meta("recorded_histories_by_level", data)
