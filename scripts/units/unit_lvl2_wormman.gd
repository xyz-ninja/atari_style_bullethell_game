extends "res://scripts/units/unit.gd"

var init_pos

func _ready():
	set_health(SYS.get_random_int(2, 4))

	init_anim_time = 0.15

	exp_bonus_count = SYS.get_random_int(0,2)

	#set_movement_speed(150 + SYS.get_random_int(-25, 75))
	set_movement_speed(SYS.get_random_int(110, 150))
	
	is_can_be_pushed_back = true

	custom_blink_color = SYS.Colors.white

	set_process(true)
	
func _process(delta):
	play_frame_animation(4)

	var cur_pos = get_global_pos()

	if init_pos == null:
		init_pos = cur_pos

	if cur_pos.y > game.play_region_y_end_pos + 30:
		destroy()

	var dx = 0
	var dy = 0

	if init_pos.x < game.play_region_x_end_pos / 2:
		dx += movement_speed / 4 * delta
	else:
		dx -= movement_speed / 4 * delta

	dy += movement_speed * delta

	set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))