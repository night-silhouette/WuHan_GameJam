extends Node2D
@onready var grid_container: GridContainer = $GridContainer

var Size:int:
	set(value):
		Size=value
		SizeChange(Size)
		
var FieldActiveList:Array[FieldPerform]


	
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
		child.visible=true
	var i=0
	for child in children:
		i+=1
		if i>s*s:
			child.visible=false
			continue
		tempList.append(child)
		
	grid_container.columns=s
	FieldActiveList=tempList
	
	var j=0
	for f in FieldActiveList:
		f.x=j%s
		f.y=j/s
		j+=1

func RangeOp(Obj:Vector2,ex:int)->Array[Vector2]:
	var res:Array[Vector2]=[]
	var s:=GameData.F.currentSize
	for i in range(-ex,ex+1):
		for j in range(-ex,ex+1):
			if i+Obj.x<0||i+Obj.x>Size:
				continue
			if j+Obj.y<0||j+Obj.y>Size:
				continue
			if i==0&&j==0:
				continue
			res.push_back(Vector2(i+Obj.x,j+Obj.y))
	return res
	
	
func _ready() -> void:
	Size=2
	
	var children=grid_container.get_children()
	for child:FieldPerform in children:
		child.SignEntering.connect(func(obj:FieldPerform):pass)
		child.SignExit.connect(func(obj:FieldPerform):pass)
		
		child.SignSickle.connect(func(obj:FieldPerform):
			var OpList:=RangeOp(Vector2(obj.x,obj.y),SkillTree.GetHavestRange()-1)
			for c:FieldPerform in FieldActiveList:
				var pos:=Vector2(c.x,c.y)
				if pos in OpList:
					c.sickle()
					
			
			)
		child.SignWatering1.connect(func(obj:FieldPerform):pass)
		child.SignWatering2.connect(func(obj:FieldPerform):pass)
		
		
		
		
		
		
		
