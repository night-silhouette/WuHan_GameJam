extends Node

enum ToolMode {
	NORMAL,
	SHOVEL,
	SICKLE,
	WATERING_CAN
}

signal mosChange
var mos: ToolMode = ToolMode.NORMAL:
	set(value):
		mos=value
		mosChange.emit()

# 存储缩放并转换后的 Texture2D 资源
var cursor_textures: Dictionary = {}

func _ready() -> void:
	var target_size = Vector2i(28, 28)
	
	cursor_textures[ToolMode.NORMAL] = load_and_resize_cursor("res://Asset/cursor.png", target_size)
	cursor_textures[ToolMode.SHOVEL] = load_and_resize_cursor("res://Asset/farming tools1/shovel.png", target_size)
	cursor_textures[ToolMode.SICKLE] = load_and_resize_cursor("res://Asset/farming tools1/sickle.PNG", target_size)
	cursor_textures[ToolMode.WATERING_CAN] = load_and_resize_cursor("res://Asset/farming tools1/watering can.png", target_size)

	update_cursor(mos)

func change_tool_mode(new_mode: ToolMode) -> void:
	# 打印看一下每次调用时传进来的新模式是什么，防止外部传参断掉
	print("切换前的 mos: ", mos, " | 接收到的新模式: ", new_mode)
	
	mos = new_mode
	update_cursor(mos)
	
	print("切换后的 mos: ", mos)

func update_cursor(current_mos: ToolMode) -> void:
	var texture = cursor_textures.get(current_mos, null)
	var hotspot = Vector2(14, 14) if texture else Vector2.ZERO
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, hotspot)

func load_and_resize_cursor(path: String, new_size: Vector2i) -> Texture2D:
	var original_texture = load(path) as Texture2D
	if not original_texture:
		print("加载光标图片失败: ", path)
		return null
		
	var img: Image = original_texture.get_image()
	img.resize(new_size.x, new_size.y, Image.INTERPOLATE_BILINEAR)
	return ImageTexture.create_from_image(img)
