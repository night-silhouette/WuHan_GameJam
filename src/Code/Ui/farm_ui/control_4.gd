extends Control

# ==================== 可调参数 ====================
@export var crop_size: float = 32.0        # 素材大小（像素）
@export var spin_speed: float = 100.0      # 旋转初速度（度/秒）
@export var gravity: float = 1500.0        # 重力加速度（像素/秒²）
# ================================================

const TEX_APPLE := preload("res://Asset/plants/apple.png")
const TEX_FLOWER := preload("res://Asset/plants/flower.PNG")
const TEX_MUSHROOM := preload("res://Asset/plants/mushroom.png")

var _crop_textures := {
	Const.CropId.Apple: TEX_APPLE,
	Const.CropId.Flower: TEX_FLOWER,
	Const.CropId.Mushroom: TEX_MUSHROOM,
}

@onready var _audio: AudioStreamPlayer = $AudioStreamPlayer

var _falling: Array = []   # 正在下落的作物列表

func _ready() -> void:
	SignalBus.InventoryRot.connect(_on_inventory_rot)
	SignalBus.StageRain(apple_count: int, flower_count: int, mushroom_count: int)

func _on_inventory_rot(crop_id: int, lost: int) -> void:
	if lost <= 0:
		return
	var tex: Texture2D = _crop_textures.get(crop_id)
	if tex == null:
		return

	var spawn_time: float = 0.0
	var n: int = lost
	for i in n:
		var t: float = float(i) / float(max(n - 1, 1))
		spawn_time += _rain_delay(t)
		var delay: float = spawn_time
		get_tree().create_timer(delay).timeout.connect(
			func(): _spawn(tex)
		)

func _rain_delay(t: float) -> float:
	var intensity: float = sin(t * PI)
	var max_d: float = 0.25
	var min_d: float = 0.03
	return max_d * (1.0 - intensity) + min_d * intensity

func _spawn(tex: Texture2D) -> void:
	var rect := TextureRect.new()
	rect.texture = tex
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# 用 scale 缩放，不受 minimum_size 影响
	var tex_size: Vector2 = tex.get_size()
	var scale_factor: float = crop_size / max(tex_size.x, tex_size.y)
	rect.scale = Vector2(scale_factor, scale_factor)

	# 实际显示大小
	var real_size: Vector2 = tex_size * scale_factor

	var w: float = get_viewport_rect().size.x
	var x: float = randf() * max(w - real_size.x, 1.0)
	rect.position = Vector2(x, -real_size.y)
	rect.pivot_offset = real_size * 0.5
	add_child(rect)

	if _audio:
		_audio.play()

	_falling.append({
		"rect": rect,
		"vy": 0.0,
		"spin": spin_speed * (0.8 + randf() * 0.4),
		"size": real_size.y,   # 记一下高度，下落判断用
	})
func _process(delta: float) -> void:
	var ground_y: float = get_viewport_rect().size.y + crop_size
	var to_remove: Array = []

	for data in _falling:
		var rect: TextureRect = data["rect"]
		data["vy"] += gravity * delta                 # 重力加速
		rect.position.y += data["vy"] * delta
		rect.rotation += deg_to_rad(data["spin"]) * delta

		if rect.position.y >= ground_y:
			to_remove.append(data)

	for data in to_remove:
		data["rect"].queue_free()
		_falling.erase(data)
