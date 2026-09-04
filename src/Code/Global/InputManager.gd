extends Node

signal Esc

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ESC"): 
		Esc.emit()
