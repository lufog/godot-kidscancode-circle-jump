extends Node


signal game_started

var current_screen = null

@onready var tree := get_tree()
@onready var title_screen := $TitleScreen as BaseScreen
@onready var settings_screen := $SettingsScreen as BaseScreen
@onready var gameover_screen := $GameOverScreen as BaseScreen


func _ready() -> void:
	_register_buttons()
	_change_screen(title_screen)


func _on_button_pressed(_name: String) -> void:
	match _name:
		"Home":
			_change_screen(title_screen)
		"Play":
			_change_screen(null)
			game_started.emit()
		"Settings":
			_change_screen(settings_screen)


func _change_screen(new_screen: BaseScreen) -> void:
	if current_screen:
		current_screen.dissapier()
		await current_screen.tween.finished
		
	current_screen = new_screen
	
	if new_screen:
		current_screen.appear()
		await current_screen.tween.finished

func _register_buttons() -> void:
	var buttons := get_tree().get_nodes_in_group("buttons") as Array[TextureButton]
	for button in buttons:
		button.pressed.connect(self._on_button_pressed.bind(button.name))
