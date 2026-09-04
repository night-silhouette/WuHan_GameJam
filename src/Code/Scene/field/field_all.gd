extends Node2D
@onready var grid_container: GridContainer = $GridContainer

var Size:int:
	set(value):
		Size=value
		SizeChange(Size)
var FieldActiveList:Array[FieldPerform]

func _ready() -> void:
	Size=2
	
func _process(delta: float) -> void:
	if GameData.F.currentSize!=Size:
		Size=GameData.F.currentSize
	for f in FieldActiveList:
		if GameData.F.GetPlot(f.x,f.y).Level!=f.level:
			f.level=GameData.F.GetPlot(f.x,f.y).Level
		if f.cropId!=GameData.F.GetPlot(f.x,f.y).CropId:
			f.cropId=GameData.F.GetPlot(f.x,f.y).CropId
	
func SizeChange(s:int)->void:
	var tempList:Array[FieldPerform]=[]
	var children=grid_container.get_children()
	for child in children:
		Util.Revive(child)
	var i=0
	for child in children:
		i+=1
		if i>s*s:
			Util.FakeDeath(child)
			continue
		tempList.append(child)
		
	grid_container.columns=s
	FieldActiveList=tempList
	
	var j=0
	for f in FieldActiveList:
		f.x=j%s
		f.y=j/s
		j+=1

	
		
		
		
		
