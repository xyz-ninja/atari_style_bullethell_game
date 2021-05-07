extends Node2D

onready var gui = get_node("gui")
onready var cam = get_node("cam")

onready var objects_node = get_node("main/objects")
onready var game_floor = get_node("main/floor")

onready var sound = get_node("sound")

enum ENEMY_TYPE {
	FAITH_DEVIL, LVL1_GHOUL, LVL1_BIRD,
	LVL2_WORMMAN, LVL2_SPAWNER, LVL2_SPAWNER_HENCHMAN, LVL2_DOG,
	LVL3_SHIELDMAN, LVL3_SHIELDMAN_SUPPORT, LVL3_SNAKE,
	LVL4_SKULLS, LVL4_ACNE, LVL4_ATTRACTOR
}

enum PROJECTILE_TYPE {
	PLAYER_DAGGER, ENEMY_NORMAL, ENEMY_VOMIT
}

enum PLAYER_POWER_TYPE {CROSS}

enum EVENTS {
	NEXT_GAME_LEVEL, GET_ITEM_REWARD, GAME_OVER,
	S_FAITH_DEVIL_ARRIVE, S_FAITH_OVERDOSE, S_FAITH_PACIFISM, S_FAITH_MASOHISM,
	BOSS_NECROMANCER, BOSS_SKINEATER, BOSS_MUSHROOM, BOSS_UGLY_THING, BOSS_SATAN
}

enum ITEMS {
	CHAMBER_OF_REFLECTION, 		# больше blink time
	TRACHOMA_EYE,					# больше spawn_timer в enemy_pack
	MAGNETIC_SKULL, 				# больше радиус сбора черепов
	UGLY_SKULL, 					# больше черепов
	BLOODY_CALLUS, 				# кровавая мозоль, враги отталкиваются дальше
	LASH_OF_REPOSE, 				# плеть упокоения, faith копится медленнее
	ASH_MAW,							# пепельная пасть, +1 предмет при выборе, они больше не сгорают при подборе
	# карты - пики, улучшают атаку игрока на определенном уровне
	CARD_OF_SPADES_1, CARD_OF_SPADES_2, CARD_OF_SPADES_3, CARD_OF_SPADES_4, CARD_OF_SPADES_5,
	CARD_OF_SPADES_6, CARD_OF_SPADES_7, CARD_OF_SPADES_8, CARD_OF_SPADES_9, CARD_OF_SPADES_10,
	DEVIL_DAGGER,					# снаряды пробивают одного врага насквозь
	LEFT_TENTACLE,					# доп снаряд слева
	RIGHT_TENTACLE,				# доп снаряд справа
	MUTATED_WORM,					# доп снаряд снизу
	CACTUS_RASH, 					# враги получают урон при касании с игроком
}

# addit timers
var too_much_faith_event_complete_timer = TIME.create_new_timer("too_much_faith_event_complete_timer", 12.0)

# icons
var u_spawn_icon_scn = load("res://objects/spawn_enemy_icon.tscn")
var u_below_screen_icon_scn = load("res://objects/below_screen_enemy_icon.tscn")
var u_attack_direction_marker_scn = load("res://objects/unit_attack_direction_marker.tscn")
var faith_icon_scn = load("res://objects/faith_icon.tscn")
var item_icon_scn = load("res://objects/item_icon.tscn")
var blood_obj_scn = load("res://objects/blood.tscn")

