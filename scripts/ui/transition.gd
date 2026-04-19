extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

var _is_transitioning: bool = false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    if fade_rect:
        fade_rect.color = Color(0, 0, 0, 0)

func change_scene_to_file(path: String, duration: float = 0.25) -> void:
    if _is_transitioning:
        return
    if not ResourceLoader.exists(path):
        push_warning("Scene path does not exist: " + path)
        return
    await fade_to_black(duration)
    get_tree().paused = false
    get_tree().change_scene_to_file(path)
    await get_tree().process_frame
    await fade_from_black(duration)

func fade_to_black(duration: float = 0.25) -> void:
    _is_transitioning = true
    var tween := create_tween()
    tween.tween_property(fade_rect, "color:a", 1.0, duration)
    await tween.finished

func fade_from_black(duration: float = 0.25) -> void:
    var tween := create_tween()
    tween.tween_property(fade_rect, "color:a", 0.0, duration)
    await tween.finished
    _is_transitioning = false
