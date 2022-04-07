class_name BaseScreen
extends CanvasLayer


const TRANS_EFFECT_DURATION := 0.5
const TRANS_EFFECT_OFFSET_START := 0.0
const TRANS_EFFECT_OFFSET_END := 500.0

@onready var tween: Tween


#func _unhandled_input(event: InputEvent) -> void:
#	var just_pressed = event.is_pressed() and not event.is_echo()
#
#	if Input.is_key_pressed(KEY_1):
#		appear()
#
#	if Input.is_key_pressed(KEY_2):
#		dissapier()


func appear() -> void:
	tween = create_tween()
	tween.tween_property(self, "offset:x", TRANS_EFFECT_OFFSET_START, TRANS_EFFECT_DURATION) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)


func dissapier() -> void:
	tween = create_tween()
	tween.tween_property(self, "offset:x", TRANS_EFFECT_OFFSET_END, TRANS_EFFECT_DURATION) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
