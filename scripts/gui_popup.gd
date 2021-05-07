extends Node2D

var game
var gui

onready var tabs = get_node("tabs")

var cur_tab
var from_event # событие с которым был вызван popup
var is_opened = false

var loc_autoclose_time = null
var loc_autoclose_timer = null

var init_scale
var show_scale_up_speed = 5

func _ready():
	init_scale = get_scale()

	gui = get_tree().get_nodes_in_group("gui")[0]
	game = get_tree().get_nodes_in_group("game")[0]

	set_process(true)
	
func _process(delta):
	if cur_tab == gui.POPUP_TAB.GAME_OVER:
		if Input.is_action_pressed("ui_select"):
			get_tree().set_pause(false)
			get_tree().change_scene("res://scenes/game.tscn")
		elif Input.is_action_pressed("esc"):
			get_tree().change_scene("res://scenes/main_menu.tscn")
			get_tree().set_pause(false)

	if loc_autoclose_time != null:
		if loc_autoclose_time < 9999:
			loc_autoclose_timer -= delta

		if loc_autoclose_timer < 1.0:
			var cur_scale = get_scale()
			set_scale(Vector2(cur_scale.x * loc_autoclose_timer, cur_scale.y * loc_autoclose_timer))

		elif loc_autoclose_timer > loc_autoclose_time - 0.5:
			var cur_scale = get_scale()
			
			if cur_scale.x < init_scale.x:
				var ds = 0
				ds = show_scale_up_speed * delta

				cur_scale.x += ds
				cur_scale.y += ds

				if cur_scale.x > init_scale.x:
					cur_scale = init_scale

				set_scale(cur_scale)

		else:
			set_scale(init_scale)

		if loc_autoclose_timer < 0:
			close()

func open_tab(_tab, _from_event = null):
	cur_tab = _tab
	from_event = _from_event

	loc_autoclose_time = null
	
	hide_all_tabs()

	set_scale(Vector2(0, 0))

	if cur_tab == gui.POPUP_TAB.FAITH_OVERDOSE:
		tabs.get_node("tab_too_much_faith/header").set_gradual_text("your faith is too strong", 0.02)

		var logo_color = SYS.Colors.gray # HAS GRAY AND RED LOGO VARIATIONS
		var cur_logo_node
		var logo_x_offset = 0

		var show_debuffs_node = true

		var event_desc = "no faith event desc"
		if from_event == game.EVENTS.S_FAITH_DEVIL_ARRIVE:
			event_desc = "the devil has arrived"
			logo_color = SYS.Colors.red
			logo_x_offset = 0
			show_debuffs_node = false

		elif from_event == game.EVENTS.S_FAITH_OVERDOSE:
			event_desc = "temporarily you cannot use the cross"
			logo_x_offset = 1

		elif from_event == game.EVENTS.S_FAITH_PACIFISM:
			event_desc = "temporary PACIFISM"
			logo_x_offset = 2

		elif from_event == game.EVENTS.S_FAITH_MASOHISM:
			event_desc = "temporary MASOHISM"
			logo_x_offset = 3

		if logo_color == SYS.Colors.red:
			cur_logo_node = tabs.get_node("tab_too_much_faith/logo_red")
			tabs.get_node("tab_too_much_faith/logo_gray").hide()
		else:
			cur_logo_node = tabs.get_node("tab_too_much_faith/logo_gray")
			tabs.get_node("tab_too_much_faith/logo_red").hide()

		cur_logo_node.set_region_rect(Rect2(50 * logo_x_offset, 0, 50, 50))
		cur_logo_node.show()

		tabs.get_node("tab_too_much_faith/desc/text").set_gradual_text(event_desc, 0.03, 
			tabs.get_node("tab_too_much_faith/header"))

		tabs.get_node("tab_too_much_faith").show()
		loc_autoclose_time = 4.3

	elif cur_tab == gui.POPUP_TAB.BOSS_ARRIVE:
		tabs.get_node("tab_boss_appears/warning").set_gradual_text("WARNING!\nmeet the..", 0.085)
		
		var boss_name = "unknown boss"
		var boss_logo_x_offset = 0

		if from_event == game.EVENTS.BOSS_NECROMANCER:
			boss_name = "Maddened Necromancer"
			boss_logo_x_offset = 0
		elif from_event == game.EVENTS.BOSS_SKINEATER:
			boss_name = "Skin Eater"
			boss_logo_x_offset = 2
		elif from_event == game.EVENTS.BOSS_MUSHROOM:
			boss_name = "Mushroom Wannabe"
			boss_logo_x_offset = 4
		elif from_event == game.EVENTS.BOSS_UGLY_THING:
			boss_name = "Ugly Thing"
			boss_logo_x_offset = 6
		elif from_event == game.EVENTS.BOSS_SATAN:
			boss_name = "SATAN"
			boss_logo_x_offset = 8

		tabs.get_node("tab_boss_appears/desc/text").set_gradual_text(boss_name, 0.04, 
			tabs.get_node("tab_boss_appears/warning"))

		tabs.get_node("tab_boss_appears/logo").set_region_rect(Rect2(60 * boss_logo_x_offset, 0, 60, 60))

		tabs.get_node("tab_boss_appears").show()
		
		loc_autoclose_time = 5.75
		#loc_autoclose_time = 1

	elif cur_tab == gui.POPUP_TAB.ITEM_REWARD:
		tabs.get_node("tab_item_reward/header").set_gradual_text("the liberated soul offers a reward", 0.04)
		tabs.get_node("tab_item_reward/desc/text").set_gradual_text("CHOOSE\nWISELY", 0.085, 
			tabs.get_node("tab_item_reward/header"))

		tabs.get_node("tab_item_reward").show()

		loc_autoclose_time = 5
	elif cur_tab == gui.POPUP_TAB.GAME_OVER:
		#tabs.get_node("tab_game_over/desc/text").set_gradual_text("MORTIS", 0.06)
		tabs.get_node("tab_game_over").show()
		loc_autoclose_time = 9999

	loc_autoclose_timer = loc_autoclose_time

	get_tree().set_pause(true)

	show()

