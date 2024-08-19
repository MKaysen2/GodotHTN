class_name CompoundBuilder
extends Resource

const is_compound = true
@export var task_name : String = ''
@export var arg_names : Array = []
@export var methods : Array

func ToString() -> String:
	var string = task_name + '\n'
	for m in methods:
		string += m.ToString()
	return string

func to_dict() -> Dictionary:
	return {
		'is_compound': true,
		'task_name' : task_name,
		'arg_names' : arg_names,
		'methods' : methods.map(func(m): return m.to_dict())
	}

func move_method_up(i : int):
	swap(i, i-1)

func move_method_down(i :int):
	swap(i, i+1)

func swap(i0, i1):
	var temp = methods[i0]
	methods[i0] = methods[i1]
	methods[i1] = temp

func delete_method(i : int):
	methods.remove_at(i)

func from_dict(dict : Dictionary):
	task_name = dict.get('task_name', '')
	arg_names = dict.get('arg_names', [])
	methods = dict.get('methods', []).map(_method_from_dict)

func _method_from_dict(d : Dictionary) -> MethodBuilder:
	var method = MethodBuilder.new()
	method.from_dict(d)
	return method
