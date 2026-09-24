extends CanvasLayer

const ENDINGS = {
	"apple": "res://Code/Scene/end_apple.tscn",
	"flower": "res://Code/Scene/end_flower.tscn",
	"mushroom": "res://Code/Scene/end_mushroom.tscn",
}
const TITLES = {"apple": "苹果结局", "flower": "花朵结局", "mushroom": "蘑菇结局"}
const TEXTS = {
	"apple": "走到这一步，你已经分不清驱动自己的是什么了。责任、热爱、恐惧、攀比，它们已经搅拌到了一起，变成一个永不停歇的引擎",
	"flower": "和世界牵起丝线，对现状的不满让你卷入一场场拔河，心甘情愿地被拉扯。\n或许这绳索本是和世界的牵起的红线，毕竟，你的生命力不息地燃烧着",
	"mushroom": "你停下来，起锅烧油翻炒调味，大口吞噬意义；任由其余人被痛苦或虚无撕裂",
}
var controls: VBoxContainer
var ending_text: Label
var end_panel: PanelContainer
var busy := false

func _ready() -> void:
	layer = 100
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var corner := PanelContainer.new()
	corner.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	corner.offset_left = -246
	corner.offset_right = -10
	corner.offset_top = 78
	root.add_child(corner)
	controls = VBoxContainer.new()
	controls.add_theme_constant_override("separation", 6)
	corner.add_child(controls)
	var heading := Label.new()
	heading.text = "最终阶段试玩"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 18)
	controls.add_child(heading)
	_add_button("进入成人农田", _farm)
	_add_button("查看结局", _show_choices)
	end_panel = PanelContainer.new()
	root.add_child(end_panel)
	end_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	end_panel.offset_left = 20
	end_panel.offset_right = -20
	end_panel.offset_top = -140
	end_panel.offset_bottom = -15
	var reading_style := StyleBoxFlat.new()
	reading_style.bg_color = Color(0.07, 0.06, 0.05, 0.95)
	reading_style.content_margin_left = 14
	reading_style.content_margin_right = 14
	reading_style.content_margin_top = 10
	reading_style.content_margin_bottom = 10
	end_panel.add_theme_stylebox_override("panel", reading_style)
	end_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ending_text = Label.new()
	ending_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ending_text.add_theme_font_size_override("font_size", 20)
	ending_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	end_panel.add_child(ending_text)
	end_panel.hide()

func _add_button(text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(228, 36)
	button.add_theme_font_size_override("font_size", 17)
	button.pressed.connect(callback)
	controls.add_child(button)

func _show_choices() -> void:
	if controls.get_child_count() > 3:
		return
	_add_button("苹果结局", show_ending.bind("apple"))
	_add_button("花朵结局", show_ending.bind("flower"))
	_add_button("蘑菇结局", show_ending.bind("mushroom"))
	_add_button("按当前库存选择结局", finish_current)

func finish_current() -> void:
	var best := "apple"
	var count: int = GameData.Invent.items.get(Const.CropId.Apple, 0)
	if int(GameData.Invent.items.get(Const.CropId.Flower, 0)) > count:
		best = "flower"
		count = GameData.Invent.items.get(Const.CropId.Flower, 0)
	if int(GameData.Invent.items.get(Const.CropId.Mushroom, 0)) > count:
		best = "mushroom"
	show_ending(best)

func show_ending(kind: String) -> void:
	if busy or not ENDINGS.has(kind):
		return
	busy = true
	GameData.GameState = 3
	var game_root = get_tree().current_scene
	await game_root.change_ui("res://Code/Ui/defaultUi/default_ui.tscn")
	await game_root.change_scene(ENDINGS[kind])
	game_root.current_ui.visible = false
	ending_text.text = TITLES[kind] + "\n" + TEXTS[kind]
	end_panel.show()
	print("FINAL_PREVIEW_ENDING:", kind)
	busy = false

func _farm() -> void:
	if busy:
		return
	busy = true
	GameData.GameState = 3
	end_panel.hide()
	var game_root = get_tree().current_scene
	await game_root.change_scene("res://Code/Scene/main/main.tscn")
	await game_root.change_ui("res://Code/Ui/farm_ui/farm_ui.tscn")
	var submit_control = game_root.current_ui.find_child("submit", true, false)
	if submit_control != null:
		submit_control.preview_finished = false
	busy = false
