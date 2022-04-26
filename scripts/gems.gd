extends Sprite

export var gem_color = "clear"

var taken = false
var set_timer = false
var slide_down = false

onready var gem_pink = get_node("../gem-pink")
onready var gem_yellow = get_node("../gem-yellow")
onready var gem_blue = get_node("../gem-blue")

onready var gem_pink_init_pos = gem_pink.position
onready var gem_yellow_init_pos = gem_yellow.position
onready var gem_blue_init_pos = gem_blue.position
onready var gem_scale = gem_pink.scale

onready var safe_interior = get_parent()

var slide_speed = 20
var slide_coefficient = 0
var slide_counter = 0.01


func _input(event):
	if Input.is_action_just_pressed("left_mouse") && get_rect().has_point(to_local(event.position)):
		taken = true
		play_ting_sound()

func _process(delta):
	if(taken && self.position.y < 1000):
		self.position.y += 15
		self.position.x -= 2
		self.scale.y -= 0.05
		self.scale.x -= 0.05
	if(gem_pink.taken && gem_yellow.taken && gem_blue.taken && !set_timer):
		set_timer = true
		yield(get_tree().create_timer(0.75), "timeout")
		slide_down = true
		yield(get_tree().create_timer(1.0), "timeout")
		get_node("../../bg_front/dial").reset_game()
		reset_interior()
	if(slide_down):
		safe_interior.position.y += slide_speed * slide_coefficient
		slide_counter += 0.01
		slide_coefficient = slide_counter * slide_counter * (3.0 - 2.0 * slide_counter)

func play_ting_sound():
	
	var sample_index
	match(gem_color):
		"pink":
			sample_index = 1
		"yellow":
			sample_index = 2
		"blue":
			sample_index = 3
	
	var new_stream_player = AudioStreamPlayer.new()
	add_child(new_stream_player)
	
	var sample_path = "res://sound_assets/Gem-Ting-" + str(sample_index) + ".mp3"
	
	# load the audio path
	var sound_to_play = load(sample_path)
	
	# create new stream player instance to host the sound, then play the sound
	new_stream_player.stream = sound_to_play
	new_stream_player.bus = "Gems"
	new_stream_player.play(0.0)
	
	# delete node once the sample finishes playing
	yield(new_stream_player, "finished")
	new_stream_player.stop()
	new_stream_player.queue_free()

func reset_interior():
	safe_interior.position.y = 0
	gem_pink.position = gem_pink_init_pos
	gem_yellow.position = gem_yellow_init_pos
	gem_blue.position = gem_blue_init_pos
	gem_pink.scale = gem_scale
	gem_yellow.scale = gem_scale
	gem_blue.scale = gem_scale
	
