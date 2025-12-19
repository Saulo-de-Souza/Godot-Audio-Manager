@tool
@icon("res://addons/godot_audio_manager/icons/icon.svg")


## Manage all audio files such as AudioStreamPlayer, AudioStreamPlayer2D, and AudioStreamPlayer3D 
## directly from a single node, and enjoy extra features like the ability to loop all audio types 
## and enable audio pauses when the window is out of focus or when switching tabs in the web browser.
class_name GodotAudioManager extends Node


#region EXPORTS ************************************************************************************
@export_subgroup("Audios Omni")
## These are the audio files that represent the AudioStreamPlayer (one-way audio).
@export var audios_omni: Dictionary[String, GodotAudioManagerOmni]:
	set(value):
		audios_omni = value
		if not is_node_ready(): return
		for key in audios_omni:
			var audio_omni: GodotAudioManagerOmni = audios_omni.get(key)
			if audio_omni:
				audio_omni._init_owner(self, key)
		update_configuration_warnings()

@export_subgroup("Audios 2D")
## This is the node where the 2D audio files will be inserted. 
## If you don't assign anything, the audio files will be created within the GodotAudioManager node.
@export var parent_2d: Node2D:
	set(value):
		parent_2d = value
		if not is_node_ready(): return
		for key in audios_2d:
			var audio_2d: GodotAudioManager2D = audios_2d.get(key)
			if audio_2d:
				audio_2d._change_parent(parent_2d)
		update_configuration_warnings()

## These are the audio files that represent AudioStreamPlayer2D.
@export var audios_2d: Dictionary[String, GodotAudioManager2D]:
	set(value):
		audios_2d = value
		if not is_node_ready(): return
		for key in audios_2d:
			var audio_2d: GodotAudioManager2D = audios_2d.get(key)
			if audio_2d:
				audio_2d._init_owner(self, key, parent_2d)
		update_configuration_warnings()

@export_subgroup("Audios 3D")
## This is the node where the 3D audio files will be inserted. 
## If you don't assign anything, the audio files will be created within the GodotAudioManager node.
@export var parent_3d: Node3D:
	set(value):
		parent_3d = value
		if not is_node_ready(): return
		for key in audios_3d:
			var audio_3d: GodotAudioManager3D = audios_3d.get(key)
			if audio_3d:
				audio_3d._change_parent(parent_3d)
		update_configuration_warnings()

## These are the audio files that represent AudioStreamPlayer3D.
@export var audios_3d: Dictionary[String, GodotAudioManager3D]:
	set(value):
		audios_3d = value
		if not is_node_ready(): return
		for key in audios_3d:
			var audio_3d: GodotAudioManager3D = audios_3d.get(key)
			if audio_3d:
				audio_3d._init_owner(self, key, parent_3d)
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


#region ENGINE METHODS *****************************************************************************
func _ready() -> void:
	for key in audios_omni:
		var audio_omni: GodotAudioManagerOmni = audios_omni.get(key)
		if audio_omni:
			audio_omni._init_owner(self, key)
			
	for key in audios_2d:
		var audio_2d: GodotAudioManager2D = audios_2d.get(key)
		if audio_2d:
			audio_2d._init_owner(self, key, parent_2d)

	for key in audios_3d:
		var audio_3d: GodotAudioManager3D = audios_3d.get(key)
		if audio_3d:
			audio_3d._init_owner(self, key, parent_3d)

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
	var find_audio: GodotAudioManagerOmni = audios_omni.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().play(from_position)


## Stops all sounds from this node.
func stop_omni(audio_name: String) -> void:
	var find_audio: GodotAudioManagerOmni = audios_omni.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().stop()
	
	
## The sounds are paused.
func pause_omni(audio_name: String) -> void:
	var find_audio: GodotAudioManagerOmni = audios_omni.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().stream_paused = true
	
	
## Resumes paused sounds.
func unpause_omni(audio_name: String) -> void:
	var find_audio: GodotAudioManagerOmni = audios_omni.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().stream_paused = false
	
	
## Check if the sound is playing.
func is_playing_omni(audio_name: String) -> bool:
	var find_audio: GodotAudioManagerOmni = audios_omni.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return false
	return find_audio.get_audio().playing
	

## Check if the sound is paused.
func is_paused_omni(audio_name: String) -> bool:
	var find_audio: GodotAudioManagerOmni = audios_omni.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return false
	return find_audio.get_audio().stream_paused
	

## Restarts all sounds to be played from the given to_position, in seconds. Does nothing if no sounds are playing.
func seek_omni(audio_name: String, position: float) -> void:
	var find_audio: GodotAudioManagerOmni = audios_omni.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().seek(position)
	

