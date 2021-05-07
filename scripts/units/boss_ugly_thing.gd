extends "res://scripts/units/unit.gd"

var run_away_timer = TIME.create_new_timer("boss_ugly_thing_run_away_timer", 3.1)
var run_away_shoot_timer = TIME.create_new_timer("boss_ugly_thing_run_away_shoot_timer", 0.7)
var cur_mode_timer = TIME.create_new_timer("boss_ugly_thing_cur_mode_timer", 5.2)
var wait_to_dash_timer = TIME.create_new_timer("boss_ugly_thing_wait_to_dash_timer", 0.6)
var dash_shoot_timer = TIME.create_new_timer("boss_ugly_thing_dash_shoot_timer", 0.4)
var shoot_mode_shoot_timer = TIME.create_new_timer("boss_ugly_thing_shoot_mode_shoot_timer", 0.7)

enum ATTACK_MODES {DASH, SHOOT}

var cur_mode

func _ready():
	set_health(120)

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

		if cur_mode != null:
			if cur_mode_timer.is_finish():
				run_away_timer.reload()

				if cur_mode == ATTACK_MODES.DASH and !game.is_unit_in_play_zone(self):
					cur_mode = ATTACK_MODES.SHOOT
				else:
					cur_mode = null

		# RUN AWAY
		if cur_mode == ATTACK_MODES.DASH:

			init_anim_time = 0.12

			if is_need_dash and !is_already_dash:				
				play_frame_animation(1,4)

			elif is_already_dash:
				play_frame_animation(4,5)

				wait_to_dash_timer.reload()

				if dash_shoot_timer.is_finish():
					shoot()
					dash_shoot_timer.reload()
			else:
				dash_shoot_timer.reload()
				
				play_frame_animation(1,4)

				var pl_pos = game.player.get_global_pos()

				if wait_to_dash_timer.is_finish():
					set_dash(-SYS.get_angle_between_positions(cur_pos, pl_pos) + SYS.get_random_int(-10, 10),
						0.3, 0.65, 250)

		elif cur_mode == ATTACK_MODES.SHOOT:

			set_movement_speed(55)

			init_anim_time = 0.09
			play_frame_animation(4)

			var pl_pos = game.player.get_global_pos()

			if cur_pos.x < pl_pos.x - 1:
				dx += movement_speed * delta
			elif cur_pos.x > pl_pos.x + 1:
				dx -= movement_speed * delta

			if cur_pos.y < pl_pos.y - 1:
				dy += movement_speed * delta
			elif cur_pos.y > pl_pos.y + 1:
				dy -= movement_speed * delta

			if shoot_mode_shoot_timer.is_finish():
				shoot()
				shoot_mode_shoot_timer.reload()
		else:
			tex.set_modulate(init_tex_modulate)

			if run_away_timer.is_finish():
				cur_mode_timer.reload()
				cur_mode = SYS.get_random_arr_item([ATTACK_MODES.DASH, ATTACK_MODES.SHOOT])

			else:
				set_movement_speed(105)

				init_anim_time = 0.12
				play_frame_animation(4)

				if run_away_shoot_timer.is_finish():
					shoot()
					run_away_shoot_timer.reload()

				var pl_pos = game.player.get_global_pos()
				if pl_pos.x < cur_pos.x - 2 and cur_pos.x + dx < game.play_region_x_end_pos - 50:
					dx += movement_speed * delta
				elif pl_pos.x > cur_pos.x + 2 and cur_pos.x - dx > 50:
					dx -= movement_speed * delta

				if pl_pos.y < cur_pos.y - 2 and cur_pos.y + dy < game.play_region_y_end_pos - 50:
					dy += movement_speed * delta
				elif pl_pos.y > cur_pos.y + 2 and cur_pos.y - dy > game.play_region_y_start_pos + 30:
					dy -= movement_speed * delta

		set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

func shoot():
	var cur_pos = get_global_pos()
	cur_pos.x += 25
	cur_pos.y += 25

	var proj_speed = 200

	if cur_mode == ATTACK_MODES.DASH:
		spawn_projectile(cur_pos, proj_speed, 45)
		spawn_projectile(cur_pos, proj_speed, 135)
		spawn_projectile(cur_pos, proj_speed, 225)
		spawn_projectile(cur_pos, proj_speed, 315)

	elif cur_mode == ATTACK_MODES.SHOOT:
		proj_speed = 140

		spawn_projectile(cur_pos, proj_speed, 45)
		spawn_projectile(cur_pos, proj_speed, 135)
		spawn_projectile(cur_pos, proj_speed, 225)
		spawn_projectile(cur_pos, proj_speed, 315)
		spawn_projectile(cur_pos, proj_speed, 0)
		spawn_projectile(cur_pos, proj_speed, 90)
		spawn_projectile(cur_pos, proj_speed, 180)
		spawn_projectile(cur_pos, proj_speed, 270)

	else:
		spawn_projectile(cur_pos, proj_speed, 0)
		spawn_projectile(cur_pos, proj_speed, 90)
		spawn_projectile(cur_pos, proj_speed, 180)
		spawn_projectile(cur_pos, proj_speed, 270)

func destroy():
	.destroy()

	game.complete_event(game.EVENTS.BOSS_UGLY_THING)