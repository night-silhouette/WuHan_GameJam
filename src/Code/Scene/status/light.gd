extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Util.TweenFastToSlow(self,"modulate:a",0.5,0.5,dark)
	
	
func dark():
	Util.TweenFastToSlow(self,"modulate:a",0,1.5,light)
	
func light():
	Util.TweenFastToSlow(self,"modulate:a",0.5,2,dark)
