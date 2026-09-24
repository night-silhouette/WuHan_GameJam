extends Node

var failed := false

func check(condition: bool, message: String) -> void:
	if not condition:
		failed = true
		push_error("PREVIEW_CHECK_FAILED: " + message)

func run(game_root: Node) -> void:
	# Bound the check even when a resource cannot be loaded.
	get_tree().create_timer(40.0).timeout.connect(func(): get_tree().quit(2))
	while game_root.current_scene == null or game_root.current_ui == null:
		await get_tree().process_frame
	var controller = get_node("/root/FinalPreviewController")
	check(GameData.GameState == 3, "stage is 3")
	check(game_root.current_scene.scene_file_path.ends_with("adult_sence.tscn"), "adult entry")
	check(GameData.Invent.save_path == "user://inventory_final_preview.tres", "separate save")
	for amount in GameData.Invent.items.values():
		check(amount == 10000000000, "initial inventory is 10B per crop")
	check(Inventory.new().save_path == "user://inventory.tres", "ordinary save unchanged")
	await controller._farm()
	var farm_ui = game_root.current_ui
	var submit_control = farm_ui.find_child("submit", true, false)
	check(submit_control != null, "submit control exists")
	check(submit_control.label.text == "1T", "displayed threshold")
	# Actual UI signals, not only controller methods.
	submit_control.get_node("TextureButton").button_down.emit()
	check(controller.controls.get_child_count() == 7, "ending options opened")
	for kind in ["apple", "flower", "mushroom"]:
		await controller.show_ending(kind)
		check(game_root.current_scene.scene_file_path == controller.ENDINGS[kind], "ending " + kind)
		check(controller.ending_text.text.contains(controller.TEXTS[kind]), "ending text " + kind)
		check(controller.end_panel.visible, "ending panel visible")
	await controller._farm()
	check(not controller.end_panel.visible, "text hidden on farm return")
	farm_ui._on_back_button_down()
	await get_tree().process_frame
	check(game_root.current_scene.scene_file_path.ends_with("adult_sence.tscn"), "back to adult")
	await controller._farm()
	# High inventory must not allocate billions of timers when rot is applied.
	var before: Dictionary = GameData.Invent.items.duplicate()
	GameData.Invent.UpdateRot(30.0)
	for crop_id in before:
		check(GameData.Invent.items[crop_id] < before[crop_id], "rot deducts inventory")
	await get_tree().create_timer(0.3).timeout
	var rain = farm_ui.get_node("Control4")
	check(not rain._falling.is_empty(), "rot animation is present")
	for drop in rain._falling:
		check(drop["rect"].mouse_filter == Control.MOUSE_FILTER_IGNORE, "rot visuals do not intercept clicks")
	# Check the exact threshold and the below-threshold boundary.
	GameData.Invent.items = {Const.CropId.Apple: 0, Const.CropId.Flower: 999999999999, Const.CropId.Mushroom: 0}
	SignalBus.DataChange.emit()
	check(not submit_control.preview_finished, "below 1T does not finish")
	GameData.Invent.items[Const.CropId.Flower] += 1
	SignalBus.DataChange.emit()
	SignalBus.DataChange.emit()
	check(submit_control.preview_finished, "exactly 1T finishes once")
	for i in range(120):
		if game_root.current_scene.scene_file_path == controller.ENDINGS["flower"] and not controller.busy:
			break
		await get_tree().process_frame
	check(game_root.current_scene.scene_file_path == controller.ENDINGS["flower"], "automatic flower ending")
	await controller._farm()
	check(not submit_control.preview_finished, "submission resets on return")
	GameData.Invent.items = {Const.CropId.Apple: 10, Const.CropId.Flower: 10, Const.CropId.Mushroom: 10}
	await controller.finish_current()
	for i in range(120):
		if not controller.busy:
			break
		await get_tree().process_frame
	check(game_root.current_scene.scene_file_path == controller.ENDINGS["apple"], "ties prefer apple")
	if not failed:
		print("FINAL_PREVIEW_CHECK_PASSED: entry, inventory, save isolation, UI, three endings, return, rot, 1T boundary, tie")
	get_tree().quit(1 if failed else 0)
