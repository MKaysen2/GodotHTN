@tool
extends EditorPlugin

const domain_editor = preload('res://addons/htn_editor/DomainEditor.tscn')
var domain_ed_inst

func _enter_tree():
	# Initialization of the plugin goes here.
	domain_ed_inst = domain_editor.instantiate()
	
	EditorInterface.get_editor_main_screen().add_child(domain_ed_inst)
	_make_visible(false)

func _has_main_screen():
	return true

func _exit_tree():
	if domain_ed_inst:
		domain_ed_inst.queue_free()

func _make_visible(visible):
	if domain_ed_inst:
		domain_ed_inst.visible = visible

func _get_plugin_name():
	return "HTNEditor"

func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
