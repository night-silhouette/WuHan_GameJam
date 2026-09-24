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
var preview_finished := false
func _ready() -> void:
	_refresh()
	SignalBus.DataChange.connect(_check)

func _preview_controller() -> Node:
	return get_node_or_null("/root/FinalPreviewController")

func _refresh():
	if _preview_controller() != null:
		button.texture = preload("res://Asset/submit/submit_graduate.png")
		label.text = "1T"
		return
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
	var preview := _preview_controller()
	if preview != null:
		if preview_finished or GameData.GameState != 3:
			return
		var total: int = 0
		for crop_id in [Const.CropId.Apple, Const.CropId.Flower, Const.CropId.Mushroom]:
			total += int(GameData.Invent.items.get(crop_id, 0))
		if total >= 1000000000000:
			preview_finished = true
			preview.call_deferred("finish_current")
		return
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
		if GameData.GameState >= 4:
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
				Const.CropId.Apple:   SignalBus.ChangeSence.emit("res://Code/Scene/end_apple.tscn");
				Const.CropId.Flower:  SignalBus.ChangeSence.emit("res://Code/Scene/end_flower.tscn");
				Const.CropId.Mushroom: SignalBus.ChangeSence.emit("res://Code/Scene/end_mushroom.tscn");	
				pass
		Util.setTime(10,func( ): SignalBus.Ready.emit())
		
		

	
func _next_status_down() -> void:
	var preview := _preview_controller()
	if preview != null:
		preview._show_choices()
	else:
		SignalBus.InventoryRot.emit()
