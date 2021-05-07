extends Node2D

onready var game = get_tree().get_nodes_in_group("game")[0]

var is_projectile = true

var tex
var init_tex_scale

var is_belongs_to_player = false
var is_ready_to_update = false

var move_speed
var move_angle

var damage = 1
var by_unit

var collision_dist = 22 # small - 22, big
var type

var autodestroy_time
var autodestroy_timer

var hits_to_destroy = 0 # количество столкновений для уничтожения снаряда
var hits_to_destroy_timer = TIME.create_new_timer("hits_to_destroy_timer", 0.12)

func _ready():
	tex = get_node("tex")
	init_tex_scale = tex.get_scale()

	set_process(true)

func _process(delta):
	var cur_pos = get_global_pos()
		
	if !game.is_unit_in_play_zone(self):
		destroy()

	if autodestroy_timer != null:
		if autodestroy_timer.check_time() < 1.0:
			set_scale(Vector2(1.0 * autodestroy_timer.check_time(), 1.0 * autodestroy_timer.check_time()))

		if autodestroy_timer.is_finish():
			destroy()

	if is_ready_to_update:
		show()

		# setup effects
		if is_belongs_to_player:
			if by_unit.level >= 4:
				if has_node("lvl4_effects"):
					if OPTIONS.is_light_effects_enabled:
						get_node("lvl4_effects/light").set_enabled(true)
						if tex.get_rotd() == 270:
							get_node("lvl4_effects/light").set_global_pos(Vector2(cur_pos.x - 14, cur_pos.y))
						elif tex.get_rotd() == 180:
							get_node("lvl4_effects/light").set_global_pos(Vector2(cur_pos.x - 14, cur_pos.y - 13))
						elif tex.get_rotd() == 90:
							get_node("lvl4_effects/light").set_global_pos(Vector2(cur_pos.x, cur_pos.y - 13))
						get_node("lvl4_effects/light")
					get_node("lvl4_effects").show()
			else:
				if has_node("lvl4_effects"):
					get_node("lvl4_effects/light").set_enabled(false)
					get_node("lvl4_effects").hide()
		else:
			if has_node("enemy_effects"):
				if OPTIONS.is_light_effects_enabled:
					get_node("enemy_effects/light").set_enabled(true)
				get_node("enemy_effects").show()

		# move by angle
		var dx = 0
		var dy = 0

		if move_angle != null:
			dx = 1.0
			dy = 1.0

			dx *= cos(deg2rad(move_angle)) * move_speed * delta
			dy *= sin(deg2rad(move_angle)) * move_speed * delta
		else:
			if is_belongs_to_player:
				dy -= move_speed * delta
			else:
				dy += move_speed * delta
				
		var prev_pos = get_global_pos()
		set_global_pos(Vector2(prev_pos.x + dx, prev_pos.y + dy))

		# CHECK COLLISIONS
		if is_belongs_to_player:
			for enemy_unit in game.cur_enemy_units:
				if weakref(enemy_unit).get_ref() and enemy_unit.get("is_unit"):
					if SYS.get_dist_between_sprites(tex, enemy_unit.tex) < enemy_unit.collision_dist and \
						hits_to_destroy_timer.is_finish():
						
						enemy_unit.deal_damage(damage)
	
						if hits_to_destroy == 0:
							destroy()
						else:
							hits_to_destroy -= 1
							hits_to_destroy_timer.reload()
		else:
			var pl = game.player
			if pl != null and weakref(pl).get_ref():
				if pl.cur_power == null:
					if SYS.get_dist_between_sprites(tex, pl.tex) < pl.collision_dist - 10:
						pl.deal_damage(1)

						destroy()
				elif pl.cur_power == game.PLAYER_POWER_TYPE.CROSS:
					if SYS.get_dist_between_sprites(tex, pl.tex) < 60:
						game.sound.play("env2", "enemy_proj_destroyed")
						destroy()
	else:
		hide()

func setup(_type, _move_speed, _move_angle = null, _autodestroy_time = null):
	type = _type
	move_speed = _move_speed
	move_angle = _move_angle
	autodestroy_time = _autodestroy_time

	var tex_offset = Vector2(0, 0)
	var tex_modulate_color

	if type == game.PROJECTILE_TYPE.PLAYER_DAGGER or type == null:
		#collision_dist = 22
		tex_modulate_color = "#0057ff"

	elif type == game.PROJECTILE_TYPE.ENEMY_NORMAL:
		tex_offset.x = 0
		tex_offset.y = 1
		tex_modulate_color = "#ff0000"

		tex.set_scale(Vector2(init_tex_scale.x - 0.25, init_tex_scale.y - 0.25))

	elif type == game.PROJECTILE_TYPE.ENEMY_VOMIT:
		tex_offset.x = SYS.get_random_int(0, 3)
		tex_offset.y = 2
		tex_modulate_color = SYS.Colors.red

		tex.set_scale(Vector2(init_tex_scale.x + 0.35, init_tex_scale.y + 0.35))

	tex.set_region_rect(Rect2(15 * tex_offset.x, 15 * tex_offset.y, 15, 15))
	tex.set_modulate(tex_modulate_color)

	if autodestroy_time != null:
		autodestroy_timer = TIME.create_new_timer("projectile_autodestroy_timer", autodestroy_time)

	is_ready_to_update = true

func set_damage(_count):
	damage = _count

func destroy():
	#if weakref(by_unit).get_ref() and by_unit.get_type() == "Node2D":
	#	by_unit.cur_projectiles.erase(self)
	queue_free()

func set_tex_rotd(_deg):
	tex.set_rotd(_deg)
	if has_node("lvl4_effects"):
		get_node("lvl4_effects/tex").set_rotd(_deg)