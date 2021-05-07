extends Node2D

var is_hacks_enabled = false
var is_vsync_enabled = true
var is_tutorial_enabled = true
var is_light_effects_enabled = true
var is_music_enabled = true
var is_sound_enabled = true
var is_blood_enabled = true

var config_path = "user://options.cfg"
var save_path = "user://save.dat"

func _ready():
	check_config()

# CONFIG
func check_config():
	var config = ConfigFile.new()
	var load_status = config.load(config_path)

	if load_status == OK:
		setup_by_config()
	else:
		print("CREATING CONFIG FILE...")

		config.set_value("options", "hacks", false)
		config.set_value("options", "vsync", true)
		config.set_value("options", "tutorial_tips", true)
		config.set_value("options", "light_effects", true)
		config.set_value("options", "music", true)
		config.set_value("options", "sound", true)
		config.set_value("options", "blood", true)

		config.save(config_path)

		setup_by_config()

func setup_by_config():
	var config = ConfigFile.new()
	config.load(config_path)

	is_hacks_enabled = config.get_value("options", "hacks", false)
	is_vsync_enabled = config.get_value("options", "vsync", true)
	OS.set_use_vsync(is_vsync_enabled)
	
	is_tutorial_enabled = config.get_value("options", "tutorial_tips", true)
	is_light_effects_enabled = config.get_value("options", "light_effects", true)
	is_music_enabled = config.get_value("options", "music", true)
	is_sound_enabled = config.get_value("options", "sound", true)
	is_blood_enabled = config.get_value("options", "blood", true)

func change_config_value(_section_name, _key, _bool):
	var section_name = _section_name
	var k = _key
	var is_enabled = _bool

	var config = ConfigFile.new()
	var load_status = config.load(config_path)
	if load_status != OK:
		check_config()
		print("CONFIG LOAD STATUS ERROR!")

	if config.has_section_key(section_name, k):
		config.set_value(section_name, k, is_enabled)
		config.save(config_path)
		setup_by_config()
	else:
		print("change_config_value() error! this section_key pair dont found.")

func get_config_value(_section_name, _key):
	var section_name = _section_name
	var k = _key

	var config = ConfigFile.new()
	var load_status = config.load(config_path)
	if load_status != OK:
		check_config()
		print("CONFIG LOAD STATUS ERROR!")
	return config.get_value(section_name, k)

# SAVE
var save_content_params = {
	game_version = {cur = 1.1, default = 1.1},
	start_from_level = {cur = 1, default = 1},
	player_level = {cur = 1, default = 1},
	player_items = {cur = [], default = [6]}
}
var save_var_type_key = {
	type_int = "int",
	type_float = "float",
	type_str = "str",
	type_int_arr = "int_arr"
}

func load_save():
	var f = File.new()
	f.open(save_path, f.READ)
	var content = f.get_as_text()
	
	# parse save content, в gdscript нет указателей так что придётся ебаться вот так
	var is_now_parse_key = false
	var cur_key = ""
	var is_now_parse_var_type_key = false
	var cur_var_type_key = ""
	var is_now_parse_val = false
	var cur_val = ""
	
	var cur_real_val # преобразованное в настоящую переменную str значение cur_val

	for ch in content:
		var is_need_write_this_char = true
		# получаем имя ключа
		if ch == "-":
			cur_key = ""
			is_now_parse_key = true
			is_now_parse_var_type_key = false
			is_now_parse_val = false
		# получаем имя типа переменной
		elif ch == "(":
			cur_var_type_key = ""
			is_now_parse_key = false
			is_now_parse_var_type_key = true
			is_now_parse_val = false
		# получаем значение переменной
		elif ch == ")":
			cur_val = ""
			is_now_parse_key = false
			is_now_parse_var_type_key = false
			is_now_parse_val = true
		elif ch == "!":
			is_need_write_this_char = false
			
			#print("new_line! saving values..")
			#print("cur_key: " + cur_key)
			#print("cur_var_type_key: " + cur_var_type_key)
			#print("cur_val: " + cur_val)

			# СОХРАНЯЕМ ДАННЫЕ в save_content_params
			# получаем настоящее значение переменной по cur_var_type_key
			if cur_var_type_key == save_var_type_key.type_int:
				cur_real_val = int(cur_val)
			elif cur_var_type_key == save_var_type_key.type_float:
				cur_real_val = float(cur_val)
			elif cur_var_type_key == save_var_type_key.type_str:
				cur_real_val = str(cur_val)
			elif cur_var_type_key == save_var_type_key.type_int_arr:
				# получаем массив чисел через небольшой парсинг
				var cur_str = ""
				var cur_arr = []
				for ch in cur_val:
					
					if ch == "[" or ch == "," or ch == "]":
						if cur_str != "":
							cur_arr.append(int(cur_str))
						cur_str = ""
					else:
						cur_str += ch
				cur_real_val = cur_arr + []
			else:
				print("SAVE ERROR! cannot setup real var value..")

			if save_content_params.has(cur_key):
				save_content_params[cur_key].cur = cur_real_val
			else:
				print("SAVE ERROR! save_content_params doesnt have cur_key.. ")

			#print("real_val: " + str(cur_real_val))

		elif ch == ":" or ch == " ":
			is_need_write_this_char = false

		else:
			if is_need_write_this_char:
				if is_now_parse_key:
					cur_key += ch
				elif is_now_parse_var_type_key:
					cur_var_type_key += ch
				elif is_now_parse_val:
					cur_val += ch
	f.close()

	print(save_content_params)

func save_game():
	# в файле сохранения сохраняются разные типы данных
	# пример @имя_переменной(int):13
	var content = ""
	
	print("saved")

	var f = File.new()
	f.open(save_path, f.WRITE)

	for k in save_content_params.keys():
		var cur_v = save_content_params[k].cur
		content += "-" + k + "(" + get_str_key_of_var_type(cur_v) + "):" + str(cur_v) + "!\n"

	f.store_string(content)
	f.close()

func change_save_content_param_value(_key, _val):
	if save_content_params.has(_key):
		save_content_params[_key].cur = _val
		save_game()
	else:
		print("change_save_content_param_value() error! key not found..")

func restore_save_default_values():
	print("restored")
	for k in save_content_params.keys():
		save_content_params[k].cur = save_content_params[k].default
	save_game()

# получает текстовый ключ типа переменной для сохранения
func get_str_key_of_var_type(_var):
	var v = _var
	var str_key
	if typeof(v) == TYPE_INT:
		str_key = save_var_type_key.type_int
	elif typeof(v) == TYPE_REAL:
		str_key = save_var_type_key.type_float
	elif typeof(v) == TYPE_STRING:
		str_key = save_var_type_key.type_str
	elif typeof(v) == TYPE_ARRAY:
		# тут доп.проверка значений массива
		# сейчас только числа
		str_key = save_var_type_key.type_int_arr

	return str_key