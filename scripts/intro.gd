extends Node2D

onready var sound = get_node("sound")
onready var tabs = get_node("tabs")

var tab_timer = TIME.create_new_timer("intro_tab_timer", 4.3)
var tab_block_timer = TIME.create_new_timer("intro_tab_block_timer", 0.8)
var cur_tab_num
var cur_tab_block_num = 0

func _ready():
	set_cur_anim_tab(1)
	set_process(true)

func _process(delta):
	if tab_timer.is_finish():
		if cur_tab_num == 3:
			get_tree().change_scene("res://scenes/main_menu.tscn")
		else:
			set_cur_anim_tab(cur_tab_num + 1)
	else:
		if cur_tab_num == 2:
			if tab_block_timer.is_finish():
				
				if cur_tab_block_num == 0:
					tabs.get_node("tab2/block1").show()
				elif cur_tab_block_num == 1:
					tabs.get_node("tab2/block2").show()
				elif cur_tab_block_num == 2:
					tabs.get_node("tab2/block3").show()

				if cur_tab_block_num <= 2:
					sound.play("ui","block_showed")
				
				cur_tab_block_num += 1
				tab_block_timer.reload()			


func set_cur_anim_tab(_num):
	if cur_tab_num != _num:
		cur_tab_num = _num
		tab_block_timer.reload()
		cur_tab_block_num = 0

		if cur_tab_num == 3:
			sound.play("ui","headphones")
		else:
			sound.play("ui","tab_showed")

		for tab in tabs.get_children():
			tab.hide()

		var cur_tab 
		if cur_tab_num == 1:
			cur_tab = tabs.get_node("tab1")
		elif cur_tab_num == 2:
			cur_tab = tabs.get_node("tab2")
		elif cur_tab_num == 3:
			cur_tab = tabs.get_node("tab3")

		cur_tab.show()

		tab_timer.reload()