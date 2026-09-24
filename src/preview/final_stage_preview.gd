extends "res://Code/Scene/root/root.gd"

const PREVIEW_SAVE := "user://inventory_final_preview.tres"
const INITIAL_AMOUNT: int = 10000000000

func _ready() -> void:
	GameData.GameState = 3
	var inventory := Inventory.new()
	inventory.save_path = PREVIEW_SAVE
	for crop_id in [Const.CropId.Apple, Const.CropId.Flower, Const.CropId.Mushroom]:
		inventory.items[crop_id] = INITIAL_AMOUNT
	if not "--preview-check" in OS.get_cmdline_user_args():
		inventory.LoadGame()
	GameData.Invent = inventory
	var controller := preload("res://preview/final_controller.gd").new()
	controller.name = "FinalPreviewController"
	get_tree().root.add_child.call_deferred(controller)
	super._ready()
	if "--preview-check" in OS.get_cmdline_user_args():
		call_deferred("_run_check")

func _run_check() -> void:
	await get_tree().process_frame
	var checks = load("res://preview/preview_checks.gd").new()
	add_child(checks)
	await checks.run(self)
