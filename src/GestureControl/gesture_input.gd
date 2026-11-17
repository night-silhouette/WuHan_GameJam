extends Node
## Local gesture input. Camera service follows the game process lifetime.
## F8 toggles gesture input; the camera preview can be closed with Q/Esc.

const PORT: int = 47823
const TIMEOUT_MS: int = 1500
const TOOL_MAP: Dictionary = {
	"NORMAL": Mouse.ToolMode.NORMAL,
	"SHOVEL": Mouse.ToolMode.SHOVEL,
	"SICKLE": Mouse.ToolMode.SICKLE,
	"WATERING_CAN": Mouse.ToolMode.WATERING_CAN,
}
const TOOL_NAMES: Dictionary = {
	"NORMAL": "普通鼠标", "SHOVEL": "铲子", "SICKLE": "镰刀", "WATERING_CAN": "水壶",
}

var _udp := PacketPeerUDP.new()
var _enabled: bool = true
var _bound: bool = false
var _last_packet_ms: int = -1
var _latched_tool: String = ""
var _pending_tool: String = ""
var _label: Label
var _status: String = "等待摄像头程序"
var _camera_pid: int = -1

func _start_camera() -> void:
	# Python must stay outside a PCK: native libraries cannot execute inside it.
	var folder: String = ProjectSettings.globalize_path("res://GestureControl")
	if OS.has_feature("standalone"):
		folder = OS.get_executable_path().get_base_dir().path_join("GestureControl")
	var launcher: String = folder.path_join("launch.py")
	if not FileAccess.file_exists(launcher):
		_status = "未找到摄像头程序，鼠标仍可用"
		return
	var python_path: String = folder.path_join(".venv/Scripts/python.exe" if OS.get_name() == "Windows" else ".venv/bin/python")
	if not FileAccess.file_exists(python_path):
		python_path = "python" if OS.get_name() == "Windows" else "python3"
	var args := PackedStringArray([launcher, "--parent-pid", str(OS.get_process_id())])
	_camera_pid = OS.create_process(python_path, args)
	_status = "正在启动摄像头（首次可能安装依赖）" if _camera_pid > 0 else "摄像头启动失败，请检查 Python"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer := CanvasLayer.new()
	layer.layer = 80
	add_child(layer)
	_label = Label.new()
	_label.position = Vector2(12, 12)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size", 16)
	_label.add_theme_color_override("font_color", Color.WHITE)
	_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	_label.add_theme_constant_override("shadow_offset_x", 2)
	_label.add_theme_constant_override("shadow_offset_y", 2)
	layer.add_child(_label)
	var error := _udp.bind(PORT, "127.0.0.1")
	_bound = error == OK
	if not _bound:
		_status = "端口占用，手势不可用（鼠标仍可用）"
		push_warning("GestureControl: cannot bind localhost UDP port %d, error %d" % [PORT, error])
	if _bound and DisplayServer.get_name() != "headless":
		_start_camera()
	_update_label()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F8:
		_enabled = not _enabled
		_pending_tool = ""
		_latched_tool = ""
		_update_label()

func _process(_delta: float) -> void:
	if not _bound:
		return
	# Bound work per frame; packet size is checked before JSON parsing.
	var count: int = 0
	while _udp.get_available_packet_count() > 0 and count < 64:
		count += 1
		var packet: PackedByteArray = _udp.get_packet()
		if packet.size() > 1024 or _udp.get_packet_ip() != "127.0.0.1":
			continue
		var decoded: Variant = JSON.parse_string(packet.get_string_from_utf8())
		if not decoded is Dictionary:
			continue
		var message: Dictionary = decoded
		if message.get("version") != 1:
			continue
		var status: Variant = message.get("status")
		if not status is String or status not in ["tracking", "no_gesture", "offline"]:
			continue
		var tool: Variant = message.get("tool")
		if tool != null and (not tool is String or not TOOL_MAP.has(tool)):
			continue
		_last_packet_ms = Time.get_ticks_msec()
		_pending_tool = ""
		if status == "offline":
			_status = "摄像头程序已关闭"
			_latched_tool = ""
		elif tool == null:
			_status = "已连接，请保持手势" if status == "tracking" else "已连接，未识别到有效手势"
			_latched_tool = ""
		else:
			_status = "已识别：" + str(TOOL_NAMES[tool])
			if _enabled and tool != _latched_tool:
				_pending_tool = tool
		if not _enabled:
			_latched_tool = ""
	if _last_packet_ms >= 0 and Time.get_ticks_msec() - _last_packet_ms > TIMEOUT_MS:
		_status = "连接断开，保留当前工具"
		_pending_tool = ""
		_latched_tool = ""
	# Never switch during a mouse action, in a paused game, or without focus.
	if not _pending_tool.is_empty() and _enabled and not get_tree().paused and get_window().has_focus():
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			var mode: int = TOOL_MAP[_pending_tool]
			if Mouse.mos != mode:
				Mouse.change_tool_mode(mode)
			_latched_tool = _pending_tool
			_pending_tool = ""
	_update_label()

func _update_label() -> void:
	var state: String = "开启" if _enabled else "暂停"
	_label.text = "手势输入 [%s] · F8 开关\n%s" % [state, _status]

func _exit_tree() -> void:
	_udp.close()
	if _camera_pid > 0 and OS.is_process_running(_camera_pid):
		OS.kill(_camera_pid)
	_camera_pid = -1
