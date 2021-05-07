extends Camera2D

var init_pos
var init_zoom

var change_speed = 1
var change_zoom = null
onready var d = get_parent()

var shake_timer = TIME.create_new_timer("cam_shake_timer", 1)
var autodisable_shaking_timer = TIME.create_new_timer("autodisable_shaking_timer", 2.5)
var shake_power = 1
var shake_range = 1
var is_need_shake_camera = false

func _ready():
	init_pos = get_global_pos()
	init_zoom = Vector2(1,1)

	set_process(true)

var zoom_buffer = 0.01

var anim_t = 0
func _process(delta):
	anim_t += delta

	# CHANGE ZOOM
	if change_zoom != null:
		var cx = 0 # change x
		var cy = 0

		if get_zoom().x < change_zoom.x:
			cx += change_speed * delta
			if get_zoom().x + cx >= change_zoom.x:
				cx = 0
		elif get_zoom().x > change_zoom.x:
			cx -= change_speed * delta
			if get_zoom().x - cx <= change_zoom.x:
				cx = 0

		if get_zoom().y < change_zoom.y:
			cy += change_speed * delta
			if get_zoom().y + cy >= change_zoom.y:
				cy = 0
		elif get_zoom().y > change_zoom.y:
			cy -= change_speed * delta
			if get_zoom().y - cy <= change_zoom.y:
				cy = 0

		var new_zoom = Vector2(0,0)
		if cx == 0:
			new_zoom.x = change_zoom.x
		else:
			new_zoom.x = get_zoom().x + cx

		if cy == 0:
			new_zoom.y = change_zoom.y
		else:
			new_zoom.y = get_zoom().y + cy

		set_zoom(new_zoom)

	# SHAKE EFFECT
	if is_need_shake_camera:
		if shake_timer.is_finish() or autodisable_shaking_timer.is_finish():
			#TIME.destroy_timer(shake_timer)
			#shake_timer = null
			is_need_shake_camera = false
			reset()
		else:
			var n_pos = get_global_pos()

			n_pos.x = n_pos.x + shake_range * cos(anim_t * shake_power)
			#n_pos.y = n_pos.y + shake_range * cos(anim_t * shake_power)

			set_global_pos(n_pos)
	else:
		autodisable_shaking_timer.reload()

var zoom_margin = Vector2(-100,-150)
func zoom_to_node(_node, _addit_margin = null):
	var node_pos = _node.get_global_pos()
	var add_margin = _addit_margin

	var z_margin = zoom_margin

	if add_margin != null:
		z_margin = add_margin

	set_global_pos(Vector2(node_pos.x + z_margin.x, node_pos.y + z_margin.y))
	smooth_change_zoom(Vector2(0.7,0.7))

func shake(_range, _power, _time):
	if !is_need_shake_camera:
		shake_range = _range
		shake_power = _power
		shake_timer.change_init_time(_time)
		is_need_shake_camera = true

func reset():
	set_global_pos(init_pos)
	smooth_change_zoom(init_zoom)

func smooth_change_zoom(_to):
	change_zoom = _to
