class_name PrimitiveBuilder
extends Resource

@export var task_name : String = ''
@export var script_path : String = ''
const is_compound = false
@export var arg_names : Array = []
@export var params : Dictionary = {}
@export var precondition : String = ''
@export var del_list : Array = []
@export var add_list : Array = []

var task_path : String #I don't know a better way of doing this yet.

func to_dict():
	return {
		'task_name' : task_name,
		'script_path' : script_path,
		'arg_names' : arg_names,
		'params' : params,
		'precondition': precondition,
		'del_list' : del_list,
		'add_list' : add_list.map(func(e): return e.to_dict()),
		'is_compound' : false
	}

func from_dict(d : Dictionary):
	task_name = d.get('task_name', '')
	script_path = d.get('script_path', '')
	arg_names = d.get('arg_names', [])
	params = d.get('params', {})
	precondition = d.get('precondition', '')
	del_list = d.get('del_list', [])
	add_list = d.get('add_list', []).map(_effect_from_dict)

func _effect_from_dict(d : Dictionary) -> EffectBuilder:
	var e = EffectBuilder.new()
	e.from_dict(d)
	return e

func ToString():
	var res = task_name + '\n'
	res += '\tp: ' + precondition + '\n'
	if del_list.size() > 0:
		res += "\tDelete:\n\t\t"
		for k in del_list:
			res += k + ', '
		res += '\n'
	if add_list.size() > 0:
		res += '\tAdd:\n'
		for e in add_list:
			res += '\t\t' + e.key + ' = ' + e.expr + '\n'
	return res
