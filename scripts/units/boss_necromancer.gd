extends "res://scripts/units/unit.gd"

var phase1_move_points
var phase2_move_points

var phase_timer = TIME.create_new_timer("boss_necromancer_phase_timer", 6)

var phase1_timers = {
	drop_spawn_markers_t = TIME.create_new_timer("boss_necromancer_drop_sp_mark_timer", 5),
	player_shoot_t = TIME.create_new_timer("boss_necromancer_player_shoot_timer", 1.3)
}
var phase2_timers = {
	shoot_t = TIME.create_new_timer("boss_necromancer_shoot_timer", 1.8)
}

var cur_phase = 1
var cur_move_point_index = 0

func _ready():
	set_health(75)

	exp_bonus_count = 32
	guaranteed_exp_bonus_count = SYS.get_random_int(80, 120)

	addit_death_timer = TIME.create_new_timer("boss_death_timer", 3.1)

	set_movement_speed(115)

	set_medium_size_enemy(true)

	custom_blink_color = SYS.Colors.yellow

	is_boss = true

	phase1_move_points = [
		Vector2(5, game.play_region_y_start_pos + 15), 
		Vector2(game.play_region_x_end_pos - 30, game.play_region_y_start_pos + 15),
		Vector2(game.play_region_x_end_pos / 2, game.play_region_y_start_pos + 50),
	]

	phase2_move_points = [
		Vector2(5, game.play_region_y_start_pos + 15), 
		Vector2(game.play_region_x_end_pos - 30, game.play_region_y_end_pos - 300),
		Vector2(game.play_region_x_end_pos - 30, game.play_region_y_start_pos + 15),
		Vector2(5, game.play_region_y_end_pos - 300)
	]

	set_process(true)
	
func _process(delta):
	if is_already_dead:
		pass
	else:
		if health < init_health / 3:
			set_movement_speed(140)

		var cur_pos = get_global_pos()

		var dx = 0
		var dy = 0

		var move_points

		if phase_timer.is_finish():
			cur_phase += 1
			if cur_phase > 2:
				cur_phase = 1

			phase_timer.reload()
			
			cur_move_point_index = SYS.get_random_int(0, 1)

		# CHECK PHASES
		if cur_phase == 1:
			move_points = phase1_move_points

			# DROP SPAWN MARKERS
			if phase1_timers.drop_spawn_markers_t.is_finish():
				var spawn_markers_positions = []
				for i in range(SYS.get_random_int(3, 8)):
					spawn_markers_positions.append(Vector2(
						SYS.get_random_int(30, game.play_region_x_end_pos - 30),
						SYS.get_random_int(game.play_region_y_start_pos + 70, game.play_region_y_start_pos + 160))
					)

				for s_pos in spawn_markers_positions:
					var spawn_marker = game.spawn_object_from_scene(game.spawn_marker_scn, s_pos)
					spawn_marker.setup_marker(game.u_necromancer_henchman_scn, SYS.get_random_float(1.0, 2.0))

				phase1_timers.drop_spawn_markers_t.reload()

			# СТРЕЛЯЕТ В ИГРОКА ЕСЛИ ТОТ НАХОДИТСЯ ПРИМЕРНО ПОД НИМ
			if phase1_timers.player_shoot_t.is_finish():
				# проверяем расстояние между ними по оси абсцисс
				if SYS.get_dist_between_points_in_detail(cur_pos, game.player.get_global_pos()).horizontal < 15:
					cur_pos.x += 8
					cur_pos.y += 10

					spawn_projectile(cur_pos, 170, null)
					spawn_projectile(cur_pos, 220, null)
					spawn_projectile(cur_pos, 270, null)
					
					phase1_timers.player_shoot_t.reload()

			for timer in phase2_timers.values():
				timer.reload()

		elif cur_phase == 2:
			move_points = phase2_move_points

			if phase2_timers.shoot_t.is_finish():
				spawn_projectile(cur_pos, 150, 65)
				spawn_projectile(cur_pos, 150, 105)
				spawn_projectile(cur_pos, 250, 65)
				spawn_projectile(cur_pos, 250, 105)

				phase2_timers.shoot_t.reload()

			for timer in phase1_timers.values():
				timer.reload()
		else:
			print("WTF")

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

	game.complete_event(game.EVENTS.BOSS_NECROMANCER)