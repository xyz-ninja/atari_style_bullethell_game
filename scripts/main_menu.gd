extends Node2D

enum TABS {MAIN_MENU, OPTIONS, CHARACTER_SELECT, TUTORIAL}

var mus_menu_scn = load("res://music/menu.ogg")

var sound

func _ready():
	sound = get_node("sound")
	
	sound.set_music_stream(mus_menu_scn)

func show_tab(_enum_tab):
	var enum_tab = _enum_tab
	hide_all_tabs()

	var cur_tab
	if enum_tab == TABS.MAIN_MENU:
		cur_tab = get_node("tabs/tab_menu")
	elif enum_tab == TABS.OPTIONS:
		cur_tab = get_node("tabs/tab_options")
	elif enum_tab == TABS.CHARACTER_SELECT:
		cur_tab = get_node("tabs/tab_char_select")
	elif enum_tab == TABS.TUTORIAL:
		cur_tab = get_node("tabs/tab_tutorial")

	cur_tab.show()

func hide_all_tabs():
	for tab in get_node("tabs").get_children():
		tab.hide()