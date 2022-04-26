extends Node2D

onready var safe = get_node("bg_front")

var opening_safe = false

var open_speed = 20
var open_coefficient = 0
var open_counter = 0.01


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
	
	var new_stream_player = AudioStreamPlayer.new()
	add_child(new_stream_player)

	# load the random audio path
	var sound_to_play = load("res://sound_assets/Safe-Opening.mp3")
	
	# create new stream player instance to host the sound, then play the sound
	new_stream_player.stream = sound_to_play
	new_stream_player.bus = "SafeTick"
	new_stream_player.play(0.0)
	
	# delete node once the sample finishes playing
	yield(new_stream_player, "finished")
	new_stream_player.stop()
	new_stream_player.queue_free()
