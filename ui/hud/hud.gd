class_name HUD
extends CanvasLayer


@onready var score := $Score as CanvasItem
@onready var score_value := $Score/HBoxContainer/Value as Label
@onready var bonus := $BonusBox/Bonus as Label
@onready var message := $Message as Label
@onready var bonus_animation_player := $BonusAnimationPlayer as AnimationPlayer
@onready var score_animation_player := $ScoreAnimationPlayer as AnimationPlayer
@onready var message_animation_player := $MessageAnimationPlayer as AnimationPlayer


func _ready() -> void:
	message.pivot_offset = message.size / 2


func update_score(value: float) -> void:
	score_value.text = str(value)
	score_animation_player.play("score")

func update_bonus(value: int) -> void:
	bonus.text = str(value) + "x"
	if value > 1:
		bonus_animation_player.play("bonus")


func show_message(text: String) -> void:
	message.text = text
	message_animation_player.play("show_message")


func hide() -> void:
	score.hide()


func show() -> void:
	score.show()
