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

func _ready():
	generate_rand_combination()


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
	
	# only update current combo term and update safe tick sfx filter cutoff
	match(current_combo_term):
		1:
			combo_term1 = term_to_string(current_term_value)
			tweak_bus_effects(combo_term1, solution_term1)
		2:
			combo_term2 = term_to_string(current_term_value)
			tweak_bus_effects(combo_term2, solution_term2)
		3:
			combo_term3 = term_to_string(current_term_value)
			tweak_bus_effects(combo_term3, solution_term3)
			

func _input(event):
	# reset game on esc press
	if Input.is_action_just_pressed("esc"):
		Global.reset_game()
	
	if Input.is_action_just_pressed("cheat"):
		generate_rand_combination(true)
	
	if Input.is_action_just_pressed("left_mouse"):
		play_safe_tick()
	
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
		play_safe_tick()
		if(int(combo_term1) == solution_term1 && current_combo_term == 1):
			play_safe_tick(true)
		elif(int(combo_term2) == solution_term2 && current_combo_term == 2):
			play_safe_tick(true)
		elif(int(combo_term3) == solution_term3 && current_combo_term == 3):
			play_safe_tick(true)
		
# generate random safe combination
func generate_rand_combination(cheat_mode = false):
	rng.randomize()
	solution_term1 = rng.randi_range(1,119)
	solution_term2 = rng.randi_range(1,119)
	solution_term3 = rng.randi_range(1,119)
	if(cheat_mode):
		var solution = str(solution_term1) + " " + str(solution_term2) + " " + str(solution_term3)
		print(solution)

# play safe tick sound effect
func play_safe_tick(solution = false):
	var sample_path
	
	# choose random tick sound effect
	if(solution):
		sample_path = "res://sound_assets/Safe-Solution-Tick.mp3"
		Global.play_sound(sample_path, "SolutionTick")
	else:
		var sample_number = rng.randi_range(1,4)
		sample_path = "res://sound_assets/Safe-Tick-" + str(sample_number) + ".mp3"
		Global.play_sound(sample_path, "SafeTick")


func test_solution():
	var term1_value = int(term1_label.text)
	var term2_value = int(term2_label.text)
	var term3_value = int(term3_label.text)
	if(solution_term1 == term1_value && solution_term2 == term2_value && solution_term3 == term3_value):
		return true
	else:
		return false

# use the distance from the current_term_value to the solution value to change audio effects based on distance to the solution term
func tweak_bus_effects(combo_term_value, solution_value):
	# calculate the shortest angular distance between the current term value and the solution value
	# the units are (degrees / 3)
	var solution_distance = abs( int(combo_term_value) - solution_value ) + 60
	solution_distance = abs( (solution_distance % 120) - 60 )
	
	# use formula to change values in the range (0,60) to values in the range (13000,2500)
	# so a distance of 0 would become 13000 and a distance of 60 would be 2500
	# this makes the ticks sound fuller the closer you get to the solution_term
	var new_cutoff = (-175 * solution_distance) + 13000
	
	# apply the new cutoff to the audio bus
	var bus_cutoff = AudioServer.get_bus_effect(AudioServer.get_bus_index("SafeTick"),1)
	bus_cutoff.cutoff_hz = new_cutoff
	
	# use formula to change values in the range (0,60) to values in the range (0,0.15)
	var new_reverb_wetness = 0.0025 * solution_distance
	
	# apply the new cutoff to the audio bus
	var bus_reverb = AudioServer.get_bus_effect(AudioServer.get_bus_index("SafeTick"),2)
	bus_reverb.wet = new_reverb_wetness
	
	
#	var bus_hipass = AudioServer.get_bus_effect(AudioServer.get_bus_index("SafeTick"),3)
#	if(solution_distance < 5):
#		# use formula to change values in the range (0,4) to values in the range (5000,1000)
#		var new_hipass_cutoff = (-solution_distance * 100) + 500
#		print(new_hipass_cutoff)
#
#		# apply the new cutoff to the audio bus
#		bus_hipass.cutoff_hz = new_hipass_cutoff
#		print(bus_hipass.cutoff_hz)
#	else:
#		bus_hipass.cutoff_hz = 1
