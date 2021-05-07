extends Node2D

var game

var move_timer = TIME.create_new_timer("blood_move_timer", SYS.get_random_float(0.25, 0.4))
var scale_decrease_timer = TIME.create_new_timer("blood_scale_decrease_timer", 0.06)
var autodestroy_timer = TIME.create_new_timer("blood_autodestroy_timer", SYS.get_random_float(4.0, 7.0))

var tex

var init_tex_rect
var init_tex_scale

var is_immovable = true
var is_splatted = false

var move_speed = SYS.get_random_int(125, 170)
var move_angle

var tex_offset = Vector2(0, 0)

func _ready():
	tex = get_node("tex")

	init_tex_scale = tex.get_scale()
	init_tex_rect = tex.get_region_rect()

	move_angle = SYS.get_random_int(0, 360)
	tex_offset = Vector2(SYS.get_random_int(0, 3), 0)

	game = get_tree().get_nodes_in_group("game")[0]

	set_process(true)

func _process(delta):
	# setup tex rect2
	tex.set_region_rect(Rect2(Vector2(
		init_tex_rect.size.x * tex_offset.x, init_tex_rect.size.y * tex_offset.y),
		init_tex_rect.size
	))

	var cur_tex_scale = tex.get_scale()

	if is_splatted:
		is_immovable = false

		if autodestroy_timer.is_finish():
			set_process(false)
			queue_free()
		else:
			var decrease_mul = 2
			if autodestroy_timer.check_time() * decrease_mul < cur_tex_scale.x:
				tex.set_scale(Vector2(
					autodestroy_timer.check_time() * decrease_mul, 
					autodestroy_timer.check_time() * decrease_mul)
				)
	else:
		if !is_immovable:
			is_immovable = true

		if move_angle != null:
			if move_timer.is_finish():
				var rand_scale_val = SYS.get_random_float(0.6, 0.9)
				tex.set_scale(Vector2(init_tex_scale.x + rand_scale_val, init_tex_scale.y + rand_scale_val))
				tex_offset = Vector2(SYS.get_random_int(0, 4), 1)
				is_splatted = true
			else:
				if scale_decrease_timer.is_finish():
					
					cur_tex_scale.x -= 0.1
					cur_tex_scale.y -= 0.1
					tex.set_scale(cur_tex_scale)

					scale_decrease_timer.reload()

				var cur_pos = get_global_pos()

				var dx = 1.0
				var dy = 1.0

				dx *= cos(deg2rad(move_angle)) * move_speed * delta
				dy *= sin(deg2rad(move_angle)) * move_speed * delta

				set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))