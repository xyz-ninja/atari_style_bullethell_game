extends "res://scripts/units/unit.gd"

var run_away_timer = TIME.create_new_timer("boss_mushroom_run_away_timer", 2.1)
var phantoms_shoot_timer = TIME.create_new_timer("boss_mushroom_phantoms_shoot_timer", 1.85)
var phantoms_dash_timer = TIME.create_new_timer("boss_mushroom_phantoms_dash_timer", 0.7)
var phantoms_spawn_wait_timer = TIME.create_new_timer("boss_mushroom_phantoms_spawn_wait_timer", 1.45)
var phantoms_afterspawn_wait_timer = TIME.create_new_timer("boss_mushroom_phantoms_afterspawn_wait_timer", 1.0)

enum PHANTHOM_TYPE {MOVE, DASH, SHOOT}

var cur_phantoms = []
var cur_phantoms_type

func _ready():
	set_health(150)

	exp_bonus_count = 32
	guaranteed_exp_bonus_count = SYS.get_random_int(80, 120)

	addit_death_timer = TIME.create_new_timer("boss_death_timer", 3.1)

	set_medium_size_enemy(true)

	custom_blink_color = SYS.Colors.yellow

	is_boss = true

	set_process(true)
	
func _process(delta):
	if is_already_dead:
		pass
	else:
		var addit_movement_speed = 0
		if health < init_health / 3:
			addit_movement_speed = 30

		var cur_pos = get_global_pos()

		var dx = 0
		var dy = 0

		# RUN AWAY
		if cur_phantoms_type == null:
			if run_away_timer.is_finish():

				# SELECT PHANTOMS TYPE AND SPAWN PHANTOMS
				if phantoms_spawn_wait_timer.is_finish():	
					var sel_type = SYS.get_random_arr_item(
						[PHANTHOM_TYPE.MOVE, PHANTHOM_TYPE.DASH, PHANTHOM_TYPE.SHOOT])

					# spawn phantoms
					var phantoms_count
					if sel_type == PHANTHOM_TYPE.MOVE:
						phantoms_count = SYS.get_random_int(4,8)
						set_movement_speed(55)
					elif sel_type == PHANTHOM_TYPE.DASH:
						phantoms_count = SYS.get_random_int(3,5)
						set_movement_speed(70)
					elif sel_type == PHANTHOM_TYPE.SHOOT:
						phantoms_count = SYS.get_random_int(4,5)
						set_movement_speed(15)

					for i in range(phantoms_count):
						# выбираем позицию на некотором расстоянии от игрока
						var sel_pos
						while sel_pos == null:
							sel_pos = Vector2(
								SYS.get_random_int(60, game.play_region_x_end_pos - 80),
								SYS.get_random_int(game.play_region_y_start_pos + 60, game.play_region_y_end_pos - 120)
							)

							if SYS.get_dist_between_points(sel_pos, game.player.get_global_pos()) < 130:
								sel_pos = null

						var phantom_unit = game.spawn_unit_from_scene(game.u_mushroom_phantom_scn, sel_pos)

						phantom_unit.setup(self, sel_type)

						cur_phantoms.append(phantom_unit)

					# с большим шансом меняется с фантомом местами
					if SYS.get_random_percent_0_to_100() < 85:
						var sel_ph = SYS.get_random_arr_item(cur_phantoms)

						var prev_pos = get_global_pos()
						var prev_ph_pos = sel_ph.get_global_pos()

						cur_pos = prev_ph_pos
						sel_ph.set_global_pos(prev_pos)

					phantoms_afterspawn_wait_timer.reload()

					cur_phantoms_type = sel_type

				else:
					init_anim_time = 0.08
					play_frame_animation(4, 4)
			else:
				set_movement_speed(115)

				init_anim_time = 0.14
				play_frame_animation(4)

				phantoms_spawn_wait_timer.reload()

				var pl_pos = game.player.get_global_pos()
				if pl_pos.x < cur_pos.x - 2 and cur_pos.x + dx < game.play_region_x_end_pos - 50:
					dx += movement_speed * delta
				elif pl_pos.x > cur_pos.x + 2 and cur_pos.x - dx > 50:
					dx -= movement_speed * delta

				if pl_pos.y < cur_pos.y - 2 and cur_pos.y + dy < game.play_region_y_end_pos - 50:
					dy += movement_speed * delta
				elif pl_pos.y > cur_pos.y + 2 and cur_pos.y - dy > game.play_region_y_start_pos + 30:
					dy -= movement_speed * delta
		
		# PHANTOMS
		else:
			run_away_timer.reload()

			init_anim_time = 0.14
			play_frame_animation(4)

			if phantoms_afterspawn_wait_timer.is_finish():
				# check is phantoms alive
				var erased_phantoms = []
				for ph in cur_phantoms:
					if ph == null or weakref(ph).get_ref() == null:
						erased_phantoms.append(ph)
				for er_ph in erased_phantoms:
					cur_phantoms.erase(er_ph)

				if cur_phantoms.size() == 0:
					cur_phantoms_type = null
				else:
					# MOVEMENT AND ACTION
					var vec2_dx_dy = get_dx_dy_by_phantom_type(delta, cur_phantoms_type)

					if cur_phantoms_type == PHANTHOM_TYPE.DASH and phantoms_dash_timer.is_finish():
						var cur_units = [self] + cur_phantoms

						for u in cur_units:
							if u != null and weakref(u).get_ref() and u.get("is_unit"):
								u.set_dash(-SYS.get_angle_between_positions(
									cur_pos, game.player.get_global_pos()) + SYS.get_random_int(-10, 10),
									0.7, 0.5, 250)

						phantoms_dash_timer.reload()
					elif cur_phantoms_type == PHANTHOM_TYPE.SHOOT:
						if phantoms_shoot_timer.is_finish():
							shoot()
							phantoms_shoot_timer.reload()

					dx = vec2_dx_dy.x
					dy = vec2_dx_dy.y
			else:
				phantoms_dash_timer.reload()
				phantoms_shoot_timer.reload()

		set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

