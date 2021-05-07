extends "res://scripts/obj.gd"

enum EXP_BONUS_TYPE {ONE, MED, BIG}

var type

var is_attracts_to_player = false
var attract_speed = 160

var game
var player

var buffer_zone = 1

var exp_count = 0

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	game = player.game

	set_process(true)
	
func _process(delta):
	if is_attracts_to_player:
		var dx = 0
		var dy = 0
		
		var cur_pos = get_global_pos()
		var pl_pos = player.get_global_pos()
		
		if pl_pos.x < cur_pos.x - buffer_zone:
			dx -= attract_speed * delta
		else:
			dx += attract_speed * delta

		if pl_pos.y < cur_pos.y - buffer_zone:
			dy -= attract_speed * delta
		else:
			dy += attract_speed * delta

		set_global_pos(Vector2(cur_pos.x + dx, cur_pos.y + dy))

		if SYS.get_dist_between_sprites(get_node("tex"), player.tex) < 25:
			player.add_exp(exp_count)

			game.sound.play("objects", "skull_pickup")

			queue_free()

func activate():
	is_attracts_to_player = true

func set_type(_e_type):
	type = _e_type

	if type == EXP_BONUS_TYPE.ONE:
		get_node("tex").set_region_rect(Rect2(15, 0, 15, 15))
		exp_count = 1
		deceleration_speed = 50
	elif type == EXP_BONUS_TYPE.MED:
		get_node("tex").set_region_rect(Rect2(30, 0, 15, 15))
		exp_count = 10
		deceleration_speed = 80
	elif type == EXP_BONUS_TYPE.BIG:
		get_node("tex").set_region_rect(Rect2(45, 0, 15, 15))
		exp_count = 40
		deceleration_speed = 100