extends Control

@onready var apple: TextureButton = $apple
@onready var flower: TextureButton = $flower
@onready var mashroom: TextureButton = $mashroom
@onready var apple_value: TextureButton = $apple_value
@onready var flower_value: TextureButton = $flower_value
@onready var mashroom_value: TextureButton = $mashroom_value
@onready var auto_havest: TextureButton = $auto_havest
@onready var auto_plant: TextureButton = $auto_plant
@onready var auto_water: TextureButton = $auto_water
@onready var water: TextureButton = $water
@onready var havest: TextureButton = $havest
@onready var plant: TextureButton = $plant
@onready var quantity: TextureButton = $quantity
@onready var field: TextureButton = $field
@onready var apple_rot: TextureButton = $apple_rot
@onready var flower_rot: TextureButton = $flower_rot
@onready var mashroom_rot: TextureButton = $mashroom_rot

# 货币图标
@onready var tex_apple: Texture2D = preload("res://Asset/plants/apple.png")
@onready var tex_flower: Texture2D = preload("res://Asset/plants/flower.PNG")
@onready var tex_mushroom: Texture2D = preload("res://Asset/plants/mushroom.png")
var _current_hover: TextureButton = null

func _ready() -> void:
	init_dots()
	refresh_dots()
	_connect_hover() 
	
func _connect_hover() -> void:
	for dot in [apple, flower, mashroom, apple_value, flower_value, mashroom_value,
				auto_havest, auto_plant, auto_water, water, havest, plant,
				quantity, field, apple_rot, flower_rot, mashroom_rot]:
		dot.mouse_entered.connect(_on_dot_hover.bind(dot))
		dot.mouse_exited.connect(_on_dot_exit.bind(dot))

# 某个 dot 被 hover：先把其他所有 dot 的 tooltip 强制隐藏，再显示当前的
func _on_dot_hover(dot: TextureButton) -> void:
	_hide_all_tooltips_except(dot)
	_show_tooltip(dot)
	_current_hover = dot

# 鼠标离开 dot
func _on_dot_exit(dot: TextureButton) -> void:
	if _current_hover == dot:
		_current_hover = null
	_hide_tooltip(dot)

# 隐藏除了 except_dot 之外所有 dot 的 tooltip
func _hide_all_tooltips_except(except_dot: TextureButton) -> void:
	for dot in [apple, flower, mashroom, apple_value, flower_value, mashroom_value,
				auto_havest, auto_plant, auto_water, water, havest, plant,
				quantity, field, apple_rot, flower_rot, mashroom_rot]:
		if dot != except_dot:
			_hide_tooltip(dot)

func _show_tooltip(dot: TextureButton) -> void:
	var tb := dot.get_node_or_null("Textbox")
	if tb:
		Util.TweenFastToSlow(tb, "modulate:a", 1.0, 0.25, func(): pass)

func _hide_tooltip(dot: TextureButton) -> void:
	var tb := dot.get_node_or_null("Textbox")
	if tb:
		Util.TweenFastToSlow(tb, "modulate:a", 0.0, 0.15, func(): pass)
var s = SkillTree


