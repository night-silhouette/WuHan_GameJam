extends TextureRect
var labfix : = LabelFix

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.MessagePopu.connect(MessagePopu)
	modulate.a = 0;

func MessagePopu(message:String):
	labfix.auto_text = message;
	Util.TweenFastToSlow(self,"modulate:a",1,0.25,func(): Util.setTime(1,func(): pass))

func tween_ani():
	Util.setTime(1,func():Util.TweenSlowToFast(self,"modulate:a",0,0.25,func(): pass))
	
