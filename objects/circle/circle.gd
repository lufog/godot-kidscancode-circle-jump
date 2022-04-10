class_name Circle
extends Area2D


const ORBIT_OFFSET = 25
enum Modes { STATIC, LIMITED }

var radius: float
var rotation_speed := PI
var rotation_direction := 0
var mode := Modes.STATIC
var number_orbits: int = 3
var current_orbits := 0
var orbit_start: float
var jumper: Jumper = null

@onready var sprite := $Sprite as Sprite2D
@onready var sprite_effect := $SpriteEffect as Sprite2D
@onready var collision := $Collision as CollisionShape2D
@onready var pivot := $Pivot as Node2D
@onready var orbit := $Pivot/Orbit as Position2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var orbits_counter := $OrbitsCounter as Label
@onready var beep := $Beep as AudioStreamPlayer


func _process(delta: float) -> void:
	pivot.rotation += rotation_direction * rotation_speed * delta
	if mode == Modes.LIMITED and jumper:
		_check_orbits()
		update()


func _draw() -> void:
	if jumper:
		var r := ((radius - 50) / number_orbits) * (1 + number_orbits - current_orbits)
		_draw_circle_arc_poly(Vector2.ZERO, r + 10, orbit_start + PI / 2, 
				pivot.rotation + PI / 2, Settings.theme["circle_fill"])


func init(_position: Vector2, _radius: int, _mode := Modes.LIMITED) -> void:
	position = _position
	radius = _radius
	var sprite_radius = sprite.texture.get_size().x / 2
	sprite.scale = Vector2.ONE * radius / sprite_radius
	collision.shape = CircleShape2D.new()
	collision.shape.radius = radius
	orbit.position.x = radius + ORBIT_OFFSET
	rotation_direction = [-1, 1][randi_range(0, 1)]
	set_mode(_mode)
	
	sprite.material = sprite.material.duplicate()
	sprite_effect.material = sprite.material


func set_mode(_mode: Modes) -> void:
	mode = _mode
	var color: Color
	match mode:
		Modes.STATIC:
			orbits_counter.hide()
			color = Settings.theme["circle_static"]
		Modes.LIMITED:
			current_orbits = number_orbits
			orbits_counter.text = str(current_orbits)
			orbits_counter.show()
			color = Settings.theme["circle_limited"]
	sprite.material.set_shader_param("color", color)


func implode() -> void:
	animation_player.play("implode")
	@warning_ignore(redundant_await) # TODO: remove warning ignore after fix: https://github.com/godotengine/godot/issues/56265
	await animation_player.animation_finished
	queue_free()


func capture(_jumper: Jumper) -> void:
	jumper = _jumper
	animation_player.play("capture")
	pivot.rotation = (jumper.position - position).angle()
	orbit_start = pivot.rotation


func _check_orbits() -> void:
	if abs(pivot.rotation - orbit_start) > 2 * PI:
		current_orbits -= 1
		orbits_counter.text = str(current_orbits)
		if current_orbits == 0:
			jumper.die()
			jumper = null
			implode()
		orbit_start = pivot.rotation
		
		if Settings.enable_sound:
			beep.play()


func _draw_circle_arc_poly(center, _radius, angle_from, angle_to, color) -> void:
	var nb_points = 32
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	var colors = PackedColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - PI/2
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * _radius)
	draw_polygon(points_arc, colors)
