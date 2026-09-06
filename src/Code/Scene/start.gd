extends Node2D

func _unhandled_input(event: InputEvent) -> void:
	# 任意键按下（键盘/鼠标点击/手柄都算，鼠标移动不算）
	if event.is_pressed():
		_enter_game()

func _enter_game() -> void:
	# 防止重复触发
	set_process_unhandled_input(false)
	# 切换到游戏场景（用你之前的场景管理器）
	SignalBus.ChangeSence.emit("res://Code/Scene/status/chlid_sence.tscn")
	SignalBus.ChangeUi.emit("res://Code/Ui/defaultUi/default_ui.tscn")
