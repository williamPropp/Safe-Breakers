extends Node2D

#var width
#var height
#var from
#var to = Vector2(0,0)
#var color = Color(255,0,0)
#var go_right = true
#
#var rng = RandomNumberGenerator.new()
#
#enum MOVE_STATE {TOP, RIGHT, BOTTOM, LEFT}
#var curr_move_state = MOVE_STATE.TOP
var quadrant_array = []

func _ready():
	var rot = 0
	for i in 200:
		var new_quadrant = load("res://quadrant.tscn")
		var new_quadrant_instance = new_quadrant.instance()
		add_child(new_quadrant_instance)
		rot += 1.9
		new_quadrant_instance.position = Vector2(400,200)
		new_quadrant_instance.rotation = deg2rad(rot)
		quadrant_array.append(new_quadrant_instance)
#	var new_quadrant = Polygon2D
#	new_quadrant = get_node("quadrant_container/quadrant")
#	new_quadrant.rotation = deg2rad(5)

#	rng.randomize()
#	width = get_viewport().size.x
#	height = get_viewport().size.y
#	from = Vector2(width/2,height/2)
	
func _process(delta):
	pass
#	match(curr_move_state):
#		MOVE_STATE.TOP:
#			if(to.x >= width):
#				to.x = width
#				curr_move_state = MOVE_STATE.RIGHT
#			else:
#				to += Vector2(10,0)
#
#		MOVE_STATE.RIGHT:
#			if(to.y >= height):
#				to.y = height
#				curr_move_state = MOVE_STATE.BOTTOM
#			else:
#				to += Vector2(0,10)
#
#		MOVE_STATE.BOTTOM:
#			if(to.x <= 0):
#				to.x = 0
#				curr_move_state = MOVE_STATE.LEFT
#			else:
#				to -= Vector2(10,0)
#
#		MOVE_STATE.LEFT:
#			if(to.y <= 0):
#				to.y = 0
#				curr_move_state = MOVE_STATE.TOP
#			else:
#				to -= Vector2(0,10)
#	update()
	
#func _draw():
#	draw_line(from,to,color)
