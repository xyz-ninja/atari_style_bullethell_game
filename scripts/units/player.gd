extends "res://scripts/units/unit.gd"

onready var fade_anim = get_node("fade_anim")

var init_walk_time = 0.4
var walk_time = init_walk_time
var walk_timer = TIME.create_new_timer("player_walk_timer", init_walk_time)

var level = 1
var max_level = 10

var move_speed = 392
var projectile_speed = 515

var shoot_delay_time = 0.17
var shoot_timer = TIME.create_new_timer("player_shoot_timer", shoot_delay_time)
var power_timer = TIME.create_new_timer("power_timer", 0.05)
var power_accum_timer = TIME.create_new_timer("power_accum_timer", 0.38)
var power_clean_timer = TIME.create_new_timer("power_clean_timer", 0.8)

var cur_power

var cur_faith = 1
var max_faith = 6
var cur_exp = 0
var exp_to_level_up = 1

var char_portrait

var init_blink_time

var is_moving = false

# нужны например для того что-бы притягивать игрока к определенным юнитам
var addit_dx = 0
var addit_dy = 0
var attract_by_unit

var is_alive = true

func _ready():
	is_player = true

	level = OPTIONS.save_content_params.player_level.cur

	projectile_damage = 1

	set_custom_blink_time(0.21)

	check_exp()

	set_cur_projectile_type(game.PROJECTILE_TYPE.PLAYER_DAGGER)

	init_blink_time = loc_blink_time

	setup_walk_time()

	set_process(true)

func _process(delta):
	if !is_alive:
		return

	var prev_pos = get_global_pos()
	# INPUT
	update_input(delta)
	# ANIMATION
	if game.is_world_stopped and prev_pos == get_global_pos():
		play_frame_animation(1)
		is_moving = false
	else:
		if walk_timer.init_time != walk_time:
			walk_timer.change_init_time(walk_time)

		if walk_timer.is_finish():
			game.sound.play("walk", "walk")
			walk_timer.reload()

		is_moving = true
		play_frame_animation(4)

	# SOME ITEMS
	if game.cur_player_items.has(game.ITEMS.CHAMBER_OF_REFLECTION) and loc_blink_time <= init_blink_time:
		loc_blink_time = init_blink_time * 2
		loc_blink_timer = loc_blink_time

	# SETUP LEVEL AND FAITH
	if game.current_events.has(game.EVENTS.S_FAITH_MASOHISM):
		get_node("masohism_tex").show()
	else:
		get_node("masohism_tex").hide()

	if cur_power != null:
		# ACCUM FAITH
		if power_accum_timer.is_finish():
			if cur_faith < max_faith:
				cur_faith += 1
				#game.sound.play("shoot", "faith_up")

				power_accum_timer.reload()
			else:
				# ЗАПУСКАЕМ ПЛОХОЕ СОБЫТИЕ ПРИ СЛИШКОМ БОЛЬШОЙ ВЕРЕ
				var faith_events = game.too_much_faith_events + []
				var correct_faith_events = []
				# добавляем событие в пул если оно не завершено
				for f_ev in faith_events:
					if !game.completed_events.has(f_ev) and !game.current_events.has(f_ev):
						correct_faith_events.append(f_ev)

				# если событий больше не осталось - отнимаем два уровня 
				if correct_faith_events.size() == 0:
					reduce_levels(2)
				else:
					game.launch_event(SYS.get_random_arr_item(correct_faith_events))

				cur_faith = 1
		else:
			if cur_faith == max_faith:
				game.sound.play("shoot", "faith_max")
			else:
				game.sound.play("shoot", "faith")
	else:
		power_accum_timer.reload()
		# CLEAN FAITH
		if cur_faith > 1:
			if power_clean_timer.is_finish():
				cur_faith -= 1
				power_clean_timer.reload()
		else:
			power_clean_timer.reload()

	if level > 0 and level < 6:
		shoot_delay_time = 0.17
	else:
		shoot_delay_time = 0.12

	# SETUP TIMERS
	if shoot_timer.init_time != shoot_delay_time:
		shoot_timer.change_init_time(shoot_delay_time)

	# COLLISIONS
	# enemies
	for enemy_unit in game.cur_enemy_units:
		if weakref(enemy_unit).get_ref() and enemy_unit.get("is_unit"):
			# cross power
			if cur_power == game.PLAYER_POWER_TYPE.CROSS:
				if power_timer.is_finish():
					if SYS.get_dist_between_sprites(tex, enemy_unit.get_node("tex")) < 95:
						enemy_unit.deal_damage(1)	
			else:
				var collision_dist = enemy_unit.collision_dist - 1

				if game.current_events.has(game.EVENTS.S_FAITH_MASOHISM):
					collision_dist += 15

				# check is enemy hit player
				if SYS.get_dist_between_sprites(tex, enemy_unit.get_node("tex")) < collision_dist:
					deal_damage(1)

					if game.cur_player_items.has(game.ITEMS.CACTUS_RASH):
						enemy_unit.deal_damage(16)

	# obj
	for obj_node in game.objects_node.get_children():
		if weakref(obj_node).get_ref():
			# exp bonus
			if obj_node.is_in_group("exp_bonus"):
				var attract_dist = 60
				if game.cur_player_items.has(game.ITEMS.MAGNETIC_SKULL):
					attract_dist = 90

				if game.is_world_stopped:
					attract_dist = 350

				if SYS.get_dist_between_sprites(tex, obj_node.get_node("tex")) < attract_dist:
					obj_node.is_attracts_to_player = true
			# reward item
			elif obj_node.is_in_group("reward_item"):
				if SYS.get_dist_between_sprites(tex, obj_node.get_node("bg")) < 30:
					take_item(obj_node.type)
					game.sound.play("objects", "item_pickup")

	if power_timer.is_finish() and cur_power != null:
		power_timer.reload()

