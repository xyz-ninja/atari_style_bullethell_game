extends Node2D


# максимальная заполненность шкалы
var type 
export var init_points = 100
export var points = 50

var step_time = 0
var step = 0

# sprites
onready var bg = get_node("bg")
onready var bar = get_node("bar")

var autodestroy_when_empty = false

var init_bar_width

func _ready():
	init_bar_width = bar.get_region_rect().size.width


func setup_progressbar(_init_points):
	if init_points != _init_points:
		init_points = _init_points
		points = init_points


func update(_points):
	points = _points

	if points == 0:
		hide()
	else:
		show()

	var bg_width = bg.get_region_rect().size.width
	var bar_width = bar.get_region_rect().size.width

	# init_points = 100%
	# points = x
	# points * 100.0 / init_points

	var coef = points * 100.0 / init_points
	var change_percents = coef / 100.0 # 100 => 1.0

	var bar_region_rect = bar.get_region_rect()
	bar_region_rect.size.width = init_bar_width * change_percents
	
	bar.set_region_rect(bar_region_rect)

	if has_node("val"):
		#get_node("val").set_text(str(points)+"/"+str(init_points))
		get_node("val").set_text(str(points))

	if autodestroy_when_empty:
		if points <= 2:
			queue_free()

func set_autodestroy_when_empty(_bool):
	autodestroy_when_empty = _bool

# for auto-progressbars
func set_step_with_time(_step, _time):
	pass

func set_bar_color(_color):
	bar.set_modulate(_color)