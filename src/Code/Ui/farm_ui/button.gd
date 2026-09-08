extends Button



func _on_button_down() -> void:
	SignalBus.StageRain.emit(20,40,79)
