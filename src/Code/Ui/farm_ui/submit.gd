extends Control
@export var baby : Texture
@export var gaokao : Texture
@export var graduate : Texture
var cost := [1000000,1000000000,1000000000000]

@onready var button := $TextureButton/Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	match GameData.GameState:
		0:
			button.texture = baby
		1:
			button.texture = gaokao
		2:
			button.texture = graduate
		

func _on_texture_button_button_down() -> void:
	var sum = GameData.Invent.items.get(0) + GameData.Invent.items.get(1) + GameData.Invent.items.get(2)
	if sum > cost[GameData.GameState]:
		var index = sum - cost[GameData.GameState];
		
	
	
		
		
