extends Sprite

export var gem_color = "clear"

var taken = false
var set_timer = false
var slide_down = false

onready var gem_pink = get_node("../gem-pink")
onready var gem_yellow = get_node("../gem-yellow")
onready var gem_blue = get_node("../gem-blue")

onready var safe_interior = get_parent()

var safe_open = false;

var slide_speed = 20
var slide_coefficient = 0
var slide_counter = 0.01

func _input(event):
	if Input.is_action_just_pressed("left_mouse") && (get_rect().has_point(to_local(event.position)) && safe_open):
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
		
		# after gems are taken, wait a sec and slide down, playing the safe opening sound while it occurs
		yield(get_tree().create_timer(0.75), "timeout")
		slide_down = true
		Global.play_sound("res://sound_assets/Safe-Opening.mp3", "SafeTick")
		
		# reset game after safe_interior fades away
		yield(get_tree().create_timer(1.0), "timeout")
		Global.reset_game()
		
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

	var sample_path = "res://sound_assets/Gem-Ting-" + str(sample_index) + ".mp3"
	
<<<<<<< Updated upstream
	Global.play_sound(sample_path, "Gems")
=======
	safe_open = false
>>>>>>> Stashed changes
