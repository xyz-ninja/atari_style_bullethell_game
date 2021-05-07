extends CanvasLayer

onready var game = get_parent()

onready var popup = get_node("popup")
onready var messagebox = get_node("top/message_box")
onready var character_portrait = get_node("bottom/character_portrait")
onready var faith_icons_pb = get_node("top/faith_icons_pb")
onready var entering_level_info = get_node("entering_level_info")

enum POPUP_TAB {FAITH_OVERDOSE, BOSS_ARRIVE, ITEM_REWARD, GAME_OVER}

var units_below_screen_track_icons_params = []

var is_messagebox_active = false 
var messagebox_show_timer = TIME.create_new_timer("messagebox_show_timer", 3.2)

var items_icons_nodes = []

var player_fade_anim_speed = 60
var player_fade_anim_timer = TIME.create_new_timer("player_fade_anim_timer", 0.05)
var min_fade_scale = 1.1
var max_fade_scale = 20.0
var is_player_fade_in_anim_active = false
var is_player_fade_in_anim_finished = false
var is_player_fade_out_anim_active = false
var is_player_fade_out_anim_finished = true
var show_level_name_timer = TIME.create_new_timer("show_level_name_timer", 1.5)

func _ready():
	pass

func update(delta):
	if game.cur_enemy_units.size() == 0:
		units_below_screen_track_icons_params = []

	# SYS INFO
	var sys_info_text = ""
	sys_info_text += "PLAYER CUR POWER: " + str(game.player.cur_power) + "\n"
	sys_info_text += "POWER TIMER: " + str(game.player.power_timer.check_time())
	get_node("sys_info").set_text(sys_info_text)
	
	if game.player.is_need_blink:
		get_node("player_hurt_bg").show()
	else:
		get_node("player_hurt_bg").hide()

	# MESSAGE BOX
	if is_messagebox_active:
		messagebox.show()
		
		if messagebox_show_timer.check_time() > messagebox_show_timer.init_time - 1.0:
			var cur_messagebox_scale = messagebox.get_scale()
			if cur_messagebox_scale.x < 1.0:
				var new_x_scale = cur_messagebox_scale.x + 4 * delta
				if new_x_scale > 1.0:
					new_x_scale = 1.0

				messagebox.set_scale(Vector2(new_x_scale, 1.0))

		elif messagebox_show_timer.check_time() < 0.33:
			messagebox.set_scale(Vector2(messagebox_show_timer.check_time() * 3.0, 1.0))

		if messagebox_show_timer.is_finish():
			is_messagebox_active = false
	else:
		messagebox.hide()

	# PLAYER FADE IN/OUT ANIMATION
	var cur_pl_fade_scale = game.player.fade_anim.get_node("tex").get_scale()

	var ds = 0
	# FADE IN
	if is_player_fade_in_anim_active and !is_messagebox_active:

		game.sound.set_music_stream(game.mus_change_level_scn)

		if cur_pl_fade_scale.x <= min_fade_scale:
			
			is_player_fade_in_anim_finished = true

			# при событии NEXT_GAME_LEVEL, показываем доп информацию
			# после того как текст наберется, автоматически включается fade_out анимация
			if game.current_events.has(game.EVENTS.NEXT_GAME_LEVEL):
				if entering_level_info.is_visible():
					if entering_level_info.get_node("header").is_finish:
						if show_level_name_timer.is_finish():
							entering_level_info.hide()
							# МЕНЯЕМ УРОВЕНЬ
							OPTIONS.change_save_content_param_value("start_from_level", game.game_level + 1)

							#game.set_game_level(game.game_level + 1)

							# запускаем обратную анимацию
							play_player_fade_out_anim()

							get_tree().reload_current_scene()

					else:
						show_level_name_timer.reload()

				else:
					entering_level_info.get_node("entering").set_gradual_text("entering...", 0.03)
					entering_level_info.get_node("header").set_gradual_text(
						ENV.get_level_info_by_num(game.game_level + 1).header, 0.05,
						entering_level_info.get_node("entering")
					)

					show_level_name_timer.reload()

					entering_level_info.show()
			else:
				is_player_fade_in_anim_active = false
		else:
			if player_fade_anim_timer.is_finish():
				ds -= player_fade_anim_speed * delta
				player_fade_anim_timer.reload()

	# FADE OUT
	elif is_player_fade_out_anim_active and !is_messagebox_active:
		if cur_pl_fade_scale.x >= max_fade_scale:
			is_player_fade_out_anim_active = false
			is_player_fade_out_anim_finished = true

			if game.current_events.has(game.EVENTS.NEXT_GAME_LEVEL):
				game.complete_event(game.EVENTS.NEXT_GAME_LEVEL)

			game.player.fade_anim.hide()
		else:
			if player_fade_anim_timer.is_finish():
				ds += player_fade_anim_speed * delta
				player_fade_anim_timer.reload()

	game.player.fade_anim.get_node("tex").set_scale(Vector2(cur_pl_fade_scale.x + ds, cur_pl_fade_scale.y + ds))

	# PLAYER FAITH
	if faith_icons_pb.is_setuped:
		faith_icons_pb.update_progressbar(game.player.cur_faith)
	else:
		faith_icons_pb.setup_progressbar(game.faith_icon_scn, game.player.max_faith, game.player.cur_faith, 35)

	if game.player.cur_faith == game.player.max_faith:
		for icon_n in faith_icons_pb.get_children():
			icon_n.get_node("tex").set_modulate(Color(SYS.Colors.red))
	else:
		for icon_n in faith_icons_pb.get_children():
			icon_n.get_node("tex").set_modulate(SYS.Colors.OBJ_original)

	# PLAYER LEVEL
	if game.player.level > 0:
		get_node("top/level").set_text("LVL. " + str(game.player.level))
	else:
		game.launch_event(game.EVENTS.GAME_OVER)
		get_node("top/level").set_text("MORTIS")
	
	# BOSS HEALTH
	if game.cur_active_boss != null and weakref(game.cur_active_boss).get_ref() and game.cur_active_boss.get("is_unit"):
		get_node("top/dist").hide()
		get_node("top/boss").show()
		get_node("top/boss/gore_progressbar").setup_progressbar(game.cur_active_boss.init_health)
		get_node("top/boss/gore_progressbar").update(game.cur_active_boss.init_health - game.cur_active_boss.health)
		
	# DIST TO FINISH
	else:
		get_node("top/dist").show()
		get_node("top/boss").hide()

		get_node("top/dist/passed_dist").set_text(str(int(game.passed_dist)) + "/" + str(game.dist_to_finish))	

	if game.player.level < game.player.max_level:
		get_node("top/exp_progressbar").show()
		get_node("top/exp_progressbar").setup_progressbar(game.player.exp_to_level_up)
		get_node("top/exp_progressbar").update(game.player.cur_exp)
	else:
		get_node("top/exp_progressbar").hide()

	# DEBUFFS
	var debuffs_text = ""
	if game.current_events.has(game.EVENTS.S_FAITH_PACIFISM):
		debuffs_text += "PACIFISM "
	if game.current_events.has(game.EVENTS.S_FAITH_MASOHISM):
		debuffs_text += "MASOHISM "		
	if game.current_events.has(game.EVENTS.S_FAITH_OVERDOSE):
		debuffs_text += "OVERDOSE "

	if debuffs_text != "":
		get_node("top/debuffs").show()
		get_node("top/debuffs/text").set_text("WEAKNESS! " + str(int(
			game.too_much_faith_event_complete_timer.check_time())) + "\n" +
			debuffs_text
		)
	else:
		get_node("top/debuffs").hide()

	# ITEM ICONS
	if items_icons_nodes.size() != game.cur_player_items.size():
		for icon_node in items_icons_nodes:
			icon_node.queue_free()

		items_icons_nodes = []

		var left_icons_holder = get_node("bottom/items/left")
		var right_icons_holder = get_node("bottom/items/right")

		var icons_y_offset = 40

		var rest_items_count = 0
		for i in range(game.cur_player_items.size()):
			var cur_item_type = game.cur_player_items[i]

			var new_icon = game.item_icon_scn.instance()
			# setup position and holder
			if i < 4:
				left_icons_holder.add_child(new_icon)
				var holder_pos = left_icons_holder.get_global_pos()
				new_icon.set_global_pos(Vector2(holder_pos.x, holder_pos.y + icons_y_offset * i))
			elif i >= 4 and i < 7:
				right_icons_holder.add_child(new_icon)
				var holder_pos = right_icons_holder.get_global_pos()
				new_icon.set_global_pos(Vector2(holder_pos.x, holder_pos.y + icons_y_offset * (i - 4)))
			else:
				rest_items_count += 1

			var item_params = ENV.get_item_info_params_by_type(cur_item_type)
			new_icon.get_node("tex").set_region_rect(Rect2(
				20 * item_params.icon_x_offset, 
				20 * item_params.icon_y_offset,
				20, 20)
			)

			items_icons_nodes.append(new_icon)

		if rest_items_count > 0:
			get_node("bottom/items/rest_items").show()
			get_node("bottom/items/rest_items").set_text("+" + str(rest_items_count))
		else:
			get_node("bottom/items/rest_items").hide()

	# CHECK BELOW SCREEN TRACK UNIT ICONS
	# если юнит вернулся в игровую область, удаляем иконку и связанный параметр
	var erased_u_below_screen_params = []
	for u_below_screen_icon_param in units_below_screen_track_icons_params:
		if game.is_unit_in_play_zone(u_below_screen_icon_param.unit):
			erased_u_below_screen_params.append(u_below_screen_icon_param)

	for er_u_below_screen_param in erased_u_below_screen_params:
		var cur_icon_node = er_u_below_screen_param.icon_node
		if cur_icon_node != null and weakref(cur_icon_node).get_ref():
			cur_icon_node.queue_free()

		units_below_screen_track_icons_params.erase(er_u_below_screen_param)

