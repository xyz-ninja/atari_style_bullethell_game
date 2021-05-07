extends "res://scripts/units/unit.gd"

func _ready():
	set_health(SYS.get_random_int(1, 3))

	init_anim_time = 0.11
	set_movement_speed(150 + SYS.get_random_int(-25, 75))
	
	is_can_be_pushed_back = true

	set_process(true)
	
func _process(delta):
	play_frame_animation(4)
	
	var cur_pos = get_global_pos()
	var dy = 0
	
	if cur_pos.y > game.play_region_y_end_pos + 30:
		destroy()
	
	if !is_pushing_back:
		dy += movement_speed * delta
	
	set_global_pos(Vector2(cur_pos.x + 0, cur_pos.y + dy))