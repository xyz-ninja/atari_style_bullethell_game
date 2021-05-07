extends "res://scripts/units/unit.gd"

var wait_to_attract_timer = TIME.create_new_timer("unit_attractor_wait_to_attract_timer", 2.1)
var attract_timer = TIME.create_new_timer("unit_attractor_attract_timer", 3.0)
var shoot_timer = TIME.create_new_timer("unit_attractor_shoot_timer", 0.8)

var cur_move_pos

var is_attract_player = false
var attract_str = 110

func _ready():
	set_health(SYS.get_random_int(7, 10))

	exp_bonus_count = SYS.get_random_int(2,4)

	init_anim_time = 0.11
	set_movement_speed(100 + SYS.get_random_int(-25, 25))
	
	set_medium_size_enemy(true)

	#is_can_be_pushed_back = true

	set_process(true)
	
func _process(delta):
	var cur_pos = get_global_pos()

	var pl = game.player

	# ATTRACT PLAYER
	if is_attract_player:
		play_frame_animation(1, 2)

		wait_to_attract_timer.reload()

		if attract_timer.is_finish():
			is_attract_player = false

			if pl.attract_by_unit == self:
				pl.addit_dx = 0
				pl.addit_dy = 0
				pl.attract_by_unit = null
		else:
			var pl_pos = pl.get_global_pos()
			if SYS.get_dist_between_points(cur_pos, pl_pos) < 220:
				if pl.attract_by_unit == self or pl.attract_by_unit == null:
					if pl_pos.x < cur_pos.x:
						pl.addit_dx = attract_str
					elif pl_pos.x > cur_pos.x:
						pl.addit_dx = -attract_str

					if pl_pos.y < cur_pos.y:
						pl.addit_dy = attract_str
					elif pl_pos.y > cur_pos.y:
						pl.addit_dy = -attract_str
					
					pl.attract_by_unit = self

		if shoot_timer.is_finish():
			var proj_speed = 160

			cur_pos.x += 15
			cur_pos.y += 15

			spawn_projectile(cur_pos, proj_speed, 0)
			spawn_projectile(cur_pos, proj_speed, 90)
			spawn_projectile(cur_pos, proj_speed, 180)
			spawn_projectile(cur_pos, proj_speed, 270)

			shoot_timer.reload()
	# MOVE
	else:
		play_frame_animation(1)

		attract_timer.reload()

		if cur_move_pos == null:
			cur_move_pos = Vector2(
				SYS.get_random_int(0, game.play_region_x_end_pos),
				SYS.get_random_int(game.play_region_y_start_pos + 60, game.play_region_y_start_pos + 180)
			)

		else:
			var dx = 0
			var dy = 0

			if cur_pos.x < cur_move_pos.x - 1.0:
				dx += movement_speed * delta
			elif cur_pos.x > cur_move_pos.x + 1.0:
				dx -= movement_speed * delta

			if cur_pos.y < cur_move_pos.y - 1.0:
				dy += movement_speed * delta
			elif cur_pos.y > cur_move_pos.y + 1.0:
				dy -= movement_speed * delta

			set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

			if SYS.get_dist_between_points(cur_pos, cur_move_pos) < 15:
				cur_move_pos = null

				if wait_to_attract_timer.is_finish():
					is_attract_player = true

func destroy():
	var pl = game.player
	if pl.attract_by_unit == self:
		pl.addit_dx = 0
		pl.addit_dy = 0
		pl.attract_by_unit = null
	
	.destroy()
