extends Node2D


func _process(delta: float) -> void:
	GameData.F.ForEachUnlockedCrop(func(c:Crop)->void:
		var Value=0
		Value=delta*Const.GrowthSpeed
		if c.IsWatering:
			Value*=Const.WateringBaseSpeed*SkillTree.GetWateringSpeed()
		c.growthProgress+=Value
		
		)
	##腐烂函数
	GameData.Invent.UpdateRot(delta)



	
	

		
