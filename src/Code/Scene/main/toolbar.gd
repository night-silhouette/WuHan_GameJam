extends Sprite2D




func _ready() -> void:
	InputManager.Esc.connect(func():Mouse.change_tool_mode(Mouse.ToolMode.NORMAL))
	InputManager.Q.connect(func():Mouse.change_tool_mode(Mouse.ToolMode.SHOVEL))
	InputManager.W.connect(func():Mouse.change_tool_mode(Mouse.ToolMode.SICKLE))
	InputManager.E.connect(func():Mouse.change_tool_mode(Mouse.ToolMode.WATERING_CAN))
