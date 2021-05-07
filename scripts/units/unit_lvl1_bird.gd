extends "res://scripts/units/unit.gd"

# BIRD ENEMY

var is_need_return_back = false
var loc_start_return_back_time = SYS.get_random_int(1,2)
var loc_start_return_back_timer = loc_start_return_back_time
var loc_return_back_time = SYS.get_random_float(0.9, 1.2)
var loc_return_back_timer = loc_return_back_time

func _ready():
	set_health(SYS.get_random_int(4, 7))

	exp_bonus_count = SYS.get_random_int(2,4)
	
	#init_anim_time = 0.13
	set_movement_speed(120)

	is_can_be_pushed_back = true
	push_back_time = 0.1
	pushing_speed_multiplier = 1.5

	set_process(true)
	
func _process(delta):
	var cur_pos = get_global_pos()
	
	# TEXTURE
	play_frame_animation(4)
	
	if cur_pos.x > 0 and cur_pos.x < game.play_region_x_end_pos / 2:
		flip_texture_right()
	else:
		flip_texture_left()
	
	# POSITION
	var dy = 0
	
	if cur_pos.y > game.play_region_y_end_pos + 30:
		if !is_need_return_back:
			if SYS.get_random_percent_0_to_100() < 65:
				cur_pos.x = SYS.get_random_int(0, game.play_region_x_end_pos)
	
				game.gui.add_track_icon_unit_below_play_screen(self, cur_pos.x)
				is_need_return_back = true
			else:
				destroy()
		else:
			loc_start_return_back_timer -= delta
		
	#else:
	#	loc_start_return_back_timer = loc_start_return_back_time
	
	# если юнит внизу экрана и ему нужно возвращаться обратно
	if is_need_return_back and loc_start_return_back_timer < 0:
		loc_return_back_timer -= delta
		if loc_return_back_timer < 0:
			is_need_return_back = false
		else:
			dy -= movement_speed * 3 * delta
	else:
		if !is_pushing_back:
			dy += movement_speed * delta
			
		loc_return_back_timer = loc_return_back_time
	
	set_global_pos(Vector2(cur_pos.x + 0, cur_pos.y + dy))
	
func deal_damage(_count):
	.deal_damage(_count)
