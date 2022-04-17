class_name Screens
extends Node


signal start_game

var current_screen = null
var sound_buttons := { true: preload("res://ui/assets/textures/buttons/audio_on.png"),
		false: preload("res://ui/assets/textures/buttons/audio_off.png") }
var music_buttons := { true: preload("res://ui/assets/textures/buttons/music_on.png"),
		false: preload("res://ui/assets/textures/buttons/music_off.png") }

@onready var tree := get_tree()
@onready var title_screen := $TitleScreen as BaseScreen
@onready var settings_screen := $SettingsScreen as BaseScreen
@onready var about_screen := $AboutScreen as BaseScreen
@onready var game_over_screen := $GameOverScreen as BaseScreen
@onready var click := $Click as AudioStreamPlayer

func _ready() -> void:
	_register_buttons()
	_change_screen(title_screen)


func _on_button_pressed(button: BaseButton) -> void:
	match button.name:
		StringName("Home"):
			_change_screen(title_screen)
		StringName("Play"):
			_change_screen(null)
			@warning_ignore(redundant_await) # TODO: remove warning ignore after fix: https://github.com/godotengine/godot/issues/56265
			await tree.create_timer(0.5).timeout
			start_game.emit()
		StringName("Settings"):
			_change_screen(settings_screen)
		StringName("Sound"):
			Settings.enable_sound = !Settings.enable_sound
			button.texture_normal = sound_buttons[Settings.enable_sound]
			Settings.save_settings()
		StringName("Music"):
			Settings.enable_music = !Settings.enable_music
			button.texture_normal = music_buttons[Settings.enable_music]
			Settings.save_settings()
		StringName("About"):
			_change_screen(about_screen)
		
	if Settings.enable_sound:
		click.play()

func _register_buttons() -> void:
	var buttons := get_tree().get_nodes_in_group("buttons") as Array[BaseButton]
	for button in buttons:
		button.pressed.connect(self._on_button_pressed.bind(button))
		match button.name:
			StringName("Sound"):
				button.texture_normal = sound_buttons[Settings.enable_sound]
			StringName("Music"):
				button.texture_normal = music_buttons[Settings.enable_music]


func _change_screen(new_screen: BaseScreen) -> void:
	if current_screen:
		current_screen.dissapier()
		@warning_ignore(redundant_await) # TODO: remove warning ignore after fix: https://github.com/godotengine/godot/issues/56265
		await current_screen.tween.finished
		
	current_screen = new_screen
	
	if new_screen:
		current_screen.appear()
		@warning_ignore(redundant_await) # TODO: remove warning ignore after fix: https://github.com/godotengine/godot/issues/56265
		await current_screen.tween.finished


func game_over() -> void:
	_change_screen(game_over_screen)
