extends Node

@export var Sence_root : Node2D
@export var Ui_root : Control
var current_ui : Node
var current_sence :Node

func _ready() -> void:
	SignalBus.ChangeSence.connect(ChangeScence)
	SignalBus.ChangeUi.connect(ChangeUi)
	
func ChangeScence(next_sence:String)->void:
	var index: int = 0
	await _goto_scene(next_sence,index)

func ChangeUi(next_sence:String)->void:
	var index: int = 1
	await _goto_scene(next_sence,index)

func _goto_scene(path: String,index:int) -> void:
	var root_node:Node;
	var current : Node;
	
	if index == 0:
		root_node = Sence_root
		current = current_sence
	elif index == 1:
		root_node = Ui_root
		current = current_ui
		
	if root_node == null:
		push_error("root_node not registered")
		return

	# 1 异步加载请求
	ResourceLoader.load_threaded_request(path)

	# 2 等待加载完成
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame

	# 3 获取资源
	var scene_res = ResourceLoader.load_threaded_get(path)

	if scene_res == null:
		push_error("scene load failed")
		return

	# 4 删除旧场景
	if current:
		current.queue_free()

	# 5 实例化
	current = scene_res.instantiate()

	# 6 添加
	root_node.add_child(current)
