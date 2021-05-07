extends "res://scripts/units/unit.gd"

var henchmans_spawn_timer = TIME.create_new_timer("unit_skulls_henchmans_spawn_timer", SYS.get_random_float(1.4,1.8))
var henchmans_shoot_to_player_timer = TIME.create_new_timer("unit_skulls_henchmans_shoot_to_player_timer", 0.9)
var spawn_wait_timer = TIME.create_new_timer("unit_skulls_spawn_wait_timer", SYS.get_random_int(1.2, 3))
var spawn_delay_timer = TIME.create_new_timer("unit_skulls_spawn_delay_timer", 0.2)

var gen_positions = []
var gen_units = []
var gen_units_count = SYS.get_random_int(2, 3)
var gen_units_radius = 40
var t_step_size = 1.1

var cur_move_pos

func _ready():
	set_health(SYS.get_random_int(9, 12))

	guaranteed_exp_bonus_count = 4
	exp_bonus_count = SYS.get_random_int(5,10)

	init_anim_time = 0.11
	set_movement_speed(80 + SYS.get_random_int(-25, 25))
	
	set_medium_size_enemy(true)

	#is_can_be_pushed_back = true

	set_process(true)
	
func _process(delta):
	play_frame_animation(4)

	var cur_pos = get_global_pos()

	if spawn_wait_timer.is_finish():
		#set_movement_speed(100)

		# SPAWN UNITS
		if gen_units.size() == 0 and gen_positions.size() == 0:
			if henchmans_spawn_timer.is_finish():
				
				# генерация позиций юнитов по кругу вокруг спавнера
				var units_count = gen_units_count
				var cur_units_count = 0

				var t = 0
				gen_positions = []
				
				while t < 2 * PI and cur_units_count < units_count:
					gen_positions.append(Vector2(
						gen_units_radius * cos(t) + cur_pos.x, gen_units_radius * sin(t) + cur_pos.y))
					t += t_step_size
					cur_units_count += 1

				henchmans_spawn_timer.change_init_time(3.6)
		else:
			henchmans_spawn_timer.reload()
			
			# СПАУНИМ ЮНИТОВ В СГЕНЕРИРОВАННЫХ ПОЗИЦИЯХ ЕСЛИ ОНИ НЕ ПУСТЫЕ
			if gen_positions.size() > 0:
				if spawn_delay_timer.is_finish():
					var cur_unit_pos = gen_positions.back()

					var gen_unit = game.spawn_unit_from_scene(game.u_lvl4_skulls_henchman_scn, Vector2(-100, -100))

					var unit_init_angle = SYS.get_angle_between_positions(cur_pos, cur_unit_pos)

					gen_unit.setup(self, unit_init_angle)
		
					gen_units.append(gen_unit)
					gen_positions.erase(cur_unit_pos)

					# в следующий раз, если он будет, юнитов будет на 1 больше
					gen_units_count += 1 

					spawn_delay_timer.reload()

				henchmans_shoot_to_player_timer.reload()

			# ЕСЛИ ВСЕ ЮНИТЫ СГЕНЕРИРОВАНЫ
			else:

				# УДАЛЯЕМ УНИЧТОЖЕННЫЕ ИЛИ ЗАПУЩЕННЫЕ В ИГРОКА ЮНИТЫ
				var erased_units = []
				for unit in gen_units:
					if unit == null or weakref(unit).get_ref() == null or unit.move_by_angle != null:
						erased_units.append(unit)

				for er_unit in erased_units:
					gen_units.erase(er_unit)

				# ПО ИСТЕЧЕНИЮ ТАЙМЕРА СТРЕЛЯЕТ СЛУЧАЙНЫМ ПРИСЛУЖНИКОМ В ИГРОКА
				if henchmans_shoot_to_player_timer.is_finish() and gen_units.size() > 0:

					var random_unit = SYS.get_random_arr_item(gen_units)
					random_unit.set_move_by_angle(SYS.get_angle_between_positions(
						random_unit.get_global_pos(), game.player.get_global_pos()) + 175)

					henchmans_shoot_to_player_timer.reload()

	# MOVE
	if cur_move_pos == null:
		cur_move_pos = Vector2(
			SYS.get_random_int(0, game.play_region_x_end_pos),
			SYS.get_random_int(game.play_region_y_start_pos + 25, game.play_region_y_start_pos + 150)
		)

	else:
		var dx = 0
		var dy = 0

		if cur_pos.x < cur_move_pos.x - 1.0:
			dx += movement_speed * delta
		elif cur_pos.x > cur_move_pos.x + 1.0:
			dx -= movement_speed * delta

		if cur_pos.y < cur_move_pos.y - 1.0:
			dy += movement_speed * delta
		elif cur_pos.y > cur_move_pos.y + 1.0:
			dy -= movement_speed * delta

		set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

		if SYS.get_dist_between_points(cur_pos, cur_move_pos) < 15:
			cur_move_pos = null

func destroy():
	for unit in gen_units:
		if unit != null and weakref(unit).get_ref() and unit.get("is_unit"):
			unit.destroy()

	.destroy()
