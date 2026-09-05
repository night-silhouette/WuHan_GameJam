extends Node

@export_file("*.tscn") var initial_scene: String = ""
@export_file("*.tscn") var initial_ui: String = ""

@onready var sence_root: Node2D = $Sence_root
@onready var ui_root: Control = $Ui_root

var current_scene_node: Node = null
var current_ui_node: Node = null

func _ready() -> void:
	SignalBus.ChangeSence.connect(change_scene)
	SignalBus.ChangeUi.connect(change_ui)
	
	if not initial_scene.is_empty():
		change_scene(initial_scene)
	if not initial_ui.is_empty():
		change_ui(initial_ui)

func change_scene(path: String) -> void:
	if path.is_empty():
		return
	var new_node = await _load_and_instantiate(path)
	if new_node:
		if current_scene_node:
			current_scene_node.queue_free()
		current_scene_node = new_node
		sence_root.add_child(current_scene_node)

func change_ui(path: String) -> void:
	if path.is_empty():
		return
	var new_node = await _load_and_instantiate(path)
	if new_node:
		if current_ui_node:
			current_ui_node.queue_free()
		current_ui_node = new_node
		ui_root.add_child(current_ui_node)

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
