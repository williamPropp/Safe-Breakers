extends Area2D


func _on_quadrant_mouse_entered():
	var area_image = get_node("area_image")
	if(area_image.color == Color(255,0,0)):
		area_image.color = Color(0,255,0)
	elif(area_image.color == Color(0,255,0)):
		area_image.color = Color(0,0,255)
	elif(area_image.color == Color(0,0,255)):
		area_image.color = Color(0,0,0)
	elif(area_image.color == Color(0,0,0)):
		area_image.color = Color(255,255,255)
	else:
		area_image.color = Color(255,0,0)
