extends "res://scripts/units/unit.gd"

var shoot_timer = TIME.create_new_timer("mushroom_phantom_shoot_timer", SYS.get_random_float(0.8, 1.6))

var parent_unit
var type

func _ready():
	health = SYS.get_random_int(12, 16)
	init_anim_time = 0.14
	set_movement_speed(0)

	exp_bonus_count = 0
	guaranteed_exp_bonus_count = 0

	custom_blink_color = SYS.Colors.yellow

	set_medium_size_enemy(true)

	is_without_blood = true

	set_process(true)
	
func _process(delta):
	play_frame_animation(4)

	if parent_unit != null and weakref(parent_unit).get_ref() and type != null:
		if parent_unit.phantoms_afterspawn_wait_timer.is_finish():
			var cur_pos = get_global_pos()

			set_movement_speed(parent_unit.movement_speed)

			var vec2_dx_dy = parent_unit.get_dx_dy_by_phantom_type(delta, type, self)

			var dx = vec2_dx_dy.x
			var dy = vec2_dx_dy.y

			set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

func setup(_parent_unit, _type):
	parent_unit = _parent_unit
	type = _type