func update_input(delta):
	# POSITION
	var dx = 0
	var dy = 0

	if Input.is_action_pressed("ui_left") and get_global_pos().x > 0:
		dx -= move_speed * delta
	if Input.is_action_pressed("ui_right") and get_global_pos().x < game.play_region_x_end_pos:
		dx += move_speed * delta

	if	Input.is_action_pressed("ui_up") and get_global_pos().y > game.play_region_y_start_pos:
		dy -= move_speed * delta
	if	Input.is_action_pressed("ui_down") and get_global_pos().y < game.play_region_y_end_pos - 20: 
		dy += move_speed * delta

	dx += addit_dx * delta
	dy += addit_dy * delta

	var prev_pos = get_global_pos()
	set_global_pos(Vector2(prev_pos.x + dx, prev_pos.y + dy))

	var is_shooting = false
	var is_faith = false

	# SHOOTING
	if Input.is_action_pressed("key_z") and !game.current_events.has(game.EVENTS.S_FAITH_PACIFISM):
		is_shooting = true
		is_faith = false

		if shoot_timer.is_finish():
			shoot()
			cur_power = null
			
			shoot_timer.reload()

	if Input.is_action_pressed("key_x") and !game.current_events.has(game.EVENTS.S_FAITH_OVERDOSE) and \
		!game.current_events.has(game.EVENTS.GET_ITEM_REWARD):
		
		is_shooting = false
		is_faith = true	
		if shoot_timer.is_finish():
			cur_power = game.PLAYER_POWER_TYPE.CROSS
			get_node("power_effect/cross").show()
			
			if power_timer.is_finish():
				game.cam.shake(0.4, 0.4, 0.1)
			
	else:
		get_node("power_effect/cross").hide()
		cur_power = null

	# CHARACTER PORTRAIT
	char_portrait = game.gui.character_portrait
	if is_shooting:
		char_portrait.set_character_action(char_portrait.CHARACTER_ACTION.ATTACK)
	elif is_faith:
		char_portrait.set_character_action(char_portrait.CHARACTER_ACTION.FAITH)
	else:
		char_portrait.set_character_action(char_portrait.CHARACTER_ACTION.RUN)

	if OPTIONS.is_hacks_enabled:
		if Input.is_action_pressed("plus") and game.button_timer.is_finish() and level < 20:
			add_exp(exp_to_level_up)
			game.button_timer.reload()
		elif Input.is_action_pressed("minus") and game.button_timer.is_finish() and level > 1:
			reduce_levels(1)
			game.button_timer.reload()

	var is_player_move
	if dx == 0 or dy == 0:
		is_player_move = true
	else:
		is_player_move = false
	
	return is_player_move

