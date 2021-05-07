extends "res://scripts/units/unit.gd"

var no_dir_move_points
# босс спаунит пачки врагов слева и права
# если он заспаунил врагов слева то он начинает двигаться в правой части игрового пространства
var left_move_points
var right_move_points

var phase_timer = TIME.create_new_timer("boss_skineater_phase_timer", 6)

var phase1_timers = {
	wait_for_units_spawn_timer = TIME.create_new_timer("boss_skineater_wait_to_units_timer", 2),
	drop_spawn_markers_t = TIME.create_new_timer("boss_skineater_drop_sp_mark_timer", 7),
	player_shoot_t = TIME.create_new_timer("boss_skineater_player_shoot_timer", 0.9)
}

var cur_phase = 1
var cur_move_point_index = 0

var move_points

func _ready():
	set_health(105)

	exp_bonus_count = 32
	guaranteed_exp_bonus_count = SYS.get_random_int(100, 140)

	addit_death_timer = TIME.create_new_timer("boss_death_timer", 3.1)

	set_movement_speed(115)

	set_medium_size_enemy(true)

	custom_blink_color = SYS.Colors.yellow

	is_boss = true

	no_dir_move_points = [
		Vector2(5, game.play_region_y_start_pos + 55), 
		Vector2(50, game.play_region_y_start_pos + 45),
		Vector2(game.play_region_x_end_pos - 50, game.play_region_y_start_pos + 255),
	]

	left_move_points = [
		Vector2(35, game.play_region_y_start_pos + 55),
		Vector2(game.play_region_x_end_pos / 2 - 55, game.play_region_y_start_pos + 58),
		Vector2(game.play_region_x_end_pos / 2 - 55, game.play_region_y_end_pos / 2 + 65),
		Vector2(38, game.play_region_y_end_pos / 2 + 65)
	]

	right_move_points = [
		Vector2(game.play_region_x_end_pos / 2 + 55, game.play_region_y_start_pos + 25),
		Vector2(game.play_region_x_end_pos - 55, game.play_region_y_start_pos + 28),
		Vector2(game.play_region_x_end_pos / 2 + 65, game.play_region_y_end_pos / 2 + 65),
		Vector2(game.play_region_x_end_pos - 55, game.play_region_y_end_pos / 2 + 65)
	]

	is_anim_loop_backwards = true

	set_process(true)
	
func _process(delta):
	if is_already_dead:
		pass
	else:
		init_anim_time = 0.07
		play_frame_animation(4)

		if health < init_health / 3:
			set_movement_speed(140)

		var cur_pos = get_global_pos()

		var dx = 0
		var dy = 0
		
		# CHECK PHASES
		if cur_phase == 1:
			
			if move_points == null or \
				game.cur_enemy_units.size() <= 1 and phase1_timers.wait_for_units_spawn_timer.is_finish():
				
				move_points = no_dir_move_points
			else:
				phase1_timers.wait_for_units_spawn_timer.reload()

			# DROP SPAWN MARKERS
			if phase1_timers.drop_spawn_markers_t.is_finish():
				var spawn_markers_positions = []

				if move_points == no_dir_move_points:
					if SYS.get_random_percent_0_to_100() < 50:
						move_points = left_move_points
					else:
						move_points = right_move_points
				elif move_points == left_move_points:
					move_points = right_move_points
				elif move_points == right_move_points:
					move_points = left_move_points

				var spawn_start_x = 0
				var markers_offset = 35

				# if current move at left side of area
				if move_points == left_move_points:
					spawn_start_x = game.play_region_x_end_pos / 2 - 25
				# if current move at right side of area
				elif move_points == right_move_points:
					spawn_start_x = 25

				cur_move_point_index = 0

				for i in range(SYS.get_random_int(6, 7)):
					spawn_markers_positions.append(Vector2(
						spawn_start_x + markers_offset * i,
						game.play_region_y_start_pos + SYS.get_random_int(59,60))
					)

				for s_pos in spawn_markers_positions:
					var spawn_marker = game.spawn_object_from_scene(game.spawn_marker_scn, s_pos)
					spawn_marker.setup_marker(game.u_skineater_henchman_scn, 1.0, 7)

				phase1_timers.drop_spawn_markers_t.reload()

			# БЛЮЕТ В ИГРОКА
			if phase1_timers.player_shoot_t.is_finish():
				if SYS.get_dist_between_points_in_detail(cur_pos, game.player.get_global_pos()).common < 250:
					cur_pos.x += 8
					cur_pos.y += 10

					for i in range(SYS.get_random_int(6,12)):
						var cur_angle = SYS.get_angle_between_positions(cur_pos, game.player.get_global_pos()) + 180 + \
							SYS.get_random_int(-12, 12)
						set_cur_projectile_type(game.PROJECTILE_TYPE.ENEMY_VOMIT)	
						spawn_projectile(cur_pos, SYS.get_random_int(140, 180), cur_angle, SYS.get_random_float(1.1, 1.5))
					
					phase1_timers.player_shoot_t.reload()

		# MOVE BETWEEN POINTS
		var cur_move_pos = move_points[cur_move_point_index]
		var cur_pos = get_global_pos()

		if SYS.get_dist_between_points(cur_pos, cur_move_pos) < 15:
			cur_move_point_index += 1
			if cur_move_point_index > move_points.size() - 1:
				cur_move_point_index = 0
		else:
			if cur_pos.x > cur_move_pos.x - 1:
				dx -= movement_speed * delta
			elif cur_pos.x < cur_move_pos.x + 1:
				dx += movement_speed * delta

			if cur_pos.y > cur_move_pos.y - 1:
				dy -= movement_speed * delta
			elif cur_pos.y < cur_move_pos.y + 1:
				dy += movement_speed * delta

		set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

func destroy():
	.destroy()

	for unit in game.cur_enemy_units:
		unit.destroy()

	game.complete_event(game.EVENTS.BOSS_SKINEATER)