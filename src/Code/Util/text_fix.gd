extends Label
class_name LabelFix
var fixed_size : Vector2

@export var max_font_size: int = 64:
	set(value):
		max_font_size = value
		_update_text()


@export var min_font_size: int = 10:
	set(value):
		min_font_size = value
		_update_text()


@export_multiline var auto_text: String = "":
	set(value):
		auto_text = value
		_update_text()


func _ready() -> void:
	#autowrap_mode = TextServer.AUTOWRAP_OFF
	fixed_size = size
	_update_text()


func _update_text() -> void:
	if not is_inside_tree():
		return
	
	if auto_text.is_empty():
		text = ""
		return
	
	set_auto_text(auto_text)


func set_auto_text(content: String) -> void:
	var low := min_font_size
	var high := max_font_size
	var best := min_font_size
	var best_text := content
	
	var font := get_theme_font("font")

	if font == null:
		text = content
		return

	while low <= high:
		var mid := (low + high) / 2
		
		# 当前字号
		add_theme_font_size_override("font_size", mid)
		
		# 根据 Label 宽度自己换行
		var wrapped_text := _wrap_text(content, font, mid)
		
		# 计算换行后的总高度
		var line_height := font.get_height(mid)
		var line_count := wrapped_text.count("\n") + 1
		var text_height := line_height * line_count
		
		# 判断高度是否放得下
		if text_height <= fixed_size.y:
			best = mid
			best_text = wrapped_text
			low = mid + 1
		else:
			high = mid - 1
	
	# 使用最终结果
	add_theme_font_size_override("font_size", best)
	text = best_text
	size = fixed_size
	custom_minimum_size = fixed_size
	
func _wrap_text(content: String, font: Font, font_size: int) -> String:
	var result := ""
	var current_width := 0.0
	var max_width := fixed_size.x
	
	for character in content:
		# 手动换行
		if character == "\n":
			result += "\n"
			current_width = 0
			continue
		
		var char_width := font.get_string_size(
			character,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size
		).x
		
		# 当前字符放不下
		if current_width + char_width > max_width:
			result += "\n"
			current_width = 0
		
		result += character
		current_width += char_width
	
	return result	
