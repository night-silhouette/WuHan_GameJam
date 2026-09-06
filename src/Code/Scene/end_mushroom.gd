extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.TextBox.emit("你停下来，起锅烧油翻炒调味，大口吞噬意义；任由其余人被痛苦或虚无撕裂")
