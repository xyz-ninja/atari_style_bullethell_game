extends Node2D

# переменная нужна для правильной обработки приорита нажатий
var is_ignore_mouse_overlap = false

var is_mouse_overlap = false

func _ready():
	set_process(true)

func _process(delta):
	if has_node("bg"):
		if !is_ignore_mouse_overlap and is_mouse_over(get_local_mouse_pos(), get_node("bg")):
			is_mouse_overlap = true
		else:
			is_mouse_overlap = false

func is_mouse_clicked(_ignore_timer = false):
	if TIME.Timers.button_timer.is_finish() or _ignore_timer:
		if Input.is_action_pressed("mouse_left_click") and is_visible():
			if !_ignore_timer:
				TIME.Timers.button_timer.reload()
			return true
		else:
			return false

func is_mouse_rb_clicked():
	if TIME.Timers.button_timer.is_finish():
		if Input.is_action_pressed("mouse_right_click"):
			TIME.Timers.button_timer.reload()
			return true
		else:
			return false

func is_mouse_over(_mouse_pos, _sprite, _ignore_timer = false):
	var is_cursor_over_sprite = SYS.is_pos_inside_rect(_mouse_pos , Rect2(
		_sprite.get_pos().x , _sprite.get_pos().y ,
		_sprite.get_region_rect().size.width * _sprite.get_scale().x ,
		_sprite.get_region_rect().size.height * _sprite.get_scale().y ))

	if is_cursor_over_sprite and _sprite.is_visible() and is_visible():
		if _ignore_timer:
			return true 
		else:
			if TIME.Timers.button_timer.is_finish(): 
				if !is_ignore_mouse_overlap:
					is_mouse_overlap = true
				return true
			else:
				return false
	else:
		is_mouse_overlap = false
		return false