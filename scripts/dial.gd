extends Sprite

var rng = RandomNumberGenerator.new()

var click_pos = Vector2.ZERO
var dial_rotation = 0

var prev_term_value = 0
var current_term_value = 0
var current_combo_term = 1

# combo term label nodes
onready var term1_label = get_node("../combo_term1")
onready var term2_label = get_node("../combo_term2")
onready var term3_label = get_node("../combo_term3")

onready var handle = get_node("../handle")

var combo_term1 = "000"
var combo_term2 = "000"
var combo_term3 = "000"

var prev_term1_text = "000"
var prev_term2_text = "000"
var prev_term3_text = "000"

var clockwise = true
var skip_tolerance = 20

var solution_term1
var solution_term2
var solution_term3

var is_dragging = false

signal safe_tick

func _ready():
#	OS.window_fullscreen = true
	generate_rand_combination()
	connect("safe_tick", self, "play_safe_tick")
	
	var solution = str(solution_term1) + " " + str(solution_term2) + " " + str(solution_term3)
	print(solution)

func _process(delta):
	# on direction change, move on to the next combo term
	if(prev_term_value < current_term_value && abs(prev_term_value - current_term_value) < skip_tolerance && clockwise):
		current_combo_term += 1
		clockwise = false
		
	elif(prev_term_value > current_term_value && abs(prev_term_value - current_term_value) < skip_tolerance && !clockwise):
		current_combo_term += 1
		clockwise = true
	
	# reset terms after third direction change
	if(current_combo_term > 3):
		combo_term1 = "000"
		combo_term2 = "000"
		combo_term3 = "000"
		current_combo_term = 1
	
	# only update current combo term and update safe tick sfx pitch
	match(current_combo_term):
		1:
			combo_term1 = term_to_string(current_term_value)
			change_bus_pitch(combo_term1, solution_term1)
		2:
			combo_term2 = term_to_string(current_term_value)
			change_bus_pitch(combo_term2, solution_term2)
		3:
			combo_term3 = term_to_string(current_term_value)
			change_bus_pitch(combo_term3, solution_term3)
			

func _input(event):
	# store term value to check for updates
	prev_term_value = get_term_value()
	
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
		
		# rotate the dial using the current dial_rotation as an offset
		self.rotation_degrees = add_rotation + dial_rotation
		
		# convert any rotation angle above or below the range (0,359) to its corresponding angle in that range
		self.rotation_degrees = ( ( int(self.rotation_degrees) % 360 ) + 360 ) % 360
		
		current_term_value = get_term_value()
		
	update_combination()
	
	if(test_solution()):
		handle.locked = false
	else:
		handle.locked = true


# calculate the angle between 2 points about a center point
# c is the center of the dial, p0 is the initial click position, and p1 is the current drag position
func angle_diff(c : Vector2, p0 : Vector2, p1 : Vector2):
	# the first half of the expression is the angle in radians between p1 and the x axis
	# the second half of the expression is the angle offset in radians from the x axis, determined by p0
	var angle_delta_rad = atan2(p1.y - c.y, p1.x - c.x) - atan2(p0.y - c.y, p0.x - c.x)
	
	# convert to degrees before returning
	var angle_delta_deg = rad2deg(angle_delta_rad)

	return angle_delta_deg

# calculate the term value from the rotation value and convert it to the correct type
func get_term_value():
	var calculated_term_value = self.rotation_degrees / 3
	
	# round down from rotation_degrees float value
	calculated_term_value = int( floor(calculated_term_value) )
	
	# make sure term direction aligns with dial sprite marks and 0 doesn't become 120
	if(calculated_term_value != 0): calculated_term_value = abs(120-calculated_term_value)
	
	return calculated_term_value

# add additional prefix zeros to term
func term_to_string(raw_term):
	raw_term = int(raw_term)
	
	# avoid multiply by zero errors
	if(raw_term == 0):
		return "000"
	
	var multiplied_term = raw_term
	var prefix = ""
	
	# add prefix zero for every power of 10 not in the raw_term up to 1000
	for i in 2:
		multiplied_term *= 10
		if(multiplied_term > 0 && multiplied_term < 1000):
			prefix += "0"
	
	return prefix + str(raw_term)
	

# update combo term labels and check for term updates to play 
func update_combination():
	# store prev_terms to check for term updates
	prev_term1_text = term1_label.text
	prev_term2_text = term2_label.text
	prev_term3_text = term3_label.text
	
	# set combo labels to combo_terms
	term1_label.text = str(combo_term1)
	term2_label.text = str(combo_term2)
	term3_label.text = str(combo_term3)
	
	# on term update, play tick sound
	if(term1_label.text != prev_term1_text || term2_label.text != prev_term2_text || term3_label.text != prev_term3_text):
		emit_signal("safe_tick")

# generate random safe combination
func generate_rand_combination():
	rng.randomize()
	solution_term1 = rng.randi_range(1,119)
	solution_term2 = rng.randi_range(1,119)
	solution_term3 = rng.randi_range(1,119)

# play safe tick sound effect
func play_safe_tick():
	# create new stream player and add it to the scene
	var new_stream_player = AudioStreamPlayer.new()
	add_child(new_stream_player)
	
	# choose random tick sound effect
	var sample_number = rng.randi_range(1,4)
	var sample_path = "res://sound_assets/Safe-Tick-" + str(sample_number) + ".mp3"
	
	# load the random audio path
	var sound_to_play = load(sample_path)
	
	# create new stream player instance to host the sound, then play the sound
	new_stream_player.stream = sound_to_play
	new_stream_player.bus = "SafeTick"
	new_stream_player.play(0.0)
	
	# delete node once the sample finishes playing
	yield(new_stream_player, "finished")
	new_stream_player.stop()
	new_stream_player.queue_free()

func test_solution():
	var term1_value = int(term1_label.text)
	var term2_value = int(term2_label.text)
	var term3_value = int(term3_label.text)
	if(solution_term1 == term1_value && solution_term2 == term2_value && solution_term3 == term3_value):
		return true
	else:
		return false

func change_bus_pitch(combo_term_value, solution_value):
#	var new_pitch_scale = abs( float(combo_term_value) - solution_value ) + 1
#	var new_pitch_scale = abs( int(combo_term_value) - solution_value ) + 60
#	new_pitch_scale = abs( (new_pitch_scale % 120) - 60 )
#	new_pitch_scale = ( float(new_pitch_scale) / 2000 ) + 1
#	print(new_pitch_scale)
#	var bus_pitch = AudioServer.get_bus_effect(AudioServer.get_bus_index("SafeTick"),1)
#	bus_pitch.pitch_scale = new_pitch_scale

	var new_cutoff = abs( int(combo_term_value) - solution_value ) + 60
	new_cutoff = abs( (new_cutoff % 120) - 60 )
	new_cutoff = (new_cutoff * 50) + 1000
	var bus_cutoff = AudioServer.get_bus_effect(AudioServer.get_bus_index("SafeTick"),1)
	bus_cutoff.cutoff_hz = new_cutoff
