extends Sprite2D


@onready var par: FieldPerform = $".."


@onready var m: Area2D = $Mushroom/Area2D
@onready var f: Area2D = $Flower/Area2D
@onready var a: Area2D = $Apple/Area2D


func _ready() -> void:
	InputManager.Esc.connect(func():
		par.barFlag=false
		visible=par.barFlag)
	
	Util.Area2dConnectClick(m,func():
		GameData.F.GetPlot(par.x,par.y).CropId=Const.CropId.Mushroom
		GameData.F.GetPlot(par.x,par.y).growthProgress=0
		par.barFlag=false
		visible=par.barFlag
		)
	Util.Area2dConnectClick(f,func():
		GameData.F.GetPlot(par.x,par.y).CropId=Const.CropId.Flower
		GameData.F.GetPlot(par.x,par.y).growthProgress=0
		par.barFlag=false
		visible=par.barFlag
		)
	Util.Area2dConnectClick(a,func():
		GameData.F.GetPlot(par.x,par.y).CropId=Const.CropId.Apple
		GameData.F.GetPlot(par.x,par.y).growthProgress=0
		par.barFlag=false
		visible=par.barFlag
		)
	
