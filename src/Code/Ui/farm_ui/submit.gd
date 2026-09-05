extends Control
@export var baby : Texture
@export var gaokao : Texture
@export var graduate : Texture
var cost := [1000000,1000000000,1000000000000]

@onready var button := $TextureButton/Sprite2D
@export var label := Label
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	_refresh()

func _refresh():
	
		
	match GameData.GameState:
		0:
			button.texture = baby
			label.text = Util.FormatNumber(cost[0])
		1:
			button.texture = gaokao
			label.text = Util.FormatNumber(cost[1])
		2:
			button.texture = graduate
			label.text = Util.FormatNumber(cost[2])
			
	
	
		
func _check():
	var sum = GameData.Invent.items.get(0) + GameData.Invent.items.get(1) + GameData.Invent.items.get(2)
	if sum > cost[GameData.GameState]:
		var index = sum - cost[GameData.GameState];
		GameData.Invent.RemoveItem(0,GameData.Invent.items.get(0))
		GameData.Invent.RemoveItem(1,GameData.Invent.items.get(1))
		GameData.Invent.RemoveItem(2,GameData.Invent.items.get(2))
		GameData.Invent.AddItem(0,index)
