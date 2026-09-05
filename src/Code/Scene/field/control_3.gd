extends TextureButton


func _ready() -> void:
	SkillTree.f.connect(func():self.visible=true)
