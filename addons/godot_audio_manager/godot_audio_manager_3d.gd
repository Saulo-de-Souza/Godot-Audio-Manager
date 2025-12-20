@tool
@icon("res://addons/godot_audio_manager/icons/icon_3d.svg")


## Audio resource for AudioManager that replaces Godot's native AudioStreamPlayer3D node.
class_name GodotAudioManager3D extends Resource


## The AudioStream resource to be played. 
## Setting this property stops all currently playing sounds. 
## If left empty, the AudioStreamPlayer does not work.
@export var stream: AudioStream:
	set(value):
		stream = value.duplicate(true) if value else null
		if is_instance_valid(_audio_preview):
			_audio_preview.stream = stream
		for audio in _audios_ref:
			if audio:
				audio.stream = stream

## Decides if audio should get quieter with distance linearly, quadratically, logarithmically, or not be affected by distance, effectively disabling attenuation.
@export var attenuation_model: AudioStreamPlayer3D.AttenuationModel = AudioStreamPlayer3D.AttenuationModel.ATTENUATION_INVERSE_DISTANCE:
	set(value):
		attenuation_model = value
		if is_instance_valid(_audio_preview):
			_audio_preview.attenuation_model = attenuation_model
		for audio in _audios_ref:
			if audio:
				audio.attenuation_model = attenuation_model

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
			if audio:
				audio.volume_db = volume_db

## The factor for the attenuation effect. Higher values make the sound audible over a larger distance.
@export_range(0.1, 100, 0.1, "or_greater") var unit_size: float = 10.0:
	set(value):
		if value < 0.1:
			push_warning("The unit_size property cannot be less than 0.1. Consider assigning a valid value.")
			return
		unit_size = value
		if is_instance_valid(_audio_preview):
			_audio_preview.unit_size = unit_size
		for audio in _audios_ref:
			if audio:
				audio.unit_size = unit_size

## Sets the absolute maximum of the sound level, in decibels.
@export_range(-24.0, 6.0, 0.1, "suffix:db") var max_db: float = 3.0:
	set(value):
		if value < -24.0 or value > 6.0:
			push_warning("The max_db property cannot be less than -24.0 or greater than 6.0. Consider assigning a valid value.")
			return
		max_db = value
		if is_instance_valid(_audio_preview):
			_audio_preview.max_db = max_db
		for audio in _audios_ref:
			if audio:
				audio.max_db = max_db
			
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
			if audio:
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
			if audio:
				audio.stream_paused = stream_paused

## Enable loop.
@export var loop: bool = false:
	set(value):
		loop = value
		if is_instance_valid(_audio_preview) and is_instance_valid(_owner):
			_owner._set_loop(stream, loop)
		if is_instance_valid(_owner):
			for audio in _audios_ref:
				if audio:
					_owner._set_loop(audio.stream, loop)
			
## Pause on blur.
@export var pause_on_blur: bool = false:
	set(value):
		pause_on_blur = value
		for audio in _audios_ref:
			if audio:
				audio.set_meta("pause_on_blur", pause_on_blur)
			
## The distance past which the sound can no longer be heard at all. 
##  Only has an effect if set to a value greater than 0.0. max_distance works in tandem with unit_size. 
## However, unlike unit_size whose behavior depends on the attenuation_model, max_distance always works in a linear fashion. 
## This can be used to prevent the AudioStreamPlayer3D from requiring audio mixing when the listener is far away, which saves CPU resources.
@export_range(0.1, 4096, 0.1, "or_greater", "suffix:m") var max_distance: float = 2000.0:
	set(value):
		if value < 0.1:
			push_warning("The max_distance property cannot be less than 0.1. Consider assigning a valid value.")
			return
		max_distance = value
		if is_instance_valid(_audio_preview):
			_audio_preview.max_distance = max_distance
		for audio in _audios_ref:
			if audio:
				audio.max_distance = max_distance
			
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
			if audio:
				audio.max_polyphony = max_polyphony

## Scales the panning strength for this node by multiplying the base Audio > General > 3D Panning Strength by this factor. 
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
			if audio:
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
			if audio:
				audio.bus = bus
			
## Determines which Area3D layers affect the sound for reverb and audio bus effects. 
## Areas can be used to redirect AudioStreams so that they play in a certain audio bus. 
## An example of how you might use this is making a "water" area so that sounds played in the water are redirected through an audio bus to make them sound like they are being played underwater.
@export_flags_3d_physics() var area_mask: int = 1:
	set(value):
		if value < 0.0:
			push_warning("The area_mask property cannot be negative. Consider assigning a valid value.")
			return
		area_mask = value
		if is_instance_valid(_audio_preview):
			_audio_preview.area_mask = area_mask
		for audio in _audios_ref:
			if audio:
				audio.area_mask = area_mask

## The playback type of the stream player. 
## If set other than to the default value, it will force that playback type.
@export var playback_type: AudioServer.PlaybackType = AudioServer.PlaybackType.PLAYBACK_TYPE_DEFAULT:
	set(value):
		playback_type = value
		if is_instance_valid(_audio_preview):
			_audio_preview.playback_type = playback_type
		for audio in _audios_ref:
			if audio:
				audio.playback_type = playback_type

## If true, the audio should be attenuated according to the direction of the sound.
@export var emission_angle_enabled: bool = false:
	set(value):
		emission_angle_enabled = value
		if is_instance_valid(_audio_preview):
			_audio_preview.emission_angle_enabled = emission_angle_enabled
		for audio in _audios_ref:
			if audio:
				audio.emission_angle_enabled = emission_angle_enabled

