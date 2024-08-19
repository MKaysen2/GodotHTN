class_name DomainBuilder
extends Resource

@export var domain_name : String = ''
@export var tasks : Array
@export var base_path : String = 'res://'
func ToString():
	var res = domain_name + '\n'
	for t in tasks:
		res += t.ToString()
	return res

func to_dict() -> Dictionary:
	var task_dicts = {}
	for t in tasks:
		task_dicts[t.task_name] = t.to_dict()
	var res = {
		'domain_name' : domain_name,
		'base_path': base_path,
		'tasks' : task_dicts
	}
	return res

func from_dict(d : Dictionary):
	domain_name = d.get('domain_name', '')
	base_path = d.get('base_path', 'res://')
	tasks = d.get('tasks', {}).values().map(_task_from_dict)

func _task_from_dict(d : Dictionary):
	if d['is_compound']:
		var task := CompoundBuilder.new()
		task.from_dict(d)
		return task
	else:
		var task := PrimitiveBuilder.new()
		task.from_dict(d)
		return task