# units
var u_faith_devil_scn = load("res://units/unit_faith_devil.tscn")
var u_lvl1_ghoul_scn = load("res://units/unit_lvl1_ghoul.tscn")
var u_lvl1_bird_scn = load("res://units/unit_lvl1_bird.tscn")
var u_lvl1_BOSS_necromancer_scn = load("res://units/boss_necromancer.tscn")
var u_necromancer_henchman_scn = load("res://units/unit_necromancer_henchman.tscn")
var u_lvl2_wormman_scn = load("res://units/unit_lvl2_wormman.tscn")
var u_lvl2_spawner_scn = load("res://units/unit_lvl2_spawner.tscn")
var u_lvl2_spawner_henchman_scn = load("res://units/unit_lvl2_spawner_henchman.tscn")
var u_lvl2_dog_scn = load("res://units/unit_lvl2_dog.tscn")
var u_lvl2_BOSS_skineater_scn = load("res://units/boss_skineater.tscn")
var u_skineater_henchman_scn = load("res://units/unit_skineater_henchman.tscn")
var u_lvl3_shieldman_scn = load("res://units/unit_lvl3_shieldman.tscn")
var u_lvl3_shieldman_support_scn = load("res://units/unit_lvl3_shieldman_support.tscn")
var u_lvl3_snake_scn = load("res://units/unit_lvl3_snake.tscn")
var u_lvl3_BOSS_mushroom_scn = load("res://units/boss_mushroom.tscn")
var u_mushroom_phantom_scn = load("res://units/unit_mushroom_phantom.tscn")
var u_lvl4_acne_scn = load("res://units/unit_lvl4_acne.tscn")
var u_lvl4_skulls_scn = load("res://units/unit_lvl4_skulls.tscn")
var u_lvl4_skulls_henchman_scn = load("res://units/unit_lvl4_skulls_henchman.tscn")
var u_lvl4_attractor_scn = load("res://units/unit_lvl4_attractor.tscn")
var u_lvl4_BOSS_ugly_thing_scn = load("res://units/boss_ugly_thing.tscn")
var u_lvl5_BOSS_satan_lvl1 = load("res://units/boss_satan_lvl1.tscn")
var u_lvl5_BOSS_satan_lvl2 = load("res://units/boss_satan_lvl2.tscn")
var u_lvl5_BOSS_satan_lvl3 = load("res://units/boss_satan_lvl3.tscn")

# objects
var particles_blood_scn = load("res://objects/particles_blood.tscn")

var projectile_scn = load("res://objects/projectile.tscn")
var exp_bonus_scn = load("res://objects/exp_bonus.tscn")
var spawn_marker_scn = load("res://objects/spawn_unit_marker.tscn")
var reward_item_scn = load("res://objects/item.tscn")

var floor_small_obj_scn = load("res://objects/floor_small_obj.tscn")

# music
var mus_lvl1_scn = load("res://music/music5.ogg")
var mus_lvl2_scn = load("res://music/music4.ogg")
var mus_lvl3_scn = load("res://music/music1.ogg")
var mus_lvl4_scn = load("res://music/music3.ogg")
var mus_lvl5_scn = load("res://music/music2.ogg")

var mus_boss_scn = load("res://music/boss.ogg")
var mus_final_boss_scn = load("res://music/final_boss.ogg")
var mus_rewards_scn = load("res://music/rewards.ogg")
var mus_change_level_scn = load("res://music/change_level.ogg")

# WORLD

var game_level = 1
var is_level_complete = false

var cur_world_speed = 1.2
var world_speed_change_coef_by_player_lvl = 0.08 # на это значение ускоряется мир при каждом левел апе игрока
var passed_dist = 0
var dist_to_finish = 1000
var is_world_stopped = false
var obj_world_speed_multiplier = 200

var player

# SYS

var button_timer = TIME.create_new_timer("button_timer", 0.13)

var loc_dist_time = 0.1
var loc_dist_timer = loc_dist_time

var play_region_x_end_pos = 380
var play_region_y_start_pos = 75
var play_region_y_end_pos = 500

# EVENTS

var too_much_faith_events = [
	EVENTS.S_FAITH_DEVIL_ARRIVE, EVENTS.S_FAITH_OVERDOSE, EVENTS.S_FAITH_PACIFISM, EVENTS.S_FAITH_MASOHISM]

var lvl1_boss_events = [EVENTS.BOSS_NECROMANCER]
var lvl2_boss_events = [EVENTS.BOSS_SKINEATER]
var lvl3_boss_events = [EVENTS.BOSS_MUSHROOM]
var lvl4_boss_events = [EVENTS.BOSS_UGLY_THING]
var lvl5_boss_events = [EVENTS.BOSS_SATAN]

