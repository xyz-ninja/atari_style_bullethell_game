extends Label

var cur_text
export var final_text = ""

export var typing_speed = 0.1
#var typing_timer = TIME.create_new_timer("typing_timer", typing_speed)

var typing_time = 0.1
var typing_timer = typing_time

var is_finish = false
var wait_when_this_gradual_text_finish

var game
var sound

func _ready():
	var game_nodes = get_tree().get_nodes_in_group("game")
	if game_nodes.size() != 0:
		game = game_nodes[0]
	
	set_text("")
	
	var sound_nodes = get_tree().get_nodes_in_group("sound")
	if sound_nodes.size() > 0:
		sound = sound_nodes[0]

	if final_text != "":
		set_gradual_text(final_text, typing_speed)

	set_process(true)
	
func _process(delta):
	# если нужно ждать когда напишется другой постепенный текст
	# если такой текст ещё не написан
	if wait_when_this_gradual_text_finish != null and !wait_when_this_gradual_text_finish.is_finish:
		#typing_timer.reload()
		typing_timer = typing_time
	else:
		typing_timer -= delta

		if cur_text != null and cur_text != final_text:
			show()
			#if typing_timer.is_finish():
			if typing_timer < 0:
				cur_text += final_text[cur_text.length()]
				#typing_timer.reload()

				if sound != null:
					sound.play("env", "char")

				typing_timer = typing_time

			set_text(cur_text)
			is_finish = false
		else:
			is_finish = true

func set_gradual_text(_text, _typing_speed = 0.2, _wait_when_this_gradual_text_finish = null):
	cur_text = ""
	final_text = _text
	typing_speed = _typing_speed
	wait_when_this_gradual_text_finish = _wait_when_this_gradual_text_finish
	
	hide()
	
	typing_time = _typing_speed
	typing_timer = typing_time
	
	#if typing_timer.init_time != typing_speed:
	#	typing_timer.change_init_time(typing_speed)