# 初始化所有 dot 的：描述(下一级效果)、等级、货币图标、消耗
func init_dots() -> void:
	

	# ========== 解锁类 ==========
	apple.set_dot_data("解锁苹果种植", 1 if s.apple else 0, tex_apple, 0)
	flower.set_dot_data("解锁花朵种植", 1 if s.flower else 0, tex_apple, 2)
	mashroom.set_dot_data("解锁蘑菇种植", 1 if s.mashroom else 0, tex_apple, 2)

	# ========== 价值类（下一级价值 = 当前 ×2） ==========
	apple_value.set_dot_data(
		"苹果价值 ×%.2f" % (s.GetValue(Const.CropId.Apple) * 2.0),
		s.value_level[1], tex_apple, s.get_value_upgrade_cost(Const.CropId.Apple))

	flower_value.set_dot_data(
		"花朵价值 ×%.2f" % (s.GetValue(Const.CropId.Flower) * 2.0),
		s.value_level[0], tex_flower, s.get_value_upgrade_cost(Const.CropId.Flower))

	mashroom_value.set_dot_data(
		"蘑菇价值 ×%.2f" % (s.GetValue(Const.CropId.Mushroom) * 2.0),
		s.value_level[2], tex_mushroom, s.get_value_upgrade_cost(Const.CropId.Mushroom))

	# ========== 自动类 ==========
	auto_havest.set_dot_data("自动收割", 1 if s.auto_havest else 0, tex_mushroom, s.auto_havest_cost)
	auto_plant.set_dot_data("自动种植", 1 if s.auto_plant else 0, tex_flower, s.auto_plant_cost)
	auto_water.set_dot_data("自动浇水", 1 if s.auto_water else 0, tex_apple, s.auto_water_cost)
	auto_water.unit2.texture = tex_flower
	auto_water.unit2.visible = true
	auto_water.unit3.texture = tex_mushroom
	auto_water.unit3.visible = true

	# ========== 浇水 ==========
	var w_max : int = s.watering_level >= 7
	water.set_dot_data(
		"浇水速度 ×%.2f\n范围 %d" % [pow(2.0, 0.25 * (s.watering_level + 1)), min(s.watering_level + 2, 7)],
		-1 if w_max else s.watering_level, tex_apple, 0 if w_max else s.get_watering_upgrade_cost())
	water.unit2.texture = tex_flower
	water.unit2.visible = true
	water.unit3.texture = tex_mushroom
	water.unit3.visible = true
	
	# ========== 收割 ==========
	var h_max :int = s.havesting_level >= 7
	havest.set_dot_data(
		"收割范围 %d" % min(s.havesting_level + 2, 7),
		-1 if h_max else s.havesting_level, tex_flower, 0 if h_max else s.get_field_upgrade_cost())

	# ========== 种植 ==========
	var p_max :int= s.planting_level >= 7
	plant.set_dot_data(
		"种植范围 %d" % min(s.planting_level + 2, 7),
		-1 if p_max else s.planting_level, tex_mushroom, 0 if p_max else s.get_palent_upgrade_cost())

	# ========== 产量（下一级概率分布） ==========
	var q_lv :float= s.quantity_level + 1
	var q_p2 :float= min(q_lv * 0.04, 0.40)
	var q_p3 :float= min(q_lv * 0.02, 0.20)
	var q_p1 :float= 1.0 - q_p2 - q_p3
	quantity.set_dot_data(
		"产量概率:\n1个 %.0f%%\n2个 %.0f%%\n3个 %.0f%%" % [q_p1 * 100, q_p2 * 100, q_p3 * 100],
		s.quantity_level, tex_apple, s.get_quantity_upgrade_cost() / 3.0)
	quantity.unit2.texture = tex_flower
	quantity.unit2.visible = true
	quantity.unit3.texture = tex_mushroom
	quantity.unit3.visible = true
	# ========== 田地 ==========
	var f_max :int= s.field_level >= 7
	field.set_dot_data(
		"田地数量 %d" % ((s.field_level + 1) * (s.field_level + 1)),
		-1 if f_max else s.field_level, tex_apple, 0 if f_max else s.get_field_upgrade_cost())
	field.unit2.texture = tex_flower
	field.unit2.visible = true
	field.unit3.texture = tex_mushroom
	field.unit3.visible = true
	# ========== 腐烂抗性（下一级倍率 = 当前 ×0.9） ==========
	apple_rot.set_dot_data(
		"苹果腐烂倍率 ×%.2f" % pow(0.9, s.rot_level[1] + 1),
		s.rot_level[1], tex_flower, s.GetRotUpgradeCost(Const.CropId.Apple))

	flower_rot.set_dot_data(
		"花朵腐烂倍率 ×%.2f" % pow(0.9, s.rot_level[0] + 1),
		s.rot_level[0], tex_mushroom, s.GetRotUpgradeCost(Const.CropId.Flower))

	mashroom_rot.set_dot_data(
		"蘑菇腐烂倍率 ×%.2f" % pow(0.9, s.rot_level[2] + 1),
		s.rot_level[2], tex_apple, s.GetRotUpgradeCost(Const.CropId.Mushroom))

