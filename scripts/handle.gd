extends Sprite

var rng = RandomNumberGenerator.new()

var locked = true
var is_dragging = false
var dial_rotation = 0
var click_pos = Vector2.ZERO
var locked_rot_constraint = 15
var unlocked_rot_constraint = 40

func _input(event):
	# tests whether a click occured within the area of the sprite
	if Input.is_action_just_pressed("left_mouse") && get_rect().has_point(to_local(event.position)):
		# update click_pos offset and is_dragging state
		click_pos = event.position
		is_dragging = true
	elif Input.is_action_just_released("left_mouse"):
		# update dial_rotation offset and is_dragging state
		dial_rotation = int( floor(self.rotation_degrees) )
		is_dragging = false
	
	if is_dragging:
		# get points: c (center of the dial), p0 (initial click position), and p1 (current drag position)
		var c = position
		var p0 = click_pos
		var p1 = event.position
		
		# calculate the angle to add to the dial's rotation
		var add_rotation = angle_diff(c, p0, p1)
		
		# depending on the unlock state, rotate the handle with a corresponding constraint
		if(locked && add_rotation + dial_rotation < locked_rot_constraint):
			self.rotation_degrees = add_rotation + dial_rotation
		elif(locked):
			is_dragging = false
			play_sfx_open_attempt(false)
		elif(!locked && add_rotation + dial_rotation < unlocked_rot_constraint):
			self.rotation_degrees = add_rotation + dial_rotation
		elif(!locked):
			is_dragging = false
			play_sfx_open_attempt(true)
		
		# convert any rotation angle above or below the range (0,359) to its corresponding angle in that range
		self.rotation_degrees = ( ( int(self.rotation_degrees) % 360 ) + 360 ) % 360

func _physics_process(delta):
	if(!is_dragging):
		if(self.rotation_degrees > 0.25):
			self.rotation_degrees -= 0.7
			dial_rotation -= 0.7
		else:
			self.rotation = 0
			dial_rotation = 0

# calculate the angle between 2 points about a center point
# c is the center of the dial, p0 is the initial click position, and p1 is the current drag position
func angle_diff(c : Vector2, p0 : Vector2, p1 : Vector2):
	# the first half of the expression is the angle in radians between p1 and the x axis
	# the second half of the expression is the angle offset in radians from the x axis, determined by p0
	var angle_delta_rad = atan2(p1.y - c.y, p1.x - c.x) - atan2(p0.y - c.y, p0.x - c.x)
	
	# convert to degrees before returning
	var angle_delta_deg = rad2deg(angle_delta_rad)

	return angle_delta_deg

# play unlock or locked sound effect
func play_sfx_open_attempt(success):
	# create new stream player and add it to the scene
	var new_stream_player = AudioStreamPlayer.new()
	add_child(new_stream_player)
	
	var sample_number
	var sample_path
	
	if(success):
		# choose random success sound effect
		sample_number = rng.randi_range(1,2)
		sample_path = "res://sound_assets/Safe-Success-" + str(sample_number) + ".mp3"
		new_stream_player.bus = "HandleSuccess"
		
		# open safe
		get_parent().get_parent().opening_safe = true
		
	else:
		# choose random fail sound effect
		sample_number = rng.randi_range(1,4)
		print(sample_number)
		sample_path = "res://sound_assets/Safe-Fail-" + str(sample_number) + ".mp3"
		new_stream_player.bus = "HandleFail"
	
	# load the corresponding audio path
	var sound_to_play = load(sample_path)
	
	# create new stream player instance to host the sound, then play the sound
	new_stream_player.stream = sound_to_play
	new_stream_player.play(0.0)
	
	# delete node once the sample finishes playing
	yield(new_stream_player, "finished")
	new_stream_player.stop()
	new_stream_player.queue_free()