var delayed_event_timer = TIME.create_new_timer("delayed_event_timer", 1.0)
var delayed_event

var current_events = []
var completed_events = []

# ITEMS
var available_items = []
var lost_items = [] # items that unavailable in current run
var cur_player_items = []

# ENEMIES
var spawn_timer

var enemy_packs_params = []
var cur_enemy_packs = []
var cur_enemy_units = []
var cur_active_boss

class EnemyPack:
	var game

	var spawn_time = 1.2
	var spawn_timer 

	var init_enemy_type = [] # изначальные враги которые должны заспаунится
	var spawn_enemy_type = [] # список врагов которые заспаунятся
	var spawn_enemies_params = [] # параметр спауна юнита (позиция, тип)

	var icons_nodes = []

	var is_active = false
	var is_ready_to_spawn = false

	func _init(_game, _init_enemy_type, _count):
		game = _game
		init_enemy_type = _init_enemy_type
		var count = _count

		if game.cur_player_items.has(game.ITEMS.TRACHOMA_EYE):
			spawn_time += 1.2

		spawn_timer = TIME.create_new_timer("enemy_pack_spawn_timer", spawn_time)

		for i in range(count):
			spawn_enemy_type.append(SYS.get_random_arr_item(init_enemy_type))

	func update():
		if is_active and !is_ready_to_spawn:
			if spawn_timer.check_time() <= spawn_timer.init_time * 0.3:
				for icon_n in icons_nodes:
					if icon_n != null and weakref(icon_n).get_ref() and icon_n.has_node("tex"):
						icon_n.get_node("tex").set_modulate(Color("#ff7777"))

			if spawn_timer.is_finish():
				spawn_units()

				TIME.destroy_timer(spawn_timer)
				is_ready_to_spawn = true

	func activate():
		# SETUP ENEMIES TO SPAWN
		for en_type in spawn_enemy_type:
			var en_param = {type = en_type, scene = null, pos_x = null}
			
			# GHOUL
			if en_type == ENEMY_TYPE.LVL1_GHOUL:
				en_param.scene = game.u_lvl1_ghoul_scn
				en_param.pos_x = SYS.get_random_int(0, game.play_region_x_end_pos)
			# BIRD
			elif en_type == ENEMY_TYPE.LVL1_BIRD:
				en_param.scene = game.u_lvl1_bird_scn
				if SYS.get_random_percent_0_to_100() < 50:
					en_param.pos_x = SYS.get_random_int(0, 100)
				else:
					en_param.pos_x = SYS.get_random_int(game.play_region_x_end_pos - 100, game.play_region_x_end_pos - 50)
			# WORM MAN
			elif en_type == ENEMY_TYPE.LVL2_WORMMAN:
				en_param.scene = game.u_lvl2_wormman_scn
				en_param.pos_x = SYS.get_random_int(0, game.play_region_x_end_pos)
			# SPAWNER
			elif en_type == ENEMY_TYPE.LVL2_SPAWNER:
				en_param.scene = game.u_lvl2_spawner_scn
				en_param.pos_x = SYS.get_random_int(0, game.play_region_x_end_pos)
			# DOG
			elif en_type == ENEMY_TYPE.LVL2_DOG:
				en_param.scene = game.u_lvl2_dog_scn
				if SYS.get_random_percent_0_to_100() < 50:
					en_param.pos_x = SYS.get_random_int(40, 150)
				else:
					en_param.pos_x = SYS.get_random_int(game.play_region_x_end_pos - 150, game.play_region_x_end_pos - 80)
			# SHIELDMAN
			elif en_type == ENEMY_TYPE.LVL3_SHIELDMAN:
				en_param.scene = game.u_lvl3_shieldman_scn

				var av_x = [110, 200, 290, 380]
				en_param.pos_x = SYS.get_random_arr_item(av_x)

			elif en_type == ENEMY_TYPE.LVL3_SHIELDMAN_SUPPORT:
				en_param.scene = game.u_lvl3_shieldman_support_scn
				en_param.pos_x = SYS.get_random_int(0, game.play_region_x_end_pos)

			elif en_type == ENEMY_TYPE.LVL4_ACNE:
				en_param.scene = game.u_lvl4_acne_scn
				en_param.pos_x = SYS.get_random_int(0, game.play_region_x_end_pos)

			elif en_type == ENEMY_TYPE.LVL4_SKULLS:
				en_param.scene = game.u_lvl4_skulls_scn
				en_param.pos_x = SYS.get_random_int(50, game.play_region_x_end_pos - 50)

			elif en_type == ENEMY_TYPE.LVL4_ATTRACTOR:
				en_param.scene = game.u_lvl4_attractor_scn
				en_param.pos_x = SYS.get_random_int(50, game.play_region_x_end_pos - 50)

			# SHIELDMAN SUPPORT
			#elif en_type == ENEMY_TYPE.LVL3_SHIELDMAN_SUPPORT:
			#	en_param.scene = game.u_lvl3_shieldman_support_scn
			#	var av_x = [
			#		SYS.get_random_int(90,130),
			#		SYS.get_random_int(170,220), 
			#		SYS.get_random_int(260,310), 
			#		SYS.get_random_int(350,400)]
			#	en_param.pos_x = SYS.get_random_arr_item(av_x)

			# SNAKE
			elif en_type == ENEMY_TYPE.LVL3_SNAKE:
				en_param.scene = game.u_lvl3_snake_scn
				en_param.pos_x = SYS.get_random_int(140, game.play_region_x_end_pos - 180)

			spawn_enemies_params.append(en_param)

		# ADD SPAWN ICONS (EYE)
		for en_param in spawn_enemies_params:
			var new_icon = game.u_spawn_icon_scn.instance()
			var icons_node = game.gui.get_node("top/spawn_enemies_icons")
			icons_node.add_child(new_icon)
			new_icon.set_global_pos(Vector2(en_param.pos_x, icons_node.get_global_pos().y))

			icons_nodes.append(new_icon)

		if spawn_enemies_params.size() <= 0:
			print("PARAMS SIZE ERROR! SIZE == 0")

		#print("ENEMIES PACK ACTIVATED! PARAMS SIZE: " + str(spawn_enemies_params.size()))

		spawn_timer.reload()
		is_active = true

	func spawn_units():
		for icon_n in icons_nodes:
			if icon_n != null and weakref(icon_n).get_ref():
				icon_n.queue_free()

		game.sound.play("units_appear", "enemies_appear")

		# спауним юнитов из параметров
		for en_param in spawn_enemies_params:
			var icons_node = game.gui.get_node("top/spawn_enemies_icons")

			var addit_y_offset = 0
			if en_param.has("addit_y_offset"):
				addit_y_offset = en_param.addit_y_offset

			game.spawn_unit_from_scene(en_param.scene, Vector2(
				en_param.pos_x, 
				icons_node.get_global_pos().y - 46 - addit_y_offset)
			)

		game.cur_enemy_packs.erase(self)

