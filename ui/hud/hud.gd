class_name HUD
extends CanvasLayer


@onready var score := $Score as CanvasItem
@onready var score_value := $Score/HBoxContainer/Value as Label
@onready var message := $Message as Label
@onready var animation_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	message.pivot_offset = message.size / 2


func update_score(value: int) -> void:
	score_value.text = str(value)


func show_message(text: String) -> void:
	message.text = text
	animation_player.play("show_message")


func hide() -> void:
	score.hide()


func show() -> void:
	score.show()
