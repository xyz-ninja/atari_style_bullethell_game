extends Node2D

export var disable_opacity_change = false

var autodestroy_timer
var amountdestroy_time = 0.05
var amountdestroy_timer = amountdestroy_time

var need_destroy_amount = false

var init_opacity

func _ready():
	init_opacity = get_opacity()
	set_process(true)
	
func _process(delta):
	#set_rotd(0)
	if autodestroy_timer != null:
		autodestroy_timer -= delta
			
		if autodestroy_timer < amountdestroy_time / 2 and !disable_opacity_change:
			init_opacity -= 0.05 * delta
			set_opacity(init_opacity)
			
		if autodestroy_timer < 0:
			autodestroy_timer = null
			get_node("p").set_emitting(false)
			need_destroy_amount = true
	
	if need_destroy_amount:
		amountdestroy_timer -= delta
		if amountdestroy_timer <= 0:
			amountdestroy_timer = amountdestroy_time
			var cur_am = get_node("p").get_amount()
			get_node("p").set_amount(cur_am - 1)
			if get_node("p").get_amount() <= 0:	
				get_node("p").queue_free()
				queue_free()
		
func set_autodestroy_and_emit_timer(_time):
	if autodestroy_timer == null:
		autodestroy_timer = _time