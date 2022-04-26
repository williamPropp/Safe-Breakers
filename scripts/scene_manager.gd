extends Node2D

var opening_safe = false

var open_speed = 20
var open_coefficient = 0
var open_counter = 0.01

# slide the safe mini game to the left using an ease-in ease-out motion
func _process(delta):
	if(opening_safe && self.position.x > -1380):
		self.position.x -= open_speed * open_coefficient
		open_counter += 0.01
		open_coefficient = open_counter * open_counter * (3.0 - 2.0 * open_counter)
		

func open_safe():
	opening_safe = true
