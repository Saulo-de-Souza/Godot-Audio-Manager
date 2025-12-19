@tool
@icon("res://addons/godot_audio_manager/icons/icon_2d.svg")


## Audio resource for AudioManager that replaces Godot's native AudioStreamPlayer2D node.
class_name GodotAudioManager2D extends Resource


## The AudioStream resource to be played. 
## Setting this property stops all currently playing sounds. 
## If left empty, the AudioStreamPlayer does not work.
@export var stream: AudioStream:
	set(value):
		stream = value
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.stream = stream
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## Volume of sound, in decibels. This is an offset of the stream's volume.
@export_range(-80.0, 24.0, 0.1, "suffix:db") var volume_db: float = 0.0:
	set(value):
		if value < -80.0 or value > 24.0:
			push_warning("The volume_db property does not accept the value (%d). Consider assigning a value from -80.0 to 24.0.(%s)" % [value, get_audio_name()])
			return

		volume_db = value
		
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.volume_db = volume_db
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
			
## The audio's pitch and tempo, as a multiplier of the stream's sample rate. 
## A value of 2.0 doubles the audio's pitch, while a value of 0.5 halves the pitch.
@export_range(0.01, 4.0, 0.01) var pitch_scale: float = 1.0:
	set(value):
		if value < 0.01 or value > 4.0:
			push_warning("The pitch_scale property does not accept the value (%d). Consider assigning a value from 0.01 to 4.0. (%s)" % [value, get_audio_name()])
			return
			
		pitch_scale = value
		
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.pitch_scale = pitch_scale
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## If true, this node is playing sounds. Setting this property has the same effect as play() and stop().
@export var playing: bool = false:
	set(value):
		playing = value
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.playing = playing
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
			
## If true, this node calls play() when entering the tree.
@export var autoplay: bool = false:
	set(value):
		autoplay = value
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.autoplay = autoplay
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## If true, the sounds are paused. Setting stream_paused to false resumes all sounds.
@export var stream_paused: bool = false:
	set(value):
		stream_paused = value
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.stream_paused = stream_paused
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## Enable loop.
@export var loop: bool = false:
	set(value):
		loop = value
		if is_instance_valid(_audio_stream_player):
			_set_loop(stream, loop)
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
			
## Pause on blur.
@export var pause_on_blur: bool = false:
	set(value):
		pause_on_blur = value
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.set_meta("pause_on_blur", pause_on_blur)
			if _audio_stream_player.is_inside_tree():
				for child in _audio_stream_player.get_parent().get_children():
					if child.has_meta("name") and child.has_meta(META_2D) and child.get_meta("name") == get_audio_name():
						child.set_meta("pause_on_blur", pause_on_blur)
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
			
## The distance past which the sound can no longer be heard at all. 
##  Only has an effect if set to a value greater than 0.0. max_distance works in tandem with unit_size. 
## However, unlike unit_size whose behavior depends on the attenuation_model, max_distance always works in a linear fashion. 
## This can be used to prevent the AudioStreamPlayer2D from requiring audio mixing when the listener is far away, which saves CPU resources.
@export_range(0.1, 4096, 0.1, "or_greater", "suffix:m") var max_distance: float = 2000.0:
	set(value):
		if value < 0.1:
			push_warning("The max_distance property cannot be less than 0.1. Consider assigning a valid value. (%s)" % [get_audio_name()])
			return
			
		max_distance = value
		
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.max_distance = max_distance
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## The volume is attenuated over distance with this as an exponent.	
@export_exp_easing("attenuation", "positive_only") var attenuation: float = 1.0:
	set(value):
		if value < 0.0 or value > 1000000.0:
			push_warning("The attenuation property does not accept the value (%d). Consider assigning a value from 0.0 to 1000000.0. (%s)" % [value, get_audio_name()])
			return
			
		attenuation = value
		
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.attenuation = attenuation
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()


## The maximum number of sounds this node can play at the same time. 
## Calling play() after this value is reached will cut off the oldest sounds.
@export_range(1, 10, 1, "or_greater") var max_polyphony: int = 1:
	set(value):
		if value < 1:
			push_warning("The max_polyphony property does not accept the value (%d). Consider assigning a value greater than zero. (%s)"%get_audio_name())
			return
			
		if stream and stream.is_class("AudioStreamInteractive") and value > 1:
			push_warning("Audio of type Audio Stream Interactive does not accept a value greater than 1 for the max_polyphony property. (%s)"%get_audio_name())
			return
			
		if stream and stream.is_class("AudioStreamSynchronized") and value > 1:
			push_warning("Audio of type Audio Stream Synchronized does not accept a value greater than 1 for the max_polyphony property. (%s)"%get_audio_name())
			return
			
		if stream and stream.is_class("AudioStreamPlaylist") and value > 1:
			push_warning("Audio of type Audio Stream Playlist does not accept a value greater than 1 for the max_polyphony property. (%s)"%get_audio_name())
			return
			
		max_polyphony = value
		
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.max_polyphony = max_polyphony
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## Scales the panning strength for this node by multiplying the base Audio > General > 2D Panning Strength by this factor. 
## If the product is 0.0 then stereo panning is disabled and the volume is the same for all channels. 
## If the product is 1.0 then one of the channels will be muted when the sound is located exactly to the left (or right) of the listener.
## Two speaker stereo arrangements implement the WebAudio standard for StereoPannerNode Panning   where the volume is cosine of half the azimuth angle to the ear.
## For other speaker arrangements such as the 5.1 and 7.1 the SPCAP (Speaker-Placement Correction Amplitude) algorithm is implemented.
@export_range(0.0, 3.0, 0.01, "or_greater") var panning_strength: float = 1.0:
	set(value):
		if value < 0.0:
			push_warning("The panning_strength property cannot be negative. Consider assigning a valid value. (%s)" % [get_audio_name()])
			return
			
		panning_strength = value
		
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.panning_strength = panning_strength
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
		
