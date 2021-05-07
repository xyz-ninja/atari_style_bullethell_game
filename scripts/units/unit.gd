extends Node2D

var game

var is_unit = true

export var is_active = true
export var is_spawn_from_editor = false

var tex
var init_tex_modulate
var init_tex_scale

# animation
var init_anim_time = 0.12
var anim_timer = TIME.create_new_timer("unit_anim_timer", init_anim_time)
var cur_anim_frame_num = 0
var is_anim_loop_backwards = false # когда анимация проигралась, она начинает играть задом наперед
var is_anim_now_loop_backwards = false

var init_health
var health

var is_player = false
var is_med_enemy = false
var is_big_enemy = false
var is_boss = false

var is_flipped_left = false
var is_flipped_right = true
var is_flipped_vertical = false

var collision_dist = 22

var is_need_blink = false # "мерцание" текстуры при нанесении урона

# push
var is_can_be_pushed_back = false # может ли юнит отталкиваться от попаданий
var is_pushing_back = false
var pushing_speed_multiplier = 1.4
var push_back_time = 0.22
var push_back_timer = TIME.create_new_timer("push_back_timer", push_back_time)

# dash
var is_need_dash = false
var is_already_dash = false
var dash_speed = 150
var dash_wait_timer = TIME.create_new_timer("dash_wait_timer", 1.0)
var dash_timer = TIME.create_new_timer("dash_timer", 1.0)
var dash_angle
var dash_angle_icon
var is_destroy_after_dash = false

# blink
var loc_blink_time = 0.04
var loc_blink_timer = loc_blink_time

var custom_blink_color

var cur_projectiles = []
var projectile_damage = 1

# move
var init_movement_speed
var movement_speed # у врагов она изменяется в зависимости от скорости мира

# exp
var exp_bonus_count = 1
var guaranteed_exp_bonus_count = 0 # гарантированный бонус exp

var cur_projectile_type = null

var is_already_dead = false 
var addit_death_timer # нужен для того что бы некоторые юниты не умирали сразу

var is_autodestroy_outside_screen = true # уничтожается ли юнит автоматически далеко внизу экрана
var autodestroy_timer = TIME.create_new_timer("unit_autodestroy_timer", 7.0)
var is_autodestroy_sound_already_played = false

var blood_spawn_pos = Vector2(0, 0)

var is_without_blood = false

func _ready():
	game = get_tree().get_nodes_in_group("game")[0]

	tex = get_node("tex")
	init_tex_modulate = tex.get_modulate()
	init_tex_scale = tex.get_scale()

	if is_spawn_from_editor:
		game.cur_enemy_units.append(self)

	if !is_player:
		set_cur_projectile_type(game.PROJECTILE_TYPE.ENEMY_NORMAL)
	
	set_process(true)

