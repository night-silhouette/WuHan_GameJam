extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.TextBox.emit("和世界牵起丝线，对现状的不满让你卷入一场场拔河，心甘情愿地被拉扯。
或许这绳索本是和世界的牵起的红线，毕竟，你的生命力不息地燃烧着")
