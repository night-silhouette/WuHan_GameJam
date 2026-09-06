extends TextureRect

@onready  var TXT := $Label

func _ready() -> void:
	SignalBus.TextBox.connect(_Textbox)
	TXT.modulate.a = 0
	
func _Textbox(message:String):
	TXT.text = message
	Util.TweenFastToSlow(TXT,,)
	
	
