extends "res://scripts/units/unit.gd"

var shoot_timer = TIME.create_new_timer("necromancer_henchman_shoot_timer", SYS.get_random_float(0.8, 1.6))

func _ready():
	health = SYS.get_random_int(2, 4)
	init_anim_time = 0.12
	set_movement_speed(0)
	
	#guaranteed_exp_bonus_count = 1
	exp_bonus_count = 1

	custom_blink_color = SYS.Colors.yellow

	set_medium_size_enemy(true)

	set_process(true)
	
func _process(delta):
	play_frame_animation(5, init_anim_time)

	if shoot_timer.is_finish():
		shoot()
		shoot_timer.reload()

func shoot():
	set_cur_projectile_type(game.PROJECTILE_TYPE.ENEMY_NORMAL)

	var cur_pos = get_global_pos()

	if cur_pos.x < game.play_region_x_end_pos / 2:
		spawn_projectile(cur_pos, 250, 25)
		spawn_projectile(cur_pos, 250, 50)
	else:
		spawn_projectile(cur_pos, 250, 125)
		spawn_projectile(cur_pos, 250, 150)
	
	# PLAYER ANGLE SHOOT
	#spawn_projectile(cur_pos, 250, 65)
	#spawn_projectile(cur_pos, 250, 105)