func _ready():
	ENV.set_game(self)

	player = get_tree().get_nodes_in_group("player")[0]
	OPTIONS.load_save()

	set_game_level(OPTIONS.save_content_params.start_from_level.cur)

	for item_v in ITEMS.values():
		available_items.append(item_v)

	#print("TIMERS")
	#for timer_key in TIME.Timers.keys():
	#	print(timer_key)
	
	#launch_event_delayed(EVENTS.GET_ITEM_REWARD, 0.3)
	#launch_event(EVENTS.BOSS_MUSHROOM)
	
	#is_world_stopped = false
	
	if game_level == 1:
		player.take_items([ITEMS.ASH_MAW], true)
	else:
		player.take_items(OPTIONS.save_content_params.player_items.cur, true)
	#player.take_items([ITEMS.LEFT_TENTACLE, ITEMS.RIGHT_TENTACLE, ITEMS.MUTATED_WORM], true)
	#player.take_items(available_items, true)

	#OPTIONS.save_game()

	set_process(true)

func _process(delta):
	gui.update(delta)

	if Input.is_action_pressed("esc"):
		get_tree().change_scene("res://scenes/main_menu.tscn")

	# check delayed events
	if delayed_event != null:
		if delayed_event_timer.is_finish():
			launch_event(delayed_event)
			delayed_event = null

	# check current faith events
	if too_much_faith_event_complete_timer.is_finish():
		var cur_faith_events = []
		for faith_event in too_much_faith_events:
			if current_events.has(faith_event):
				cur_faith_events.append(faith_event)

		for ev in cur_faith_events:
			complete_event(ev)

	if is_world_stopped or gui.is_messagebox_active:
		pass
	else:
		# update floor and spawn floor objects
		game_floor.update(delta, cur_world_speed * obj_world_speed_multiplier)

		# RUN
		if passed_dist < dist_to_finish:
			loc_dist_timer -= delta
			if loc_dist_timer < 0:
				passed_dist += cur_world_speed
				if passed_dist > dist_to_finish:
					passed_dist = dist_to_finish
				
				loc_dist_timer = loc_dist_time
		# FINISH
		else:
			var erased_enemies = []

			for enemy in cur_enemy_units:
				if enemy == null or !weakref(enemy).get_ref():
					erased_enemies.append(enemy)
			for er_enemy in erased_enemies:
				cur_enemy_units.erase(er_enemy)

			# BOSS 
			if cur_enemy_units.size() == 0 and cur_active_boss == null and !is_level_complete:
				if game_level == 1:
					launch_event(SYS.get_random_arr_item(lvl1_boss_events))
				elif game_level == 2:
					launch_event(SYS.get_random_arr_item(lvl2_boss_events))
				elif game_level == 3:
					launch_event(SYS.get_random_arr_item(lvl3_boss_events))
				elif game_level == 4:
					launch_event(SYS.get_random_arr_item(lvl4_boss_events))
				elif game_level == 5:
					launch_event(SYS.get_random_arr_item(lvl5_boss_events))

		# UPDATE OBJECTS
		for obj_node in objects_node.get_children():
			if weakref(obj_node).get_ref():
				var obj_prev_pos = obj_node.get_global_pos()
				
				var dy = 0
		
				if is_world_stopped:
					dy = 0
				else:
					var deceleration_speed = 0
					if obj_node.get("deceleration_speed"):
						deceleration_speed = obj_node.deceleration_speed

					dy += (cur_world_speed * obj_world_speed_multiplier - deceleration_speed) * delta
		
				if obj_node.is_in_group("immovable") or obj_node.get("is_immovable") and obj_node.is_immovable:
					dy = 0

				obj_node.set_global_pos(Vector2(obj_prev_pos.x, obj_prev_pos.y + dy))
		
				if obj_node.get_global_pos().y > play_region_y_end_pos + 50:
					obj_node.queue_free()

	# CHECK ENEMIES PACKS
	var erased_packs_params = []
	# проверяем нужно ли добавить новую пачку врагов по списку параметров
	for pack_param in enemy_packs_params:
		if pack_param.pack == null:
			erased_packs_params.append(pack_param)
			continue

		# если пройдено нужное расстояние для активации
		if passed_dist >= pack_param.on_dist:
			pack_param.pack.activate()

			cur_enemy_packs.append(pack_param.pack)
			erased_packs_params.append(pack_param)

	# удаляем связанный параметр
	for er_pack_param in erased_packs_params:
		enemy_packs_params.erase(er_pack_param)

	for pack in cur_enemy_packs:
		pack.update()

