extends TextureButton
@onready var stroy_label: Label = $Textbox/level
@onready var skill_des_label: Label = $Textbox/skill_des
@onready var unit_icon: TextureRect = $unit
@onready var cost_label: Label = $num

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(hover)
	mouse_exited.connect(exit)
	$Textbox.modulate.a = 0.0
	
func hover():
	Util.TweenFastToSlow($Textbox,"modulate:a",1,0.25,func():pass)
	
func exit():
	Util.TweenFastToSlow($Textbox,"modulate:a",0,0.15,func():pass)
# 设置技能点显示数据
# desc:       skill_des 描述文本
# level:      等级，stroy 会显示 "Level: {level}"
# unit_tex:   unit 的图标(Texture2D)
# cost:       消耗数值，会自动格式化成 1B / 1T 形式显示在 cost_label
func set_dot_data(desc: String, level: int, unit_tex: Texture2D, cost: int) -> void:
	skill_des_label.text = desc
	if level != -1:
		stroy_label.text = "Level: %d" % level
	else:
		stroy_label.text = "满级" 
	unit_icon.texture = unit_tex
	cost_label.text = Util.FormatNumber(cost)


func _on_button_down() -> void:
	print("press")
