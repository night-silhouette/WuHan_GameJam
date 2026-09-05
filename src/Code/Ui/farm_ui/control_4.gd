extends Control

const TEX_APPLE := preload("res://Asset/plants/apple.png")
const TEX_FLOWER := preload("res://Asset/plants/flower.PNG")
const TEX_MUSHROOM := preload("res://Asset/plants/mushroom.png")

# 三种作物配置：下落时长(秒)、旋转速度(度/秒)、贴图大小
const CROP_CONFIG := {
	Const.CropId.Apple:    {"fall_time": 1.2, "spin": 360.0, "size": Vector2(60, 60)},
	Const.CropId.Flower:   {"fall_time": 1.6, "spin": 540.0, "size": Vector2(55, 55)},
	Const.CropId.Mushroom: {"fall_time": 0.9, "spin": 720.0, "size": Vector2(50, 50)},
}

var _crop_textures := {
	Const.CropId.Apple: TEX_APPLE,
	Const.CropId.Flower: TEX_FLOWER,
	Const.CropId.Mushroom: TEX_MUSHROOM,
}

@onready var _audio: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	SignalBus.InventoryRot.connect(_on_inventory_rot)

func _on_inventory_rot(crop_id: int, lost: int) -> void:
	if lost <= 0:
		return
	var cfg: Dictionary = CROP_CONFIG.get(crop_id, {})
	var tex: Texture2D = _crop_textures.get(crop_id)
	if cfg.is_empty() or tex == null:
		return

	# 像下雨一样的生成节奏：稀 → 密 → 稀
	var spawn_time: float = 0.0
	var n: int = lost
	for i in n:
		var t: float = float(i) / float(max(n - 1, 1))
		spawn_time += _rain_delay(t)
		var delay: float = spawn_time
		get_tree().create_timer(delay).timeout.connect(
			func(): _spawn(crop_id, cfg, tex)
		)

# 雨势：中间密、两头稀，返回到下一个作物的生成间隔（秒）
func _rain_delay(t: float) -> float:
	var intensity: float = sin(t * PI)            # 0 → 1 → 0（雨势大小）
	var max_d: float = 0.25                        # 雨最小时的间隔
	var min_d: float = 0.03                        # 雨最大时的间隔
	return max_d * (1.0 - intensity) + min_d * intensity

func _spawn(crop_id: int, cfg: Dictionary, tex: Texture2D) -> void:
	var rect := TextureRect.new()
	rect.texture = tex
	rect.size = cfg["size"]
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL

	var w: float = size.x
	var x: float = randf() * max(w - cfg["size"].x, 1.0)
	rect.position = Vector2(x, -cfg["size"].y)
	rect.pivot_offset = cfg["size"] * 0.5
	add_child(rect)

	if _audio:
		_audio.play()

	# 下落：慢 → 快（加速下落）
	var fall_time: float = cfg["fall_time"] * (0.85 + randf() * 0.3)
	var target_y: float = size.y + cfg["size"].y

	var tween := create_tween().set_parallel(true)
	tween.tween_property(rect, "position:y", target_y, fall_time) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_CUBIC)           # 立方加速，越落越快
	tween.tween_property(rect, "rotation", deg_to_rad(cfg["spin"] * fall_time), fall_time) \
		.set_ease(Tween.EASE_LINEAR)
	tween.finished.connect(func(): rect.queue_free())
