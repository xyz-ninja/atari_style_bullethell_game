extends Node2D

onready var sound = get_node("sound")
onready var tabs = get_node("tabs")
var mus_win = load("res://music/final.ogg")

var tab_timer = TIME.create_new_timer("final_tab_timer", 7.0)
var cur_tab_num

func _ready():
	set_cur_anim_tab(1)
	set_process(true)

func _process(delta):
	if tab_timer.is_finish():
		if cur_tab_num == 4:
			get_tree().change_scene("res://scenes/main_menu.tscn")
		else:
			set_cur_anim_tab(cur_tab_num + 1)

func set_cur_anim_tab(_num):
	if cur_tab_num != _num:
		cur_tab_num = _num

		for tab in tabs.get_children():
			tab.hide()

		var cur_tab 
		if cur_tab_num == 1:
			cur_tab = tabs.get_node("tab1")
			cur_tab.get_node("text").set_gradual_text(
				"Whether this creature was a devil or not is no longer important.", 0.06
			)
		elif cur_tab_num == 2:
			cur_tab = tabs.get_node("tab2")
			cur_tab.get_node("text").set_gradual_text(
				"The euphoria of victory gave him confidence that everything was over.", 0.06
			)
		elif cur_tab_num == 3:
			cur_tab = tabs.get_node("tab3")
			cur_tab.get_node("text").set_gradual_text(
				"The thief can finally rest.", 0.09
			)
		elif cur_tab_num == 4:
			cur_tab = tabs.get_node("tab4")
			sound.set_music_stream(mus_win)

			tab_timer.change_init_time(13.0)

		cur_tab.show()

		tab_timer.reload()