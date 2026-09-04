## 对外方法是 ExpandFarm # 扩展农田（例如从 2x2 变成 3x3）  GetPlot(x: int, y: int）# 获取指定坐标的格子 ForEachUnlockedCrop(callback: Callable) -> void 遍历所有当前已解锁激活的格子，并对每个格子上的作物执行传入的回疡函数
class_name Field
extends Node

const MAX_GRID_SIZE: int = 7
var FarmGrid: Array[Array] = [] # 存储 Array[Array[Crop]]

# 当前解锁的大小，初始为 2 (即 2x2)
var currentSize: int = 2:
	
	set(value):
		currentSize = clampi(value, 2, MAX_GRID_SIZE)
		_updateUnlockedPlots()

func _init() -> void:
	_initializeGrid()

# 初始化整个 7x7 的网格
func _initializeGrid() -> void:
	FarmGrid.clear()
	for x in range(MAX_GRID_SIZE):
		var row: Array = []
		for y in range(MAX_GRID_SIZE):
			var cropPlot:Crop= Crop.new()
			# 初始时，如果在 2x2 范围内则设为已解锁
			if x < 2 and y < 2:
				cropPlot.IsUnlocked = true
			row.append(cropPlot)
		FarmGrid.append(row)

# 根据当前尺寸更新解锁状态
func _updateUnlockedPlots() -> void:
	for x:int in range(MAX_GRID_SIZE):
		for y:int in range(MAX_GRID_SIZE):
			var cropPlot = FarmGrid[x][y]
			if x < currentSize and y < currentSize:
				cropPlot.isUnlocked = true

# 扩展农田（例如从 2x2 变成 3x3）
func ExpandFarm() -> void:
	if currentSize < MAX_GRID_SIZE:
		currentSize += 1
		print("农田已成功扩展至: ", currentSize, "x", currentSize)

# 获取指定坐标的格子
func GetPlot(x: int, y: int) -> Crop:
	if x >= 0 and x < MAX_GRID_SIZE and y >= 0 and y < MAX_GRID_SIZE:
		return FarmGrid[x][y]
	return null
	
	
# 遍历所有当前已解锁激活的格子，并对每个格子上的作物执行传入的回疡函数
func ForEachUnlockedCrop(callback: Callable) -> void:
	for x:int in range(MAX_GRID_SIZE):
		for y:int in range(MAX_GRID_SIZE):
			var cropPlot: Crop = FarmGrid[x][y]
			if cropPlot and cropPlot.IsUnlocked:
				callback.call(cropPlot)
				
				

	
	
