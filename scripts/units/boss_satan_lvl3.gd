extends "res://scripts/units/unit.gd"

enum MODES {SHOOT, SHOOT_TRIANGLE}

var mode_set_timer = TIME.create_new_timer("boss_satan_lvl3_mode_set_timer", 2.7)
var mode_end_timer = TIME.create_new_timer("boss_satan_lvl3_mode_end_timer", 4.0)

var mode_null_shoot_timer = TIME.create_new_timer("boss_satan_lvl3_null_mode_shoot_timer", 0.35)

var mode_shoot = {
	shoot_timer = TIME.create_new_timer("boss_satan_lvl3_shoot_mode_shoot_timer", 0.41)
}

var mode_shoot_triangle = {
	shoot_timer = TIME.create_new_timer("boss_satan_lvl3_shoot_triangle_mode_shoot_timer", 0.6)
}

var cur_mode

var cur_move_pos

func _ready():
	set_health(130)

	exp_bonus_count = 0
	guaranteed_exp_bonus_count = 0

	addit_death_timer = TIME.create_new_timer("boss_death_timer", 3.0)

	set_big_size_enemy(true)

	custom_blink_color = SYS.Colors.red

	is_boss = true

	is_anim_loop_backwards = true

	set_process(true)
	
func _process(delta):
	if is_already_dead:
		return

	var dx = 0
	var dy = 0
	
	var cur_pos = get_global_pos()
	cur_pos.x += 20
	cur_pos.y += 20

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

	if cur_mode == null:
		set_movement_speed(110)

		init_anim_time = 0.04
		play_frame_animation(3)

		mode_end_timer.reload()

		# SHOOT
		if mode_null_shoot_timer.is_finish():
			if SYS.get_dist_between_points_in_detail(cur_pos, game.player.get_global_pos()).common < 350:
				cur_pos.x += 8
				cur_pos.y += 10

				for i in range(SYS.get_random_int(3,6)):
					var cur_angle = SYS.get_angle_between_positions(cur_pos, game.player.get_global_pos()) + 180 + \
						SYS.get_random_int(-12, 12)
					set_cur_projectile_type(game.PROJECTILE_TYPE.ENEMY_VOMIT)	
					spawn_projectile(cur_pos, SYS.get_random_int(140, 180), cur_angle, SYS.get_random_float(1.1, 1.5))
				
				mode_null_shoot_timer.reload()

		if mode_set_timer.is_finish():
			mode_shoot.shoot_timer.reload()
			mode_shoot_triangle.shoot_timer.reload()

			cur_mode = SYS.get_random_arr_item([MODES.SHOOT, MODES.SHOOT_TRIANGLE])
	else:
		mode_set_timer.reload()

		if cur_mode == MODES.SHOOT:
			set_movement_speed(30)

			init_anim_time = 0.135
			play_frame_animation(4,3)

			if mode_shoot.shoot_timer.is_finish():
				set_cur_projectile_type(game.PROJECTILE_TYPE.ENEMY_NORMAL)

				var angle_step = 45

				for ang in range(0, 360, angle_step):
					var proj_speed = 180

					spawn_projectile(cur_pos, proj_speed, ang)
					spawn_projectile(cur_pos, proj_speed - 50, ang - 15)

				mode_shoot.shoot_timer.reload()

		elif cur_mode == MODES.SHOOT_TRIANGLE:
			set_movement_speed(40)

			init_anim_time = 0.08
			play_frame_animation(4,3)

			if mode_shoot_triangle.shoot_timer.is_finish():
				set_cur_projectile_type(game.PROJECTILE_TYPE.ENEMY_NORMAL)

				var angle_step = 45

				for ang in range(0, 360, angle_step):
					var proj_speed = 120

					spawn_projectile(cur_pos, proj_speed, ang)

				var shoot_angle = SYS.get_angle_between_positions(cur_pos, game.player.get_global_pos()) + 175

				var proj_speed = 195

				var between_shots_range = 15

				spawn_projectile(cur_pos, proj_speed - 15, shoot_angle - between_shots_range - 5)
				spawn_projectile(cur_pos, proj_speed - 5, shoot_angle - between_shots_range)
				spawn_projectile(cur_pos, proj_speed, shoot_angle)
				spawn_projectile(cur_pos, proj_speed - 5, shoot_angle + between_shots_range)
				spawn_projectile(cur_pos, proj_speed - 15, shoot_angle - between_shots_range + 5)

				mode_shoot_triangle.shoot_timer.reload()

		if mode_end_timer.is_finish():
			cur_mode = null

	cur_pos = get_global_pos()
	set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

func destroy():
	.destroy()

	get_tree().change_scene("res://scenes/final.tscn")
	#game.complete_event(game.EVENTS.BOSS_SATAN)