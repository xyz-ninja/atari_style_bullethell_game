extends Node

class Timer:
	var id = 0

	var init_time = 0
	var timer = 0

	var name = "unknown" # also a dict key

	func _init(_id, _init_time):
		id = _id
		init_time = _init_time
		timer = init_time

	func update(_delta):
		if timer > 0:
			timer -= _delta
		else:
			timer = -0.001

	func reload():
		timer = init_time

	func change_init_time(_new_time):
		init_time = _new_time
		reload()

	func check_time():
		return timer
		
	func finish():
		timer = 0

	func set_name(_name):
		name = _name

	func is_finish(): # return true when timer is over
		if timer < 0:
			return true
		else:
			return false	

var Timers = {}
var timers_updater = []
var last_timer_id = 0

func _ready():
	create_new_timer("button_timer", 0.1)

	set_process(true)

func _process(delta):
	for timer in timers_updater:
		timer.update(delta)

func create_new_timer(_str_timer_name,_init_time):
	var new_timer = Timer.new(last_timer_id, _init_time)
	last_timer_id += 1

	var init_timer_name = _str_timer_name
	var timer_name = init_timer_name

	# проверяем ключи других таймеров, если такой уже есть назначаем ему свой id
	for timer_key in Timers.keys():
		var cur_key = ""
		var cur_key_id = ""
		var is_now_analyse_id = false

		for let in timer_key:
			if is_now_analyse_id:
				cur_key_id += let
			else:
				if let == "#":
					is_now_analyse_id = true
					cur_key_id = ""
				else:
					cur_key += let

			if cur_key == init_timer_name:
				if cur_key_id == "":
					timer_name = init_timer_name + "#1"
				else:
					timer_name = init_timer_name + "#" + str(int(cur_key_id) + 1)

	new_timer.set_name(timer_name)

	Timers[timer_name] = new_timer
	timers_updater.append(new_timer)

	return Timers[timer_name]
	
func destroy_timer(_timer):
	var erase_timer = _timer
	var erase_key = erase_timer.name	

	if erase_key == null:
		print("SYS TIME timer destroy error! Key not found")
	else:
		Timers.erase(erase_key)

func destroy_timer_by_name(_str_timer_name):
	Timers.erase(_str_timer_name)
