extends Sprite2D
@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
var lock = false
func _ready() -> void:
	Util.Area2dConnectClick(area_2d,func():
		if !lock : 
			animation_player.play("book")
			lock = true
			SignalBus.TextBox.emit("翻开后，会掉出干透的银杏叶，露出歪扭的小字。")
		)
	
	
