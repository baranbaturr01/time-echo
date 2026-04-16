extends Node

# Game state
var current_level: int = 1
var max_echoes: int = 3
var echo_count: int = 0
var is_resetting: bool = false
var turn_step: int = 0

# Signals
signal echo_spawned(echo)
signal level_completed
signal level_reset
signal turn_advanced(step: int)

func _ready():
	pass

func reset_level():
	is_resetting = true
	echo_count = 0
	turn_step = 0
	emit_signal("level_reset")
	get_tree().reload_current_scene()

func advance_turn():
	turn_step += 1
	emit_signal("turn_advanced", turn_step)

func complete_level():
	emit_signal("level_completed")
	current_level += 1
	# Load next level
	var next_level_path = "res://scenes/levels/level_" + str(current_level) + ".tscn"
	if ResourceLoader.exists(next_level_path):
		get_tree().change_scene_to_file(next_level_path)
	else:
		print("Game Complete! No more levels.")

func register_echo():
	echo_count += 1

func can_spawn_echo() -> bool:
	return echo_count < max_echoes
