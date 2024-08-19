@tool
class_name PrimitiveEditor
extends VBoxContainer

@onready var pre = $Margin/VBoxContainer/Precondition
@onready var del_list = $Margin/VBoxContainer/Margin/HBoxContainer/DeleteList
@onready var add_list = $Margin/VBoxContainer/Margin2/VBoxContainer/AddList
@onready var params = $Margin/VBoxContainer/Params
@export var arg_names : HBoxContainer

var effect_scene := preload('res://addons/htn_editor/EffectLayout.tscn')
var param_scene := preload('res://addons/htn_editor/ParamLayout.tscn')
var primitive : PrimitiveBuilder

var idx := 0
signal task_name_changed(text : String, index : int)

func open(p : PrimitiveBuilder):
	primitive = p
	pre.text = p.precondition
	$Path.text = p.script_path
	$HBoxContainer/TaskName.text = p.task_name
	var script = load(p.script_path)
	for a in primitive.arg_names:
		_add_arg(a)
	for k in p.del_list:
		_add_del_key(k)
	for e in p.add_list:
		_add_effect(e)
	for prop in script.new().get_property_list():
		if prop.name.begins_with('param_'):
			_add_param(prop.name, p.params.get(prop.name, ""))

func _on_add_arg_pressed():
	primitive.arg_names.push_back('')
	_add_arg('')

func _add_arg(_name):
	var line = LineEdit.new()
	line.text = _name
	arg_names.add_child(line)
	line.text_changed.connect(_on_arg_name_changed.bind(arg_names.get_child_count() -1))

func _on_del_arg_pressed():
	if primitive.arg_names.is_empty():
		return
	primitive.arg_names.pop_back()
	var line = arg_names.get_children().back()
	arg_names.remove_child(line)

func _on_arg_name_changed(text : String, i : int):
	primitive.arg_names[i] = text

func _on_task_name_changed(text : String):
	primitive.task_name = text
	task_name_changed.emit(text, idx)

func _on_pre_text_changed(text : String):
	primitive.precondition = text

func _on_script_path_changed(text : String):
	primitive.script_path = text

func _on_add_del_key_pressed():
	primitive.del_list.push_back('')
	_add_del_key('')

func _on_del_list_text_changed(text : String, i : int):
	primitive.del_list[i] = text

func _add_del_key(init_text : String):
	var line = LineEdit.new()
	del_list.add_child(line)
	var index = del_list.get_child_count() - 1
	line.text = init_text
	line.text_changed.connect(_on_del_list_text_changed.bind(index))

func _remove_del_key_pressed():
	var line = del_list.get_children().back()
	if line != null:
		line.queue_free()
		primitive.del_list.pop_back()

func refresh_effect_idxs():
	var children = add_list.get_children()
	for i in children.size():
		children[i].idx = i

func _add_effect(e: EffectBuilder):
	var effect_view : EffectLayout = effect_scene.instantiate()
	add_list.add_child(effect_view)
	effect_view.open(e)
	effect_view.idx = add_list.get_child_count() - 1
	effect_view.delete.connect(_on_remove_effect_pressed)

func _on_add_effect_pressed():
	var e = EffectBuilder.new()
	primitive.add_list.push_back(e)
	_add_effect(e)

func _on_remove_effect_pressed(i : int):
	var effect_view = add_list.get_child(i)
	add_list.remove_child(effect_view)
	primitive.add_list.remove_at(i)
	refresh_effect_idxs()

func _add_param(param, val):
	var param_view = param_scene.instantiate()
	params.add_child(param_view)
	param_view.open(param, val)
	param_view.value_updated.connect(_on_param_changed)

func _on_param_changed(param_name : String, val: String) -> void:
	primitive.params[param_name] = val
