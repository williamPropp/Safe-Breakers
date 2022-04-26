extends Node

func reset_game():
	get_tree().reload_current_scene()

# play specified sound using specified bus
func play_sound(sample_path, bus = "Master"):
	# create new stream player and add it to the scene
	var new_stream_player = AudioStreamPlayer.new()
	add_child(new_stream_player)

	# load the audio path
	var sound_to_play = load(sample_path)
	
	# create new stream player instance to host the sound, then play the sound
	new_stream_player.stream = sound_to_play
	new_stream_player.bus = bus
	new_stream_player.play(0.0)
	
	# delete node once the sample finishes playing
	yield(new_stream_player, "finished")
	new_stream_player.stop()
	new_stream_player.queue_free()
