extends Node



var F:Field
var Invent:Inventory
var GameState :int = 0;

func _ready() -> void:
	F=Field.new()
	F.ForEachUnlockedCrop(func(c:Crop)->void:print(c.CropId))
	Invent=Inventory.new()
	Invent.LoadGame()
	
		
		
		
