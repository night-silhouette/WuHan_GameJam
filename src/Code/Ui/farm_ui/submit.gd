extends Control
@export var baby : Texture
@export var gaokao : Texture
@export var graduate : Texture
var cost := [1000000,1000000000,1000000000000]

@onready var button := $TextureButton/Sprite2D
@export var label := Label
# Called when the node enters the scene tree for the first time.
var apple: = 0
var flower:  = 0
var mushroom: = 0
func _ready() -> void:
	_refresh()
	SignalBus.DataChange.connect(_check)

func _refresh():
	match GameData.GameState:
		1:
			button.texture = baby
			label.text = Util.FormatNumber(cost[0])
		2:
			button.texture = gaokao
			label.text = Util.FormatNumber(cost[1])
		3:
			button.texture = graduate
			label.text = Util.FormatNumber(cost[2])
			
	
	
		
func _check():
	var a = GameData.Invent.items.get(Const.CropId.Apple, 0)
	var f = GameData.Invent.items.get(Const.CropId.Flower, 0)
	var m = GameData.Invent.items.get(Const.CropId.Mushroom, 0)
	var sum = a + f + m

	if sum > cost[GameData.GameState]:
		# 累计（用于最终结局判定）
		apple += a
		flower += f
		mushroom += m

		# 每一阶段结束：按本阶段提交比例下一场混合雨
		SignalBus.StageRain.emit(a, f, m)

		# 结算：清空 + 保留溢出 + 推进阶段
		var index = sum - cost[GameData.GameState]
		GameData.Invent.RemoveItem(Const.CropId.Apple, a)
		GameData.Invent.RemoveItem(Const.CropId.Flower, f)
		GameData.Invent.RemoveItem(Const.CropId.Mushroom, m)
		GameData.Invent.AddItem(Const.CropId.Apple, index)
		GameData.GameState += 1

		# 最终阶段结束后做结局判定
		if GameData.GameState >= 3:
			var counts := {
				Const.CropId.Apple: apple,
				Const.CropId.Flower: flower,
				Const.CropId.Mushroom: mushroom,
			}
			var best: int = counts.keys()[0]
			for c in counts:
				if counts[c] > counts[best]:
					best = c
			match best:
				Const.CropId.Apple:   SignalBus.ChangeSence();
				Const.CropId.Flower:  SignalBus.ChangeSence();
				Const.CropId.Mushroom: SignalBus.ChangeSence();	

func _next_status_down() -> void:
	SignalBus.InventoryRot.emit()
