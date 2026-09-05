extends Node



var F:Field
var Invent:Inventory
var GameState :int = 0;

func _ready() -> void:
	F=Field.new()
	F.ForEachUnlockedCrop(func(c:Crop)->void:print(c.CropId))
	Invent=Inventory.new()
	Invent.LoadGame()
	
	#//技能树点出田扩容
	SkillTree.filed_expand.connect(func():F.ExpandFarm())
		
		
		