func _process(delta):
	if !is_active:
		set_process(false)
		return
	
	if loc_blink_timer > 0:
		loc_blink_timer -= delta

	if !is_player:
		movement_speed = init_movement_speed * game.cur_world_speed

	var cur_pos = get_global_pos()
	
	# setting blood spawn pos
	if is_flipped_left:
		blood_spawn_pos = Vector2(cur_pos.x - collision_dist, cur_pos.y - collision_dist)
	else:
		blood_spawn_pos = Vector2(cur_pos.x + collision_dist, cur_pos.y + collision_dist)

	var dx = 0
	var dy = 0

	if is_autodestroy_outside_screen:
		if game.is_unit_in_play_zone(self):
			autodestroy_timer.reload()
		else:
			#if cur_pos.y > game.play_region_y_end_pos + 200:
			if autodestroy_timer.is_finish():
				destroy()

	# РЫВОК
	if is_need_dash:
		if dash_wait_timer.is_finish() and !is_already_dash:
			is_already_dash = true
			#dash_angle = SYS.get_angle_between_positions(get_global_pos(), game.player.get_global_pos()) + 175
			if dash_angle_icon == null or weakref(dash_angle_icon).get_ref() == null:
				dash_angle = SYS.get_angle_between_positions(get_global_pos(), game.player.get_global_pos()) + 175
			else:
				dash_angle = -dash_angle_icon.get_rotd() + 175
	else:
		dash_timer.reload()

	if is_already_dash:
		if dash_timer.is_finish():
			is_already_dash = false
			is_need_dash = false
			
			if is_destroy_after_dash:
				destroy()
		else:
			if game.is_unit_in_play_zone(self):
				game.sound.play("env2", "dash")

			dx = 1.0
			dy = 1.0
			
			dx *= cos(deg2rad(dash_angle)) * (dash_speed * game.cur_world_speed) * delta
			dy *= sin(deg2rad(dash_angle)) * (dash_speed * game.cur_world_speed) * delta

			if dash_angle_icon != null and weakref(dash_angle_icon).get_ref():
				dash_angle_icon.queue_free()
	else:
		dash_timer.reload()

	# ОТТАЛКИВАНИЕ ЮНИТА ОТ ПОПАДАНИЙ
	if is_pushing_back:
		dy -= movement_speed * pushing_speed_multiplier * delta
		
		if push_back_timer.is_finish():
			is_pushing_back = false

	set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

	# ОЖИДАНИЕ СМЕРТИ
	if is_already_dead:
		if addit_death_timer == null or addit_death_timer.is_finish():
			destroy()
		elif addit_death_timer != null and !addit_death_timer.is_finish():
			if !is_autodestroy_sound_already_played:
				game.sound.play("env2", "boss_destroyed")
				is_autodestroy_sound_already_played = true
			
	# МЕРЦАНИЕ ТЕКСТУРЫ ПРИ ПОЛУЧЕНИИ УРОНА
	if is_need_blink:
		if is_player:
			tex.set_modulate(Color(SYS.Colors.white))
		else:
			if custom_blink_color == null:
				tex.set_modulate(Color(SYS.Colors.red))
			else:
				tex.set_modulate(Color(custom_blink_color))

		#if blink_timer.is_finish():
		if loc_blink_timer < 0:
			is_need_blink = false
		
	else:
		tex.set_modulate(init_tex_modulate)

	# СТОЛКНОВЕНИЯ
	# floor objects
	for obj_node in game.objects_node.get_children():
		if weakref(obj_node).get_ref() and obj_node != null and obj_node.get("is_floor_object"):
			if SYS.get_dist_between_sprites(tex, obj_node.get_node("tex")) < 50:
				obj_node.destroy_by_unit(is_player)

func play_frame_animation(_frames_count = 6, _start_from_frame = 0, _anim_speed = init_anim_time):
	var frames_count = _frames_count
	var from_frame = _start_from_frame

	if frames_count == 0 or frames_count == 1:
		cur_anim_frame_num = 0
		is_anim_now_loop_backwards = false
	else:
		if cur_anim_frame_num >= frames_count :
			cur_anim_frame_num = 0

	# изменяем скорость анимации по таймеру если она отличается от изначальной
	if anim_timer.init_time != _anim_speed:
		anim_timer.change_init_time(_anim_speed)

	if anim_timer.is_finish():
		# loop backward mode
		if is_anim_loop_backwards:
			if frames_count > 1:
				if is_anim_now_loop_backwards:
					if cur_anim_frame_num - 1 == 0:
						cur_anim_frame_num = 0
						is_anim_now_loop_backwards = false
					else:
						cur_anim_frame_num -= 1
				else:
					if cur_anim_frame_num + 1 == frames_count:
						cur_anim_frame_num -= 1
						is_anim_now_loop_backwards = true
					else:
						cur_anim_frame_num += 1
		else:
			if cur_anim_frame_num + 1 == frames_count:
				cur_anim_frame_num = 0
			else:
				cur_anim_frame_num += 1

		var prev_rect2 = tex.get_region_rect()

		# ставим нужный кадр из текстуры
		tex.set_region_rect(Rect2(Vector2(
			prev_rect2.size.x * (cur_anim_frame_num + from_frame), prev_rect2.pos.y),
			prev_rect2.size)
		)

		if has_node("tex1"):
			get_node("tex1").set_region_rect(tex.get_region_rect())

		anim_timer.reload()

