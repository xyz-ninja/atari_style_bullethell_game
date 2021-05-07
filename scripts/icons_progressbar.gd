extends Node2D

var icon_scn
var dist_between_icons

var icons_nodes = []

var max_val
var cur_val

var is_setuped = false

func setup_progressbar(_icon_scn, _max_val, _cur_val = 1, _dist_between_icons = 20):
	icon_scn = _icon_scn
	dist_between_icons = _dist_between_icons
	max_val = _max_val
	cur_val = _cur_val
	is_setuped = true

func update_progressbar(_cur_val):
	if max_val != null:
		cur_val = _cur_val

		if cur_val > max_val:
			cur_val = max_val

		if icons_nodes.size() != cur_val:
			for n in icons_nodes:
				if weakref(n).get_ref():
					n.queue_free()
			icons_nodes = []

			for i in range(cur_val):
				var icon_pos = Vector2(get_global_pos().x, get_global_pos().y)
				if i > 0:
					icon_pos.x = icons_nodes[i - 1].get_global_pos().x + dist_between_icons

				var new_icon = icon_scn.instance()
				add_child(new_icon)
				new_icon.set_global_pos(icon_pos)
				
				icons_nodes.append(new_icon)
