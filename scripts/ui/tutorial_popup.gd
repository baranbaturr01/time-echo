extends Control

signal dismissed

@onready var message_label: Label = $CenterContainer/Panel/MarginContainer/VBox/Message
@onready var ok_button: BaseButton = $CenterContainer/Panel/MarginContainer/VBox/OkButton

var _pending_message: String = "Tutorial"

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    get_tree().paused = true
    ok_button.pressed.connect(_dismiss)
    set_message(_pending_message)

func set_message(message: String) -> void:
    _pending_message = message
    if message_label:
        message_label.text = message

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        accept_event()
        _dismiss()
    elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
        accept_event()
        _dismiss()

func _dismiss() -> void:
    if not is_inside_tree():
        return
    get_tree().paused = false
    dismissed.emit()
    queue_free()
