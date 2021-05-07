extends "res://scripts/button.gd"

export(int, "opt_vsync", "opt_music", "opt_sound", "opt_blood", "opt_high_effects", "tutorial_tips")var type = 0

var main_menu

var bg
var init_bg_modulate
var is_mouse_sound_played = false

var sound

var is_checked = false

func _ready():
	bg = get_node("bg")
	init_bg_modulate = bg.get_modulate()
	
	main_menu = get_tree().get_nodes_in_group("main_menu")[0]
	sound = get_tree().get_nodes_in_group("sound")[0]
	set_process(true)

func _process(delta):
	var is_ignore_pause = false
	
	if type == 0: # vsync
		is_checked = OPTIONS.get_config_value("options", "vsync")
	elif type == 1: # music
		is_checked = OPTIONS.get_config_value("options", "music")
	elif type == 2: # sound
		is_checked = OPTIONS.get_config_value("options", "sound")
	elif type == 3: # blood
		is_checked = OPTIONS.get_config_value("options", "blood")
	elif type == 4: # high effects
		is_checked = OPTIONS.get_config_value("options", "light_effects")
	elif type == 5: # dont_show_tutorial
		is_checked = OPTIONS.get_config_value("options", "tutorial_tips")

	if is_checked:
		get_node("bg/bg1").set_modulate(Color("#0009ee"))
		get_node("bg/bg1").set_region_rect(Rect2(50,25,25,25))
	else:
		get_node("bg/bg1").set_modulate(SYS.Colors.black)
		get_node("bg/bg1").set_region_rect(Rect2(50,0,25,25))
	
	if is_mouse_over(get_local_mouse_pos(), bg, is_ignore_pause):
		bg.set_modulate(SYS.Colors.red)
		if !is_mouse_sound_played:
			sound.play("gui", "button_enter")
			is_mouse_sound_played = true
		
		if is_mouse_clicked():
			sound.play("gui", "button_click")
			if is_checked:
				is_checked = false
			else:
				is_checked = true

			if type == 0: # vsync
				OPTIONS.change_config_value("options", "vsync", is_checked)
			elif type == 1: # music
				if is_checked:
					sound.set_music_stream(main_menu.mus_menu_scn)
				else:
					sound.set_music_stream(null)
				OPTIONS.change_config_value("options", "music", is_checked)
			elif type == 2: # sound
				OPTIONS.change_config_value("options", "sound", is_checked)
			elif type == 3: # blood
				OPTIONS.change_config_value("options", "blood", is_checked)
			elif type == 4: # high effects
				OPTIONS.change_config_value("options", "light_effects", is_checked)
			elif type == 5: # dont_show_tutorial
				OPTIONS.change_config_value("options", "tutorial_tips", is_checked)
	else:
		bg.set_modulate(init_bg_modulate)
		is_mouse_sound_played = false