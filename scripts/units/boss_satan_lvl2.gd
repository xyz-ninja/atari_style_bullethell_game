extends "res://scripts/units/unit.gd"

enum MODES {STAND_ATTACK, UNITS_SPAWN}

var mode_set_timer = TIME.create_new_timer("boss_satan_lvl2_mode_set_timer", 2.7)
var mode_end_timer = TIME.create_new_timer("boss_satan_lvl2_mode_end_timer", 2.5)

var mode_null_shoot_timer = TIME.create_new_timer("boss_satan_lvl2_null_mode_shoot_timer", 0.5)

var mode_stand_attack = {
	shoot_dir = null,
	shoot_timer = TIME.create_new_timer("boss_satan_lvl2_stand_attack_shoot_timer", 0.35)
}

var mode_units_spawn = {
	cur_move_point_index = 0,
	move_points = null,
	unit_scn = null,
	spawn_timer = TIME.create_new_timer("boss_satan_lvl2_mode_units_spawn_timer", 0.7)
}

var cur_mode

var cur_move_pos

func _ready():
	set_health(130)

	exp_bonus_count = 50
	guaranteed_exp_bonus_count = 180

	addit_death_timer = TIME.create_new_timer("boss_death_timer", 3.0)

	set_medium_size_enemy(true)

	custom_blink_color = SYS.Colors.red

	is_boss = true

	is_anim_loop_backwards = true

	mode_units_spawn.unit_scn = game.u_lvl2_wormman_scn
	mode_units_spawn.move_points = [Vector2(50, 130), Vector2(game.play_region_x_end_pos - 50, 130)]

	set_process(true)
	
func _process(delta):
	if is_already_dead:
		return

	var cur_pos = get_global_pos()
	cur_pos.x += 20
	cur_pos.y += 20

	var dx = 0
	var dy = 0

	if cur_mode == null:
		set_movement_speed(110)

		init_anim_time = 0.08
		play_frame_animation(3)

		mode_end_timer.reload()

		# MOVE
		if cur_move_pos == null:
			cur_move_pos = Vector2(
				SYS.get_random_int(70, game.play_region_x_end_pos - 70),
				SYS.get_random_int(game.play_region_y_start_pos + 40, game.play_region_y_start_pos + 200)
			)

		else:
			if cur_pos.x - 3 < cur_move_pos.x:
				dx += movement_speed * delta
			elif cur_pos.x + 3 > cur_move_pos.x:
				dx -= movement_speed * delta

			if cur_pos.y - 3 < cur_move_pos.y:
				dy += movement_speed * delta
			elif cur_pos.y + 3 > cur_move_pos.y:
				dy -= movement_speed * delta

			if SYS.get_dist_between_points(cur_pos, cur_move_pos) < 25:
				cur_move_pos = null

		# SHOOT
		if mode_null_shoot_timer.is_finish():
			var shoot_angle = SYS.get_angle_between_positions(cur_pos, game.player.get_global_pos()) + 180

			var proj_speed = 190

			var between_shots_range = 4

			spawn_projectile(cur_pos, proj_speed, shoot_angle)

			spawn_projectile(cur_pos, proj_speed - 30, 0)
			spawn_projectile(cur_pos, proj_speed - 30, 90)
			spawn_projectile(cur_pos, proj_speed - 30, 180)
			spawn_projectile(cur_pos, proj_speed - 30, 270)

			mode_null_shoot_timer.reload()

		if mode_set_timer.is_finish():
			cur_mode = SYS.get_random_arr_item([MODES.STAND_ATTACK, MODES.UNITS_SPAWN])
	else:
		mode_set_timer.reload()

		# STAND ATTACK MODE
		if cur_mode == MODES.STAND_ATTACK:
			set_movement_speed(0)

			if mode_stand_attack.shoot_dir == null:
				mode_stand_attack.shoot_dir = SYS.get_random_arr_item([
					SYS.DIR.LEFT, SYS.DIR.RIGHT, SYS.DIR.UP, SYS.DIR.DOWN
				])

			var cur_dir = mode_stand_attack.shoot_dir

			var cur_angle

			if cur_dir == SYS.DIR.LEFT:
				play_frame_animation(1, 3) # 4
				cur_angle = 180

			elif cur_dir == SYS.DIR.RIGHT:
				play_frame_animation(1, 4) # 3
				cur_angle = 0

			elif cur_dir == SYS.DIR.UP:
				play_frame_animation(1, 5)
				cur_angle = 270

			elif cur_dir == SYS.DIR.DOWN:
				play_frame_animation(1, 6)
				cur_angle = 90

			if mode_stand_attack.shoot_timer.is_finish():
				var proj_speed = 100
				var proj_mul = 20

				var between_shots_range = 6
				
				for i in range(2):
					proj_speed += proj_speed

					for j in range(8):
						var cur_shoot_angle

						cur_shoot_angle = cur_angle + between_shots_range * j

						spawn_projectile(cur_pos, proj_speed, cur_shoot_angle)

				spawn_projectile(cur_pos, proj_speed, 0)
				spawn_projectile(cur_pos, proj_speed, 90)
				spawn_projectile(cur_pos, proj_speed, 180)
				spawn_projectile(cur_pos, proj_speed, 270)

				mode_stand_attack.shoot_timer.reload()

		# UNITS SPAWN MODE
		elif cur_mode == MODES.UNITS_SPAWN:
			set_movement_speed(200)

			init_anim_time = 0.08
			play_frame_animation(3, 7)

			var cur_move_pos = mode_units_spawn.move_points[mode_units_spawn.cur_move_point_index]

			if SYS.get_dist_between_points(cur_pos, cur_move_pos) < 15:
				mode_units_spawn.cur_move_point_index += 1
				if mode_units_spawn.cur_move_point_index > mode_units_spawn.move_points.size() - 1:
					mode_units_spawn.cur_move_point_index = 0
			else:
				if cur_pos.x > cur_move_pos.x - 1:
					dx -= movement_speed * delta
				elif cur_pos.x < cur_move_pos.x + 1:
					dx += movement_speed * delta

				if cur_pos.y > cur_move_pos.y - 1:
					dy -= movement_speed * delta
				elif cur_pos.y < cur_move_pos.y + 1:
					dy += movement_speed * delta

			if mode_units_spawn.spawn_timer.is_finish():
				var spawn_range = Vector2(25, 10)
				for i in range(SYS.get_random_int(3, 6)):
					game.spawn_unit_from_scene(mode_units_spawn.unit_scn, Vector2(
						SYS.get_random_int(cur_pos.x - spawn_range.x, cur_pos.x + spawn_range.x),
						SYS.get_random_int(cur_pos.y - spawn_range.y, cur_pos.y + spawn_range.y)
					))

				mode_units_spawn.spawn_timer.reload()

		if mode_end_timer.is_finish():
			mode_stand_attack.shoot_dir = null
			mode_stand_attack.shoot_timer.reload()
			mode_units_spawn.spawn_timer.reload()

			cur_mode = null

	cur_pos = get_global_pos()
	set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

func destroy():
	if is_already_dead:
		game.spawn_unit_from_scene(game.u_lvl5_BOSS_satan_lvl3, get_global_pos())
	.destroy()