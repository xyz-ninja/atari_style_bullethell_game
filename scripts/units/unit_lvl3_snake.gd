extends "res://scripts/units/unit.gd"

var going_up_wait_timer = TIME.create_new_timer("unit_snake_going_up_wait_timer", 0.8)

var is_going_up = false

var going_up_cur_disable_count = 0
var going_up_disable_count = 3 # после достижения этой отметки юнит перестанет возвращаться

func _ready():
	set_health(SYS.get_random_int(8, 11))

	guaranteed_exp_bonus_count = 5
	exp_bonus_count = SYS.get_random_int(0,2)

	init_anim_time = 0.07
	set_movement_speed(165 + SYS.get_random_int(-25, 75))
	
	#is_can_be_pushed_back = true

	set_big_size_enemy(true)
	is_anim_loop_backwards = true

	custom_blink_color = SYS.Colors.yellow

	#flip_texture_vertical(true)

	set_process(true)
	
func _process(delta):
	play_frame_animation(5)
	
	var cur_pos = get_global_pos()
	var dx = 0
	var dy = 0
	
	if cur_pos.y > game.play_region_y_end_pos + 50 and !is_going_up:
		if going_up_wait_timer.is_finish():
			if going_up_cur_disable_count < going_up_disable_count:
				if SYS.get_random_percent_0_to_100() < 50:
					cur_pos.x = SYS.get_random_int(20, 80)
				else:
					cur_pos.x = SYS.get_random_int(game.play_region_x_end_pos - 200, game.play_region_x_end_pos - 150)

				game.gui.add_track_icon_unit_below_play_screen(self, cur_pos.x)

				flip_texture_vertical(true)

				is_going_up = true

				going_up_cur_disable_count += 1
			else:
				destroy()

	elif cur_pos.y < game.play_region_y_start_pos - 60 and is_going_up:
		cur_pos.x = SYS.get_random_int(140, game.play_region_x_end_pos - 180)
		flip_texture_vertical(false)
		is_going_up = false
	else:
		going_up_wait_timer.reload()
	
	if is_going_up:
		dy -= movement_speed * 1.25 * delta
	else:
		dy += movement_speed * delta
	
	set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))