extends Node


var circle_scene := preload("res://objects/circle/circle.tscn") as PackedScene
var jumper_scene := preload("res://objects/jumper/jumper.tscn") as PackedScene
var player: Jumper

@onready var start := $Start as Position2D
@onready var camera := $Camera as Camera2D


func _ready() -> void:
	randomize()
	new_game()


func new_game() -> void:
	camera.position = start.position
	player = jumper_scene.instantiate() as Jumper
	player.position = start.position
	add_child(player)
	player.captured.connect(_on_jumper_captured)
	spawn_circle(start.position)


func spawn_circle(_position = null) -> void:
	var circle := circle_scene.instantiate() as Circle
	if _position == null:
		var x = randf_range(-150, 150)
		var y = randf_range(-500, -400)
		_position = player.current_circle.position + Vector2(x, y)
	add_child(circle)
	circle.init(_position, 100)


func _on_jumper_captured(circle: Circle) -> void:
	camera.position = circle.position
	circle.capture(player)
	spawn_circle.call_deferred()
