extends Node2D

enum CHARACTER_ACTION {RUN, ATTACK, FAITH}

onready var game = get_tree().get_nodes_in_group("game")[0]
onready var fg_textures = get_node("foreground_textures")

var cur_action
var tex_holders = {}
var cur_tex_holder
var tex_y_offset = 0

var sine_range = Vector2(10, 5)
var sine_speed = 0.1
var sine_timer = TIME.create_new_timer("char_portrait_sine_timer", sine_speed)
var sine_angle = 0
var is_sine_angle_backwards = false

var init_pos = get_global_pos()
var init_tex_rect = Rect2(120, 60, 120, 60)

var anim_speed = 0.18
var anim_timer = TIME.create_new_timer("unit_anim_timer", anim_speed)
var anim_frames_count = 1

func _ready():
	tex_holders = {
		standard = get_node("standard"),
		med_lvl = get_node("med_lvl"),
		high_lvl = get_node("high_lvl")
	}
	
	set_cur_tex_holder(tex_holders.standard)
	set_character_action(CHARACTER_ACTION.RUN)

	set_process(true)
	
func _process(delta):

	if anim_timer.init_time != anim_speed:
		anim_timer.change_init_time(anim_speed)

	if cur_tex_holder != null and !cur_action == null:
		play_frame_animation()
		
		if !game.is_world_stopped or game.is_world_stopped and game.player.is_moving:
			if sine_timer.is_finish():
				if sine_angle > 360:
					sine_angle = 0
				else:
					sine_angle += 1
					
				sine_timer.reload()

			var dx = 0
			var dy = 0
			
			dx = sine_range.x * cos(sine_angle)
			dy = sine_range.y * cos(sine_angle)
			
			cur_tex_holder.set_global_pos(Vector2(init_pos.x + dx, init_pos.y + dy))
	
var cur_anim_frame_num = 0
func play_frame_animation():
	var frames_count = anim_frames_count

	if cur_tex_holder != null and frames_count > 1:

		if anim_timer.is_finish():
			var tex = cur_tex_holder.get_node("tex")

			if cur_anim_frame_num + 1 == frames_count:
				cur_anim_frame_num = 0
			else:
				cur_anim_frame_num += 1

			# ставим нужный кадр из текстуры
			tex.set_region_rect(Rect2(Vector2(
				init_tex_rect.size.x * cur_anim_frame_num, init_tex_rect.size.y * tex_y_offset),
				init_tex_rect.size
			))

			if cur_tex_holder.has_node("tex1"):
				cur_tex_holder.get_node("tex1").set_region_rect(tex.get_region_rect())

			anim_timer.reload()
	else:
		var tex = cur_tex_holder.get_node("tex")
		tex.set_region_rect(Rect2(Vector2(0, init_tex_rect.size.y * tex_y_offset),init_tex_rect.size))

		if cur_tex_holder.has_node("tex1"):
			cur_tex_holder.get_node("tex1").set_region_rect(tex.get_region_rect())

func set_cur_tex_holder(_holder_node):
	if cur_tex_holder != _holder_node:
		cur_tex_holder = _holder_node

		for tex_holder in tex_holders.values():
			tex_holder.hide()
			
		cur_tex_holder.show()

func set_character_action(_cur_action):
	if cur_action != _cur_action:
		cur_action = _cur_action
		var bg_color = SYS.Colors.black

		hide_all_fg_textures()

		if cur_action == CHARACTER_ACTION.RUN:
			tex_y_offset = 0
			anim_frames_count = 1
		elif cur_action == CHARACTER_ACTION.ATTACK:
			tex_y_offset = 1
			anim_frames_count = 2
		elif cur_action == CHARACTER_ACTION.FAITH:
			tex_y_offset = 2
			anim_frames_count = 2
			#bg_color = Color("#302f08")
			fg_textures.get_node("faith").show()

		get_node("bg").set_modulate(bg_color)

func hide_all_fg_textures():
	for tex_n in fg_textures.get_children():
		tex_n.hide()

func add_sine_range(_x, _y):
	sine_range.x += _x
	sine_range.y += _y

func reduce_sine_range(_x, _y):
	sine_range.x -= _x
	sine_range.y -= _y

	if sine_range.x < 1:
		sine_range.x = 1
	if sine_range.y < 1:
		sine_range.y = 1