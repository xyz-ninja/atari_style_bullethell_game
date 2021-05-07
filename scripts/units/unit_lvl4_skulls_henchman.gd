extends "res://scripts/units/unit.gd"

var parent_unit
var radius_to_parent

var angle_change_speed = 1
var init_angle
var cur_angle = 0

var is_ready_to_update = false
var move_by_angle
var move_by_angle_speed = 190

func _ready():
	set_health(SYS.get_random_int(4, 5))

	init_anim_time = 0.1
	#set_movement_speed(150 + SYS.get_random_int(-25, 75))
	set_movement_speed(0)
	
	custom_blink_color = SYS.Colors.white	

	set_process(true)
	
func _process(delta):
	play_frame_animation(4)

	var cur_pos = get_global_pos()

	if is_ready_to_update:
		if move_by_angle == null:
			is_can_be_pushed_back = false
			if parent_unit != null and weakref(parent_unit).get_ref():
		
				cur_angle += angle_change_speed * delta
				
				if cur_angle > 360:
					cur_angle = 0
			
				# ЛЕТАЕТ ПО КРУГУ ВОКРУГ parent_unit
			
				# x1 = x0 + r * cos a
				# y1 = y0 + r * sin a
				# a - угол
			
				var parent_pos = parent_unit.get_global_pos()
			
				var new_x = parent_pos.x + radius_to_parent * cos(cur_angle)
				var new_y = parent_pos.y + radius_to_parent * sin(cur_angle)
			
				set_global_pos(Vector2(new_x, new_y))
			else:
				destroy()
		else:
			is_can_be_pushed_back = true

			var dx = 1.0
			var dy = 1.0

			dx *= cos(deg2rad(move_by_angle)) * move_by_angle_speed * delta
			dy *= sin(deg2rad(move_by_angle)) * move_by_angle_speed * delta

			set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

func setup(_parent_unit, _init_angle):
	set_parent_unit(_parent_unit)

	init_angle = _init_angle
	cur_angle = init_angle

	radius_to_parent = parent_unit.gen_units_radius

	is_ready_to_update = true

func set_parent_unit(_u):
	parent_unit = _u

func set_move_by_angle(_move_angle):
	move_by_angle = _move_angle
	init_tex_modulate = SYS.Colors.plum

func destroy():
	.destroy()