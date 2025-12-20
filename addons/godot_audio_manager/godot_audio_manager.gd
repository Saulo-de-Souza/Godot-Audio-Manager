@tool
@icon("res://addons/godot_audio_manager/icons/icon.svg")


## Manage all audio files such as AudioStreamPlayer, AudioStreamPlayer2D, and AudioStreamPlayer3D 
## directly from a single node, and enjoy extra features like the ability to loop all audio types 
## and enable audio pauses when the window is out of focus or when switching tabs in the web browser.
class_name GodotAudioManager extends Node


#region EXPORTS ************************************************************************************
@export_subgroup("Audios Omni")
## These are the audio files that represent the AudioStreamPlayer (one-way audio).
@export var audios_manager_omni: Dictionary[String, GodotAudioManagerOmni]:
	set(value):
		audios_manager_omni = value
		if not is_node_ready(): return
		for key in audios_manager_omni:
			var audio_omni: GodotAudioManagerOmni = audios_manager_omni.get(key)
			if audio_omni:
				if not has_audio_stream_player(key):
					audios_stream_players[key] = _create_stream_player(audio_omni, key)
		update_configuration_warnings()

@export_subgroup("Audios 2D")
## This is the node where the 2D audio files will be inserted. 
## If you don't assign anything, the audio files will be created within the GodotAudioManager node.
@export var parent_2d: Node2D:
	set(value):
		parent_2d = value
		if Engine.is_editor_hint(): return
		if not is_node_ready(): return
		await get_tree().process_frame
		if is_instance_valid(parent_2d):
			if not parent_2d.is_node_ready(): await parent_2d.ready
			for key in audios_stream_players_2d:
				var audio: AudioStreamPlayer2D = get_audio_stream_player_2d(key)
				if audio and audio.get_parent():
					if audio.get_parent() != parent_2d:
						audio.reparent(parent_2d)
						audio.position = Vector2.ZERO
		else:
			for key in audios_stream_players_2d:
				var audio: AudioStreamPlayer2D = get_audio_stream_player_2d(key)
				if audio and audio.get_parent():
					if audio.get_parent() != self:
						audio.reparent(self)
						audio.position = Vector2.ZERO
					
		update_configuration_warnings()

## These are the audio files that represent AudioStreamPlayer2D.
@export var audios_manager_2d: Dictionary[String, GodotAudioManager2D]:
	set(value):
		audios_manager_2d = value
		if not is_node_ready(): return
		for key in audios_manager_2d:
			var audio_2d: GodotAudioManager2D = audios_manager_2d.get(key)
			if audio_2d:
				if not has_audio_stream_player_2d(key):
					audios_stream_players_2d[key] = _create_stream_player_2d(audio_2d, key)
		update_configuration_warnings()

@export_subgroup("Audios 3D")
## This is the node where the 3D audio files will be inserted. 
## If you don't assign anything, the audio files will be created within the GodotAudioManager node.
@export var parent_3d: Node3D:
	set(value):
		parent_3d = value
		if Engine.is_editor_hint(): return
		if not is_node_ready(): return
		await get_tree().process_frame
		if is_instance_valid(parent_3d):
			if not parent_3d.is_node_ready(): await parent_3d.ready
			for key in audios_stream_players_3d:
				var audio: AudioStreamPlayer3D = get_audio_stream_player_3d(key)
				if audio and audio.get_parent():
					if audio.get_parent() != parent_3d:
						audio.reparent(parent_3d)
						audio.position = Vector3.ZERO
		else:
			for key in audios_stream_players_3d:
				var audio: AudioStreamPlayer3D = get_audio_stream_player_3d(key)
				if audio and audio.get_parent():
					if audio.get_parent() != self:
						audio.reparent(self)
						audio.position = Vector3.ZERO
		
		update_configuration_warnings()

## These are the audio files that represent AudioStreamPlayer3D.
@export var audios_manager_3d: Dictionary[String, GodotAudioManager3D]:
	set(value):
		audios_manager_3d = value
		if not is_node_ready(): return
		for key in audios_manager_3d:
			var audio_3d: GodotAudioManager3D = audios_manager_3d.get(key)
			if audio_3d:
				if not has_audio_stream_player_3d(key):
					audios_stream_players_3d[key] = _create_stream_player_3d(audio_3d, key)
		update_configuration_warnings()
