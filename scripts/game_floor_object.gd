extends Node2D

var tex
var tex_offset
var init_tex_rect2

var is_destroyed = false

var is_floor_object = true

func _ready():
	tex = get_node("tex")
	init_tex_rect2 = tex.get_region_rect()

func setup_tex(_vec2_offset, _custom_color = null):
	tex_offset = _vec2_offset

	var custom_color = _custom_color

	tex.set_region_rect(Rect2(
		Vector2(init_tex_rect2.size.x * tex_offset.x, init_tex_rect2.size.y * tex_offset.y), 
		init_tex_rect2.size
	))

	if custom_color != null:
		tex.set_modulate(_custom_color)

# меняет фрейм объекта на его разрушенную версию (следующий 1 или 2 кадр в текстуре)
func destroy_by_unit(_is_destroyed_by_player = false):
	if !is_destroyed:
		var sel_frame = SYS.get_random_int(1,2)

		setup_tex(Vector2(tex_offset.x + sel_frame, tex_offset.y))

		var game = get_tree().get_nodes_in_group("game")[0]
		if _is_destroyed_by_player:
			game.cam.shake(0.4, 0.3, 0.1)
		
		game.sound.play("objects", "obj_hit")

		is_destroyed = true