func is_unit_in_play_zone(_unit):
	var u = _unit
	if weakref(u).get_ref() and !u.get("is_unit") and !u.get("is_projectile"):
		return false
	
	if u != null and weakref(u).get_ref():
		var unit_pos = u.get_global_pos()
		if unit_pos.x >= 0 and unit_pos.x <= play_region_x_end_pos and \
			unit_pos.y >= play_region_y_start_pos and unit_pos.y <= play_region_y_end_pos:
			return true
		else:
			return false
	else:
		return false

func set_game_level(_num):
	game_level = _num
	is_level_complete = false

	enemy_packs_params = []

	passed_dist = 0
	dist_to_finish = 1000

	sound.play("env", "entering_level")

	for obj_node in objects_node.get_children():
		obj_node.queue_free()

	if game_level == 1:
		sound.set_music_stream(mus_lvl1_scn)

		var spawn_point_index = SYS.get_random_int(15, 31) # по достижение этой отметки в цикле спаунится пачка врагов

		while spawn_point_index < dist_to_finish:
			var cur_enemy_type
			var cur_enemies_count

			var percent = SYS.get_random_percent_0_to_100()

			if percent < 60:
				cur_enemy_type = [LVL1_GHOUL]
				cur_enemies_count = 2 + int(spawn_point_index / 150) * 2
			elif percent > 60 and percent < 80:
				cur_enemy_type = [LVL1_BIRD]
				cur_enemies_count = 1 + int(spawn_point_index / 200) * 2
			else:
				cur_enemy_type = [LVL1_GHOUL, LVL1_BIRD]
				cur_enemies_count = 2 + int(spawn_point_index / 200) * 2

			enemy_packs_params.append({
				on_dist = spawn_point_index, pack = get_enemy_pack(cur_enemy_type, cur_enemies_count)
			})

			spawn_point_index += SYS.get_random_int(15, 38)

	elif game_level == 2:
		sound.set_music_stream(mus_lvl2_scn)

		var spawn_point_index = SYS.get_random_int(10, 31) # по достижение этой отметки в цикле спаунится пачка врагов

		while spawn_point_index < dist_to_finish:
			var cur_enemy_type
			var cur_enemies_count

			var percent = SYS.get_random_percent_0_to_100()

			if percent < 50:
				cur_enemy_type = [LVL2_WORMMAN]
				cur_enemies_count = 3 + int(spawn_point_index / 180) * 2
			elif percent >= 50 and percent < 75:
				cur_enemy_type = [LVL2_SPAWNER]
				var addit_count = floor(spawn_point_index / 400)
				cur_enemies_count = SYS.get_random_int(1,2)

				if addit_count > 0:
					cur_enemies_count += addit_count
			else:
				cur_enemy_type = [LVL2_DOG]
				var addit_count = floor(spawn_point_index / 400)
				cur_enemies_count = 2

				if addit_count > 0:
					cur_enemies_count += addit_count

			enemy_packs_params.append({
				on_dist = spawn_point_index, pack = get_enemy_pack(cur_enemy_type, cur_enemies_count)
			})

			spawn_point_index += SYS.get_random_int(15, 38)
	elif game_level == 3:
		sound.set_music_stream(mus_lvl3_scn)

		var spawn_point_index = SYS.get_random_int(10, 31) # по достижение этой отметки в цикле спаунится пачка врагов

		while spawn_point_index < dist_to_finish:
			var cur_enemy_type
			var cur_enemies_count

			var percent = SYS.get_random_percent_0_to_100()

			if percent < 78:
				cur_enemy_type = [LVL3_SHIELDMAN]
				cur_enemies_count = 1 + int(spawn_point_index / 300 * 1.5)
			else:
				cur_enemy_type = [LVL3_SNAKE]
				var addit_count = floor(spawn_point_index / 550)
				cur_enemies_count = SYS.get_random_int(1, 2)

				if addit_count > 0:
					cur_enemies_count += addit_count

			enemy_packs_params.append({
				on_dist = spawn_point_index, pack = get_enemy_pack(cur_enemy_type, cur_enemies_count)
			})

			spawn_point_index += SYS.get_random_int(25, 40)

	elif game_level == 4:
		sound.set_music_stream(mus_lvl4_scn)

		var spawn_point_index = SYS.get_random_int(10, 31) # по достижение этой отметки в цикле спаунится пачка врагов

		while spawn_point_index < dist_to_finish:
			var cur_enemy_type
			var cur_enemies_count

			var percent = SYS.get_random_percent_0_to_100()

			if percent < 25:
				cur_enemy_type = [LVL4_ATTRACTOR]
				cur_enemies_count = 1 + int(spawn_point_index / 300 * 1.5)
			elif percent >= 25 and percent < 50:
				cur_enemy_type = [LVL4_SKULLS]
				if SYS.get_random_percent_0_to_100() < 25:
					cur_enemy_type.append(LVL4_ACNE)

				cur_enemies_count = 1 + int(spawn_point_index / 300 * 1.5)
			else:
				cur_enemy_type = [LVL4_ACNE]
				cur_enemies_count = 2 + int(spawn_point_index / 180) * 2

			enemy_packs_params.append({
				on_dist = spawn_point_index, pack = get_enemy_pack(cur_enemy_type, cur_enemies_count)
			})

			spawn_point_index += SYS.get_random_int(25, 40)

	elif game_level == 5:
		sound.set_music_stream(mus_lvl5_scn)

		dist_to_finish = 1500

		var spawn_point_index = SYS.get_random_int(10, 30) # по достижение этой отметки в цикле спаунится пачка врагов

		while spawn_point_index < dist_to_finish:
			var cur_enemy_type
			var cur_enemies_count

			var percent = SYS.get_random_percent_0_to_100()

			if percent < 25:
				cur_enemy_type = [LVL2_WORMMAN]
				cur_enemies_count = 3 + int(spawn_point_index / 180) * 2
			elif percent >= 25 and percent < 50:
				cur_enemy_type = [LVL2_WORMMAN, LVL1_GHOUL]
				cur_enemies_count = 3 + int(spawn_point_index / 180) * 2
			elif percent >= 50 and percent < 75:
				cur_enemy_type = [LVL3_SHIELDMAN_SUPPORT, LVL1_GHOUL]
				cur_enemies_count = 3 + int(spawn_point_index / 180) * 2
			else:
				cur_enemy_type = [LVL4_ACNE]
				cur_enemies_count = 3 + int(spawn_point_index / 180) * 2

			enemy_packs_params.append({
				on_dist = spawn_point_index, pack = get_enemy_pack(cur_enemy_type, cur_enemies_count)
			})

			spawn_point_index += SYS.get_random_int(10, 25)

		#enemy_packs_params = [
		#	{on_dist = 25, pack = get_enemy_pack([LVL1_GHOUL], 4, 2)},
		#]


	game_floor.setup_by_game_level(game_level)