func shoot():
	var cur_pos = get_global_pos()

	cur_pos.y -= 14

	var center_pos_x = cur_pos.x + 10

	if level == 1:
		spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed, null)
		if game.cur_player_items.has(game.ITEMS.CARD_OF_SPADES_1):
			spawn_projectile(Vector2(center_pos_x + 3, cur_pos.y), projectile_speed - 55, null)

	elif level == 2:
		spawn_projectile(Vector2(center_pos_x - 10, cur_pos.y), projectile_speed, null)
		spawn_projectile(Vector2(center_pos_x + 10, cur_pos.y), projectile_speed, null)
		if game.cur_player_items.has(game.ITEMS.CARD_OF_SPADES_2):
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed + 60, null)

	elif level == 3:
		spawn_projectile(Vector2(center_pos_x - 10, cur_pos.y), projectile_speed, null)
		spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 150, null)
		spawn_projectile(Vector2(center_pos_x + 10, cur_pos.y), projectile_speed - 100, null)
		if game.cur_player_items.has(game.ITEMS.CARD_OF_SPADES_3):
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed + 25, 220)
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed + 25, 320)

	elif level == 4:
		spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed + 25, 250)
		spawn_projectile(Vector2(center_pos_x - 5, cur_pos.y), projectile_speed + 25, null)
		spawn_projectile(Vector2(center_pos_x + 5, cur_pos.y), projectile_speed + 25, null)
		spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed + 25, 300)
		if game.cur_player_items.has(game.ITEMS.CARD_OF_SPADES_4):
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed + 25, 230)
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed + 25, 310)
	elif level == 5:
		spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed, 225)
		spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 15, 245)
		spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed, null)
		spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 15, 305)
		spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed, 325)
		if game.cur_player_items.has(game.ITEMS.CARD_OF_SPADES_5):
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 45, 245)
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 45, 305)
	elif level == 6:
		spawn_projectile(Vector2(center_pos_x - 10, cur_pos.y), projectile_speed + 15, null)
		spawn_projectile(Vector2(center_pos_x - 5, cur_pos.y), projectile_speed + 45, null)
		spawn_projectile(Vector2(center_pos_x + 5, cur_pos.y), projectile_speed + 55, null)
		spawn_projectile(Vector2(center_pos_x + 10, cur_pos.y), projectile_speed + 15, null)
		if game.cur_player_items.has(game.ITEMS.CARD_OF_SPADES_6):
			spawn_projectile(Vector2(center_pos_x - 15, cur_pos.y), projectile_speed - 15, null)
			spawn_projectile(Vector2(center_pos_x + 15, cur_pos.y), projectile_speed - 15, null)

	elif level == 7:
		spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 15, 200)
		spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed + 35, null)
		spawn_projectile(Vector2(center_pos_x - 5, cur_pos.y), projectile_speed + 45, null)
		spawn_projectile(Vector2(center_pos_x + 5, cur_pos.y), projectile_speed + 55, null)
		spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 15, 350)
		if game.cur_player_items.has(game.ITEMS.CARD_OF_SPADES_7):
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 15, 250)
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 15, 300)
	elif level == 8:
		spawn_projectile(Vector2(center_pos_x - 15, cur_pos.y - 5), projectile_speed - 45, null)
		spawn_projectile(Vector2(center_pos_x - 10, cur_pos.y), projectile_speed + 15, null)
		spawn_projectile(Vector2(center_pos_x - 5, cur_pos.y), projectile_speed + 25, null)
		spawn_projectile(Vector2(center_pos_x + 5, cur_pos.y), projectile_speed + 35, null)
		spawn_projectile(Vector2(center_pos_x + 10, cur_pos.y), projectile_speed + 45, null)
		spawn_projectile(Vector2(center_pos_x + 15, cur_pos.y - 5), projectile_speed - 45, null)
		if game.cur_player_items.has(game.ITEMS.CARD_OF_SPADES_8):
			spawn_projectile(Vector2(center_pos_x - 15, cur_pos.y), projectile_speed - 85, null)
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 85, null)
			spawn_projectile(Vector2(center_pos_x + 15, cur_pos.y), projectile_speed - 85, null)

	elif level == 9:
		spawn_projectile(Vector2(center_pos_x - 15, cur_pos.y - 5), projectile_speed - 47, 265)
		spawn_projectile(Vector2(center_pos_x - 15, cur_pos.y - 5), projectile_speed - 45, null)
		spawn_projectile(Vector2(center_pos_x - 10, cur_pos.y), projectile_speed + 15, null)
		spawn_projectile(Vector2(center_pos_x - 5, cur_pos.y), projectile_speed + 25, null)
		spawn_projectile(Vector2(center_pos_x + 5, cur_pos.y), projectile_speed + 35, null)
		spawn_projectile(Vector2(center_pos_x + 10, cur_pos.y), projectile_speed + 45, null)
		spawn_projectile(Vector2(center_pos_x + 15, cur_pos.y - 5), projectile_speed - 45, null)
		spawn_projectile(Vector2(center_pos_x + 15, cur_pos.y - 5), projectile_speed - 47, 275)
		if game.cur_player_items.has(game.ITEMS.CARD_OF_SPADES_9):
			spawn_projectile(Vector2(center_pos_x - 15, cur_pos.y), projectile_speed - 85, null)
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 85, null)
			spawn_projectile(Vector2(center_pos_x + 15, cur_pos.y), projectile_speed - 85, null)

	elif level == 10:
		spawn_projectile(Vector2(center_pos_x - 15, cur_pos.y - 5), projectile_speed - 50, 255)
		spawn_projectile(Vector2(center_pos_x - 15, cur_pos.y - 5), projectile_speed - 50, 265)
		spawn_projectile(Vector2(center_pos_x - 15, cur_pos.y - 5), projectile_speed + 45, null)
		spawn_projectile(Vector2(center_pos_x - 10, cur_pos.y), projectile_speed + 15, null)
		spawn_projectile(Vector2(center_pos_x - 5, cur_pos.y), projectile_speed + 25, null)
		spawn_projectile(Vector2(center_pos_x + 5, cur_pos.y), projectile_speed + 35, null)
		spawn_projectile(Vector2(center_pos_x + 10, cur_pos.y), projectile_speed + 45, null)
		spawn_projectile(Vector2(center_pos_x + 15, cur_pos.y - 5), projectile_speed + 45, null)
		spawn_projectile(Vector2(center_pos_x + 15, cur_pos.y - 5), projectile_speed - 50, 275)
		spawn_projectile(Vector2(center_pos_x + 15, cur_pos.y - 5), projectile_speed - 50, 285)
		if game.cur_player_items.has(game.ITEMS.CARD_OF_SPADES_10):
			spawn_projectile(Vector2(center_pos_x - 15, cur_pos.y), projectile_speed - 65, null)
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 75, null)
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 85, null)
			spawn_projectile(Vector2(center_pos_x, cur_pos.y), projectile_speed - 95, null)
			spawn_projectile(Vector2(center_pos_x + 15, cur_pos.y), projectile_speed - 65, null)

	# если есть левое щупальце но нет правого
	if game.cur_player_items.has(game.ITEMS.LEFT_TENTACLE) and !game.cur_player_items.has(game.ITEMS.RIGHT_TENTACLE):
		var pr = spawn_projectile(Vector2(center_pos_x - 15, cur_pos.y + 40), projectile_speed, 180)	
		pr.set_tex_rotd(90)
	# если есть правое щупальче но нет левого
	elif game.cur_player_items.has(game.ITEMS.RIGHT_TENTACLE) and !game.cur_player_items.has(game.ITEMS.LEFT_TENTACLE):
		var pr = spawn_projectile(Vector2(center_pos_x + 17, cur_pos.y + 13), projectile_speed, 0)	
		pr.set_tex_rotd(270)
	# если есть оба щупальца
	elif game.cur_player_items.has(game.ITEMS.LEFT_TENTACLE) and game.cur_player_items.has(game.ITEMS.RIGHT_TENTACLE):
		var pr = spawn_projectile(Vector2(center_pos_x - 15, cur_pos.y + 40), projectile_speed, 180)	
		pr.set_tex_rotd(90)
		var pr = spawn_projectile(Vector2(center_pos_x - 15, cur_pos.y + 40), projectile_speed, 165)	
		pr.set_tex_rotd(90)
		var pr = spawn_projectile(Vector2(center_pos_x + 17, cur_pos.y + 13), projectile_speed, 0)	
		pr.set_tex_rotd(270)
		var pr = spawn_projectile(Vector2(center_pos_x + 17, cur_pos.y + 13), projectile_speed, 15)	
		pr.set_tex_rotd(270)

	# если есть мутировавший червь (стрельба назад)
	if game.cur_player_items.has(game.ITEMS.MUTATED_WORM):
		var pr = spawn_projectile(Vector2(center_pos_x + 30, cur_pos.y + 40), projectile_speed, 90)
		pr.set_tex_rotd(180)
		if game.cur_player_items.has(game.ITEMS.LEFT_TENTACLE):
			var pr = spawn_projectile(Vector2(center_pos_x + 30, cur_pos.y + 40), projectile_speed, 110)
			pr.set_tex_rotd(180)
		if game.cur_player_items.has(game.ITEMS.RIGHT_TENTACLE):
			var pr = spawn_projectile(Vector2(center_pos_x + 30, cur_pos.y + 40), projectile_speed, 70)
			pr.set_tex_rotd(180)

	game.sound.play("shoot", "lvl"+str(level)+"_shoot")