func spawn_projectile(_pos, _move_speed, _move_angle = null, _autodestroy_time = null):
	var new_pr = game.projectile_scn.instance()
	new_pr.set_global_pos(_pos)
	game.get_node("main/projectiles").add_child(new_pr)

	new_pr.setup(cur_projectile_type, _move_speed, _move_angle, _autodestroy_time)
	
	if is_player:
		new_pr.is_belongs_to_player = true

		if game.cur_player_items.has(game.ITEMS.DEVIL_DAGGER):
			new_pr.hits_to_destroy = 1
	else:
		new_pr.is_belongs_to_player = false
	
	new_pr.by_unit = self
	new_pr.set_damage(projectile_damage)

	cur_projectiles.append(self)

	game.sound.play("units", "enemy_shoot")

	return new_pr

func deal_damage(_count, _without_blink = false):
	if !is_need_blink and !is_already_dead:
		if is_player:
			#blink_timer.reload()
			loc_blink_timer = loc_blink_time
			is_need_blink = true
		else:
			health -= _count

			# SPAWN BLOOD
			if OPTIONS.is_blood_enabled and !is_without_blood:
				if SYS.get_random_percent_0_to_100() < 25:
					spawn_blood()

			if health > 0:
				game.sound.play("units", "unit_hit")

				#blink_timer.reload()
				if !_without_blink:
					loc_blink_timer = loc_blink_time
					is_need_blink = true

				if is_can_be_pushed_back:
					var cur_push_back_time = push_back_time
					if game.cur_player_items.has(game.ITEMS.BLOODY_CALLUS):
						cur_push_back_time += 0.1

					if push_back_timer.init_time != cur_push_back_time:
						push_back_timer.change_init_time(cur_push_back_time)

					is_pushing_back = true
					push_back_timer.reload()
			else:
				if is_boss:
					#game.sound.play("env", "boss_destroyed")
					pass
				else:
					game.sound.play("env", "unit_destroyed")

				if addit_death_timer == null:
					destroy()
				else:
					addit_death_timer.reload()

				is_already_dead = true

func spawn_blood():
	var rand_spawn_pos = Vector2(
		blood_spawn_pos.x + SYS.get_random_int(-2, 2),
		blood_spawn_pos.y + SYS.get_random_int(-2, 2)
	)

	game.spawn_object_from_scene(game.blood_obj_scn, rand_spawn_pos)

func set_health(_count):
	init_health = _count
	health = init_health

func set_movement_speed(_speed):
	if init_movement_speed != _speed:
		init_movement_speed = _speed
		movement_speed = init_movement_speed

func set_custom_blink_time(_time):
	#blink_timer.change_init_time(_time)
	loc_blink_time = _time
	loc_blink_timer = loc_blink_time

func set_cur_projectile_type(_type):
	cur_projectile_type = _type

func set_medium_size_enemy(_bool):
	if _bool:
		is_med_enemy = true
		is_big_enemy = false
		collision_dist = 32

func set_big_size_enemy(_bool):
	if _bool:
		is_med_enemy = false
		is_big_enemy = true
		collision_dist = 46

func set_push_back_time(_time):
	push_back_time

# dash angle can change for time
func set_dash(_angle, _wait_time, _dash_time, _dash_speed = 150):
	var corrected_icon_pos = get_global_pos()
	
	if is_flipped_right:
		corrected_icon_pos.x += 20
	else:
		corrected_icon_pos.x -= 5
	
	corrected_icon_pos.y += 20

	if !is_already_dash:
		dash_angle = _angle
	
	dash_speed = _dash_speed

	if is_need_dash:
		if dash_angle_icon == null or weakref(dash_angle_icon).get_ref() == null:
			dash_angle_icon = null
		else:
			dash_angle_icon.set_rotd(dash_angle)
			dash_angle_icon.set_global_pos(corrected_icon_pos)
	else:
		dash_wait_timer.change_init_time(_wait_time)
		dash_timer.change_init_time(_dash_time)

		dash_angle_icon = game.spawn_object_from_scene(game.u_attack_direction_marker_scn, corrected_icon_pos, true)
		dash_angle_icon.set_rotd(dash_angle)

		is_need_dash = true