# добавить иконку для юнита если он не уничтожается при выходе вниз экрана (показывается стрелочка вверх)
func add_track_icon_unit_below_play_screen(_unit, _pos_x):
	var unit = _unit
	var icon_node = game.u_below_screen_icon_scn.instance()
	
	get_node("bottom/below_screen_enemy_icons").add_child(icon_node)
	icon_node.set_global_pos(Vector2(_pos_x, game.play_region_y_end_pos - 10))

	units_below_screen_track_icons_params.append({unit = unit, icon_node = icon_node})

func launch_popup(_popup_tab, _event_type = null):
	popup.open_tab(_popup_tab, _event_type)

func show_messagebox(_header, _desc):
	var h = _header
	var d = _desc

	messagebox.get_node("header").set_gradual_text(h, 0.045)
	messagebox.get_node("desc").set_gradual_text(d, 0.03, messagebox.get_node("header"))

	messagebox.set_scale(Vector2(0, 1.0))

	messagebox_show_timer.reload()
	is_messagebox_active = true

# анимация: круг который "стягивается" к игроку
func play_player_fade_in_anim():
	if !is_player_fade_in_anim_active:
		entering_level_info.hide()

		#game.player.fade_anim.get_node("bg").set_opacity(0)
		game.player.fade_anim.get_node("tex").set_scale(Vector2(max_fade_scale, max_fade_scale))
		game.player.fade_anim.show()

		is_player_fade_in_anim_active = true
		is_player_fade_in_anim_finished = false
		is_player_fade_out_anim_active = false
		is_player_fade_out_anim_finished = false

func play_player_fade_out_anim():
	if !is_player_fade_out_anim_active:
		#game.player.fade_anim.get_node("bg").set_opacity(0)
		game.player.fade_anim.get_node("tex").set_scale(Vector2(min_fade_scale, min_fade_scale))
		game.player.fade_anim.show()

		is_player_fade_in_anim_active = false
		is_player_fade_in_anim_finished = false
		is_player_fade_out_anim_active = true
		is_player_fade_out_anim_finished = false