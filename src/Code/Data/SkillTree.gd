const GOODS_COUNT := 3

# 初始等级
var value_level := [0, 0, 0]
var field_level := [1, 1, 1]
var rot_level := [0, 0, 0]

# 共享等级
var quantity_level := 0
var watering_level := 0

##获取价值
func GetValue(CropId: int) -> float:
	
	var good:int = CropId - 1
	var own_level :int = value_level[good]

	var other_level := 0
	for i in GOODS_COUNT:
		if i != good:
			other_level += value_level[i]

	return pow(2.0, own_level) * pow(1.15, other_level)
	

func upgrade_value(good: int) -> float:
	var cost := get_value_upgrade_cost(good)

	value_level[good] += 1

	return GetValue(good)
	
##获取升级费用
func get_value_upgrade_cost(good: int) -> float:
	var level :int = value_level[good]

	return 9.95 * pow(4.275, level)
	
	
##获取数量
func GetPlantNum():
	var index =  randf()
	var dic = get_quantity_probability()
	if index < dic.get("one"):
		return 1;
	elif index < dic.get("one")+dic.get("two"):
		return 2;
	else :
		return 3;
	
	
##概率	
func get_quantity_probability() -> Dictionary:
	var p2 :float= min(quantity_level * 0.04, 0.40)
	var p3 :float= min(quantity_level * 0.02, 0.20)

	var p1 :float = 1.0 - p2 - p3

	return {
		"one": p1,
		"two": p2,
		"three": p3
	}
	
##期望产量
func get_expected_quantity() -> float:
	var p := get_quantity_probability()

	return (
		p["one"] * 1.0
		+ p["two"] * 2.0
		+ p["three"] * 3.0
	)
##升级花费
func get_quantity_upgrade_cost() -> float:
	return 198.9 * pow(2.8, quantity_level)
	
##获取信息	
func upgrade_quantity() -> Dictionary:
	var cost := get_quantity_upgrade_cost()

	quantity_level += 1

	return {
		"level": quantity_level,
		"expected_quantity": get_expected_quantity(),
		"next_cost": get_quantity_upgrade_cost()
	}



##水壶速度
func GetWateringSpeed() -> float:
	return pow(2.0, 0.25 * watering_level)
	
##水壶大小
func GetWateringRange() -> int:
	return min(watering_level + 1, 7)
	

func get_watering_upgrade_cost() -> float:
	return 497.3 * pow(2.2, watering_level)
	
func upgrade_watering() -> Dictionary:
	var cost := get_watering_upgrade_cost()

	watering_level += 1

	return {
		"level": watering_level,
		"speed": GetWateringSpeed(),
		"range": GetWateringRange(),
		"next_cost": get_watering_upgrade_cost()
	}
	
##获取田地数量
func GetFieldCount(good: int) -> int:
	return field_level[good] * field_level[good]
	
	
func get_field_upgrade_cost(good: int) -> float:
	var level : int = field_level[good]

	return 99.5 * pow(2.8, level - 1)
	
func upgrade_field(good: int) -> Dictionary:
	var cost := get_field_upgrade_cost(good)

	if field_level[good] >= 7:
		return {
			"level": 7,
			"size": 7,
			"count": 49,
			"next_cost": INF
		}

	field_level[good] += 1

	return {
		"level": field_level[good],
		"size": field_level[good],
		"count": GetFieldCount(good),
		"next_cost": get_field_upgrade_cost(good)
	}
	
	
	
	
func GetRotUpgradeCost(good: int) -> float:
	var level :int = rot_level[good]

	return 49.7 * pow(1.5, level)
	
	
func get_rot_multiplier(good: int) -> float:
	return pow(0.9, rot_level[good])
	
func upgrade_rot_resistance(good: int) -> Dictionary:
	var cost := GetRotUpgradeCost(good)

	rot_level[good] += 1

	return {
		"level": rot_level[good],
		"rot_multiplier": get_rot_multiplier(good),
		"next_cost": GetRotUpgradeCost(good)
	}


func get_rot_interval(stage: int) -> float:
	match stage:
		1:
			return 30.0
		2:
			return 20.0
		3:
			return 10.0

	return 30.0
	
func get_base_rot_rate(stage: int) -> float:
	match stage:
		1:
			return 0.05
		2:
			return 0.06
		3:
			return 0.08

	return 0.05
	
func get_rot_rate(good: int, stage: int) -> float:
	return (
		get_base_rot_rate(stage)
		* get_rot_multiplier(good)
	)
	
