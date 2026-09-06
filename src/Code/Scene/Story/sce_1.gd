extends Node2D
@onready var area_2d: Area2D = $Door/Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	Util.Area2dConnectClick(area_2d,func():animation_player.play("openDoor")
		)
	animation_player.animation_finished.connect(func(t):
		if t=="openDoor":
			SignalBus.Over.emit()
			$Door/AudioStreamPlayer.play()
	)


func _on_rabbit_button_down() -> void:
	SignalBus.TextBox.emit("小孩子会好奇为什么是两只角而不是三只。")


func _on_book_button_down() -> void:
	SignalBus.TextBox.emit("里面故事早已不再适合你，但在无数个白天，你还是会习惯性地翻开它。")
