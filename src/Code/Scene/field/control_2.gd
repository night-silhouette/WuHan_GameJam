extends TextureButton


func _ready() -> void:
	SkillTree.a.connect(func():self.visible=true)
