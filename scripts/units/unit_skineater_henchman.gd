extends "res://scripts/units/unit.gd"

var wait_timer = TIME.create_new_timer("unit_skineater_henchman_wait_timer", 1.0)

var is_wait = true
var is_need_move_up = false
var is_need_move_down = false

func _ready():
	set_health(SYS.get_random_int(2, 4))

	exp_bonus_count = 0
	guaranteed_exp_bonus_count = 0

	init_anim_time = 0.1
	set_movement_speed(140 + SYS.get_random_int(-4, 4))
	
	#is_can_be_pushed_back = true

	custom_blink_color = SYS.Colors.white

	is_need_move_down = true

	set_process(true)
	
func _process(delta):
	var cur_pos = get_global_pos()
	var dx = 0
	var dy = 0

	if is_wait:
		play_frame_animation(1)
		if wait_timer.is_finish():
			is_wait = false
	else:
		play_frame_animation(4)
		if is_need_move_down:
			if cur_pos.y > game.play_region_y_end_pos - 20:
				# меняем направление движения
				is_need_move_down = false
				is_need_move_up = true
				is_wait = true

				wait_timer.reload()
			else:
				dy += movement_speed * delta

		elif is_need_move_up:
			if cur_pos.y < game.play_region_y_start_pos + 40:
				# меняем направление движения
				is_need_move_up = false
				is_need_move_down = true
				is_wait = true

				wait_timer.reload()
			else:
				dy -= movement_speed * delta

	set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))