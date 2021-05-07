extends "res://scripts/units/unit.gd"

var move_points 
var cur_move_point_index = 0

var shoot_timer = TIME.create_new_timer("faith_devil_shoot_timer", 1.25)

func _ready():
	set_health(SYS.get_random_int(40, 50))

	exp_bonus_count = 50
	guaranteed_exp_bonus_count = SYS.get_random_int(150, 200)

	addit_death_timer = TIME.create_new_timer("faith_devil_death_timer", 1.9)

	set_movement_speed(145)

	set_medium_size_enemy(true)

	custom_blink_color = SYS.Colors.yellow

	move_points = [
		Vector2(5, game.play_region_y_start_pos + 15), 
		Vector2(game.play_region_x_end_pos - 30, game.play_region_y_start_pos + 15),
		Vector2(game.play_region_x_end_pos - 30, game.play_region_y_end_pos - 150),
		Vector2(5, game.play_region_y_end_pos - 150)
	]

	set_process(true)

func _process(delta):
	if is_already_dead:
		get_node("death_effects").show()

		if addit_death_timer.check_time() < 0.9:
			set_opacity(addit_death_timer.check_time())
	else:
		get_node("death_effects").hide()
		var dx = 0
		var dy = 0

		var cur_move_pos = move_points[cur_move_point_index]
		var cur_pos = get_global_pos()

		if SYS.get_dist_between_points(cur_pos, cur_move_pos) < 15:
			cur_move_point_index += 1
			if cur_move_point_index > move_points.size() - 1:
				cur_move_point_index = 0

			shoot(true)
		else:
			if cur_pos.x > cur_move_pos.x - 1:
				dx -= movement_speed * delta
			elif cur_pos.x < cur_move_pos.x + 1:
				dx += movement_speed * delta

			if cur_pos.y > cur_move_pos.y - 1:
				dy -= movement_speed * delta
			elif cur_pos.y < cur_move_pos.y + 1:
				dy += movement_speed * delta

			if shoot_timer.is_finish():
				shoot(false)

				shoot_timer.reload()

		set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

func shoot(_is_big_shot):
	var cur_pos = get_global_pos()
	if _is_big_shot:
		set_cur_projectile_type(game.PROJECTILE_TYPE.ENEMY_NORMAL)
		
		for i in range(10):
			spawn_projectile(cur_pos, SYS.get_random_int(275, 300), 36 * i)
		for i in range(10):
			spawn_projectile(cur_pos, SYS.get_random_int(220, 250), 18 * i)
	else:
		for i in range(6):
			spawn_projectile(cur_pos, SYS.get_random_int(300, 310), SYS.get_random_int(46,60) * i)