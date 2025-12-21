@tool
@icon("res://addons/godot_audio_manager/icons/icon_2d.svg")


## Audio resource for AudioManager that replaces Godot's native AudioStreamPlayer2D node.
class_name GodotAudioManager2D extends Resource


## The AudioStream resource to be played. 
## Setting this property stops all currently playing sounds. 
## If left empty, the AudioStreamPlayer does not work.
@export var stream: AudioStream:
	set(value):
		stream = value.duplicate(true) if value else null
		if is_instance_valid(_audio_preview):
			_audio_preview.stream = stream
		for audio in _audios_ref:
			if audio and audio.get_meta("name") == _name:
				audio.stream = stream

## Volume of sound, in decibels. This is an offset of the stream's volume.
@export_range(-80.0, 24.0, 0.1, "suffix:db") var volume_db: float = 0.0:
	set(value):
		if value < -80.0 or value > 24.0:
			push_warning("The volume_db property does not accept the value (%d). Consider assigning a value from -80.0 to 24.0."%value)
			return
		volume_db = value
		if is_instance_valid(_audio_preview):
			_audio_preview.volume_db = volume_db
		for audio in _audios_ref:
			if audio and audio.get_meta("name") == _name:
				audio.volume_db = volume_db
			
## The audio's pitch and tempo, as a multiplier of the stream's sample rate. 
## A value of 2.0 doubles the audio's pitch, while a value of 0.5 halves the pitch.
@export_range(0.01, 4.0, 0.01) var pitch_scale: float = 1.0:
	set(value):
		if value < 0.01 or value > 4.0:
			push_warning("The pitch_scale property does not accept the value (%d). Consider assigning a value from 0.01 to 4.0."%value)
			return
		pitch_scale = value
		if is_instance_valid(_audio_preview):
			_audio_preview.pitch_scale = pitch_scale
		for audio in _audios_ref:
			if audio and audio.get_meta("name") == _name:
				audio.pitch_scale = pitch_scale

## If true, this node is playing sounds. Setting this property has the same effect as play() and stop().
@export var playing: bool = false:
	set(value):
		playing = value
		if is_instance_valid(_audio_preview):
			_audio_preview.playing = playing
			
## If true, this node calls play() when entering the tree.
@export var autoplay: bool = false:
	set(value):
		autoplay = value

## If true, the sounds are paused. Setting stream_paused to false resumes all sounds.
@export var stream_paused: bool = false:
	set(value):
		stream_paused = value
		if is_instance_valid(_audio_preview):
			_audio_preview.stream_paused = stream_paused
		for audio in _audios_ref:
			if audio and audio.get_meta("name") == _name:
				audio.stream_paused = stream_paused

## Enable loop.
@export var loop: bool = false:
	set(value):
		loop = value
		if is_instance_valid(_audio_preview) and is_instance_valid(_owner):
			_owner._set_loop(stream, loop)
		if is_instance_valid(_owner):
			for audio in _audios_ref:
				if audio and audio.get_meta("name") == _name:
					_owner._set_loop(audio.stream, loop)
			
## Pause on blur.
@export var pause_on_blur: bool = false:
	set(value):
		pause_on_blur = value
		for audio in _audios_ref:
			if audio and audio.get_meta("name") == _name:
				audio.set_meta("pause_on_blur", pause_on_blur)
			
## The distance past which the sound can no longer be heard at all. 
##  Only has an effect if set to a value greater than 0.0. max_distance works in tandem with unit_size. 
## However, unlike unit_size whose behavior depends on the attenuation_model, max_distance always works in a linear fashion. 
## This can be used to prevent the AudioStreamPlayer2D from requiring audio mixing when the listener is far away, which saves CPU resources.
@export_range(0.1, 4096, 0.1, "or_greater", "suffix:m") var max_distance: float = 2000.0:
	set(value):
		if value < 0.1:
			push_warning("The max_distance property cannot be less than 0.1. Consider assigning a valid value.")
			return
		max_distance = value
		if is_instance_valid(_audio_preview):
			_audio_preview.max_distance = max_distance
		for audio in _audios_ref:
			if audio and audio.get_meta("name") == _name:
				audio.max_distance = max_distance

## The volume is attenuated over distance with this as an exponent.	
@export_exp_easing("attenuation", "positive_only") var attenuation: float = 1.0:
	set(value):
		if value < 0.0 or value > 1000000.0:
			push_warning("The attenuation property does not accept the value (%d). Consider assigning a value from 0.0 to 1000000.0."%value)
			return
		attenuation = value
		if is_instance_valid(_audio_preview):
			_audio_preview.attenuation = attenuation
		for audio in _audios_ref:
			if audio and audio.get_meta("name") == _name:
				audio.attenuation = attenuation