## The target bus name. All sounds from this node will be playing on this bus.
@export var bus: StringName = "Master":
	set(value):
		if AudioServer.get_bus_index(value) == -1:
			push_warning("The value (%s) for the audio bus property (%s) is not valid." % [value, get_audio_name()])
			
		bus = value
		
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.bus = bus
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
			
## Determines which Area2D layers affect the sound for reverb and audio bus effects. 
## Areas can be used to redirect AudioStreams so that they play in a certain audio bus. 
## An example of how you might use this is making a "water" area so that sounds played in the water are redirected through an audio bus to make them sound like they are being played underwater.
@export_flags_2d_physics() var area_mask: int = 1:
	set(value):
		if value < 0.0:
			push_warning("The area_mask property cannot be negative. Consider assigning a valid value. (%s)" % [get_audio_name()])
			return
			
		area_mask = value
		
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.area_mask = area_mask
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()

## The playback type of the stream player. 
## If set other than to the default value, it will force that playback type.
@export var playback_type: AudioServer.PlaybackType = AudioServer.PlaybackType.PLAYBACK_TYPE_DEFAULT:
	set(value):
		playback_type = value
		if is_instance_valid(_audio_stream_player):
			_audio_stream_player.playback_type = playback_type
		if is_instance_valid(_owner):
			_owner.update_configuration_warnings()
			

#region CONSTANTS **********************************************************************************
const META_2D: String = "am_2d"
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


const PREFIX_NAME: String = "_2d"
var _owner: GodotAudioManager
var _audio_stream_player: AudioStreamPlayer2D
var _audio_name: String


func _init_owner(p_owner: GodotAudioManager, p_name: String, p_parent: Node2D) -> void:
	_owner = p_owner
	_audio_name = p_name
	
	_audio_stream_player = AudioStreamPlayer2D.new()
	_audio_stream_player.stream = stream
	_audio_stream_player.attenuation = attenuation
	_audio_stream_player.volume_db = volume_db
	_audio_stream_player.pitch_scale = pitch_scale
	_audio_stream_player.playing = playing if _audio_stream_player.is_inside_tree() else false
	_audio_stream_player.autoplay = autoplay
	_audio_stream_player.stream_paused = stream_paused
	_audio_stream_player.max_distance = max_distance
	_audio_stream_player.max_polyphony = max_polyphony
	_audio_stream_player.panning_strength = panning_strength
	_audio_stream_player.bus = bus
	_audio_stream_player.area_mask = area_mask
	_audio_stream_player.playback_type = playback_type

	_audio_stream_player.name = get_audio_name(true)
	_audio_stream_player.set_meta(META_2D, true)
	_audio_stream_player.set_meta("pause_on_blur", pause_on_blur)
	_audio_stream_player.set_meta("name", get_audio_name())
	_set_loop(stream, loop)
	
	if p_parent:
		p_parent.add_child(_audio_stream_player)
	else:
		_owner.add_child(_audio_stream_player)
	_audio_stream_player.finished.connect(_on_audio_stream_player_finished)
	
	
func _change_parent(p_parent: Node2D) -> void:
	if p_parent:
		if get_audio() and get_audio().get_parent() and get_audio().get_parent() != p_parent:
			get_audio().reparent(p_parent)
	else:
		if get_audio() and get_audio().get_parent() and get_audio().get_parent() != _owner:
			get_audio().reparent(_owner)
	
	
## Get audio name.
func get_audio_name(with_prefix: bool = false) -> String:
	return _audio_name if not with_prefix else _audio_name + PREFIX_NAME
	

## Get AudioStreamPlayer2D.
func get_audio() -> AudioStreamPlayer2D:
	return _audio_stream_player
	
	
func _on_audio_stream_player_finished() -> void:
	if not Engine.is_editor_hint() and is_instance_valid(_owner):
		_owner.finished_2d.emit(get_audio_name())


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
