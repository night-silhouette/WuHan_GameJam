extends Sprite2D
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	Util.Area2dConnectClick(area_2d,func():Mouse.change_tool_mode(Mouse.ToolMode.SHOVEL))
	
	
	
