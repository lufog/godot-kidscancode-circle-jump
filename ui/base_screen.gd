class_name BaseScreen
extends CanvasLayer


const TRANS_EFFECT_DURATION := 0.5
const TRANS_EFFECT_OFFSET_START := 0.0
const TRANS_EFFECT_OFFSET_END := 500.0

var tween: Tween

@onready var tree := get_tree()


func appear() -> void:
	tree.call_group("buttons", "set_disabled", false)
	tween = create_tween()
	tween.tween_property(self, "offset:x", TRANS_EFFECT_OFFSET_START, TRANS_EFFECT_DURATION) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)


func dissapier() -> void:
	tree.call_group("buttons", "set_disabled", true)
	tween = create_tween()
	tween.tween_property(self, "offset:x", TRANS_EFFECT_OFFSET_END, TRANS_EFFECT_DURATION) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
