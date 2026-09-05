extends Node2D


func _process(delta: float) -> void:
	GameData.F.ForEachUnlockedCrop(func(c:Crop)->void:
		var Value=0
		Value=delta*Const.GrowthSpeed
		if SignalBus.IsWatering:
			Value*=Const.WateringBaseSpeed
		c.growthProgress+=Value
		)
