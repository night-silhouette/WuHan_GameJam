extends Node2D
@onready var house: Area2D = $Houses/Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var door: Area2D = $Area2D


signal Over

func _ready() -> void:
	Util.Area2dConnectClick(house,func():animation_player.play("house"))
	


	Util.Area2dConnectClick(door,func():animation_player.play("openDoor")
		)
	animation_player.animation_finished.connect(func(t):
		if t=="openDoor":
			Over.emit()
	)
	
