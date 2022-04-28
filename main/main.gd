extends Node


var circle_scene := preload("res://objects/circle/circle.tscn") as PackedScene
var jumper_scene := preload("res://objects/jumper/jumper.tscn") as PackedScene
var player: Jumper

var _score: int
var score: 
	get:
		return _score
	
	set(value):
		_score = value
		if _score > 1 and _score > highscore and !new_highscore:
			hud.show_message("New record!")
			new_highscore = true
		hud.update_score(_score)
		if (_score > 0) and (_score % Settings.circles_per_level == 0):
			level += 1
			hud.show_message("Level %s" % str(level))

var _bonus: int
var bonus:
	get:
		return _bonus
	
	set(value):
		_bonus = value
		hud.update_bonus(_bonus)

var highscore := 0
var new_highscore := false
var level: int
var fade_music: Tween

@onready var tree := get_tree()
@onready var screens := $Screens as Screens
@onready var hud := $HUD as HUD
@onready var start := $Start as Position2D
@onready var camera := $Camera as Camera2D
@onready var music := $Music as AudioStreamPlayer


func _ready() -> void:
	randomize()
	load_score()
	hud.hide()


func _new_game() -> void:
	new_highscore = false
	score = 0
	bonus = 0
	camera.position = start.position
	player = jumper_scene.instantiate() as Jumper
	player.position = start.position
	add_child(player)
	player.captured.connect(_on_jumper_captured)
	player.died.connect(_on_jumper_died)
	_spawn_circle(start.position)
	hud.show()
	hud.show_message("Go!")
	
	if Settings.enable_music:
		music.volume_db = 0
		music.play()


func _spawn_circle(_position = null) -> void:
	var circle := circle_scene.instantiate() as Circle
	if _position == null:
		var x = randf_range(-150, 150)
		var y = randf_range(-500, -400)
		_position = player.current_circle.position + Vector2(x, y)
	add_child(circle)
	circle.full_orbit.connect(self._set_bonus.bind(1))
	circle.init(_position, level)


func _on_jumper_captured(circle: Circle) -> void:
	camera.position = circle.position
	circle.capture(player)
	_spawn_circle.call_deferred()
	score += 1 * bonus
	bonus += 1


func _on_jumper_died() -> void:
	if score > highscore:
		highscore = score
		save_score()
	tree.call_group("circles", "implode")
	screens.game_over(score, highscore)
	hud.hide()
	
	if Settings.enable_music:
		_fade_music()


func _set_bonus(value) -> void:
	bonus = value


func save_score() -> void:
	var file = File.new()
	file.open(Settings.SCORE_FILE, File.WRITE)
	file.store_var(highscore)
	file.close()


func load_score() -> void:
	var file = File.new()
	if file.file_exists(Settings.SCORE_FILE):
		file.open(Settings.SCORE_FILE, File.READ)
		highscore = file.get_var()
	file.close()


func _fade_music() -> void:
	fade_music = create_tween()
	fade_music.tween_property(music, "volume_db", -50.0, 1.0) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN)
	@warning_ignore(redundant_await)
	await fade_music.finished
	music.stop()
