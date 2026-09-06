extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.TextBox.emit("走到这一步，你已经分不清驱动自己的是什么了。责任、热爱、恐惧、攀比，它们已经搅拌到了一起，变成一个永不停歇的引擎")
