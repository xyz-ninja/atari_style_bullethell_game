extends Node2D

var game

onready var bg = get_node("bg")

var obj_spawn_timer = TIME.create_new_timer("game_floor_object_spawn_timer", 0.25)

var cur_game_level = 1

var tex_scale

func _ready():
	game = get_tree().get_nodes_in_group("game")[0]

func update(delta, _scroll_speed):
	var scroll_speed = _scroll_speed

	var texs = get_node("texs").get_children()

	if tex_scale == null:
		tex_scale = texs[0].get_scale()

	# SPAWN FLOOR OBJECTS

	if obj_spawn_timer.is_finish():
		var obj_count = 1

		# может заспаунится сразу несколько объектов
		for i in range(2):
			if SYS.get_random_percent_0_to_100() < 50:
				obj_count += 1

		# параметры объектов в зависимости от игрового уровня
		var cur_objs_params = []
		if game.game_level == 1:
			cur_objs_params = [
				{tex_offset = Vector2(0, 0)},
				{tex_offset = Vector2(3, 0)}, 
				{tex_offset = Vector2(6, 0), custom_color = Color("#10531e")}
			]
		elif game.game_level == 2:
			cur_objs_params = [
				{tex_offset = Vector2(0, 1), custom_color = Color("#92749a")},
				{tex_offset = Vector2(3, 1), custom_color = Color("#92749a")}
			]
		elif game.game_level == 3:
			cur_objs_params = [
				{tex_offset = Vector2(0, 2), custom_color = SYS.Colors.dark_gray},
				{tex_offset = Vector2(3, 2), custom_color = SYS.Colors.black}, 
				{tex_offset = Vector2(6, 2), custom_color = Color("#3d3041")},
				{tex_offset = Vector2(9, 2), custom_color = Color("#3d3041")}
			]
		elif game.game_level == 4:
			cur_objs_params = [
				{tex_offset = Vector2(0, 3), custom_color = SYS.Colors.black},
				{tex_offset = Vector2(3, 3), custom_color = SYS.Colors.yellow}
			]
		elif game.game_level == 5:
			cur_objs_params = [
				{tex_offset = Vector2(3, 0), custom_color = Color("#091f1e")}, 
				{tex_offset = Vector2(6, 0), custom_color = Color("#091f1e")}
			]
		else:
			cur_objs_params = [
				{tex_offset = Vector2(0, 0)},
				{tex_offset = Vector2(3, 0)}, 
				{tex_offset = Vector2(6, 0)}
			]

		var cur_spawned_objects = []

		# spawn objects
		for i in range(obj_count):
			var gen_pos

			# объекты должны быть на некотором расстоянии друг от друга 
			while gen_pos == null:
				var test_pos = Vector2(
					SYS.get_random_int(60, game.play_region_x_end_pos - 80),
					SYS.get_random_int(game.play_region_y_start_pos - 50, game.play_region_y_start_pos - 70)
				)

				# сравниваем с позициями других объектов
				var is_pos_correct = true
				for spawned_obj in cur_spawned_objects:
					if SYS.get_dist_between_points_in_detail(test_pos, spawned_obj.get_global_pos()).horizontal < 45:
						is_pos_correct = false
						break

				if is_pos_correct:
					gen_pos = test_pos

			var new_obj = game.spawn_object_from_scene(game.floor_small_obj_scn, gen_pos)

			var sel_obj_param = SYS.get_random_arr_item(cur_objs_params)

			var custom_tex_color
			if sel_obj_param.has("custom_color"):
				custom_tex_color = sel_obj_param.custom_color

			new_obj.setup_tex(sel_obj_param.tex_offset, custom_tex_color)

			cur_spawned_objects.append(new_obj)

		obj_spawn_timer.change_init_time(SYS.get_random_float(0.8, 1.95))

	# ищем самую верхнюю текстуру
	var higher_tex
	var higher_tex_val
	
	for tex in texs:
		var cur_tex_pos = tex.get_global_pos()

		if higher_tex == null or cur_tex_pos.y < higher_tex_val:
			higher_tex = tex
			higher_tex_val = cur_tex_pos.y

	# PARALLAX EFFECT
	for tex in texs:
		var cur_tex_pos = tex.get_global_pos()
		var tex_dx = 0
		var tex_dy = 0 

		if cur_tex_pos.y > game.play_region_y_end_pos + 200 * tex_scale.y:
			cur_tex_pos.y = higher_tex.get_global_pos().y - 200 * tex_scale.y
		
		tex_dy += scroll_speed * delta

		tex.set_global_pos(Vector2(cur_tex_pos.x + tex_dx, cur_tex_pos.y + tex_dy))

func setup_by_game_level(_game_level):
	cur_game_level = _game_level

	var floor_tex_offset = Vector2(0, 0)
	var floor_color

	if cur_game_level == 1:
		bg.set_modulate(Color("#050e1d"))

		floor_tex_offset = Vector2(0, 0)
		floor_color = Color("#122900")

	elif cur_game_level == 2:
		bg.set_modulate(Color("#19051d"))

		floor_tex_offset = Vector2(0, 1)
		floor_color = Color("#400551")

	elif cur_game_level == 3:
		bg.set_modulate(Color("#1c0f02"))

		floor_tex_offset = Vector2(0, 2)
		floor_color = Color("#36090e")

	elif cur_game_level == 4:
		bg.set_modulate(Color("#25217a"))

		floor_tex_offset = Vector2(0, 3)
		floor_color = Color("#000000")

	elif cur_game_level == 5:
		bg.set_modulate(Color("#101b26"))

		floor_tex_offset = Vector2(0, 4)
		floor_color = Color("#042927")

	var texs = get_node("texs").get_children()
	for tex in texs:
		var tex_rect_size = tex.get_region_rect().size
		tex.set_region_rect(Rect2(
			Vector2(tex_rect_size.x * floor_tex_offset.x, tex_rect_size.y * floor_tex_offset.y),
			tex_rect_size
		))
		
		if floor_color != null:
			tex.set_modulate(floor_color)

