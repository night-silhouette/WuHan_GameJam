class_name Crop
extends RefCounted


var IsUnlocked: bool = false   # 是否已解锁
var CropId:Const.CropId  = Const.CropId.Nil        # 作物ID
var growthProgress: float = 0.0: # 生长进度
	set(value):
		growthProgress=value
		@warning_ignore("integer_division")
		if value<Const.GrowthLevel/2:
			Level=0
		if Const.GrowthLevel>value and value>Const.GrowthLevel/2:
			Level=1
		if Const.GrowthLevel<=value:
			Level=2
			
			
var Level: int = 0 # 0,1,2  生长阶段


func ReSet()->void:
	growthProgress=0
	Level=0
	CropId=Const.CropId.Nil 
