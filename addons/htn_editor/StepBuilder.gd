class_name StepBuilder
extends Resource

@export var task_name : String = ''
@export var args : Array = []#Array of expressions

func _init(t : String, a : Array[String]):
	task_name = t
	args = a

func ToString() -> String:
	var res = '\t\t' + task_name
	for a in args:
		res += ' '
		res += a
	res += '\n'
	return res

func to_dict() -> Dictionary:
	return {
		'task_name': task_name,
		'args' : args
	}

func from_dict(d : Dictionary):
	task_name = d.get('task_name', '')
	args = d.get('args', [])

func compile(d : Domain, arg_names : Array[String]):
	var arg_exprs : Array[Expression] = []
	for i in args.size():
		var expr = Expression.new()
		expr.parse(args[i], arg_names)
		arg_exprs.push_back(expr)
	return MethodStep.new(d.tasks[task_name], arg_exprs)
