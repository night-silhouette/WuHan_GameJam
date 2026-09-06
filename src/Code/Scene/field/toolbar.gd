extends Sprite2D


@onready var par: FieldPerform = $".."



@onready var m: TextureButton = $Control
@onready var a: TextureButton = $Control2
@onready var f: TextureButton = $Control3


@onready var AudioDig: AudioStreamPlayer2D = $"../dig"


func _ready() -> void:
	InputManager.Esc.connect(func():
		par.barFlag=false
		visible=par.barFlag)
	
	m.pressed.connect(func():
		Planting(Const.CropId.Mushroom)
		AudioDig.play()
		)
	
	a.pressed.connect(func():
		Planting(Const.CropId.Apple)
		AudioDig.play()
		)
	
	f.pressed.connect(func():
		Planting(Const.CropId.Flower)
		AudioDig.play()
		)
	
func Planting(CropId:Const.CropId):
		get_viewport().set_input_as_handled()
		GameData.F.GetPlot(par.x,par.y).CropId=CropId
		GameData.F.GetPlot(par.x,par.y).growthProgress=0
		par.barFlag=false
		visible=par.barFlag
		
