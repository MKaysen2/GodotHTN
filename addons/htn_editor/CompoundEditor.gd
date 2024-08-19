@tool
class_name CompoundEditor
extends VBoxContainer

var method_layout_scene = preload('res://addons/htn_editor/MethodLayout.tscn')

var focused_compound : CompoundBuilder
var idx := 0
signal task_name_changed(text : String, idx : int)

@export var TaskName : LineEdit
@export var methods : VBoxContainer
@export var arg_names : HBoxContainer

func open(compound : CompoundBuilder):
	focused_compound = compound
	TaskName.text = compound.task_name
	for m in focused_compound.methods:
		_add_method(m)

func _on_task_name_changed(text : String):
	focused_compound.task_name = text
	task_name_changed.emit(text, idx)

func _on_add_arg_pressed():
	var line = LineEdit.new()
	focused_compound.arg_names.push_back('')
	arg_names.add_child(line)
	line.text_changed.connect(_on_arg_name_changed.bind(arg_names.get_child_count() -1))

func _on_del_arg_pressed():
	if focused_compound.arg_names.is_empty():
		return
	focused_compound.arg_names.pop_back()
	var line = arg_names.get_children().back()
	arg_names.remove_child(line)

func _on_arg_name_changed(text : String, i : int):
	focused_compound.arg_names[i] = text

func _on_method_added():
	var m = MethodBuilder.new()
	focused_compound.methods.push_back(m)
	_add_method(m)

func _add_method(m : MethodBuilder):
	var method_view : MethodLayout = method_layout_scene.instantiate()
	methods.add_child(method_view)
	#method_view.ready.connect(_on_child_ready.bind(method_view, m))
	method_view.idx = methods.get_child_count() - 1
	method_view.open(m)
	method_view.move_up.connect(_on_method_move_up)
	method_view.move_down.connect(_on_method_move_down)
	method_view.delete.connect(_on_method_delete)

func refresh_method_idxs():
	var children = methods.get_children()
	for i in children.size():
		children[i].idx = i

func _on_method_delete(i : int):
	focused_compound.methods.remove_at(i)
	var step_view = methods.get_child(i)
	methods.remove_child(step_view)
	step_view.queue_free()
	refresh_method_idxs()

func _on_method_move_up(i : int):
	if i == 0:
		return
	var child = methods.get_child(i)
	methods.move_child(child, i - 1)
	focused_compound.move_method_up(i)
	refresh_method_idxs()

func _on_method_move_down(i : int):
	if i == methods.get_child_count() - 1:
		return
	var child = methods.get_child(i)
	methods.move_child(child, i + 1)
	focused_compound.move_method_down(i)
	refresh_method_idxs()
