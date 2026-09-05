extends Sprite2D


@onready var par: FieldPerform = $".."



@onready var m: TextureButton = $Control
@onready var a: TextureButton = $Control2
@onready var f: TextureButton = $Control3




func _ready() -> void:
	InputManager.Esc.connect(func():
		par.barFlag=false
		visible=par.barFlag)
	
	m.pressed.connect(func():
		Planting(Const.CropId.Mushroom)
		)
	
	a.pressed.connect(func():
		Planting(Const.CropId.Apple)
		)
	
	f.pressed.connect(func():
		Planting(Const.CropId.Flower)
		)
	
func Planting(CropId:Const.CropId):
		get_viewport().set_input_as_handled()
		
		print(111222)
		GameData.F.GetPlot(par.x,par.y).CropId=CropId
		GameData.F.GetPlot(par.x,par.y).growthProgress=0
		par.barFlag=false
		visible=par.barFlag
		
