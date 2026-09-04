extends RigidBody2D
class_name Drops

const APPLE = preload("uid://dqkddcl0tssmx")
const FLOWER = preload("uid://c4da2jq5twjpy")
const MUSHROOM = preload("uid://bpv7jnfrvtqv1")

@onready var sprite: Sprite2D = $sprite

var map:Dictionary={
	Const.CropId.Apple:APPLE,
	Const.CropId.Flower:FLOWER,
	Const.CropId.Mushroom:MUSHROOM
}


@export var CropId:Const.CropId:
	set(value):
		CropId=value
		sprite.texture=map[value]

func _ready() -> void:
	# 俯视角下确保关闭垂直重力，并开启线性阻尼（模拟地面摩擦力使它停下）
	gravity_scale = 0.0
	linear_damp = 4.0
	
 
