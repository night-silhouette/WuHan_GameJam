extends RigidBody2D
class_name Drops

const APPLE = preload("uid://dqkddcl0tssmx")
const FLOWER = preload("uid://c1vt6j6be3o0a")
const MUSHROOM = preload("uid://bpv7jnfrvtqv1")

@onready var sprite: Sprite2D = $sprite

var map:Dictionary={
	Const.CropId.Apple:APPLE,
	Const.CropId.Flower:FLOWER,
	Const.CropId.Mushroom:MUSHROOM
}


@export var CropId:Const.CropId
@onready var area_2d: Area2D = $Area2D

		

func _ready() -> void:
	
	sprite.texture=map[CropId]

	# 俯视角下确保关闭垂直重力，并开启线性阻尼（模拟地面摩擦力使它停下）
	gravity_scale = 0.0
	linear_damp = 4.0
	
	area_2d.mouse_entered.connect(func():
		GameData.Invent.AddItem(CropId,SkillTree.GetValue(CropId))
		queue_free()
		)
 
