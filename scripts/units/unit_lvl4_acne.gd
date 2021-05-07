extends "res://scripts/units/unit.gd"

func _ready():
	set_health(SYS.get_random_int(3, 5))

	init_anim_time = 0.13
	set_movement_speed(125 + SYS.get_random_int(-25, 25))
	
	is_can_be_pushed_back = true

	push_back_time = 0.1

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

func destroy():
	.destroy()

	shoot()

func shoot():
	var cur_pos = get_global_pos()
	cur_pos.x += 20
	cur_pos.y += 20
	
	var proj_speed = 170

	spawn_projectile(cur_pos, proj_speed, 45)
	spawn_projectile(cur_pos, proj_speed, 135)
	spawn_projectile(cur_pos, proj_speed, 225)
	spawn_projectile(cur_pos, proj_speed, 315)