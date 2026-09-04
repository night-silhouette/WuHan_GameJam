extends Control
class_name FieldPerform

@onready var area_2d: Area2D = $Area2D

@export var x:int 
@export var y:int
@export var level:int=0
@export var cropId:Const.CropId=Const.CropId.Nil


@onready var toolbar: Sprite2D = $Toolbar


var barFlag=false
func _ready() -> void:
	Util.Area2dConnectClick(area_2d,func():
		if Mouse.mos==Mouse.ToolMode.SHOVEL:
			barFlag=!barFlag
			toolbar.visible=barFlag
		)
		
