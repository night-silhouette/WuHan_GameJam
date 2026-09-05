extends TextureButton


		
	
func _ready() -> void:
	SkillTree.m.connect(func():self.visible=true)
	
