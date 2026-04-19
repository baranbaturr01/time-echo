extends Control

const PAGE_ICON_PATHS := [
    "res://assets/buttons/PNG/Blue/Default/arrow_basic_n.png",
    "res://assets/sokoban/PNG/Default size/Environment/environment_01.png",
    "res://assets/sokoban/PNG/Default size/Environment/environment_11.png",
    "res://assets/sokoban/PNG/Default size/Crates/crate_10.png",
    "res://assets/sokoban/PNG/Default size/Environment/environment_06.png",
]

const PAGE_TEXTS := [
    "Move with WASD or Arrow Keys. Each move is one step on the grid.",
    "Press R to reset the level. A ghostly Echo of your past self will appear, repeating every move you made. Use this to solve puzzles that require two players!",
    "Stand on buttons to open doors. Some buttons need to stay pressed — use your Echo or push a box onto them.",
    "Push boxes by walking into them. Boxes can hold down buttons and block lasers.",
    "Lasers are instant death! Block them with boxes to create a safe path.",
]

@onready var page_title: Label = $MarginContainer/VBox/PageTitle
@onready var page_text: Label = $MarginContainer/VBox/Panel/MarginContainer/PageText
@onready var icon: TextureRect = $MarginContainer/VBox/Icon
@onready var page_indicator: Label = $MarginContainer/VBox/PageIndicator
@onready var previous_button: BaseButton = $MarginContainer/VBox/Buttons/PreviousButton
@onready var next_button: BaseButton = $MarginContainer/VBox/Buttons/NextButton
@onready var close_button: BaseButton = $MarginContainer/VBox/Buttons/CloseButton

var _current_page: int = 0

func _ready() -> void:
    previous_button.pressed.connect(_go_previous)
    next_button.pressed.connect(_go_next)
    close_button.pressed.connect(func(): GameManager.go_to_main_menu())
    _render_page()

func _go_previous() -> void:
    _current_page = maxi(0, _current_page - 1)
    _render_page()

func _go_next() -> void:
    _current_page = mini(PAGE_TEXTS.size() - 1, _current_page + 1)
    _render_page()

func _render_page() -> void:
    page_title.text = "How to Play"
    page_text.text = PAGE_TEXTS[_current_page]
    page_indicator.text = "Page %d/%d" % [_current_page + 1, PAGE_TEXTS.size()]
    previous_button.disabled = _current_page == 0
    next_button.disabled = _current_page == PAGE_TEXTS.size() - 1
    var path := PAGE_ICON_PATHS[_current_page]
    if ResourceLoader.exists(path):
        icon.texture = load(path)
