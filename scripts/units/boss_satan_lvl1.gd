extends "res://scripts/units/unit.gd"

enum MODES {STAND_ATTACK, MOVE_ATTACK}

var mode_set_timer = TIME.create_new_timer("boss_satan_mode_set_timer", 2.5)
var mode_end_timer = TIME.create_new_timer("boss_satan_mode_end_timer", 4.1)

var mode_null_shoot_timer = TIME.create_new_timer("boss_satan_null_mode_shoot_timer", 1.0)

var mode_stand_attack = {
	shoot_timer = TIME.create_new_timer("boss_satan_stand_attack_shoot_timer", 0.8)
}

var mode_move_attack = {
	shoot_timer = TIME.create_new_timer("boss_satan_move_attack_shoot_timer", 0.6)
}

var cur_mode

var cur_move_pos

func _ready():
	set_health(120)

	exp_bonus_count = 30
	guaranteed_exp_bonus_count = 130

	addit_death_timer = TIME.create_new_timer("boss_death_timer", 1.9)

	set_medium_size_enemy(true)

	custom_blink_color = SYS.Colors.red

	is_boss = true

	is_anim_loop_backwards = true

	set_process(true)
	
func _process(delta):
	var cur_pos = get_global_pos()
	cur_pos.x += 20
	cur_pos.y += 20

	var dx = 0
	var dy = 0

	if is_already_dead:
		return

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

		mode_end_timer.reload()

		init_anim_time = 0.08
		play_frame_animation(4)

		if mode_null_shoot_timer.is_finish():

			var angle_step = 45

			for ang in range(0, 360, angle_step):
				var proj_speed = 180

				spawn_projectile(cur_pos, proj_speed, ang)

			mode_null_shoot_timer.reload()

		if mode_set_timer.is_finish():
			cur_mode = SYS.get_random_arr_item([MODES.STAND_ATTACK, MOVE_ATTACK])

			for t in mode_stand_attack.values():
				t.reload()

	else:
		mode_set_timer.reload()

		if cur_mode == MODES.STAND_ATTACK:
			set_movement_speed(0)

			init_anim_time = 0.08
			play_frame_animation(3, 4)

			if mode_stand_attack.shoot_timer.is_finish():
				var shoot_angle = SYS.get_angle_between_positions(cur_pos, game.player.get_global_pos()) + 175

				var proj_speed = 210
				var between_shots_range = 3
				
				for i in range(10):
					var cur_shoot_angle

					cur_shoot_angle = shoot_angle + between_shots_range * i	

					spawn_projectile(cur_pos, proj_speed, cur_shoot_angle)

				mode_stand_attack.shoot_timer.reload()

		elif cur_mode == MODES.MOVE_ATTACK:
			set_movement_speed(80)

			init_anim_time = 0.08
			play_frame_animation(3,7)
			
			if mode_move_attack.shoot_timer.is_finish():
				var shoot_angle = SYS.get_angle_between_positions(cur_pos, game.player.get_global_pos()) + 180

				var proj_speed = 210

				var between_shots_range = 4

				for i in range(15):
					var cur_shoot_angle

					cur_shoot_angle = shoot_angle + between_shots_range * i	

					spawn_projectile(cur_pos, proj_speed, cur_shoot_angle - 180)

				spawn_projectile(cur_pos, proj_speed + 105, shoot_angle)

				mode_move_attack.shoot_timer.reload()

		if mode_end_timer.is_finish():
			cur_mode = null

	cur_pos = get_global_pos()
	set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

func destroy():
	if is_already_dead:
		game.spawn_unit_from_scene(game.u_lvl5_BOSS_satan_lvl2, get_global_pos())
	.destroy()