func close():
	get_tree().set_pause(false)

	if cur_tab == gui.POPUP_TAB.FAITH_OVERDOSE:
		if from_event == game.EVENTS.S_FAITH_DEVIL_ARRIVE:
			game.spawn_unit_from_scene(game.u_faith_devil_scn, Vector2(-10, game.play_region_y_start_pos - 10))
	
	elif cur_tab == gui.POPUP_TAB.BOSS_ARRIVE:
		if from_event == game.EVENTS.BOSS_NECROMANCER:
			game.spawn_unit_from_scene(game.u_lvl1_BOSS_necromancer_scn,
				Vector2(-10, game.play_region_y_start_pos - 10))
		elif from_event == game.EVENTS.BOSS_SKINEATER:
			game.spawn_unit_from_scene(game.u_lvl2_BOSS_skineater_scn,
				Vector2(game.play_region_x_end_pos / 2, game.play_region_y_start_pos + 30))
		elif from_event == game.EVENTS.BOSS_MUSHROOM:
			game.spawn_unit_from_scene(game.u_lvl3_BOSS_mushroom_scn,
				Vector2(game.play_region_x_end_pos / 2, game.play_region_y_start_pos + 160))
		elif from_event == game.EVENTS.BOSS_UGLY_THING:
			game.spawn_unit_from_scene(game.u_lvl4_BOSS_ugly_thing_scn,
				Vector2(game.play_region_x_end_pos / 2, game.play_region_y_start_pos + 160))
		elif from_event == game.EVENTS.BOSS_SATAN:
			game.spawn_unit_from_scene(game.u_lvl5_BOSS_satan_lvl1,
				Vector2(game.play_region_x_end_pos / 2, game.play_region_y_start_pos + 160))

	elif cur_tab == gui.POPUP_TAB.ITEM_REWARD:
		game.spawn_reward_items()

	hide()

	cur_tab = null
	from_event = null

func hide_all_tabs():
	for tab_node in tabs.get_children():
		tab_node.hide()