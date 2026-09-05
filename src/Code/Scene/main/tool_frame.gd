extends Sprite2D


func TweenTo(m:Mouse.ToolMode):
	if m==Mouse.ToolMode.NORMAL:
		self.visible=false
		return
	visible=true
	var posDic:Dictionary={
		Mouse.ToolMode.SICKLE:Vector2(121,329),
		Mouse.ToolMode.SHOVEL:Vector2(121,219),
		Mouse.ToolMode.WATERING_CAN:Vector2(121,439),
	}
	Util.TweenFastToSlow(self,"position",posDic[m],0.7,func():pass)
	
func _ready() -> void:
	Mouse.mosChange.connect(func():TweenTo(Mouse.mos))


	
	
	
