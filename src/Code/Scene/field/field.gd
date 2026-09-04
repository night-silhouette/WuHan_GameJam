extends Control
class_name FieldPerform

@onready var area_2d: Area2D = $Area2D

@export var x:int 
@export var y:int
@export var level:int=0
@export var cropId:Const.CropId=Const.CropId.Nil

const DROPS = preload("uid://dhma1jsxh2bcr")

@onready var toolbar: Sprite2D = $Toolbar


var barFlag=false
func _ready() -> void:
	Util.Area2dConnectClick(area_2d,func():
		if Mouse.mos==Mouse.ToolMode.SHOVEL:
			barFlag=!barFlag
			toolbar.visible=barFlag
			return
		if Mouse.mos==Mouse.ToolMode.SICKLE:
			if IfCanDrop():
			
				spawn_drop_items(1)
		)
		
func IfCanDrop()->bool:
	if cropId==Const.CropId.Nil:
		return false
	return true

func spawn_drop_items(count: int) -> void:
	for i in range(count):
		var drop_instance = DROPS.instantiate() as RigidBody2D
		if not drop_instance:
			continue
		
		# 设置初始位置为点击位置
		
		drop_instance.CropId=cropId
		
		# 添加到当前场景树
		add_child(drop_instance)
		drop_instance.position=Vector2(50,50)
		drop_instance.z_index=50
		# 随机一个方向和速度（360度全方位散开）
		var random_angle = randf() * TAU 
		var random_speed = randf_range(120.0, 250.0)
		var random_dir = Vector2(cos(random_angle), sin(random_angle))
		
		# 施加冲量，让物体向四周滑出
		drop_instance.apply_central_impulse(random_dir * random_speed)
		
		