# 刷新所有 dot 的 light 显隐
func refresh_dots() -> void:
	var s = SkillTree

	_set_light(apple, s.apple)
	_set_light(flower, s.flower)
	_set_light(mashroom, s.mashroom)
	_set_light(auto_havest, s.auto_havest)
	_set_light(auto_plant, s.auto_plant)
	_set_light(auto_water, s.auto_water)

	_set_light(apple_value, s.value_level[1] != 0)
	_set_light(flower_value, s.value_level[0] != 0)
	_set_light(mashroom_value, s.value_level[2] != 0)

	_set_light(water, s.watering_level != 0)
	_set_light(havest, s.havesting_level != 0)
	_set_light(plant, s.planting_level != 0)
	_set_light(quantity, s.quantity_level != 0)
	_set_light(field, s.field_level != 0)

	_set_light(apple_rot, s.rot_level[1] != 0)
	_set_light(flower_rot, s.rot_level[0] != 0)
	_set_light(mashroom_rot, s.rot_level[2] != 0)

func _set_light(dot: TextureButton, on: bool) -> void:
	var light = dot.get_node_or_null("light")
	if light:
		light.visible = on

# ===== 以下是原有的按钮回调（保持你的逻辑不变） =====
func manage(goods: int, cost: float) -> int:
	if GameData.Invent.items.get(goods, 0) >= cost:
		GameData.Invent.RemoveItem(goods, cost)
		return 0
	else:
		SignalBus.MessagePopu.emit("缺少了什么")
		return 1

func _on_apple_button_down() -> void:
	SkillTree.apple = true
	apple.set_dot_data("解锁苹果种植", 1, tex_apple, 0)
	refresh_dots()

func _on_flower_button_down() -> void:
	var i = manage(Const.CropId.Apple, 2)
	if i == 0:
		SkillTree.flower = true
	init_dots()
	refresh_dots()

func _on_mashroom_button_down() -> void:
	var i = manage(Const.CropId.Apple, 2)
	if i == 0:
		SkillTree.mashroom = true
	init_dots()
	refresh_dots()

func _on_apple_value_button_down() -> void:
	var i = manage(Const.CropId.Apple, SkillTree.get_value_upgrade_cost(Const.CropId.Apple))
	if i == 0:
		SkillTree.upgrade_value(Const.CropId.Apple)
	init_dots()
	refresh_dots()

func _on_flower_value_button_down() -> void:
	var i = manage(Const.CropId.Flower, SkillTree.get_value_upgrade_cost(Const.CropId.Flower))
	if i == 0:
		SkillTree.upgrade_value(Const.CropId.Flower)
	init_dots()
	refresh_dots()

func _on_mashroom_value_button_down() -> void:
	var i = manage(Const.CropId.Mushroom, SkillTree.get_value_upgrade_cost(Const.CropId.Mushroom))
	if i == 0:
		SkillTree.upgrade_value(Const.CropId.Mushroom)
	init_dots()
	refresh_dots()

func _on_auto_havest_button_down() -> void:
	var i = manage(Const.CropId.Mushroom, SkillTree.auto_havest_cost)
	if i == 0:
		SkillTree.auto_havest = true
	init_dots()
	refresh_dots()

func _on_auto_plant_button_down() -> void:
	var i = manage(Const.CropId.Flower, SkillTree.auto_plant_cost)
	if i == 0:
		SkillTree.auto_plant = true
	init_dots()
	refresh_dots()

func _on_auto_water_button_down() -> void:
	var cost = SkillTree.auto_water_cost
	if GameData.Invent.items.get(0, 0) >= cost and GameData.Invent.items.get(1, 0) >= cost and GameData.Invent.items.get(2, 0) >= cost:
		GameData.Invent.RemoveItem(0, cost)
		GameData.Invent.RemoveItem(1, cost)
		GameData.Invent.RemoveItem(2, cost)
		SkillTree.auto_water = true
	else:
		SignalBus.MessagePopu.emit("缺少了什么")
	init_dots()
	refresh_dots()

