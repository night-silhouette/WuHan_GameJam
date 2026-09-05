extends Control
@onready var Apple_ui := $Control
@onready var Flower_ui := $Control2
@onready var Mushroom_ui := $Control3

func _ready() -> void:
	_refresh()
	SignalBus.DataChange.connect(_refresh)
		
func _refresh() :
	Apple_ui.update(Util.FormatNumber(GameData.Invent.items.get(Const.CropId.Apple)))
	Flower_ui.update(Util.FormatNumber(GameData.Invent.items.get(Const.CropId.Flower)))
	Mushroom_ui.update(Util.FormatNumber(GameData.Invent.items.get(Const.CropId.Mushroom)))


func _on_texture_button_button_down() -> void:
	$tree.visible = true	




func _on_x_button_button_down() -> void:
	$tree.visible = false
