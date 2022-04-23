extends Node


const SETTINGS_FILE = "user://settings.save"
const SCORE_FILE = "user://highscore.save"

var enable_sound := true
var enable_music := true

var circles_per_level := 5

var color_schemes := {
	"NEON1": {
		'background': Color8(0, 0, 0),
		'player_body': Color8(203, 255, 0),
		'player_trail': Color8(204, 0, 255),
		'circle_fill': Color8(255, 0, 110),
		'circle_static': Color8(0, 255, 102),
		'circle_limited': Color8(204, 0, 255)
	},
	"NEON2": {
		'background': Color8(0, 0, 0),
		'player_body': Color8(246, 255, 0),
		'player_trail': Color8(255, 255, 255),
		'circle_fill': Color8(255, 0, 110),
		'circle_static': Color8(151, 255, 48),
		'circle_limited': Color8(127, 0, 255)
	},
	"NEON3": {
		'background': Color8(0, 0, 0),
		'player_body': Color8(255, 0, 187),
		'player_trail': Color8(255, 148, 0),
		'circle_fill': Color8(255, 148, 0),
		'circle_static': Color8(170, 255, 0),
		'circle_limited': Color8(204, 0, 255)
	}
}

var theme = color_schemes["NEON1"]


func _ready() -> void:
	load_settings()


func save_settings():
	var f = File.new()
	f.open(SETTINGS_FILE, File.WRITE)
	f.store_var(enable_sound)
	f.store_var(enable_music)
	f.close()


func load_settings():
	var f = File.new()
	if f.file_exists(SETTINGS_FILE):
		f.open(SETTINGS_FILE, File.READ)
		enable_sound = f.get_var()
		enable_music = f.get_var()
		f.close()


static func rand_weighted(weights: Array):
	var sum := 0
	for weight in weights:
		sum += weight
	var num := randi_range(0, sum)
	for i in weights.size():
		if num < weights[i]:
			return i
		num -= weights[i]
	
	return 0
