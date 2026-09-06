extends TextureRect
@onready var labfix : = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.MessagePopu.connect(MessagePopu)
	$".".position.y = 460

func MessagePopu(message:String):
	labfix.text = message;
	Util.TweenFastToSlow(self,"position:y",265,0.25,tween_ani)

func tween_ani():
	Util.setTime(1,func():Util.TweenSlowToFast(self,"position:y",460,0.25,func(): pass))
	
