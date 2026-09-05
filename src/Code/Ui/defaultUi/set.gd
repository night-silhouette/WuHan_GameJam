extends TextureButton
@export var normal: Texture
@export var hover: Texture
@export var press: Texture
@onready var button:= $Sprite2D

func _ready() -> void:
	mouse_entered.connect(_hover)
	
	
	
func _hover():
	button.texture = hover 


func _on_button_up() -> void:
	button.texture = normal 


func _on_button_down() -> void:
	button.texture = press 