#endregion *****************************************************************************************


#region SIGNALS ************************************************************************************
@warning_ignore_start("unused_signal")
## Emitted when omnidirectional audio ends.
signal finished_omni(audio_name)

## Emitted when audio 2d ends.
signal finished_2d(audio_name)

## Emitted when audio 3d ends.
signal finished_3d(audio_name)
@warning_ignore_restore("unused_signal")
#endregion *****************************************************************************************


#region PRIVATE PROPERTIES *************************************************************************
var _window_ref = JavaScriptBridge.get_interface("window")
var _blur_ref = JavaScriptBridge.create_callback(_on_web_blur)
var _focus_ref = JavaScriptBridge.create_callback(_on_web_focus)
#endregion ****************************************************************************************


#region PUBLIC PROPERTIES *************************************************************************
var audios_stream_players: Dictionary[String, AudioStreamPlayer]
var audios_stream_players_2d: Dictionary[String, AudioStreamPlayer2D]
var audios_stream_players_3d: Dictionary[String, AudioStreamPlayer3D]
#endregion ****************************************************************************************


#region CONSTANTS **********************************************************************************
const META_OMNI: String = "am_omni"
const META_2D: String = "am_2d"
const META_3D: String = "am_3d"
const AUDIO_STREAM_CLASS_NAME: String = "AudioStream"
const AUDIO_STREAM_MICROPHONE_CLASS_NAME: String = "AudioStreamMicrophone"
const AUDIO_STREAM_RANDOMIZER_CLASS_NAME: String = "AudioStreamRandomizer"
const AUDIO_STREAM_GENERATOR_CLASS_NAME: String = "AudioStreamGenerator"
const AUDIO_STREAM_WAV_CLASS_NAME: String = "AudioStreamWAV"
const AUDIO_STREAM_POLYPHONIC_CLASS_NAME: String = "AudioStreamPolyphonic"
const AUDIO_STREAM_PLAYLIST_CLASS_NAME: String = "AudioStreamPlaylist"
const AUDIO_STREAM_INTERACTIVE_CLASS_NAME: String = "AudioStreamInteractive"
const AUDIO_STREAM_SYNCHRONIZED_CLASS_NAME: String = "AudioStreamSynchronized"
const AUDIO_STREAM_MP3_CLASS_NAME: String = "AudioStreamMP3"
const AUDIO_STREAM_OGGVORBIS_CLASS_NAME: String = "AudioStreamOggVorbis"
#endregion *****************************************************************************************


#region ENGINE METHODS *****************************************************************************
func _ready() -> void:
	for key in audios_manager_omni:
		var audio_omni: GodotAudioManagerOmni = audios_manager_omni.get(key)
		if audio_omni:
			audios_stream_players[key] = _create_stream_player(audio_omni, key)
			
	for key in audios_manager_2d:
		var audio_2d: GodotAudioManager2D = audios_manager_2d.get(key)
		if audio_2d:
			audios_stream_players_2d[key] = _create_stream_player_2d(audio_2d, key)

	for key in audios_manager_3d:
		var audio_3d: GodotAudioManager3D = audios_manager_3d.get(key)
		if audio_3d:
			audios_stream_players_3d[key] = _create_stream_player_3d(audio_3d, key)

	if OS.has_feature("web"):
		_window_ref.addEventListener("blur", _blur_ref)
		_window_ref.addEventListener("focus", _focus_ref)
		

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_on_web_focus([])
	
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_on_web_blur([])


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	_check_audios_omni(warnings)
	_check_audios_2d(warnings)
	_check_audios_3d(warnings)
	
	return warnings
