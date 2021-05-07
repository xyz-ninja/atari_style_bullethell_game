extends "res://scripts/units/unit.gd"

var shoot_exemplary_time = 0.55
var shoot_timer = TIME.create_new_timer("unit_shieldman_support_shoot_timer", SYS.get_random_float(1.4, 1.8))

func _ready():
	set_health(SYS.get_random_int(1, 3))

	exp_bonus_count = SYS.get_random_int(0,2)

	init_anim_time = 0.11
	set_movement_speed(90 + SYS.get_random_int(-5, 5))
	
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

	if shoot_timer.is_finish():
		# проверяем расстояние между ними по оси абсцисс
		if SYS.get_dist_between_points_in_detail(cur_pos, game.player.get_global_pos()).horizontal < 25:
			var proj_pos = cur_pos
			proj_pos.x += 8
			proj_pos.y += 15

			spawn_projectile(proj_pos, SYS.get_random_int(160, 180), null)
			shoot_timer.change_init_time(SYS.get_random_float(shoot_exemplary_time - 0.1, shoot_exemplary_time + 0.3))
			#shoot_timer.reload()
