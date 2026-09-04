extends Control
@onready var Area: Area2D = $Area2D
@onready var button: Sprite2D = $Button

@export var BUTTON_NORMAL: Texture2D = preload("uid://dqb2aqy18mg6j")
@export var BUTTON_HOVER: Texture2D = preload("uid://d0yx1oj0ky1eo")
@export var BUTTON_PRESS: Texture2D = preload("uid://bebkf3y2ggt4q")


func _ready() -> void:
	Area.mouse_entered.connect(func():Util.SetNodeTexture(button,BUTTON_HOVER))
	Area.mouse_exited.connect(func():Util.SetNodeTexture(button,BUTTON_NORMAL))
	Util.Area2dConnectClick(Area,func():Util.SetNodeTexture(button,BUTTON_PRESS))
	Util.Area2dConnectRelease(Area,func():Util.SetNodeTexture(button,BUTTON_HOVER))
