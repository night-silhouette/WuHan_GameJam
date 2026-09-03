extends Node


#时间到了,触发回调函数
func setTime(time,callback)->SceneTreeTimer:
	var temp=get_tree().create_timer(time)
	temp.timeout.connect(callback,CONNECT_ONE_SHOT)
	return temp
	#输出定时器本身,输出出来,以便于.stop()
	
	
#点击area2D,触发回调
func Area2dConnectClick(area2d:Area2D,callback:Callable)->void:
	area2d.input_event.connect(func(obj,event,id):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				callback.call()
		)
	
#松开鼠标
func Area2dConnectRelease(area2d: Area2D, callback: Callable) -> void:
	area2d.input_event.connect(func(_viewport, event, _shape_idx):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
				callback.call()
	)
	
#改变节点的texture
func SetNodeTexture(node: Node, new_texture: Texture2D) -> void:
	if node and "texture" in node:
		node.texture = new_texture


	
#tween_fast_to_slow($Sprite2D, "modulate:a", 0.0, 1.0(时间), func():
	#print("淡出动画播完了！")
#)

#callback是补间动画结束触发的回调	
func TweenFastToSlow(obj,prop,value,time,callback=func():pass):
	var tween=create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)	
	tween.tween_property(obj,prop, value,time)
	tween.finished.connect(callback)
	return tween#tween的引用没有了之后,tween.finished.connect(callback)这个的信号也会随之free,所以可以大胆的对这个tween.kill()

# callback是补间动画结束触发的回调	
func TweenSlowToFast(obj, prop, value, time, callback = func(): pass):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)	
	tween.tween_property(obj, prop, value, time)
	tween.finished.connect(callback)
	return tween
	
