class_name Inventory
extends Resource

# 背包里存储的是各种物品的 ID 或数量字典
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
		
		
