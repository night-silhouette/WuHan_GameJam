extends Node

#region napori
##切换场景
signal ChangeSence(next_path:String)
##切换UI
signal ChangeUi(next_path:String)
##message弹出
signal MessagePopu(message:String)

signal HoverOnly()

signal DataChange()




































#endregion


var IsWatering:int=false

var PickFlag=false

signal IsAutoPick

func _ready() -> void:
	SkillTree.pick.connect(AutoPick)

		
		




func AutoPick():
		while true:
			await get_tree().create_timer(2.0).timeout
			PickFlag=true
			IsAutoPick.emit()
			
