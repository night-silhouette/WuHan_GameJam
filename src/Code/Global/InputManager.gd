extends Node

signal Esc
signal Q
signal E
signal W

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ESC"): 
		Esc.emit()
	if Input.is_action_just_pressed("Q"): 
		Q.emit()
	if Input.is_action_just_pressed("E"): 
		E.emit()
	if Input.is_action_just_pressed("W"): 
		W.emit()
		
		
		
		
		
		