## Returns the position in the AudioStream of the latest sound, in seconds. Returns 0.0 if no sounds are playing.
func get_playback_position_omni(audio_name: String) -> float:
	var find_audio: GodotAudioManagerOmni = audios_omni.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return 0.0
	return find_audio.get_audio().get_playback_position()
	

## Returns the latest AudioStreamPlayback of this node, usually the most recently created by play(). 
## If no sounds are playing, this method fails and returns an empty playback.
func get_stream_playback_omni(audio_name: String) -> AudioStreamPlayback:
	var find_audio: GodotAudioManagerOmni = audios_omni.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return null
	return find_audio.get_audio().get_stream_playback()
	
	
## Returns true if any sound is active, even if stream_paused is set to true. See also playing and get_stream_playback().
func has_stream_playback_omni(audio_name: String) -> bool:
	var find_audio: GodotAudioManagerOmni = audios_omni.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return false
	return find_audio.get_audio().has_stream_playback()


## Get omni audio.
func get_audio_omni(audio_name: String) -> GodotAudioManagerOmni:
	var find_audio: GodotAudioManagerOmni = audios_omni.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
	return find_audio


## Enable loop.
func set_loop_omni(audio_name: String, value: bool) -> void:
	var find_audio: GodotAudioManagerOmni = audios_omni.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio._set_loop(find_audio.stream, value)
	
	
func _check_audios_omni(p_warnings: PackedStringArray) -> void:
	for key in audios_omni:
		var audio: GodotAudioManagerOmni = audios_omni.get(key)
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
	var find_audio: GodotAudioManager2D = audios_2d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().play(from_position)


## Stops all sounds from this node.
func stop_2d(audio_name: String) -> void:
	var find_audio: GodotAudioManager2D = audios_2d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().stop()
	
	
## The sounds are paused.
func pause_2d(audio_name: String) -> void:
	var find_audio: GodotAudioManager2D = audios_2d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().stream_paused = true
	
	
## Resumes paused sounds.
func unpause_2d(audio_name: String) -> void:
	var find_audio: GodotAudioManager2D = audios_2d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().stream_paused = false
	
	
## Check if the sound is playing.
func is_playing_2d(audio_name: String) -> bool:
	var find_audio: GodotAudioManager2D = audios_2d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return false
	return find_audio.get_audio().playing
	

## Check if the sound is paused.
func is_paused_2d(audio_name: String) -> bool:
	var find_audio: GodotAudioManager2D = audios_2d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return false
	return find_audio.get_audio().stream_paused
	

## Restarts all sounds to be played from the given to_position, in seconds. Does nothing if no sounds are playing.
func seek_2d(audio_name: String, position: float) -> void:
	var find_audio: GodotAudioManager2D = audios_2d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().seek(position)
	

## Returns the position in the AudioStream of the latest sound, in seconds. Returns 0.0 if no sounds are playing.
func get_playback_position_2d(audio_name: String) -> float:
	var find_audio: GodotAudioManager2D = audios_2d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return 0.0
	return find_audio.get_audio().get_playback_position()
	

## Returns the latest AudioStreamPlayback of this node, usually the most recently created by play(). 
## If no sounds are playing, this method fails and returns an empty playback.
func get_stream_playback_2d(audio_name: String) -> AudioStreamPlayback:
	var find_audio: GodotAudioManager2D = audios_2d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return null
	return find_audio.get_audio().get_stream_playback()
	
	
## Returns true if any sound is active, even if stream_paused is set to true. See also playing and get_stream_playback().
func has_stream_playback_2d(audio_name: String) -> bool:
	var find_audio: GodotAudioManager2D = audios_2d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return false
	return find_audio.get_audio().has_stream_playback()


## Get 2d audio.
func get_audio_2d(audio_name: String) -> GodotAudioManager2D:
	var find_audio: GodotAudioManager2D = audios_2d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
	return find_audio


## Enable loop.
func set_loop_2d(audio_name: String, value: bool) -> void:
	var find_audio: GodotAudioManager2D = audios_2d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio._set_loop(find_audio.stream, value)
	

func _check_audios_2d(p_warnings: PackedStringArray) -> void:
	for key in audios_2d:
		var audio: GodotAudioManager2D = audios_2d.get(key)
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
	var find_audio: GodotAudioManager3D = audios_3d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().play(from_position)


## Stops all sounds from this node.
func stop_3d(audio_name: String) -> void:
	var find_audio: GodotAudioManager3D = audios_3d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().stop()
	
	
## The sounds are paused.
func pause_3d(audio_name: String) -> void:
	var find_audio: GodotAudioManager3D = audios_3d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().stream_paused = true
	
	
## Resumes paused sounds.
func unpause_3d(audio_name: String) -> void:
	var find_audio: GodotAudioManager3D = audios_3d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().stream_paused = false
	
	