#endregion *****************************************************************************************

	
#region AUDIO OMNI *********************************************************************************
## Plays a sound from the beginning, or the given from_position in seconds.
func play_omni(audio_name: String, from_position: float = 0.0) -> void:
	var find_audio: AudioStreamPlayer = get_audio_stream_player(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		find_audio.play(from_position)


## Stops all sounds from this node.
func stop_omni(audio_name: String) -> void:
	var find_audio: AudioStreamPlayer = get_audio_stream_player(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		find_audio.stop()
	
	
## The sounds are paused.
func pause_omni(audio_name: String) -> void:
	var find_audio: AudioStreamPlayer = get_audio_stream_player(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		find_audio.stream_paused = true
	
	
## Resumes paused sounds.
func unpause_omni(audio_name: String) -> void:
	var find_audio: AudioStreamPlayer = get_audio_stream_player(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		find_audio.stream_paused = false
	
	
## Check if the sound is playing.
func is_playing_omni(audio_name: String) -> bool:
	var find_audio: AudioStreamPlayer = get_audio_stream_player(audio_name)
	if not find_audio: return false
	return find_audio.playing
	

## Check if the sound is paused.
func is_paused_omni(audio_name: String) -> bool:
	var find_audio: AudioStreamPlayer = get_audio_stream_player(audio_name)
	if not find_audio: return false
	return find_audio.stream_paused
	

## Restarts all sounds to be played from the given to_position, in seconds. Does nothing if no sounds are playing.
func seek_omni(audio_name: String, position: float) -> void:
	var find_audio: AudioStreamPlayer = get_audio_stream_player(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		await get_tree().process_frame
		find_audio.seek(position)
	

## Returns the position in the AudioStream of the latest sound, in seconds. Returns 0.0 if no sounds are playing.
func get_playback_position_omni(audio_name: String) -> float:
	var find_audio: AudioStreamPlayer = get_audio_stream_player(audio_name)
	if not find_audio: return 0.0
	return find_audio.get_playback_position()
	

## Returns the latest AudioStreamPlayback of this node, usually the most recently created by play(). 
## If no sounds are playing, this method fails and returns an empty playback.
func get_stream_playback_omni(audio_name: String) -> AudioStreamPlayback:
	var find_audio: AudioStreamPlayer = get_audio_stream_player(audio_name)
	if not find_audio:
		return null
	if not find_audio.is_inside_tree():
		await find_audio.tree_entered
	if not is_playing_omni(audio_name):
		return null
	if not await has_stream_playback_omni(audio_name):
		return null
	return find_audio.get_stream_playback()
	
	
## Returns true if any sound is active, even if stream_paused is set to true. See also playing and get_stream_playback().
func has_stream_playback_omni(audio_name: String) -> bool:
	var find_audio: AudioStreamPlayer = get_audio_stream_player(audio_name)
	if not find_audio: return false
	await get_tree().process_frame
	return find_audio.has_stream_playback()


## Enable loop.
func set_loop_omni(audio_name: String, value: bool) -> void:
	var find_audio: AudioStreamPlayer = get_audio_stream_player(audio_name)
	if not find_audio: return
	_set_loop(find_audio.stream, value)
	
	
func has_audio_stream_player(audio_name: String) -> bool:
	var find_audio: AudioStreamPlayer = audios_stream_players.get(audio_name)
	return true if find_audio else false


func get_audio_stream_player(audio_name: String) -> AudioStreamPlayer:
	var find_audio: AudioStreamPlayer = audios_stream_players.get(audio_name)
	if not find_audio: push_warning("Audio (%s) not found."%audio_name)
	return find_audio


func _create_stream_player(audio_omni: GodotAudioManagerOmni, audio_name: String) -> AudioStreamPlayer:
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	audio_stream_player.name = "am_omni_%s"%audio_name
	
	audio_stream_player.set_meta(META_OMNI, true)
	audio_stream_player.set_meta("name", audio_name)
	
	audio_stream_player.stream = audio_omni.stream
	audio_stream_player.volume_db = audio_omni.volume_db
	audio_stream_player.pitch_scale = audio_omni.pitch_scale
	audio_stream_player.playing = audio_omni.playing if audio_stream_player.is_inside_tree() else false
	audio_stream_player.autoplay = audio_omni.autoplay
	audio_stream_player.stream_paused = audio_omni.stream_paused
	_set_loop(audio_stream_player.stream, audio_omni.loop)
	audio_stream_player.set_meta("pause_on_blur", audio_omni.pause_on_blur)
	audio_stream_player.mix_target = audio_omni.mix_target
	audio_stream_player.max_polyphony = audio_omni.max_polyphony
	audio_stream_player.bus = audio_omni.bus
	audio_stream_player.playback_type = audio_omni.playback_type

	var cb: Callable = Callable(_on_omni_finished).bind(audio_name)
	audio_stream_player.finished.connect(cb)

	add_child.call_deferred(audio_stream_player)

	audio_omni._init_owner(self, audio_name, audio_stream_player)
	return audio_stream_player


func _on_omni_finished(audio_name: String) -> void:
	if not Engine.is_editor_hint():
		finished_omni.emit(audio_name)


func _check_audios_omni(p_warnings: PackedStringArray) -> void:
	for key in audios_manager_omni:
		var audio: GodotAudioManagerOmni = audios_manager_omni.get(key)
		if audio:
			if key == "":
				p_warnings.append("There are omni audio files without a defined name. Consider adding a name as a key to the omni audio file that is missing a key.")
			
			if AudioServer.get_bus_index(audio.bus) == -1:
				p_warnings.append("The omni audio (%s) has an invalid value for the bus property. Consider adding a valid value such as MASTER or another custom value."%key)
		else:
			p_warnings.append("There are omni audio files created without an AudioManagerOmni resource. Consider adding an AudioManagerOmni.")
#endregion *****************************************************************************************


#region AUDIO 2D *********************************************************************************
## Plays a sound from the beginning, or the given from_position in seconds.
func play_2d(audio_name: String, from_position: float = 0.0) -> void:
	if parent_2d:
		if not parent_2d.is_inside_tree(): await parent_2d.tree_entered
		await get_tree().process_frame
	var find_audio: AudioStreamPlayer2D = get_audio_stream_player_2d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		find_audio.play(from_position)


## Stops all sounds from this node.
func stop_2d(audio_name: String) -> void:
	if parent_2d:
		if not parent_2d.is_inside_tree(): await parent_2d.tree_entered
		await get_tree().process_frame
	var find_audio: AudioStreamPlayer2D = get_audio_stream_player_2d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		find_audio.stop()
	
	
## The sounds are paused.
func pause_2d(audio_name: String) -> void:
	if parent_2d:
		if not parent_2d.is_inside_tree(): await parent_2d.tree_entered
		await get_tree().process_frame
	var find_audio: AudioStreamPlayer2D = get_audio_stream_player_2d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		find_audio.stream_paused = true
	
	
## Resumes paused sounds.
func unpause_2d(audio_name: String) -> void:
	if parent_2d:
		if not parent_2d.is_inside_tree(): await parent_2d.tree_entered
		await get_tree().process_frame
	var find_audio: AudioStreamPlayer2D = get_audio_stream_player_2d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		find_audio.stream_paused = false
	
	
## Check if the sound is playing.
func is_playing_2d(audio_name: String) -> bool:
	var find_audio: AudioStreamPlayer2D = get_audio_stream_player_2d(audio_name)
	if not find_audio: return false
	return find_audio.playing
	

## Check if the sound is paused.
func is_paused_2d(audio_name: String) -> bool:
	var find_audio: AudioStreamPlayer2D = get_audio_stream_player_2d(audio_name)
	if not find_audio: return false
	return find_audio.stream_paused
	

## Restarts all sounds to be played from the given to_position, in seconds. Does nothing if no sounds are playing.
func seek_2d(audio_name: String, position: float) -> void:
	if parent_2d:
		if not parent_2d.is_inside_tree(): await parent_2d.tree_entered
		await get_tree().process_frame
	var find_audio: AudioStreamPlayer2D = get_audio_stream_player_2d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		await get_tree().process_frame
		find_audio.seek(position)
	

## Returns the position in the AudioStream of the latest sound, in seconds. Returns 0.0 if no sounds are playing.
func get_playback_position_2d(audio_name: String) -> float:
	var find_audio: AudioStreamPlayer2D = get_audio_stream_player_2d(audio_name)
	if not find_audio: return 0.0
	return find_audio.get_playback_position()
	

## Returns the latest AudioStreamPlayback of this node, usually the most recently created by play(). 
## If no sounds are playing, this method fails and returns an empty playback.
func get_stream_playback_2d(audio_name: String) -> AudioStreamPlayback:
	if parent_2d:
		if not parent_2d.is_inside_tree(): await parent_2d.tree_entered
		await get_tree().process_frame
	var find_audio: AudioStreamPlayer2D = get_audio_stream_player_2d(audio_name)
	if not find_audio:
		return null
	if not find_audio.is_inside_tree():
		await find_audio.tree_entered
	if not is_playing_2d(audio_name):
		return null
	if not await has_stream_playback_2d(audio_name):
		return null
	return find_audio.get_stream_playback()
	
	
## Returns true if any sound is active, even if stream_paused is set to true. See also playing and get_stream_playback().
func has_stream_playback_2d(audio_name: String) -> bool:
	var find_audio: AudioStreamPlayer2D = get_audio_stream_player_2d(audio_name)
	if not find_audio: return false
	await get_tree().process_frame
	return find_audio.has_stream_playback()


## Enable loop.
func set_loop_2d(audio_name: String, value: bool) -> void:
	var find_audio: AudioStreamPlayer2D = get_audio_stream_player_2d(audio_name)
	if not find_audio: return
	_set_loop(find_audio.stream, value)
	
	
func has_audio_stream_player_2d(audio_name: String) -> bool:
	var find_audio: AudioStreamPlayer2D = audios_stream_players_2d.get(audio_name)
	return true if find_audio else false


func get_audio_stream_player_2d(audio_name: String) -> AudioStreamPlayer2D:
	var find_audio: AudioStreamPlayer2D = audios_stream_players_2d.get(audio_name)
	if not find_audio: push_warning("Audio (%s) not found."%audio_name)
	return find_audio


func _create_stream_player_2d(audio_2d: GodotAudioManager2D, audio_name: String) -> AudioStreamPlayer2D:
	var audio_stream_player_2d: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio_stream_player_2d.name = "am_2d_%s"%audio_name
	
	audio_stream_player_2d.set_meta(META_2D, true)
	audio_stream_player_2d.set_meta("name", audio_name)
	
	audio_stream_player_2d.stream = audio_2d.stream
	audio_stream_player_2d.volume_db = audio_2d.volume_db
	audio_stream_player_2d.pitch_scale = audio_2d.pitch_scale
	audio_stream_player_2d.playing = audio_2d.playing if audio_stream_player_2d.is_inside_tree() else false
	audio_stream_player_2d.autoplay = audio_2d.autoplay
	audio_stream_player_2d.stream_paused = audio_2d.stream_paused
	_set_loop(audio_stream_player_2d.stream, audio_2d.loop)
	audio_stream_player_2d.set_meta("pause_on_blur", audio_2d.pause_on_blur)
	audio_stream_player_2d.max_distance = audio_2d.max_distance
	audio_stream_player_2d.attenuation = audio_2d.attenuation
	audio_stream_player_2d.max_polyphony = audio_2d.max_polyphony
	audio_stream_player_2d.panning_strength = audio_2d.panning_strength
	audio_stream_player_2d.bus = audio_2d.bus
	audio_stream_player_2d.area_mask = audio_2d.area_mask
	audio_stream_player_2d.playback_type = audio_2d.playback_type
	
	var cb: Callable = Callable(_on_2d_finished).bind(audio_name)
	audio_stream_player_2d.finished.connect(cb)

	if parent_2d:
		parent_2d.add_child.call_deferred(audio_stream_player_2d)
		# await audio_stream_player_2d.tree_entered
	else:
		add_child.call_deferred(audio_stream_player_2d)

	audio_2d._init_owner(self, audio_name, audio_stream_player_2d)
	return audio_stream_player_2d


func _on_2d_finished(audio_name: String) -> void:
	if not Engine.is_editor_hint():
		finished_2d.emit(audio_name)


func _check_audios_2d(p_warnings: PackedStringArray) -> void:
	for key in audios_manager_2d:
		var audio: GodotAudioManager2D = audios_manager_2d.get(key)
		if audio:
			if key == "":
				p_warnings.append("There are 2d audio files without a defined name. Consider adding a name as a key to the 2d audio file that is missing a key.")
			
			if AudioServer.get_bus_index(audio.bus) == -1:
				p_warnings.append("The 2d audio (%s) has an invalid value for the bus property. Consider adding a valid value such as MASTER or another custom value."%key)
		else:
			p_warnings.append("There are 2d audio files created without an AudioManager2D resource. Consider adding an AudioManager2D.")
#endregion *****************************************************************************************


#region AUDIO 3D *********************************************************************************
## Plays a sound from the beginning, or the given from_position in seconds.
func play_3d(audio_name: String, from_position: float = 0.0) -> void:
	if parent_3d:
		if not parent_3d.is_inside_tree(): await parent_3d.tree_entered
		await get_tree().process_frame
	var find_audio: AudioStreamPlayer3D = get_audio_stream_player_3d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		find_audio.play(from_position)


## Stops all sounds from this node.
func stop_3d(audio_name: String) -> void:
	if parent_3d:
		if not parent_3d.is_inside_tree(): await parent_3d.tree_entered
		await get_tree().process_frame
	var find_audio: AudioStreamPlayer3D = get_audio_stream_player_3d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		find_audio.stop()
	
	
## The sounds are paused.
func pause_3d(audio_name: String) -> void:
	if parent_3d:
		if not parent_3d.is_inside_tree(): await parent_3d.tree_entered
		await get_tree().process_frame
	var find_audio: AudioStreamPlayer3D = get_audio_stream_player_3d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		find_audio.stream_paused = true
	
	
## Resumes paused sounds.
func unpause_3d(audio_name: String) -> void:
	if parent_3d:
		if not parent_3d.is_inside_tree(): await parent_3d.tree_entered
		await get_tree().process_frame
	var find_audio: AudioStreamPlayer3D = get_audio_stream_player_3d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		find_audio.stream_paused = false
	
	
## Check if the sound is playing.
func is_playing_3d(audio_name: String) -> bool:
	var find_audio: AudioStreamPlayer3D = get_audio_stream_player_3d(audio_name)
	if not find_audio: return false
	return find_audio.playing
	

## Check if the sound is paused.
func is_paused_3d(audio_name: String) -> bool:
	var find_audio: AudioStreamPlayer3D = get_audio_stream_player_3d(audio_name)
	if not find_audio: return false
	return find_audio.stream_paused
	

## Restarts all sounds to be played from the given to_position, in seconds. Does nothing if no sounds are playing.
func seek_3d(audio_name: String, position: float) -> void:
	if parent_3d:
		if not parent_3d.is_inside_tree(): await parent_3d.tree_entered
		await get_tree().process_frame
	var find_audio: AudioStreamPlayer3D = get_audio_stream_player_3d(audio_name)
	if find_audio:
		if not find_audio.is_inside_tree(): await find_audio.tree_entered
		await get_tree().process_frame
		find_audio.seek(position)
	

## Returns the position in the AudioStream of the latest sound, in seconds. Returns 0.0 if no sounds are playing.
func get_playback_position_3d(audio_name: String) -> float:
	var find_audio: AudioStreamPlayer3D = get_audio_stream_player_3d(audio_name)
	if not find_audio: return 0.0
	return find_audio.get_playback_position()
	

## Returns the latest AudioStreamPlayback of this node, usually the most recently created by play(). 
## If no sounds are playing, this method fails and returns an empty playback.
func get_stream_playback_3d(audio_name: String) -> AudioStreamPlayback:
	if parent_3d:
		if not parent_3d.is_inside_tree(): await parent_3d.tree_entered
		await get_tree().process_frame
	var find_audio: AudioStreamPlayer3D = get_audio_stream_player_3d(audio_name)
	if not find_audio:
		return null
	if not find_audio.is_inside_tree():
		await find_audio.tree_entered
	if not is_playing_3d(audio_name):
		return null
	if not await has_stream_playback_3d(audio_name):
		return null
	return find_audio.get_stream_playback()
	
	
## Returns true if any sound is active, even if stream_paused is set to true. See also playing and get_stream_playback().
func has_stream_playback_3d(audio_name: String) -> bool:
	var find_audio: AudioStreamPlayer3D = get_audio_stream_player_3d(audio_name)
	if not find_audio: return false
	await get_tree().process_frame
	return find_audio.has_stream_playback()


## Enable loop.
func set_loop_3d(audio_name: String, value: bool) -> void:
	var find_audio: AudioStreamPlayer3D = get_audio_stream_player_3d(audio_name)
	if not find_audio: return
	_set_loop(find_audio.stream, value)
	

func has_audio_stream_player_3d(audio_name: String) -> bool:
	var find_audio: AudioStreamPlayer3D = audios_stream_players_3d.get(audio_name)
	return true if find_audio else false


func get_audio_stream_player_3d(audio_name: String) -> AudioStreamPlayer3D:
	var find_audio: AudioStreamPlayer3D = audios_stream_players_3d.get(audio_name)
	if not find_audio: push_warning("Audio (%s) not found."%audio_name)
	return find_audio


func _create_stream_player_3d(audio_3d: GodotAudioManager3D, audio_name: String) -> AudioStreamPlayer3D:
	var audio_stream_player_3d: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	audio_stream_player_3d.name = "am_3d_%s"%audio_name
	
	audio_stream_player_3d.set_meta(META_3D, true)
	audio_stream_player_3d.set_meta("name", audio_name)
	
	audio_stream_player_3d.stream = audio_3d.stream
	audio_stream_player_3d.attenuation_model = audio_3d.attenuation_model
	audio_stream_player_3d.volume_db = audio_3d.volume_db
	audio_stream_player_3d.unit_size = audio_3d.unit_size
	audio_stream_player_3d.max_db = audio_3d.max_db
	audio_stream_player_3d.pitch_scale = audio_3d.pitch_scale
	audio_stream_player_3d.playing = audio_3d.playing if audio_stream_player_3d.is_inside_tree() else false
	audio_stream_player_3d.autoplay = audio_3d.autoplay
	audio_stream_player_3d.stream_paused = audio_3d.stream_paused
	_set_loop(audio_stream_player_3d.stream, audio_3d.loop)
	audio_stream_player_3d.set_meta("pause_on_blur", audio_3d.pause_on_blur)
	audio_stream_player_3d.max_distance = audio_3d.max_distance
	audio_stream_player_3d.max_polyphony = audio_3d.max_polyphony
	audio_stream_player_3d.panning_strength = audio_3d.panning_strength
	audio_stream_player_3d.bus = audio_3d.bus
	audio_stream_player_3d.area_mask = audio_3d.area_mask
	audio_stream_player_3d.playback_type = audio_3d.playback_type
	audio_stream_player_3d.emission_angle_enabled = audio_3d.emission_angle_enabled
	audio_stream_player_3d.emission_angle_degrees = audio_3d.emission_angle_degrees
	audio_stream_player_3d.emission_angle_filter_attenuation_db = audio_3d.emission_angle_filter_attenuation_db
	audio_stream_player_3d.attenuation_filter_cutoff_hz = audio_3d.attenuation_filter_cutoff_hz
	audio_stream_player_3d.attenuation_filter_db = audio_3d.attenuation_filter_db
	audio_stream_player_3d.doppler_tracking = audio_3d.doppler_tracking
	
	var cb: Callable = Callable(_on_3d_finished).bind(audio_name)
	audio_stream_player_3d.finished.connect(cb)
	
	if parent_3d:
		parent_3d.add_child.call_deferred(audio_stream_player_3d)
		# await audio_stream_player_3d.tree_entered
	else:
		add_child.call_deferred(audio_stream_player_3d)
	
	audio_3d._init_owner(self, audio_name, audio_stream_player_3d)
	return audio_stream_player_3d


func _on_3d_finished(audio_name: String) -> void:
	if not Engine.is_editor_hint():
		finished_3d.emit(audio_name)


func _check_audios_3d(p_warnings: PackedStringArray) -> void:
	for key in audios_manager_3d:
		var audio: GodotAudioManager3D = audios_manager_3d.get(key)
		if audio:
			if key == "":
				p_warnings.append("There are 3d audio files without a defined name. Consider adding a name as a key to the 3d audio file that is missing a key.")
			
			if AudioServer.get_bus_index(audio.bus) == -1:
				p_warnings.append("The 3d audio (%s) has an invalid value for the bus property. Consider adding a valid value such as MASTER or another custom value."%key)
		else:
			p_warnings.append("There are 3d audio files created without an AudioManager3D resource. Consider adding an AudioManager3D.")
#endregion *****************************************************************************************


#region PRIVATE METHODS ****************************************************************************
func _on_web_blur(args: Array) -> void:
	if Engine.is_editor_hint(): return
	
	var has_audio_paused: bool = false
	
	for key in audios_stream_players:
		var audio: AudioStreamPlayer = audios_stream_players.get(key)
		if audio and audio.get_meta("pause_on_blur") and audio.playing:
			if audio.get_meta("pause_on_blur"):
				audio.stream_paused = true
				audio.set_meta("paused", true)
				has_audio_paused = true

	for key in audios_stream_players_2d:
		var audio: AudioStreamPlayer2D = audios_stream_players_2d.get(key)
		if audio and audio.get_meta("pause_on_blur") and audio.playing:
			if audio.get_meta("pause_on_blur"):
				audio.stream_paused = true
				audio.set_meta("paused", true)
				has_audio_paused = true

	for key in audios_stream_players_3d:
		var audio: AudioStreamPlayer3D = audios_stream_players_3d.get(key)
		if audio and audio.get_meta("pause_on_blur") and audio.playing:
			if audio.get_meta("pause_on_blur"):
				audio.stream_paused = true
				audio.set_meta("paused", true)
				has_audio_paused = true
				
				
	if has_audio_paused:
		print_rich("""
		WARNING! 
		Playback has been paused because the pause_on_blur property was set to true. 
		This message is only to remind you that nothing went wrong. 
		To test the audio without pauses, set pause_on_blur to false and, when exporting the game, set it back to true if desired.
		""".dedent())
	
	
func _on_web_focus(args: Array) -> void:
	if Engine.is_editor_hint(): return
	
	for key in audios_stream_players:
		var audio: AudioStreamPlayer = audios_stream_players.get(key)
		if audio and audio.has_meta("paused"):
			audio.remove_meta("paused")
			audio.stream_paused = false

	for key in audios_stream_players_2d:
		var audio: AudioStreamPlayer2D = audios_stream_players_2d.get(key)
		if audio and audio.has_meta("paused"):
			audio.remove_meta("paused")
			audio.stream_paused = false

	for key in audios_stream_players_3d:
		var audio: AudioStreamPlayer3D = audios_stream_players_3d.get(key)
		if audio and audio.has_meta("paused"):
			audio.remove_meta("paused")
			audio.stream_paused = false
#endregion *****************************************************************************************


#region PRIVATE METHODS - SET LOOP *****************************************************************
func _set_loop(p_stream: AudioStream, value: bool) -> void:
	if not is_instance_valid(p_stream): return
	
	if p_stream.is_class(AUDIO_STREAM_MP3_CLASS_NAME):
		_set_loop_mp3(p_stream, value)
		return
	
	if p_stream.is_class(AUDIO_STREAM_WAV_CLASS_NAME):
		_set_loop_wav(p_stream, value)
		return
	
	if p_stream.is_class(AUDIO_STREAM_OGGVORBIS_CLASS_NAME):
		_set_loop_ogg(p_stream, value)
		return
	
	if p_stream.is_class(AUDIO_STREAM_RANDOMIZER_CLASS_NAME):
		_set_loop_randomizer(p_stream, value)
		return

	if p_stream.is_class(AUDIO_STREAM_PLAYLIST_CLASS_NAME):
		_set_loop_playlist(p_stream, value)
		return
	
	if p_stream.is_class(AUDIO_STREAM_INTERACTIVE_CLASS_NAME):
		_set_loop_interactive(p_stream, value)
		return

	if p_stream.is_class(AUDIO_STREAM_SYNCHRONIZED_CLASS_NAME):
		_set_loop_synchronized(p_stream, value)
		return


func _set_loop_mp3(p_mp3: AudioStreamMP3, value: bool) -> void:
		p_mp3.loop = value
		
		
func _set_loop_ogg(p_ogg: AudioStreamOggVorbis, value: bool) -> void:
		p_ogg.loop = value

		
func _set_loop_wav(p_wav: AudioStreamWAV, value: bool) -> void:
	if value == true:
		p_wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		p_wav.loop_begin = 0
		var duracao_em_segundos = p_wav.get_length()
		var mix_rate = p_wav.mix_rate
		var total_samples = int(duracao_em_segundos * mix_rate)
		p_wav.loop_end = total_samples
	else:
		p_wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
		p_wav.loop_begin = 0
		p_wav.loop_end = -1


func _set_loop_randomizer(p_stream: AudioStreamRandomizer, value: bool) -> void:
	for i in range(p_stream.streams_count):
		_set_loop(p_stream.get_stream(i), value)
		

func _set_loop_playlist(p_stream: AudioStreamPlaylist, value: bool) -> void:
	p_stream.loop = value


func _set_loop_interactive(p_stream: AudioStreamInteractive, value: bool) -> void:
	for i in range(p_stream.clip_count):
		_set_loop(p_stream.get_clip_stream(i), value)


func _set_loop_synchronized(p_stream: AudioStreamSynchronized, value: bool) -> void:
	for i in range(p_stream.stream_count):
		_set_loop(p_stream.get_sync_stream(i), value)
#endregion *****************************************************************************************
