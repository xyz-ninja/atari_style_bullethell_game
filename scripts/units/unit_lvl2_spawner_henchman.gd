extends "res://scripts/units/unit.gd"

var parent_unit
var radius_to_parent

var angle_change_speed = 2
var init_angle
var cur_angle = 0

var wait_timer = TIME.create_new_timer("spawner_henchman_wait_timer", 0.6)
var radius_increase_timer = TIME.create_new_timer("spawner_henchman_r_increase_timer", 0.25)
var radius_increase_speed = 150

var is_ready_to_update = false

func _ready():
	set_health(SYS.get_random_int(1, 3))

	init_anim_time = 0.12
	#set_movement_speed(150 + SYS.get_random_int(-25, 75))
	set_movement_speed(0)
	
	custom_blink_color = SYS.Colors.white

	is_can_be_pushed_back = true

	set_process(true)
	
func _process(delta):
	play_frame_animation(5)

	if is_ready_to_update:
		if parent_unit != null and weakref(parent_unit).get_ref():
			var cur_pos = get_global_pos()
		
			if wait_timer.is_finish():
				if radius_increase_timer.is_finish():
					radius_to_parent += radius_increase_speed * delta
					radius_increase_timer.reload()
			else:
				radius_increase_timer.reload()
	
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

func setup(_parent_unit, _init_angle):
	set_parent_unit(_parent_unit)

	init_angle = _init_angle
	cur_angle = init_angle

	radius_to_parent = parent_unit.gen_units_radius

	is_ready_to_update = true

func set_parent_unit(_u):
	parent_unit = _u

func destroy():
	.destroy()