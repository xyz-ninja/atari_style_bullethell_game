extends Node2D

export(NodePath) var connected_node_path

export var is_sine_enable = false
export var sine_range = Vector2(0, 0)
export var sine_angle_increase_time = 0.12
var loc_sine_timer = sine_angle_increase_time
var sine_angle = 0

var init_pos

var connected_to_node

func _ready():
	print(get_name())
	init_pos = get_global_pos()

	if connected_node_path != null:
		connected_to_node = get_node(connected_node_path)

	set_process(true)

func _process(delta):
	var dx = 0
	var dy = 0

	var cur_pos
	if connected_to_node == null:
		cur_pos = init_pos
	else:
		cur_pos = connected_to_node.get_global_pos()
	
	if is_sine_enable:
		loc_sine_timer -= delta
		if loc_sine_timer < 0:
			if sine_angle > 360:
				sine_angle = 0
			else:
				sine_angle += 1
				
			loc_sine_timer = sine_angle_increase_time
			
		dx = sine_range.x * cos(sine_angle)
		dy = sine_range.y * cos(sine_angle)
		
	set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))