## Check if the sound is playing.
func is_playing_3d(audio_name: String) -> bool:
	var find_audio: GodotAudioManager3D = audios_3d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return false
	return find_audio.get_audio().playing
	

## Check if the sound is paused.
func is_paused_3d(audio_name: String) -> bool:
	var find_audio: GodotAudioManager3D = audios_3d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return false
	return find_audio.get_audio().stream_paused
	

## Restarts all sounds to be played from the given to_position, in seconds. Does nothing if no sounds are playing.
func seek_3d(audio_name: String, position: float) -> void:
	var find_audio: GodotAudioManager3D = audios_3d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio.get_audio().seek(position)
	

## Returns the position in the AudioStream of the latest sound, in seconds. Returns 0.0 if no sounds are playing.
func get_playback_position_3d(audio_name: String) -> float:
	var find_audio: GodotAudioManager3D = audios_3d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return 0.0
	return find_audio.get_audio().get_playback_position()
	

## Returns the latest AudioStreamPlayback of this node, usually the most recently created by play(). 
## If no sounds are playing, this method fails and returns an empty playback.
func get_stream_playback_3d(audio_name: String) -> AudioStreamPlayback:
	var find_audio: GodotAudioManager3D = audios_3d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return null
	return find_audio.get_audio().get_stream_playback()
	
	
## Returns true if any sound is active, even if stream_paused is set to true. See also playing and get_stream_playback().
func has_stream_playback_3d(audio_name: String) -> bool:
	var find_audio: GodotAudioManager3D = audios_3d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return false
	return find_audio.get_audio().has_stream_playback()


## Get 3d audio.
func get_audio_3d(audio_name: String) -> GodotAudioManager3D:
	var find_audio: GodotAudioManager3D = audios_3d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
	return find_audio


## Enable loop.
func set_loop_3d(audio_name: String, value: bool) -> void:
	var find_audio: GodotAudioManager3D = audios_3d.get(audio_name)
	if not find_audio:
		push_warning("Audio (%s) was not found. Check the spelling and verify that the audio with the name actually exists."%audio_name)
		return
	find_audio._set_loop(find_audio.stream, value)
	

func _check_audios_3d(p_warnings: PackedStringArray) -> void:
	for key in audios_3d:
		var audio: GodotAudioManager3D = audios_3d.get(key)
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
	var has_audio_paused: bool = false
	
	for key in audios_omni:
		var audio: GodotAudioManagerOmni = audios_omni.get(key)
		if audio and audio.pause_on_blur and audio.get_audio():
			if audio.get_audio().playing:
				has_audio_paused = true
				audio.get_audio().set_meta("paused_on_blur", true)
				audio.get_audio().stream_paused = true
	
	for key in audios_2d:
		var audio: GodotAudioManager2D = audios_2d.get(key)
		if audio and audio.pause_on_blur and audio.get_audio():
			if audio.get_audio().playing:
				has_audio_paused = true
				audio.get_audio().set_meta("paused_on_blur", true)
				audio.get_audio().stream_paused = true
	
	for key in audios_3d:
		var audio: GodotAudioManager3D = audios_3d.get(key)
		if audio and audio.pause_on_blur and audio.get_audio():
			if audio.get_audio().playing:
				has_audio_paused = true
				audio.get_audio().set_meta("paused_on_blur", true)
				audio.get_audio().stream_paused = true
				
	if has_audio_paused:
		print_rich("""
		WARNING! 
		Playback has been paused because the pause_on_blur property was set to true. 
		This message is only to remind you that nothing went wrong. 
		To test the audio without pauses, set pause_on_blur to false and, when exporting the game, set it back to true if desired.
		""".dedent())
	
	
func _on_web_focus(args: Array) -> void:
	for key in audios_omni:
		var audio: GodotAudioManagerOmni = audios_omni.get(key)
		if audio and audio.get_audio() and audio.get_audio().has_meta("paused_on_blur"):
			audio.get_audio().set_meta("paused_on_blur", false)
			audio.get_audio().stream_paused = false
			
	for key in audios_2d:
		var audio: GodotAudioManager2D = audios_2d.get(key)
		if audio and audio.get_audio() and audio.get_audio().has_meta("paused_on_blur"):
			audio.get_audio().set_meta("paused_on_blur", false)
			audio.get_audio().stream_paused = false
			
	for key in audios_3d:
		var audio: GodotAudioManager3D = audios_3d.get(key)
		if audio and audio.get_audio() and audio.get_audio().has_meta("paused_on_blur"):
			audio.get_audio().set_meta("paused_on_blur", false)
			audio.get_audio().stream_paused = false
#endregion *****************************************************************************************
