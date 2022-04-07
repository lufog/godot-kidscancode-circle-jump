class_name Jumper
extends Area2D


signal captured(area: Area2D)
signal died


var velocity: Vector2
var jump_speed := 1000
var current_circle = null
var trail_length := 25

@onready var trail := $Trail/Points as Line2D


func _physics_process(delta: float) -> void:
	if trail.points.size() > trail_length:
		trail.remove_point(0)
	
	trail.add_point(position)
	
	if current_circle:
		transform = current_circle.orbit.global_transform
	else:
		position += velocity * delta


func _unhandled_input(event: InputEvent) -> void:
	if (current_circle and (event is InputEventScreenTouch) and event.pressed):
		jump()


func _on_area_entered(circle: Circle) -> void:
	current_circle = circle
	velocity = Vector2.ZERO
	captured.emit(current_circle)


func _on_screen_exited() -> void:
	if !current_circle:
		die()


func jump() -> void:
	current_circle.implode()
	current_circle = null
	velocity = transform.x * jump_speed


func die() -> void:
	print("died")
	died.emit()
	current_circle = null
	queue_free()



