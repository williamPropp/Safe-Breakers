extends Node2D

onready var safe = get_node("bg_front")

var opening_safe = false

var open_speed = 20
var open_coefficient = 0
var open_counter = 0.01

func _ready():
	opening_safe = true
	
# slide the safe mini game to the left using an ease-in ease-out motion
func _process(delta):
	if(opening_safe && safe.rect_position.x > -1380):
		safe.rect_position.x -= open_speed * open_coefficient
		open_counter += 0.01
		open_coefficient = open_counter * open_counter * (3.0 - 2.0 * open_counter)
	else:
		opening_safe = false

func open_safe():
	opening_safe = true
#	var safe_interior = load("res://scenes/safe_interior.tscn").instance()
#	get_parent().add_child(safe_interior)
