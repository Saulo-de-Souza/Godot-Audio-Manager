@tool
@icon("res://addons/godot_audio_manager/icons/icon_omni.svg")

## Audio resource for AudioManager that replaces Godot's native AudioStreamPlayer node.
class_name GodotAudioManagerOmni extends Resource


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
			
## The mix target channels. 
## Has no effect when two speakers or less are detected (see AudioServer.SpeakerMode).
@export var mix_target: AudioStreamPlayer.MixTarget = AudioStreamPlayer.MIX_TARGET_STEREO:
	set(value):
		mix_target = value
		if is_instance_valid(_audio_preview):
			_audio_preview.mix_target = mix_target
		for audio in _audios_ref:
			if audio and audio.get_meta("name") == _name:
				audio.mix_target = mix_target

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
var _audio_preview: AudioStreamPlayer
static var _audios_ref: Array[AudioStreamPlayer]
var _name: String


# func _init() -> void:
# 	self.resource_local_to_scene = true
	

func _init_owner(p_owner: GodotAudioManager, p_name: String, p_audio_ref: AudioStreamPlayer) -> void:
	_owner = p_owner
	_name = p_name
	if not Engine.is_editor_hint():
		_audios_ref.append(p_audio_ref)

	if Engine.is_editor_hint():
		_audio_preview = AudioStreamPlayer.new()
		_audio_preview.stream = stream
		_audio_preview.volume_db = volume_db
		_audio_preview.pitch_scale = pitch_scale
		_audio_preview.playing = playing
		_audio_preview.autoplay = autoplay
		_audio_preview.stream_paused = stream_paused
		_owner._set_loop(stream, loop)
		_audio_preview.mix_target = mix_target
		_audio_preview.max_polyphony = max_polyphony
		_audio_preview.bus = bus
		_audio_preview.playback_type = playback_type

		_owner.add_child.call_deferred(_audio_preview)
