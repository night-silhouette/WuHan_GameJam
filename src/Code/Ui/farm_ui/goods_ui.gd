extends Control

@export var texture1 : Texture
var num

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureRect.texture = texture1
	
	
func update(num:String):
	$Label.text = num
	return 0
	