## The angle in which the audio reaches a listener unattenuated.
@export_range(0.1, 90.0, 0.01, "suffix:°") var emission_angle_degrees: float = 45.0:
	set(value):
		if value < 0.1 or value > 90.0:
			push_warning("The emission_angle_degrees property cannot be less than 0.1 or greater than 90.0. Consider assigning a valid value.")
			return
		emission_angle_degrees = value
		if is_instance_valid(_audio_preview):
			_audio_preview.emission_angle_degrees = emission_angle_degrees
		for audio in _audios_ref:
			if audio:
				audio.emission_angle_degrees = emission_angle_degrees

## Attenuation factor used if listener is outside of emission_angle_degrees and emission_angle_enabled is set, in decibels.
@export_range(-80.0, 0.0, 0.01, "suffix:db") var emission_angle_filter_attenuation_db: float = -12.0:
	set(value):
		if value > 0.0:
			push_warning("The emission_angle_filter_attenuation_db property cannot be greater than zero. Consider assigning a valid value.")
			return
		emission_angle_filter_attenuation_db = value
		if is_instance_valid(_audio_preview):
			_audio_preview.emission_angle_filter_attenuation_db = emission_angle_filter_attenuation_db
		for audio in _audios_ref:
			if audio:
				audio.emission_angle_filter_attenuation_db = emission_angle_filter_attenuation_db
			
## The cutoff frequency of the attenuation low-pass filter, in Hz. A sound above this frequency is attenuated more than a sound below this frequency. 
## To disable this effect, set this to 20500 as this frequency is above the human hearing limit.
@export_range(1, 20500, 1, "prefer_slider", "suffix:hz") var attenuation_filter_cutoff_hz: int = 5000:
	set(value):
		if value < 1 or value > 20500:
			push_warning("The attenuation_filter_cutoff_hz property cannot be less than 1 or greater than 20500. Consider assigning a valid value.")
			return
		attenuation_filter_cutoff_hz = value
		if is_instance_valid(_audio_preview):
			_audio_preview.attenuation_filter_cutoff_hz = attenuation_filter_cutoff_hz
		for audio in _audios_ref:
			if audio:
				audio.attenuation_filter_cutoff_hz = attenuation_filter_cutoff_hz
		
## Amount how much the filter affects the loudness, in decibels.	
@export_range(-80.0, 0.0, 0.1, "suffix:db") var attenuation_filter_db: float = -24.0:
	set(value):
		if value < -80.0 or value > 0.0:
			push_warning("The attenuation_filter_db property cannot be less than -80.0 or greater than 0.0. Consider assigning a valid value.")
			return
		attenuation_filter_db = value
		if is_instance_valid(_audio_preview):
			_audio_preview.attenuation_filter_db = attenuation_filter_db
		for audio in _audios_ref:
			if audio:
				audio.attenuation_filter_db = attenuation_filter_db
			
## Decides in which step the Doppler effect should be calculated.
@export var doppler_tracking: AudioStreamPlayer3D.DopplerTracking = AudioStreamPlayer3D.DopplerTracking.DOPPLER_TRACKING_DISABLED:
	set(value):
		doppler_tracking = value
		if is_instance_valid(_audio_preview):
			_audio_preview.doppler_tracking = doppler_tracking
		for audio in _audios_ref:
			if audio:
				audio.doppler_tracking = doppler_tracking


var _owner: GodotAudioManager
var _audio_preview: AudioStreamPlayer3D
static var _audios_ref: Array[AudioStreamPlayer3D]
var _name: String


# func _init() -> void:
# 	self.resource_local_to_scene = true


func _init_owner(p_owner: GodotAudioManager, p_name: String, p_audio_ref: AudioStreamPlayer3D) -> void:
	_owner = p_owner
	_name = p_name
	if not Engine.is_editor_hint():
		_audios_ref.append(p_audio_ref)
	
	if Engine.is_editor_hint():
		_audio_preview = AudioStreamPlayer3D.new()
		_audio_preview.stream = stream
		_audio_preview.attenuation_model = attenuation_model
		_audio_preview.volume_db = volume_db
		_audio_preview.unit_size = unit_size
		_audio_preview.max_db = max_db
		_audio_preview.pitch_scale = pitch_scale
		_audio_preview.playing = playing if _audio_preview.is_inside_tree() else false
		_audio_preview.autoplay = autoplay
		_audio_preview.stream_paused = stream_paused
		_owner._set_loop(stream, loop)
		_audio_preview.max_distance = max_distance
		_audio_preview.max_polyphony = max_polyphony
		_audio_preview.panning_strength = panning_strength
		_audio_preview.bus = bus
		_audio_preview.area_mask = area_mask
		_audio_preview.playback_type = playback_type
		_audio_preview.emission_angle_enabled = emission_angle_enabled
		_audio_preview.emission_angle_degrees = emission_angle_degrees
		_audio_preview.emission_angle_filter_attenuation_db = emission_angle_filter_attenuation_db
		_audio_preview.attenuation_filter_cutoff_hz = attenuation_filter_cutoff_hz
		_audio_preview.attenuation_filter_db = attenuation_filter_db
		_audio_preview.doppler_tracking = doppler_tracking
		
		_owner.add_child(_audio_preview)
