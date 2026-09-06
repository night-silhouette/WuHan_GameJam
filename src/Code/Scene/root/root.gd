extends Node

@export_file("*.tscn") var initial_scene: String = ""
@export_file("*.tscn") var initial_ui: String = ""

@onready var sence_root: Node2D = $Sence_root
@onready var ui_root: Control = $Ui_root

# 缓存：path -> node（首次加载后一直复用，不销毁）
var _scene_cache: Dictionary = {}
var _ui_cache: Dictionary = {}

# 正在加载中的 path，防止重复加载
var _loading: Dictionary = {}

var current_scene: Node = null
var current_ui: Node = null

func _ready() -> void:
	SignalBus.ChangeSence.connect(change_scene)
	SignalBus.ChangeUi.connect(change_ui)
	if not initial_scene.is_empty():
		change_scene(initial_scene)
	if not initial_ui.is_empty():
		change_ui(initial_ui)

# ========== 场景切换（visible 方式） ==========
func change_scene(path: String) -> void:
	if path.is_empty():
		return
	var node = await _get_or_load(_scene_cache, sence_root, path)
	if node == null:
		return
	if current_scene and current_scene != node:
		_deactivate(current_scene)
	current_scene = node
	_activate(node)

func change_ui(path: String) -> void:
	if path.is_empty():
		return
	var node = await _get_or_load(_ui_cache, ui_root, path)
	if node == null:
		return
	if current_ui and current_ui != node:
		_deactivate(current_ui)
	current_ui = node
	_activate(node)

# 激活：显示 + 恢复逻辑
func _activate(node: Node) -> void:
	node.visible = true
	node.process_mode = Node.PROCESS_MODE_INHERIT

# 停用：隐藏 + 暂停逻辑
func _deactivate(node: Node) -> void:
	node.visible = false
	node.process_mode = Node.PROCESS_MODE_DISABLED

# 从缓存取，没有则加载并缓存
func _get_or_load(cache: Dictionary, parent: Node, path: String) -> Node:
	if cache.has(path):
		return cache[path]
	# 正在加载，等它完成
	while _loading.has(path):
		await get_tree().process_frame
	if cache.has(path):
		return cache[path]

	_loading[path] = true
	var node = await _load_and_instantiate(path)
	if node:
		parent.add_child(node)
		node.visible = false   # 先隐藏，等 _activate 再显示
		cache[path] = node
	_loading.erase(path)
	return node

func _load_and_instantiate(path: String) -> Node:
	ResourceLoader.load_threaded_request(path)
	while true:
		var status = ResourceLoader.load_threaded_get_status(path)
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				var scene_res = ResourceLoader.load_threaded_get(path)
				if scene_res:
					return scene_res.instantiate()
				break
			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("加载资源失败: " + path)
				break
		await get_tree().process_frame
	return null