## The maximum number of sounds this node can play at the same time. 
## Calling play() after this value is reached will cut off the oldest sounds.
@export_range(1, 10, 1, "or_greater") var max_polyphony: int = 1:
	set(value):
		if value < 1:
			push_warning("The max_polyphony property does not accept the value (%d). Consider assigning a value greater than zero."%value)
			return
			
		if stream and stream.is_class("AudioStreamInteractive") and value > 1:
			push_warning("Audio of type Audio Stream Interactive does not accept a value greater than 1 for the max_polyphony property.")
			return
			
		if stream and stream.is_class("AudioStreamSynchronized") and value > 1:
			push_warning("Audio of type Audio Stream Synchronized does not accept a value greater than 1 for the max_polyphony property.")
			return
			
		if stream and stream.is_class("AudioStreamPlaylist") and value > 1:
			push_warning("Audio of type Audio Stream Playlist does not accept a value greater than 1 for the max_polyphony property.")
			return

		max_polyphony = value
		if is_instance_valid(_audio_preview):
			_audio_preview.max_polyphony = max_polyphony
		for audio in _audios_ref:
			if audio and audio.get_meta("name") == _name:
				audio.max_polyphony = max_polyphony

## Scales the panning strength for this node by multiplying the base Audio > General > 2D Panning Strength by this factor. 
## If the product is 0.0 then stereo panning is disabled and the volume is the same for all channels. 
## If the product is 1.0 then one of the channels will be muted when the sound is located exactly to the left (or right) of the listener.
## Two speaker stereo arrangements implement the WebAudio standard for StereoPannerNode Panning   where the volume is cosine of half the azimuth angle to the ear.
## For other speaker arrangements such as the 5.1 and 7.1 the SPCAP (Speaker-Placement Correction Amplitude) algorithm is implemented.
@export_range(0.0, 3.0, 0.01, "or_greater") var panning_strength: float = 1.0:
	set(value):
		if value < 0.0:
			push_warning("The panning_strength property cannot be negative. Consider assigning a valid value.")
			return
		panning_strength = value
		if is_instance_valid(_audio_preview):
			_audio_preview.panning_strength = panning_strength
		for audio in _audios_ref:
			if audio and audio.get_meta("name") == _name:
				audio.panning_strength = panning_strength
		
## The target bus name. All sounds from this node will be playing on this bus.
@export var bus: StringName = "Master":
	set(value):
		if AudioServer.get_bus_index(value) == -1:
			push_warning("The value (%s) for the audio bus property is not valid."%value)
		bus = value
		if is_instance_valid(_audio_preview):
			_audio_preview.bus = bus
		for audio in _audios_ref:
			if audio and audio.get_meta("name") == _name:
				audio.bus = bus
			
## Determines which Area2D layers affect the sound for reverb and audio bus effects. 
## Areas can be used to redirect AudioStreams so that they play in a certain audio bus. 
## An example of how you might use this is making a "water" area so that sounds played in the water are redirected through an audio bus to make them sound like they are being played underwater.
@export_flags_2d_physics() var area_mask: int = 1:
	set(value):
		if value < 0.0:
			push_warning("The area_mask property cannot be negative. Consider assigning a valid value.")
			return
		area_mask = value
		if is_instance_valid(_audio_preview):
			_audio_preview.area_mask = area_mask
		for audio in _audios_ref:
			if audio and audio.get_meta("name") == _name:
				audio.area_mask = area_mask

## The playback type of the stream player. 
## If set other than to the default value, it will force that playback type.
@export var playback_type: AudioServer.PlaybackType = AudioServer.PlaybackType.PLAYBACK_TYPE_DEFAULT:
	set(value):
		playback_type = value
		if is_instance_valid(_audio_preview):
			_audio_preview.playback_type = playback_type
		for audio in _audios_ref:
			if audio and audio.get_meta("name") == _name:
				audio.playback_type = playback_type


var _owner: GodotAudioManager
var _audio_preview: AudioStreamPlayer2D
static var _audios_ref: Array[AudioStreamPlayer2D]
var _name: String


# func _init() -> void:
# 	self.resource_local_to_scene = true
	
	
func _init_owner(p_owner: GodotAudioManager, p_name: String, p_audio_ref: AudioStreamPlayer2D) -> void:
	_owner = p_owner
	_name = p_name
	if not Engine.is_editor_hint():
		_audios_ref.append(p_audio_ref)

	if Engine.is_editor_hint():
		_audio_preview = AudioStreamPlayer2D.new()
		_audio_preview.stream = stream
		_audio_preview.volume_db = volume_db
		_audio_preview.pitch_scale = pitch_scale
		_audio_preview.playing = playing
		_audio_preview.autoplay = autoplay
		_audio_preview.stream_paused = stream_paused
		_owner._set_loop(stream, loop)
		_audio_preview.max_distance = max_distance
		_audio_preview.attenuation = attenuation
		_audio_preview.max_polyphony = max_polyphony
		_audio_preview.panning_strength = panning_strength
		_audio_preview.bus = bus
		_audio_preview.area_mask = area_mask
		_audio_preview.playback_type = playback_type

		_owner.add_child.call_deferred(_audio_preview)