func spawn_unit_from_scene(_unit_scn, _pos):
	var new_unit = _unit_scn.instance()

	get_node("main/units").add_child(new_unit)
	new_unit.set_global_pos(_pos)

	if !new_unit.is_player:
		cur_enemy_units.append(new_unit)

	if new_unit.is_boss:
		sound.play("units_appear", "boss_appear")
		cur_active_boss = new_unit

	return new_unit

func spawn_object_from_scene(_obj_scn, _pos, _dont_add_to_objects_node = false):
	var new_obj = _obj_scn.instance()

	if _dont_add_to_objects_node:
		get_node("main/not_objects").add_child(new_obj)
	else:
		get_node("main/objects").add_child(new_obj)

	new_obj.set_global_pos(_pos)

	return new_obj

func launch_event(_event_type):
	var e_type = _event_type

	# FAITH EVENT
	if too_much_faith_events.has(e_type):
		gui.launch_popup(gui.POPUP_TAB.FAITH_OVERDOSE, e_type)

		too_much_faith_event_complete_timer.reload()

	# BOSS EVENT
	elif lvl1_boss_events.has(e_type) or lvl2_boss_events.has(e_type) or lvl3_boss_events.has(e_type) or \
		lvl4_boss_events.has(e_type) or lvl5_boss_events.has(e_type):
		is_world_stopped = true
		
		if e_type == EVENTS.BOSS_SATAN:
			get_node("main/floor/final_boss_effects").show()
			sound.set_music_stream(mus_final_boss_scn)
		else:
			get_node("main/floor/final_boss_effects").hide()
			sound.set_music_stream(mus_boss_scn)

		for below_screen_enemy_icon in gui.get_node("bottom/below_screen_enemy_icons").get_children():
			below_screen_enemy_icon.queue_free()
		gui.units_below_screen_track_icons_params = []

		gui.launch_popup(gui.POPUP_TAB.BOSS_ARRIVE, e_type)

	# GET ITEM REWARD EVENT
	elif e_type == EVENTS.GET_ITEM_REWARD:
		is_world_stopped = true
		
		player.set_global_pos(Vector2(play_region_x_end_pos / 2 - 15, play_region_y_end_pos - 50))
		gui.launch_popup(gui.POPUP_TAB.ITEM_REWARD)

		sound.set_music_stream(mus_rewards_scn)

	# NEXT GAME LEVEL EVENT
	elif e_type == EVENTS.NEXT_GAME_LEVEL:
		is_world_stopped = true
		gui.play_player_fade_in_anim()

	if !current_events.has(e_type):
		current_events.append(e_type)

	# GAME OVER
	elif e_type == EVENTS.GAME_OVER:
		sound.set_music_stream(mus_rewards_scn)
		is_world_stopped = true
		player.is_alive = false
		for u in cur_enemy_units:
			u.destroy()
			u.queue_free()

		gui.launch_popup(gui.POPUP_TAB.GAME_OVER)
		sound.play("env", "mortis")
		#set_process(false)

