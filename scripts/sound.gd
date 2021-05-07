extends Node2D

# ERLAX, DR.DOCTOR, THE 303, Sro, Glass Boy, Humanfobia

var stream_player

func _ready():
	stream_player = get_node("stream_player")

	set_audio_volume(1.3, 4.5)

func play(_sampler_node_name, _sample_name):
	if OPTIONS.is_sound_enabled:
		var sampler_node_name = _sampler_node_name
		var sample_name = _sample_name

		if !has_node(sampler_node_name):
			#print("sound not found!!!")
			return false

		get_node(sampler_node_name).play(sample_name)
		return true

func set_audio_volume(_music_vol, _sound_vol):
	AudioServer.set_stream_global_volume_scale(_music_vol)
	AudioServer.set_fx_global_volume_scale(_sound_vol)

func set_music_stream(_music_scn):
	if OPTIONS.is_music_enabled and stream_player.get_stream() != _music_scn:
		get_node("stream_player").set_stream(_music_scn)
		get_node("stream_player").play()