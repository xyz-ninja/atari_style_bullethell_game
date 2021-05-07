extends "res://scripts/units/unit.gd"

var wait_to_dash_timer = TIME.create_new_timer("unit_shieldman_wait_to_dash_timer", 1.0)

var is_need_return_back = false
var start_return_back_timer = TIME.create_new_timer("unit_shieldman_start_return_timer", SYS.get_random_float(0.7, 0.9))
# юнит возвращается назад пока не попадет в границы игрового поля
# это дополнительное время
var return_back_timer = TIME.create_new_timer("unit_shieldman_return_back_timer", SYS.get_random_float(0.6, 1.2))

var is_with_shield = true
var is_support_units_spawned = false

var without_shield_health = 5

func _ready():
	set_health(SYS.get_random_int(9, 11) + without_shield_health)

	guaranteed_exp_bonus_count = 3
	exp_bonus_count = SYS.get_random_int(1,3)

	set_medium_size_enemy(true)
	
	push_back_time = 0.05
	is_can_be_pushed_back = true

	set_process(true)
	
func _process(delta):
	if is_with_shield:
		if health <= without_shield_health:
			is_with_shield = false

	if !is_support_units_spawned:
		# spawn support
		var between_units_margin = SYS.get_random_int(32, 41)
		for i in range(0, 2):
			game.spawn_unit_from_scene(game.u_lvl3_shieldman_support_scn, Vector2(
				get_global_pos().x + between_units_margin * (i - 1), 
				get_global_pos().y - SYS.get_random_int(15, 20)))

		is_support_units_spawned = true

	var cur_pos = get_global_pos()

	var dx = 0
	var dy = 0

	# WITH SHIELD
	if is_with_shield and !is_need_return_back:
		init_anim_time = 0.16
		play_frame_animation(2)

		custom_blink_color = SYS.Colors.yellow

		set_movement_speed(95)

		if !is_pushing_back:
			dy += movement_speed * delta

		# проверяем вышел ли юнит за границы экрана
		if cur_pos.y > game.play_region_y_end_pos + 50:
			if start_return_back_timer.is_finish():
				health = without_shield_health # убираем щит
				if cur_pos.x > 45 and cur_pos.x < game.play_region_x_end_pos - 45:
					cur_pos.x += SYS.get_random_int(-20, 20)

				game.gui.add_track_icon_unit_below_play_screen(self, cur_pos.x)

				return_back_timer.reload()
				is_need_return_back = true
		else:
			start_return_back_timer.reload()
		wait_to_dash_timer.reload()

	# RETURN BACK
	elif is_need_return_back:
		init_anim_time = 0.12
		play_frame_animation(2,2)

		dy -= movement_speed * 1.8 * delta

		if game.is_unit_in_play_zone(self):
			if return_back_timer.is_finish():
				is_need_return_back = false
		else:
			return_back_timer.reload()

	# WITHOUT SHIELD
	else:
		if !wait_to_dash_timer.is_finish() and !is_already_dash or is_need_dash and !is_already_dash:
			init_anim_time = 0.12
			play_frame_animation(2,2)
		elif is_already_dash:
			init_anim_time = 0.08
			play_frame_animation(4,4)
		else:
			play_frame_animation(1,2)

		custom_blink_color = SYS.Colors.red

		set_movement_speed(115)

		# DASH
		if wait_to_dash_timer.is_finish():
			set_dash(-SYS.get_angle_between_positions(cur_pos, game.player.get_global_pos()) + 0, 0.7, 0.7, 225)
			wait_to_dash_timer.reload()

	set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

func deal_damage(_count, _without_blink = false):
	.deal_damage(_count, _without_blink)

	# ОТТАЛКИВАЕТ ЮНИТОВ shieldman_support рядом с собой!
	if is_with_shield:
		for unit in game.cur_enemy_units:
			if unit != null and weakref(unit).get_ref() and unit.is_in_group("shieldman_support"):
				if SYS.get_dist_between_sprites(tex, unit.tex) < 75:
					unit.deal_damage(0, true)
