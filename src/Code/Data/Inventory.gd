class_name Inventory
extends Resource
# 游戏三个阶段的腐烂间隔（秒）：阶段1=120s, 阶段2=60s, 阶段3=30s
const time := [120.0, 60.0, 30.0]
# 背包里存储的是各种物品的 ID 或数量字典
var rot_timer: float = 0.0
@export var items: Dictionary = {
	Const.CropId.Flower: 0,
	Const.CropId.Apple: 0,
	Const.CropId.Mushroom: 0
}
# 添加物品
func AddItem(itemId: int, amount: int = 1) -> void:
	if items.has(itemId):
		items[itemId] += amount
	else:
		items[itemId] = amount
	SignalBus.DataChange.emit()
	print("背包更新，当前物品: ", items)

# 减少物品
func RemoveItem(itemId: int, amount: int = 1) -> void:
	if items.has(itemId):
		items[itemId] -= amount
		if items[itemId] < 0:
			items[itemId] = 0
	SignalBus.DataChange.emit()
	print("背包更新，当前物品: ", items)

func UpdateRot(delta: float) -> void:
	var stage: int = GameData.game_stage  # 当前游戏阶段 1/2/3
	rot_timer += delta

	# 没到当前阶段的腐烂间隔
	if rot_timer < time[stage - 1]:
		return

	rot_timer = 0.0

	# 到时间，对所有有库存的作物扣除
	for crop_id in [Const.CropId.Flower, Const.CropId.Apple, Const.CropId.Mushroom]:
		var current: int = items.get(crop_id, 0)
		if current <= 0:
			continue

		# 腐烂率 = 基础率(游戏阶段) × 该作物抗性倍率
		var rate: float = SkillTree.get_rot_rate(crop_id, stage)

		var lost: int = ceil(current * rate)
		if lost <= 0:
			continue

		items[crop_id] = max(0, current - lost)
		SignalBus.DataChange.emit()
		SignalBus.InventoryRot.emit(crop_id, lost)

# 存盘（保存当前资源实例到本地文件）
func SaveGame() -> void:
	@warning_ignore("return_value_discarded")
	ResourceSaver.save(self, "user://inventory.tres")
	print("背包数据保存成功！")

# 读盘（从本地文件加载，并将数据同步到当前对象的 items 中）
func LoadGame() -> void:
	if ResourceLoader.exists("user://inventory.tres"):
		var loaded = ResourceLoader.load("user://inventory.tres") as Inventory
		if loaded:
			items = loaded.items # 将加载出来的物品字典赋给当前实例
			print("背包数据加载成功！")
	else:
		print("未找到存档文件，使用默认空背包")
		
		
