extends Node2D

var game

var is_immovable = true
var is_ready_to_update = false

var spawn_unit_scn
var before_spawn_timer = TIME.create_new_timer("spawn_unit_marker_before_spawn_timer", 1.2)

func _ready():
	game = get_tree().get_nodes_in_group("game")[0]

	set_process(true)
	
func _process(delta):
	if spawn_unit_scn == null:
		before_spawn_timer.reload()
	else:
		if before_spawn_timer.is_finish():
			var corrected_pos = get_global_pos()
			corrected_pos.x -= 15
			game.spawn_unit_from_scene(spawn_unit_scn, corrected_pos)
			TIME.destroy_timer(before_spawn_timer)
			queue_free()

func setup_marker(_spawn_unit_scn, _time_before_spawn = 1.2, _icon_x_offset = 6):
	spawn_unit_scn = _spawn_unit_scn

	if before_spawn_timer.init_time != _time_before_spawn:
		before_spawn_timer.change_init_time(_time_before_spawn)
		
	get_node("icon").set_region_rect(Rect2(15 * _icon_x_offset, 0, 15, 15))