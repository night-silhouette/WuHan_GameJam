extends Sprite2D




func _ready() -> void:
	InputManager.Esc.connect(func():Mouse.change_tool_mode(Mouse.ToolMode.NORMAL))
	
