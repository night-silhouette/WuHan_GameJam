extends Control
@onready var Apple_ui := $Control
@onready var Flower_ui := $Control2
@onready var Mushroom_ui := $Control3

func _ready() -> void:
	_refresh()
		
func _refresh() :
	Apple_ui.update(Util.FormatNumber(GameData.Invent.items.get(Const.CropId.Apple)))
	Flower_ui.update(Util.FormatNumber(GameData.Invent.items.get(Const.CropId.Flower)))
	Mushroom_ui.update(Util.FormatNumber(GameData.Invent.items.get(Const.CropId.Mushroom)))
