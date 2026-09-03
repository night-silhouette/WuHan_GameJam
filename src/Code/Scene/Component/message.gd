extends TextureRect
var labfix : = LabelFix

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.MessagePopu.connect(MessagePopu)

func MessagePopu(message:String):
	labfix.auto_text = message;
	
