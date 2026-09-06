extends Node2D
@onready var house: Area2D = $Houses/Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var door: Area2D = $Area2D


func _ready() -> void:
	Util.Area2dConnectClick(house,func():animation_player.play("house"))
	
	Util.Area2dConnectClick(door,func():animation_player.play("openDoor")
		)
	animation_player.animation_finished.connect(func(t):
		if t=="openDoor":
			SignalBus.Over.emit()
			$Door/AudioStreamPlayer.play()
	)



func _on_texture_button_button_down() -> void:
	SignalBus.TextBox.emit("你以为捡到了额外的薪水，凑了过去，其实这是欢乐豆。")


func _on_texture_button_2_button_down() -> void:
	SignalBus.TextBox.emit("它的足迹散布在无数企业的收件箱。")
