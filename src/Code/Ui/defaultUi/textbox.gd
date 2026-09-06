extends TextureRect

@onready  var TXT := $Label

func _ready() -> void:
	SignalBus.TextBox.connect(_Textbox)
	TXT.modulate.a = 0
	
func _Textbox(message:String):
	TXT.text = message
	Util.TweenFastToSlow(TXT,"modulate:a",1,0.25,tween_ani)
	$AudioStreamPlayer.play()
	
	
func tween_ani():
	Util.setTime(1.5,func():Util.TweenSlowToFast(TXT,"modulate:a",0,0.25,func(): pass))
	
