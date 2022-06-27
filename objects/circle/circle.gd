class_name Circle
extends Area2D


signal full_orbit

enum Modes { STATIC, LIMITED }

var radius := 80.0
var rotation_speed := PI
var rotation_direction := 0
var mode := Modes.STATIC
var number_orbits: int = 3
var current_orbits := 0
var orbit_start: float
var jumper: Jumper = null

var move_tween: Tween
var move_range := 0.0
var move_speed := 0.0

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
	if jumper:
		_check_orbits()
		update()


func _draw() -> void:
	if mode != Modes.LIMITED:
		return
	
	if jumper:
		var r := ((radius - 40) / number_orbits) * (1 + current_orbits)
		_draw_circle_arc_poly(Vector2.ZERO, r + 10, orbit_start + PI / 2, 
				pivot.rotation + PI / 2, Settings.theme["circle_fill"])


func init(_position: Vector2, level: int = 1) -> void:
	position = _position
	var _mode: int = Settings.rand_weighted([10, level - 1])
	set_mode(_mode)
	
	var move_chance := clampf(level - 10, 0, 9) / 10.0
	if randf() < move_chance:
		move_range = maxf(25.0, 100.0 * randf_range(0.75, 1.26) * move_chance) * [-1, 1][randi_range(0, 1)]
		move_speed = maxf(2.5 - ceil(level / 5.0) * 0.25, 0.75)
	var small_chance := minf(0.9, maxf(0, (level-10) / 20.0))
	if randf() < small_chance:
		radius = maxf(50.0, radius - level * randf_range(0.75, 1.25))
		
	var sprite_radius = sprite.texture.get_size().x / 2
	sprite.scale = Vector2.ONE * radius / (sprite_radius - 60)
	collision.shape = CircleShape2D.new()
	collision.shape.radius = radius
	orbit.position.x = radius + 30
	rotation_direction = [-1, 1][randi_range(0, 1)]
	
	set_tween()
	
	sprite.material = sprite.material.duplicate()
	sprite_effect.material = sprite_effect.material.duplicate()


func set_mode(_mode: Modes) -> void:
	mode = _mode
	var color: Color
	match mode:
		Modes.STATIC:
			orbits_counter.hide()
			color = Settings.theme["circle_static"]
		Modes.LIMITED:
			current_orbits = number_orbits
			orbits_counter.text = str(number_orbits)
			orbits_counter.show()
			color = Settings.theme["circle_limited"]
	sprite.material.set_shader_param("color", color)
	sprite_effect.material.set_shader_param("color", color)


func set_tween() -> void:
	if move_range == 0:
		return
	move_tween = create_tween()
	move_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property(self, "position:x", position.x + move_range, move_speed)
	move_tween.tween_property(self, "position:x", position.x - move_range, move_speed)
	move_tween.set_loops()


func implode() -> void:
	jumper = null
	animation_player.play("implode")
	await animation_player.animation_finished
	queue_free()


func capture(_jumper: Jumper) -> void:
	current_orbits = 0
	jumper = _jumper
	animation_player.play("capture")
	pivot.rotation = (jumper.position - position).angle()
	orbit_start = pivot.rotation


func _check_orbits() -> void:
	if abs(pivot.rotation - orbit_start) > 2 * PI:
		current_orbits += 1
		full_orbit.emit()
		if mode == Modes.LIMITED:
			orbits_counter.text = str(number_orbits - current_orbits)
			if current_orbits >= number_orbits:
				jumper.die()
				jumper = null
				implode()
			if Settings.enable_sound:
				beep.play()
		
		orbit_start = pivot.rotation


func _draw_circle_arc_poly(center, _radius, angle_from, angle_to, color) -> void:
	var nb_points = 32
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	var colors = PackedColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - PI/2
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * _radius)
	draw_polygon(points_arc, colors)
