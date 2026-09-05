extends Control
@onready var Apple_ui := $Control
@onready var Flower_ui := $Control2
@onready var Mushroom_ui := $Control3
@onready var Set_ui:=$Set_sence

func _ready() -> void:
	_refresh()
	SignalBus.DataChange.connect(_refresh)
	$tree.visible= false
	InputManager.Tab.connect(_on_texture_button_button_down)
	InputManager.Esc.connect(_on_x_button_button_down)
	SignalBus.Setback.connect(setback)
func _refresh() :
	Apple_ui.update(Util.FormatNumber(GameData.Invent.items.get(Const.CropId.Apple)))
	Flower_ui.update(Util.FormatNumber(GameData.Invent.items.get(Const.CropId.Flower)))
	Mushroom_ui.update(Util.FormatNumber(GameData.Invent.items.get(Const.CropId.Mushroom)))


func _on_texture_button_button_down() -> void:
	$tree.visible = true	
	$x_button.visible = true	
	


func _on_x_button_button_down() -> void:
	$tree.visible = false
	$x_button.visible = false


func _on_set_button_down() -> void:
	#34 516
	Util.TweenFastToSlow(Set_ui,"position:x",34,0.25,func(): pass )
	
func setback():
	
	Util.TweenFastToSlow(Set_ui,"position:x",516,0.25,func(): pass )
	
