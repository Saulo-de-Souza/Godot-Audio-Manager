@tool
extends EditorPlugin

var icon = preload("res://addons/godot_audio_manager/icons/icon.svg")
var icon_omni = preload("res://addons/godot_audio_manager/icons/icon_omni.svg")
var icon_2d = preload("res://addons/godot_audio_manager/icons/icon_2d.svg")
var icon_3d = preload("res://addons/godot_audio_manager/icons/icon_3d.svg")

var script_audio_manager = preload("res://addons/godot_audio_manager/godot_audio_manager.gd")
var script_omni = preload("res://addons/godot_audio_manager/godot_audio_manager_omni.gd")
var script_2d = preload("res://addons/godot_audio_manager/godot_audio_manager_2d.gd")
var script_3d = preload("res://addons/godot_audio_manager/godot_audio_manager_3d.gd")


func _enable_plugin() -> void:
	add_custom_type("GodotAudioManager", "Node", script_audio_manager, icon)
	add_custom_type("GodotAudioManagerOmni", "Resource", script_omni, icon_omni)
	add_custom_type("GodotAudioManager2D", "Resource", script_2d, icon_2d)
	add_custom_type("GodotAudioManager3D", "Resource", script_3d, icon_3d)


func _disable_plugin() -> void:
	remove_custom_type("GodotAudioManager")
	remove_custom_type("GodotAudioManagerOmni")
	remove_custom_type("GodotAudioManager2D")
	remove_custom_type("GodotAudioManager3D")