func deal_damage(_count):
	if !is_need_blink:
		reduce_levels()

	.deal_damage(_count)
	
	game.cam.shake(1, 10, 0.6)

func add_exp(_count):
	cur_exp += _count
	check_exp()

func reduce_levels(_count = 1):
	level -= _count
	if level < 1:
		level = 0
	else:
		for i in range(_count):
			# slowly world
			game.cur_world_speed -= game.world_speed_change_coef_by_player_lvl
			char_portrait.reduce_sine_range(0.5, 1.25)

		game.sound.play("env", "level_reduce")

	setup_walk_time()

	cur_exp = 0
	check_exp()

func check_exp():
	if level < 10 and cur_exp >= exp_to_level_up:
		level += 1
		game.cur_world_speed += game.world_speed_change_coef_by_player_lvl
		cur_exp = 0
		char_portrait.add_sine_range(0.5, 1.25)

		game.sound.play("env", "level_up")
		setup_walk_time()

	if level == 1:
		exp_to_level_up = 15
	elif level == 2:
		exp_to_level_up = 20
	elif level == 3:
		exp_to_level_up = 30
	elif level == 4:
		exp_to_level_up = 45
	elif level == 5:
		exp_to_level_up = 50
	elif level == 6:
		exp_to_level_up = 60
	elif level == 7:
		exp_to_level_up = 70
	else:
		exp_to_level_up = 80

	var char_portrait_tex_holder
	if char_portrait != null:
		if level >= 7:
			get_node("tex1").show()
			get_node("tex1/l").set_enabled(true)
			char_portrait_tex_holder = char_portrait.tex_holders.high_lvl
		elif level >= 4 and level < 7:
			char_portrait_tex_holder = char_portrait.tex_holders.med_lvl
		else:
			char_portrait_tex_holder = char_portrait.tex_holders.standard
			
			get_node("tex1").hide()
			get_node("tex1/l").set_enabled(false)

	if char_portrait_tex_holder != null:
		char_portrait.set_cur_tex_holder(char_portrait_tex_holder)

func setup_walk_time():
	if level == 1:
		walk_time = init_walk_time
	else:
		walk_time = init_walk_time / (level * 0.3)

func take_item(_type, _is_without_messagebox = false):
	var taked_item_type = _type
	game.cur_player_items.append(taked_item_type)
	var item_info_params = ENV.get_item_info_params_by_type(taked_item_type)

	if taked_item_type == game.ITEMS.LASH_OF_REPOSE:
		power_accum_timer.change_init_time(power_accum_timer.init_time + 0.1)

	if !_is_without_messagebox:
		game.gui.show_messagebox(item_info_params.name, item_info_params.desc)
	
	game.complete_event(game.EVENTS.GET_ITEM_REWARD)

func take_items(_items, _is_without_messagebox = false):
	for item in _items:
		take_item(item, _is_without_messagebox)