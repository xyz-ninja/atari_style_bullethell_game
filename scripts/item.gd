extends Node2D

var game

onready var icon = get_node("icon")

var type
var info_params

var is_available_to_pick = true

func _ready():
	game = get_tree().get_nodes_in_group("game")[0]

func setup_item(_type):
	type = _type
	info_params = ENV.get_item_info_params_by_type(_type)

	get_node("icon").set_region_rect(Rect2(20 * info_params.icon_x_offset, 20 * info_params.icon_y_offset, 20, 20))

func destroy():
	is_available_to_pick = false
	queue_free()