func destroy():
	# erase bounded objects
	if dash_angle_icon != null and weakref(dash_angle_icon).get_ref():
		dash_angle_icon.queue_free()
	dash_angle_icon = null

	if is_player:
		pass
	else:
		spawn_blood()

		# exp bonus
		var true_exp_bonus_count = 0 + guaranteed_exp_bonus_count

		var cur_exp_bonus_count = exp_bonus_count

		if game.cur_player_items.has(game.ITEMS.UGLY_SKULL):
			cur_exp_bonus_count += SYS.get_random_int(0,2)
			if SYS.get_random_percent_0_to_100() < 20:
				cur_exp_bonus_count += 1

		for i in range(cur_exp_bonus_count):
			if SYS.get_random_percent_0_to_100() < 20:
				true_exp_bonus_count += 1

		var big_exp_count = 0
		var med_exp_count = 0

		if true_exp_bonus_count > 40:
			big_exp_count = int(true_exp_bonus_count / 40) 
			true_exp_bonus_count -= 40 * big_exp_count
			big_exp_count += SYS.get_random_int(0, 1)

		if true_exp_bonus_count > 10:
			med_exp_count = int(true_exp_bonus_count / 10) 
			true_exp_bonus_count -= 10 * med_exp_count
			med_exp_count += SYS.get_random_int(0, 2)

		for i in range(true_exp_bonus_count):
			var new_exp_bonus = game.exp_bonus_scn.instance()
			game.get_node("main/objects").add_child(new_exp_bonus)
			new_exp_bonus.set_global_pos(Vector2(
				get_global_pos().x + SYS.get_random_int(-8, 8), get_global_pos().y + SYS.get_random_int(-8, 8)))

			if big_exp_count > 0:
				new_exp_bonus.set_type(new_exp_bonus.EXP_BONUS_TYPE.BIG)
				big_exp_count -= 1
			elif med_exp_count > 0:
				new_exp_bonus.set_type(new_exp_bonus.EXP_BONUS_TYPE.MED)
				med_exp_count -= 1
			else:
				new_exp_bonus.set_type(new_exp_bonus.EXP_BONUS_TYPE.ONE)

		# particles
		var new_p = game.particles_blood_scn.instance()
		game.get_node("main/objects").add_child(new_p)
		new_p.set_global_pos(get_global_pos())

		new_p.set_autodestroy_and_emit_timer(SYS.get_random_float(0.5, 0.9))

		game.cur_enemy_units.erase(self)
		queue_free()

func flip_texture_left():
	var cur_scale = tex.get_scale()

	tex.set_scale(Vector2(-init_tex_scale.x, cur_scale.y))
	if has_node("tex1"):
		get_node("tex1").set_scale(Vector2(-init_tex_scale.x, cur_scale.y))

	is_flipped_left = true
	is_flipped_right = false

func flip_texture_right():
	var cur_scale = tex.get_scale()

	tex.set_scale(Vector2(init_tex_scale.x, cur_scale.y))
	if has_node("tex1"):
		get_node("tex1").set_scale(Vector2(init_tex_scale.x, init_tex_scale.y))

	is_flipped_left = false
	is_flipped_right = true

func flip_texture_vertical(_bool):
	var cur_scale = tex.get_scale()

	if _bool:
		tex.set_scale(Vector2(cur_scale.x, -init_tex_scale.y))
	else:
		tex.set_scale(Vector2(cur_scale.x, init_tex_scale.y))

	is_flipped_vertical = _bool