func launch_event_delayed(_event_type, _delay_time):
	delayed_event = _event_type
	delayed_event_timer.change_init_time(_delay_time)

func complete_event(_event_type):
	var e_type = _event_type

	if !completed_events.has(e_type) and current_events.has(e_type):
		var is_event_cannot_be_completed = false
		var is_boss_event_completed = false

		if lvl1_boss_events.has(e_type) or lvl2_boss_events.has(e_type) or lvl3_boss_events.has(e_type) or \
		lvl4_boss_events.has(e_type) or lvl5_boss_events.has(e_type):
			is_boss_event_completed = true

		elif e_type == EVENTS.GET_ITEM_REWARD:
			is_event_cannot_be_completed = true

			is_world_stopped = false

			# ПРЕДМЕТ ИГРОКА ДОБАВЛЯЕТСЯ ЧЕРЕЗ player.gd
			# ДОБАВЛЯЕМ ВСЕ ТЕКУЩИЕ ПРЕДМЕТЫ В lost_items, что бы они больше не использовались
			for obj in objects_node.get_children():
				if obj.is_in_group("reward_item"):
					lost_items.append(obj.type)
					obj.destroy()

			OPTIONS.change_save_content_param_value("player_items", cur_player_items)
			OPTIONS.change_save_content_param_value("player_level", player.level)

			launch_event(EVENTS.NEXT_GAME_LEVEL)

		elif e_type == EVENTS.NEXT_GAME_LEVEL:
			is_event_cannot_be_completed = true
			is_world_stopped = false
			#set_game_level(game_level + 1)

		if !is_event_cannot_be_completed:
			completed_events.append(e_type)
		
		current_events.erase(e_type)

		if is_boss_event_completed:
			cur_active_boss = null
			is_level_complete = true
			launch_event_delayed(EVENTS.GET_ITEM_REWARD, 1.2)

func spawn_reward_items():
	is_world_stopped = true

	var av_items = available_items + []
	
	# delete unavailable items
	for item in cur_player_items:
		if av_items.has(item):
			av_items.erase(item)

	if !cur_player_items.has(ITEMS.ASH_MAW):
		for lost_item in lost_items:
			if av_items.has(lost_item):
				av_items.erase(lost_item)

	var items_count = 3

	if cur_player_items.has(ITEMS.ASH_MAW):
		items_count = 4

	for i in range(items_count):
		if av_items.size() > 0:
			var new_item = spawn_object_from_scene(reward_item_scn, Vector2(50 + 90 * i, play_region_y_start_pos + 100))
			var sel_type = SYS.get_random_arr_item(av_items)
			new_item.setup_item(sel_type)
			av_items.erase(sel_type)
		else:
			print("NO MORE AVAILABLE ITEMS!")

func get_enemy_pack(_init_enemy_type, _count):
	var new_pack = EnemyPack.new(self, _init_enemy_type, _count)
	return new_pack