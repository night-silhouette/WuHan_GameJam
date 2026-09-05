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
	Vector2(Const.CropId.Flower,0):preload("uid://811wul2q57b4"),
	Vector2(Const.CropId.Flower,1):preload("uid://dsav1g82wiqcf"),
	Vector2(Const.CropId.Flower,2):preload("uid://ckcrx38ft38u8"),
	Vector2(Const.CropId.Mushroom,0):preload("uid://bbt1sli76udgj"),
	Vector2(Const.CropId.Mushroom,1):preload("uid://bgsrxj5wdakbp"),
	Vector2(Const.CropId.Mushroom,2):preload("uid://dakha6n5od1k8"),
	Vector2(Const.CropId.Apple,0):preload("uid://dv2hfwi4gny0f"),
	Vector2(Const.CropId.Apple,1):preload("uid://b0tvrn6yxr58c"),
	Vector2(Const.CropId.Apple,2):preload("uid://ff05i6h3snsj")
}
@onready var water_spritesheet: Sprite2D = $WaterSpritesheet
@onready var pool_spritesheet: Sprite2D = $PoolSpritesheet


@onready var frame_havest: Sprite2D = $FrameHavest
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var FrameVisible:bool=false:
	set(value):
		FrameVisible=value
		frame_havest.visible=value
		


var barFlag=false
func _ready() -> void:
	Util.Area2dConnectClick(area_2d,func():
		if Mouse.mos==Mouse.ToolMode.SHOVEL:
			barFlag=!barFlag
			toolbar.visible=barFlag
			return
		if Mouse.mos==Mouse.ToolMode.SICKLE:
			if IfCanDrop():
				GameData.F.GetPlot(x,y).growthProgress=0
				spawn_drop_items(1)
		)
	
		
	area_2d.mouse_entered.connect(func():
		FrameVisible=true
		)
	area_2d.mouse_exited.connect(func():
		FrameVisible=false
		)
		
	Util.Area2dConnectHold(area_2d,func():
		if Mouse.mos==Mouse.ToolMode.WATERING_CAN:
			water_spritesheet.visible=true
			pool_spritesheet.visible=true
			animation_player.play("洒水")
			SignalBus.IsWatering=true,
		func():
			if Mouse.mos==Mouse.ToolMode.WATERING_CAN:
				water_spritesheet.visible=false
				pool_spritesheet.visible=false
				animation_player.stop()
				SignalBus.IsWatering=false)
				
		
func IfCanDrop()->bool:
	if cropId==Const.CropId.Nil:
		return false
	if level!=2:
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
		
		
