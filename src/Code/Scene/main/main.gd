extends Node2D


func _process(delta: float) -> void:
	GameData.F.ForEachUnlockedCrop(func(c:Crop)->void:
		c.growthProgress+=delta*Const.GrowthSpeed
		print(c.Level)
		)
