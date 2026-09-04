extends Node

enum ToolMode {
	NORMAL,
	SHOVEL,
	SICKLE,
	WATERING_CAN
}

var mos: ToolMode = ToolMode.NORMAL

# 存储缩放并转换后的 Texture2D 资源
var cursor_textures: Dictionary = {}

func _ready() -> void:
	# 在初始化时，通过代码加载图片并动态缩放（例如目标大小为 32x32 像素）
	var target_size = Vector2i(32, 32)
	
	cursor_textures[ToolMode.NORMAL] = null
	cursor_textures[ToolMode.SHOVEL] = load_and_resize_cursor("res://Asset/farming tools1/shovel.png", target_size)
	cursor_textures[ToolMode.SICKLE] = load_and_resize_cursor("res://Asset/farming tools1/sickle.PNG", target_size)
	cursor_textures[ToolMode.WATERING_CAN] = load_and_resize_cursor("res://Asset/farming tools1/watering can.png", target_size)

	update_cursor(mos)

func change_tool_mode(new_mode: ToolMode) -> void:
	mos = new_mode
	update_cursor(mos)

func update_cursor(current_mos: ToolMode) -> void:
	var texture = cursor_textures.get(current_mos, null)
	
	# 如果有图片，热点设为图片大小的一半（即正中心）；如果没有则用 Vector2.ZERO
	var hotspot = Vector2(16, 16) if texture else Vector2.ZERO
	
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, hotspot)

# 辅助函数：加载图片、缩放尺寸并转回 Texture2D
func load_and_resize_cursor(path: String, new_size: Vector2i) -> Texture2D:
	var original_texture = load(path) as Texture2D
	if not original_texture:
		return null
		
	# 获取 Image 对象并缩放
	var img: Image = original_texture.get_image()
	img.resize(new_size.x, new_size.y, Image.INTERPOLATE_BILINEAR)
	
	# 将修改后的 Image 重新包装为 ImageTexture
	return ImageTexture.create_from_image(img)
