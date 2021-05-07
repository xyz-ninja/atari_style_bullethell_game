extends "res://scripts/units/unit.gd"

var wait_to_start_dash_timer = TIME.create_new_timer("u_dog_wait_to_dash_timer", SYS.get_random_float(1.1, 2.6))

func _ready():
	set_health(SYS.get_random_int(4, 6))

	guaranteed_exp_bonus_count = 1
	exp_bonus_count = SYS.get_random_int(3,5)

	init_anim_time = 0.07
	set_movement_speed(90 + SYS.get_random_int(-25, 25))
	custom_blink_color = SYS.Colors.white

	push_back_time = 0.1

	is_can_be_pushed_back = true
	is_destroy_after_dash = true

	set_process(true)

func _process(delta):
	var cur_pos = get_global_pos()

	if wait_to_start_dash_timer.is_finish():
		set_dash(-SYS.get_angle_between_positions(cur_pos, game.player.get_global_pos()) + 0, 2, 15, 230)
		if is_already_dash:
			play_frame_animation(8, 2)
		else:
			play_frame_animation(2)
	else:
		play_frame_animation(2)

		if get_global_pos().x > 0 and get_global_pos().x < game.play_region_x_end_pos / 2:
			flip_texture_right()
		else:
			flip_texture_left()

		var dx = 0
		var dy = 0
		
		dy += movement_speed * delta

		set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))