# dx, dy из этой функции могут получать фантомы для своего личного передвижения (_other_unit) 
func get_dx_dy_by_phantom_type(delta, _type, _other_unit = null):
	var cur_type = _type	
	var cur_unit
	if _other_unit == null:
		cur_unit = self
	else:
		cur_unit = _other_unit
	var cur_pos = cur_unit.get_global_pos()

	var dx = 0
	var dy = 0	

	var pl_pos = game.player.get_global_pos()

	if cur_pos.x < pl_pos.x - 1:
		dx += (movement_speed + SYS.get_random_int(-15, 15)) * delta
	elif cur_pos.x > pl_pos.x + 1:
		dx -= (movement_speed + SYS.get_random_int(-15, 15)) * delta

	if cur_pos.y < pl_pos.y - 1:
		dy += (movement_speed + SYS.get_random_int(-15, 15)) * delta
	elif cur_pos.y > pl_pos.y + 1:
		dy -= (movement_speed + SYS.get_random_int(-15, 15)) * delta

	if cur_type == PHANTHOM_TYPE.DASH:
		if cur_unit.is_need_dash or cur_unit.is_already_dash:
			dx = 0
			dy = 0

	return Vector2(dx, dy)

func shoot():
	var cur_units = [self] + cur_phantoms

	var proj_speed = SYS.get_random_int(170, 220)

	for u in cur_units:
		if u != null and weakref(u).get_ref() and u.get("is_unit"):
			var cur_pos = u.get_global_pos()
			cur_pos.x += 20
			cur_pos.y += 20
			
			u.spawn_projectile(cur_pos, proj_speed, 0)
			u.spawn_projectile(cur_pos, proj_speed, 90)
			u.spawn_projectile(cur_pos, proj_speed, 180)
			u.spawn_projectile(cur_pos, proj_speed, 270)

func deal_damage(_count, _without_blink = false):
	.deal_damage(_count, _without_blink)

	# deal damage to phantoms if player hit boss
	for ph in cur_phantoms:
		if ph != null and weakref(ph).get_ref() and ph.get("is_unit"):
			ph.deal_damage(1)

func destroy():
	for ph in cur_phantoms:
		if ph != null and weakref(ph).get_ref() and ph.get("is_unit"):
			ph.destroy()

	.destroy()

	game.complete_event(game.EVENTS.BOSS_MUSHROOM)