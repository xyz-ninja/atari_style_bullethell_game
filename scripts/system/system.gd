extends Node

# ЗАМЕНИТЬ ЭТИМ ФАЙЛОМ АНАЛОГИЧНЫЙ В CRIMINAL TYCOON

const Colors = {
	OBJ_original 	= Color(1,1,1,1),
	white 			= "#ffffff",
	black 			= "#000000",
	gray 				= "#696B6E",
	dark_gray 		= "#202020",
	red 				= "#D73030",
	green 			= "#54D830",
	light_yellow 	= "#E9E747",
	yellow 			= "#C9C708",
	light_blue 		= "#1E90FF",
	blue 				= "#0000FF",
	plum 				= "#DDA0DD"
}

var InitValues = {
	dist_collide = 75
}

enum DIR {LEFT, RIGHT, UP, DOWN}
enum ISOM_WALL_DIR {FRONT, BACK, LEFT, RIGHT}
enum ONTILE_OBJ_TYPE {UNIT, FUR, MOUSE_CURSOR} # need in isometric_tile show/hide around tiles funcs

var astar = null

var tms_last_id = 0

func _ready():
	astar = AStar.new()

func is_pos_inside_rect(_pos , _rect):
	if (_pos.x >= _rect.pos.x and 
		_pos.x <= _rect.size.width and
		_pos.y >= _rect.pos.y and
		_pos.y <= _rect.size.height ):
		return true
	else:
		return false

func is_spr_collide_other_spr(_spr , _other_spr):
	var spr = _spr
	var other_spr = _other_spr

	var t_spr = get_true_sprite_rect2(spr)
	var t_other_spr = get_true_sprite_rect2(other_spr)

	if (t_spr.pos.x >= t_other_spr.pos.x and
		t_spr.pos.x + t_spr.size.width <= t_other_spr.pos.x + t_other_spr.size.width  or
		t_spr.pos.y >= t_other_spr.pos.y and
		t_spr.pos.y + t_spr.size.height <= t_other_spr.pos.y + t_other_spr.size.height):
		return true
	else:
		return false

func get_dist_between_points(_p1, _p2):
	var p1 = _p1
	var p2 = _p2

	var dist = sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
	return dist

func get_dist_between_points_in_detail(_p1, _p2):
	var p1 = _p1
	var p2 = _p2

	var dist = sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
	var dist_x = sqrt(pow(p2.x - p1.x, 2))
	var dist_y = sqrt(pow(p2.y - p1.y, 2))

	return {common = dist, horizontal = dist_x, vertical = dist_y}

func get_dist_between_sprites(_spr, _other_spr):
	var spr = _spr
	var other_spr = _other_spr

	# ищем центральные точки спрайтов
	var c_pos1 = get_sprite_center_pos(spr)
	var c_pos2 = get_sprite_center_pos(other_spr)

	var dist = sqrt(pow(c_pos2.x - c_pos1.x,2) + pow(c_pos2.y - c_pos1.y, 2))

	return dist

func get_angle_between_positions(_pos1, _pos2):
	var pos1 = _pos1
	var pos2 = _pos2

	var angle = rad2deg(atan2(pos1.y - pos2.y, pos1.x - pos2.x))
	if angle < 0:
		angle += 360

	return angle

# позиция и настоящие размеры спрайта с учётом region_rect.size * scale
func get_true_sprite_rect2(_spr):
	var spr = _spr
	var true_rect = Rect2(
		spr.get_global_pos(),
		Vector2(
			spr.get_region_rect().size.width * spr.get_scale().x,
			spr.get_region_rect().size.height * spr.get_scale().y 
		)
	)
	return true_rect

func get_random_int(_min, _max):
	randomize()
	var min_v = int(_min)
	var max_v = int(_max)

	return ceil(rand_range(min_v, max_v))

func get_random_float(_min, _max):
	randomize()
	return rand_range(_min, _max)

func get_random_percent_0_to_100():
	randomize()
	return ceil(rand_range(0, 100))

func get_random_arr_item(_arr):
	var cur_arr = _arr
	if cur_arr != null and cur_arr.size() > 0:
		randomize()
		var rand_index = int(rand_range(0, cur_arr.size()))
		return cur_arr[rand_index]
	else:
		return null

func get_random_enum_item(_enum):
	var cur_enum = _enum
	randomize()
	var rand_index = int(rand_range(0, cur_enum.size()))
	for key in cur_enum.keys():
		if cur_enum[key] == rand_index:
			return cur_enum[key]

func get_random_dict_item(_dict):
	var cur_dict = _dict
	randomize()
	var rand_index = int(rand_range(0, cur_dict.size()))
	
	var cur_item_index = 0
	for key in cur_dict.keys():
		if cur_item_index == rand_index:
			return cur_dict[key]
		else:
			cur_item_index += 1

func get_sprite_center_pos(_spr):
	var spr = _spr
	if spr != null:
		var gl_pos = spr.get_global_pos()
		return Vector2(
			gl_pos.x + (spr.get_region_rect().size.width * spr.get_scale().x / 2),
			gl_pos.y + (spr.get_region_rect().size.height * spr.get_scale().y / 2)
		)