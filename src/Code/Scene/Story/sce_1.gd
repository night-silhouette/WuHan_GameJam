extends Node2D
@onready var area_2d: Area2D = $Door/Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
signal Over
func _ready() -> void:
	Util.Area2dConnectClick(area_2d,func():animation_player.play("openDoor")
		)
	animation_player.animation_finished.connect(func(t):
		if t=="openDoor":
			Over.emit()
	)
	
