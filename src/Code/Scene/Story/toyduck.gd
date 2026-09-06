extends Sprite2D

@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

func _ready() -> void:
	Util.Area2dConnectClick(area_2d,func():
		animation_player.play("鸭子")
		)
