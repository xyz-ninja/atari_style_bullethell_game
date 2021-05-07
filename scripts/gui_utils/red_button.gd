extends "res://scripts/button.gd"

export(int, "start", "options", "options_save", "char_select_start", "tutorial_go", "restart_game", "main_menu")var type = 0

var bg
var init_bg_modulate
var is_mouse_sound_played = false

var main_menu
var sound

func _ready():
	bg = get_node("bg")
	init_bg_modulate = bg.get_modulate()
	
	var main_menu_nodes = get_tree().get_nodes_in_group("main_menu")
	if main_menu_nodes.size() > 0:
		main_menu = main_menu_nodes[0]
	
	sound = get_tree().get_nodes_in_group("sound")[0]
	set_process(true)

func _process(delta):
	var is_ignore_pause = false
	
	if is_mouse_over(get_local_mouse_pos(), bg, is_ignore_pause):
		bg.set_modulate(SYS.Colors.blue)
		if !is_mouse_sound_played:
			sound.play("gui", "button_enter")
			is_mouse_sound_played = true
		
		if is_mouse_clicked():
			sound.play("gui", "button_click")
		
			if type == 0:  # start
				main_menu.show_tab(main_menu.TABS.CHARACTER_SELECT)
			elif type == 1: # options
				main_menu.show_tab(main_menu.TABS.OPTIONS)
			elif type == 2: # options save
				pass
			elif type == 3: # char select start
				OPTIONS.restore_save_default_values()

				if OPTIONS.is_tutorial_enabled:
					main_menu.show_tab(main_menu.TABS.TUTORIAL)
				else:
					get_tree().change_scene("res://scenes/game.tscn")
			elif type == 4: # tutorial go
				get_tree().change_scene("res://scenes/game.tscn")
			elif type == 5: # restart game
				OPTIONS.restore_save_default_values()
				get_tree().set_pause(false)
				get_tree().change_scene("res://scenes/game.tscn")
			elif type == 6: # main menu
				main_menu.show_tab(main_menu.TABS.MAIN_MENU)
	else:
		bg.set_modulate(init_bg_modulate)
		is_mouse_sound_played = false