func _on_water_button_down() -> void:
	if SkillTree.watering_level >= 7:
		SignalBus.MessagePopu.emit("已升满")
		return
	var cost = SkillTree.get_watering_upgrade_cost()
	if GameData.Invent.items.get(0, 0) >= cost and GameData.Invent.items.get(1, 0) >= cost and GameData.Invent.items.get(2, 0) >= cost:
		GameData.Invent.RemoveItem(0, cost)
		GameData.Invent.RemoveItem(1, cost)
		GameData.Invent.RemoveItem(2, cost)
		SkillTree.upgrade_watering()
	else:
		SignalBus.MessagePopu.emit("缺少了什么")
	init_dots()
	refresh_dots()

func _on_havest_button_down() -> void:
	if SkillTree.havesting_level >= 7:
		SignalBus.MessagePopu.emit("已升满")
		return
	var cost = SkillTree.get_havest_upgrade_cost()
	var i = manage(Const.CropId.Flower, cost)
	if i == 0:
		SkillTree.havesting_level += 1
	init_dots()
	refresh_dots()

func _on_plant_button_down() -> void:
	if SkillTree.planting_level >= 7:
		SignalBus.MessagePopu.emit("已升满")
		return
	var cost = SkillTree.get_palent_upgrade_cost()
	var i = manage(Const.CropId.Mushroom, cost)
	if i == 0:
		SkillTree.planting_level += 1
	init_dots()
	refresh_dots()

func _on_quantity_button_down() -> void:
	var cost = SkillTree.get_quantity_upgrade_cost() / 3.0
	if GameData.Invent.items.get(0, 0) >= cost and GameData.Invent.items.get(1, 0) >= cost and GameData.Invent.items.get(2, 0) >= cost:
		GameData.Invent.RemoveItem(0, cost)
		GameData.Invent.RemoveItem(1, cost)
		GameData.Invent.RemoveItem(2, cost)
		SkillTree.upgrade_quantity()
	else:
		SignalBus.MessagePopu.emit("缺少了什么")
	init_dots()
	refresh_dots()

func _on_field_button_down() -> void:
	if SkillTree.field_level >= 7:
		SignalBus.MessagePopu.emit("已升满")
		return
	var cost = SkillTree.get_field_upgrade_cost()
	if GameData.Invent.items.get(0, 0) >= cost and GameData.Invent.items.get(1, 0) >= cost and GameData.Invent.items.get(2, 0) >= cost:
		GameData.Invent.RemoveItem(0, cost)
		GameData.Invent.RemoveItem(1, cost)
		GameData.Invent.RemoveItem(2, cost)
		SkillTree.upgrade_field()
		SkillTree.filed_expand.emit()
	else:
		SignalBus.MessagePopu.emit("缺少了什么")
	init_dots()
	refresh_dots()

func _on_apple_rot_button_down() -> void:
	var i = manage(Const.CropId.Flower, SkillTree.GetRotUpgradeCost(Const.CropId.Apple))
	if i == 0:
		SkillTree.upgrade_rot_resistance(Const.CropId.Apple)
	init_dots()
	refresh_dots()

func _on_flower_rot_button_down() -> void:
	var i = manage(Const.CropId.Mushroom, SkillTree.GetRotUpgradeCost(Const.CropId.Flower))
	if i == 0:
		SkillTree.upgrade_rot_resistance(Const.CropId.Flower)
	init_dots()
	refresh_dots()

func _on_mashroom_rot_button_down() -> void:
	var i = manage(Const.CropId.Apple, SkillTree.GetRotUpgradeCost(Const.CropId.Mushroom))
	if i == 0:
		SkillTree.upgrade_rot_resistance(Const.CropId.Mushroom)
	init_dots()
	refresh_dots()
