extends Control
class_name FieldPerform

@onready var area_2d: Area2D = $Area2D
@onready var plant: Sprite2D = $Plant

@export var x:int 
@export var y:int
@export var level:int=0:
	set(value):
		level=value
		if cropId!=Const.CropId.Nil:
			plant.texture=PlantMap[Vector2(cropId,level)]
			
@export var cropId:Const.CropId=Const.CropId.Nil:
	set(value):
		cropId=value
		if cropId!=Const.CropId.Nil:
			plant.texture=PlantMap[Vector2(cropId,level)]

const DROPS = preload("uid://dhma1jsxh2bcr")

@onready var toolbar: Sprite2D = $Toolbar

var PlantMap:Dictionary={
	Vector2(Const.CropId.Flower,0):preload("uid://m3cc7oqutc2g"),
	Vector2(Const.CropId.Flower,1):preload("uid://m5yae1wbh0xx"),
	Vector2(Const.CropId.Flower,2):preload("uid://cwhbfu7javom4"),
	Vector2(Const.CropId.Mushroom,0):preload("uid://b701tv106h8vm"),
	Vector2(Const.CropId.Mushroom,1):preload("uid://dsdwcpdus72aq"),
	Vector2(Const.CropId.Mushroom,2):preload("uid://q3hju68j2o1w"),
	Vector2(Const.CropId.Apple,0):preload("uid://bqakxj76bb0vh"),
	Vector2(Const.CropId.Apple,1):preload("uid://t57cyyxxnyc7"),
	Vector2(Const.CropId.Apple,2):preload("uid://caokmrtnbnwj7")
}


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
		
		
